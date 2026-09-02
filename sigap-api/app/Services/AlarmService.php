<?php

namespace App\Services;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\Pengguna;
use App\Models\Petugas;
use App\Services\ActorService;
use App\Services\NotifikasiService;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Collection;

class AlarmService
{
    protected ActorService $actorService;

    public function __construct(ActorService $actorService)
    {
        $this->actorService = $actorService;
    }

    /**
     * Generate custom unique ID for Alarm (ALM-001, ALM-002, etc.)
     */
    public function generateAlarmId(): string
    {
        $latest = Alarm::orderBy('id_alarm', 'desc')->first();

        if (!$latest) {
            return 'ALM-001';
        }

        $number = (int) substr($latest->id_alarm, 4);
        $nextNumber = $number + 1;

        return 'ALM-' . str_pad((string) $nextNumber, 3, '0', STR_PAD_LEFT);
    }

    /**
     * Store new Alarm created by a Masyarakat user.
     */
    public function createAlarm(Pengguna $pengguna, array $data): Alarm
    {
        $alarm = new Alarm();
        $alarm->id_alarm      = $this->generateAlarmId();
        $alarm->id_pengguna   = $pengguna->id_pengguna;
        $alarm->jenis_darurat = $data['jenis_darurat'];
        $alarm->waktu_alarm   = $data['waktu_alarm'] ?? now();
        $alarm->latitude      = $data['latitude'];
        $alarm->longitude     = $data['longitude'];
        $alarm->cuaca         = $data['cuaca'] ?? null;
        $alarm->lalu_lintas   = $data['lalu_lintas'] ?? null;
        $alarm->status_alarm  = 'menunggu';
        $alarm->save();

        // Notify all admins and ketua_tim (staff monitoring)
        $this->notifyStaffNewAlarm($alarm, $pengguna);

        return $alarm;
    }

    private function notifyStaffNewAlarm(Alarm $alarm, Pengguna $pengguna): void
    {
        $notifikasiService = app(NotifikasiService::class);

        $admins = Admin::all();
        foreach ($admins as $admin) {
            $notifikasiService->createNotifikasi(
                $admin->id_admin,
                'admin',
                'ALARM_CREATED',
                'Laporan Darurat Baru',
                "Laporan {$alarm->jenis_darurat} dari {$pengguna->nama} memerlukan verifikasi.",
                ['id_alarm' => $alarm->id_alarm]
            );
        }

        $staff = Petugas::where('status_petugas', 'aktif')->get();
        foreach ($staff as $petugas) {
            $notifikasiService->createNotifikasi(
                $petugas->id_petugas,
                $petugas->role,
                'ALARM_CREATED',
                'Laporan Darurat Baru',
                "Laporan {$alarm->jenis_darurat} dari {$pengguna->nama} memerlukan verifikasi.",
                ['id_alarm' => $alarm->id_alarm]
            );
        }
    }

    /**
     * Retrieve alarm collection filtered by user actor identity.
     */
    public function getAlarmsForUser(Authenticatable $user): Collection
    {
        $actor = $this->actorService->resolveActor($user);

        if ($actor === 'masyarakat') {
            return Alarm::with([
                    'pengguna',
                    'penugasan.tim',
                    'penugasan.ketuaTim',
                    'penugasan.petugasArmada',
                    'penugasan.armada',
                    'penanganan.petugas',
                ])
                ->withCount(['penanganan as has_penanganan'])
                ->where('id_pengguna', $user->id_pengguna)
                ->orderBy('waktu_alarm', 'desc')
                ->get();
        }

        // Admin & Petugas can view all alarms
        return Alarm::with([
                    'pengguna',
                    'penugasan.tim',
                    'penugasan.ketuaTim',
                    'penugasan.petugasArmada',
                    'penugasan.armada',
                    'penanganan.petugas',
                ])
                ->withCount(['penanganan as has_penanganan'])
                ->orderBy('waktu_alarm', 'desc')
                ->get();
    }

    /**
     * Find single Alarm by primary key.
     */
    public function getAlarmById(string $idAlarm): ?Alarm
    {
        return Alarm::with([
                    'pengguna',
                    'penugasan.tim',
                    'penugasan.ketuaTim',
                    'penugasan.petugasArmada',
                    'penugasan.armada',
                    'penanganan.petugas',
                ])
                ->where('id_alarm', $idAlarm)
                ->first();
    }

    /**
     * Perform strict state transition validation and update alarm status.
     * Valid transitions:
     * - menunggu -> diverifikasi
     * - menunggu -> ditolak
     * - diverifikasi -> selesai
     */
    public function transitionStatus(Alarm $alarm, string $targetStatus, Authenticatable $user): array
    {
        $actor = $this->actorService->resolveActor($user);

        // 1. Authorization check: Masyarakat cannot update alarm status
        if ($actor === 'masyarakat') {
            return [
                'success' => false,
                'message' => 'Forbidden. Masyarakat tidak memiliki hak akses untuk mengubah status alarm.',
                'code'    => 403,
            ];
        }

        $currentStatus = $alarm->status_alarm;

        // 2. State transition validation matrix
        $validTransitions = [
            'menunggu'     => ['diverifikasi', 'ditolak'],
            'diverifikasi' => ['selesai'],
            'ditolak'      => [],
            'selesai'      => [],
        ];

        if (!isset($validTransitions[$currentStatus]) || !in_array($targetStatus, $validTransitions[$currentStatus], true)) {
            if ($currentStatus === 'selesai') {
                $msg = 'Alarm yang sudah selesai tidak dapat diubah kembali.';
            } elseif ($currentStatus === 'ditolak') {
                $msg = 'Alarm yang sudah ditolak tidak dapat diproses kembali.';
            } elseif ($currentStatus === 'diverifikasi' && $targetStatus === 'ditolak') {
                $msg = 'Alarm yang sudah diverifikasi tidak dapat ditolak.';
            } else {
                $msg = "Transisi status alarm dari '{$currentStatus}' ke '{$targetStatus}' tidak valid.";
            }

            return [
                'success' => false,
                'message' => $msg,
                'code'    => 422,
            ];
        }

        // 3. Apply state change
        $alarm->status_alarm = $targetStatus;
        $alarm->save();

        // Generate notification for alarm owner (masyarakat)
        $this->notifyAlarmOwner($alarm, $targetStatus);

        return [
            'success' => true,
            'message' => "Status alarm berhasil diperbarui menjadi '{$targetStatus}'.",
            'code'    => 200,
            'alarm'   => $alarm,
        ];
    }

    /**
     * Verifikasi alarm (menunggu -> diverifikasi).
     */
    public function verifyAlarm(Alarm $alarm, Authenticatable $user): array
    {
        return $this->transitionStatus($alarm, 'diverifikasi', $user);
    }

    /**
     * Tolak alarm (menunggu -> ditolak).
     */
    public function rejectAlarm(Alarm $alarm, Authenticatable $user): array
    {
        return $this->transitionStatus($alarm, 'ditolak', $user);
    }

    /**
     * Selesaikan alarm (diverifikasi -> selesai).
     */
    public function completeAlarm(Alarm $alarm, Authenticatable $user): array
    {
        return $this->transitionStatus($alarm, 'selesai', $user);
    }

    private function notifyAlarmOwner(Alarm $alarm, string $targetStatus): void
    {
        $notifikasiService = app(NotifikasiService::class);

        $type = match ($targetStatus) {
            'diverifikasi' => 'ALARM_VERIFIED',
            'ditolak'      => 'ALARM_REJECTED',
            'selesai'      => 'ALARM_COMPLETED',
            default        => 'ALARM_UPDATED',
        };

        $title = match ($targetStatus) {
            'diverifikasi' => 'Laporan Diverifikasi',
            'ditolak'      => 'Laporan Ditolak',
            'selesai'      => 'Laporan Ditangani',
            default        => 'Status Laporan Diperbarui',
        };

        $message = match ($targetStatus) {
            'diverifikasi' => "Laporan {$alarm->jenis_darurat} ({$alarm->id_alarm}) telah diverifikasi dan sedang dalam proses penugasan.",
            'ditolak'      => "Laporan {$alarm->jenis_darurat} ({$alarm->id_alarm}) telah ditolak oleh admin.",
            'selesai'      => "Laporan {$alarm->jenis_darurat} ({$alarm->id_alarm}) telah selesai ditangani.",
            default        => "Status laporan {$alarm->id_alarm} telah diperbarui.",
        };

        $notifikasiService->createNotifikasi(
            $alarm->id_pengguna,
            'masyarakat',
            $type,
            $title,
            $message,
            ['id_alarm' => $alarm->id_alarm]
        );
    }
}
