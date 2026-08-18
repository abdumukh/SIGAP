<?php

namespace App\Services;

use App\Models\Alarm;
use App\Models\Pengguna;
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

        return $alarm;
    }

    /**
     * Retrieve alarm collection filtered by user actor identity.
     */
    public function getAlarmsForUser(Authenticatable $user): Collection
    {
        $actor = $this->actorService->resolveActor($user);

        if ($actor === 'masyarakat') {
            return Alarm::where('id_pengguna', $user->id_pengguna)
                ->orderBy('waktu_alarm', 'desc')
                ->get();
        }

        // Admin & Petugas can view all alarms
        return Alarm::orderBy('waktu_alarm', 'desc')->get();
    }

    /**
     * Find single Alarm by primary key.
     */
    public function getAlarmById(string $idAlarm): ?Alarm
    {
        return Alarm::where('id_alarm', $idAlarm)->first();
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
}
