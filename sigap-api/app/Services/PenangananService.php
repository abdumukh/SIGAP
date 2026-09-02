<?php

namespace App\Services;

use App\Models\Armada;
use App\Models\Alarm;
use App\Models\Penanganan;
use App\Models\Penugasan;
use App\Models\Petugas;
use App\Services\NotifikasiService;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;

class PenangananService
{
    public function __construct(
        protected AuthorizationService $authService,
        protected ActorService $actorService
    ) {
    }

    public function generatePenangananId(): string
    {
        $latest = Penanganan::orderBy('id_penanganan', 'desc')->first();

        if (!$latest) {
            return 'PNG-001';
        }

        $number = (int) substr($latest->id_penanganan, 4);

        return 'PNG-' . str_pad((string) ($number + 1), 3, '0', STR_PAD_LEFT);
    }

    public function getPenangananListForUser(Authenticatable $user): Collection
    {
        $actor = $this->actorService->resolveActor($user);

        if ($actor === 'admin') {
            return Penanganan::with(['alarm', 'penugasan', 'petugas', 'korban', 'logistik'])
                ->orderByDesc('created_at')
                ->get();
        }

        return Penanganan::with(['alarm', 'penugasan', 'petugas', 'korban', 'logistik'])
            ->where(function ($query) use ($user) {
                $query->where('id_petugas', $user->id_petugas)
                    ->orWhereHas('penugasan', function ($q) use ($user) {
                        $q->where('id_ketua_tim', $user->id_petugas)
                            ->orWhere('id_petugas_armada', $user->id_petugas)
                            ->orWhereHas('tim.anggotaTim', function ($at) use ($user) {
                                $at->where('id_petugas', $user->id_petugas)
                                    ->where('status_anggota', 'aktif');
                            });
                    });
            })
            ->orderByDesc('created_at')
            ->get();
    }

    public function getPenangananById(string $idPenanganan): ?Penanganan
    {
        return Penanganan::with(['alarm', 'penugasan', 'petugas', 'korban', 'logistik'])
            ->where('id_penanganan', $idPenanganan)
            ->first();
    }

    public function createPenanganan(Authenticatable $user, array $data): Penanganan
    {
        return DB::transaction(function () use ($user, $data) {
            /** @var Penugasan|null $penugasan */
            $penugasan = Penugasan::where('id_penugasan', $data['id_penugasan'])
                ->lockForUpdate()
                ->first();

            if (!$penugasan) {
                throw ValidationException::withMessages([
                    'id_penugasan' => ['Penugasan tidak ditemukan.'],
                ]);
            }

            $hasExistingPenanganan = Penanganan::where('id_penugasan', $penugasan->id_penugasan)->exists();
            if ($hasExistingPenanganan) {
                throw ValidationException::withMessages([
                    'id_penugasan' => ['Penugasan tersebut sudah memiliki penanganan.'],
                ]);
            }

            if (!$this->authService->canPetugasExecutePenugasan($user, $penugasan)) {
                throw ValidationException::withMessages([
                    'id_penugasan' => ['Petugas tidak memiliki akses ke penugasan ini.'],
                ]);
            }

            $penanganan = Penanganan::create([
                'id_penanganan'     => $this->generatePenangananId(),
                'id_alarm'          => $penugasan->id_alarm,
                'id_penugasan'      => $penugasan->id_penugasan,
                'id_petugas'        => $user->id_petugas,
                'waktu_berangkat'   => now(),
                'waktu_tiba'        => null,
                'waktu_selesai'     => null,
                'status_penanganan' => 'menuju_lokasi',
                'note'              => $data['note'] ?? null,
            ]);

            // Notify alarm owner and admin
            $this->notifyPenangananStarted($penanganan, $penugasan);

            return $this->getPenangananById($penanganan->id_penanganan);
        });
    }

    public function updatePenangananStatus(Penanganan $penanganan, array $data): Penanganan
    {
        $currentStatus = $penanganan->status_penanganan;
        $targetStatus = $data['status_penanganan'] ?? $currentStatus;

        $validTransitions = [
            'menuju_lokasi' => ['di_lokasi'],
            'di_lokasi'     => ['selesai'],
            'selesai'       => [],
        ];

        if (!isset($validTransitions[$currentStatus]) || !in_array($targetStatus, $validTransitions[$currentStatus], true)) {
            if ($currentStatus === 'selesai') {
                $msg = 'Penanganan yang sudah selesai tidak dapat diubah kembali.';
            } else {
                $msg = "Transisi status penanganan dari '{$currentStatus}' ke '{$targetStatus}' tidak valid.";
            }

            throw ValidationException::withMessages([
                'status_penanganan' => [$msg],
            ]);
        }

        $penanganan->status_penanganan = $targetStatus;

        if ($targetStatus === 'di_lokasi') {
            $penanganan->waktu_tiba = now();
        } elseif ($targetStatus === 'selesai') {
            $penanganan->waktu_selesai = now();
        }

        if (array_key_exists('note', $data)) {
            $penanganan->note = $data['note'];
        }

        $penanganan->save();

        if ($targetStatus === 'selesai') {
            /** @var Penugasan|null $penugasan */
            $penugasan = Penugasan::where('id_penugasan', $penanganan->id_penugasan)->first();
            if ($penugasan) {
                $penugasan->status_penugasan = 'selesai';
                $penugasan->save();

                if ($penugasan->id_armada) {
                    Armada::where('id_armada', $penugasan->id_armada)
                        ->update(['status_armada' => 'tersedia']);
                }
            }

            Alarm::where('id_alarm', $penanganan->id_alarm)
                ->update(['status_alarm' => 'selesai']);
        }

        // Notify on status change
        $this->notifyPenangananStatusUpdated($penanganan, $targetStatus);

        return $this->getPenangananById($penanganan->id_penanganan);
    }

    private function notifyPenangananStarted(Penanganan $penanganan, Penugasan $penugasan): void
    {
        $notifikasiService = app(NotifikasiService::class);
        $alarm = Alarm::find($penanganan->id_alarm);

        if (!$alarm) return;

        // Notify masyarakat owner
        $notifikasiService->createNotifikasi(
            $alarm->id_pengguna,
            'masyarakat',
            'PENANGANAN_STARTED',
            'Tim Sedang Menuju Lokasi',
            "Tim penanganan sedang menuju lokasi kejadian {$alarm->jenis_darurat} ({$alarm->id_alarm}).",
            ['id_alarm' => $alarm->id_alarm, 'id_penanganan' => $penanganan->id_penanganan]
        );

        // Notify admin
        $admins = \App\Models\Admin::all();
        foreach ($admins as $admin) {
            $notifikasiService->createNotifikasi(
                $admin->id_admin,
                'admin',
                'PENANGANAN_STARTED',
                'Penanganan Dimulai',
                "Penanganan untuk {$alarm->jenis_darurat} ({$alarm->id_alarm}) telah dimulai oleh petugas.",
                ['id_alarm' => $alarm->id_alarm, 'id_penanganan' => $penanganan->id_penanganan]
            );
        }
    }

    private function notifyPenangananStatusUpdated(Penanganan $penanganan, string $status): void
    {
        $notifikasiService = app(NotifikasiService::class);
        $alarm = Alarm::find($penanganan->id_alarm);

        if (!$alarm) return;

        $type = match ($status) {
            'di_lokasi' => 'PENANGANAN_ARRIVED',
            'selesai'   => 'PENANGANAN_COMPLETED',
            default     => 'PENANGANAN_UPDATED',
        };

        $title = match ($status) {
            'di_lokasi' => 'Tim Tiba di Lokasi',
            'selesai'   => 'Penanganan Selesai',
            default     => 'Status Penanganan Diperbarui',
        };

        $message = match ($status) {
            'di_lokasi' => "Tim penanganan telah tiba di lokasi kejadian {$alarm->jenis_darurat} ({$alarm->id_alarm}).",
            'selesai'   => "Penanganan untuk {$alarm->jenis_darurat} ({$alarm->id_alarm}) telah selesai.",
            default     => "Status penanganan {$penanganan->id_penanganan} telah diperbarui.",
        };

        // Notify masyarakat
        $notifikasiService->createNotifikasi(
            $alarm->id_pengguna,
            'masyarakat',
            $type,
            $title,
            $message,
            ['id_alarm' => $alarm->id_alarm, 'id_penanganan' => $penanganan->id_penanganan]
        );

        // Notify admin
        $admins = \App\Models\Admin::all();
        foreach ($admins as $admin) {
            $notifikasiService->createNotifikasi(
                $admin->id_admin,
                'admin',
                $type,
                $title,
                $message,
                ['id_alarm' => $alarm->id_alarm, 'id_penanganan' => $penanganan->id_penanganan]
            );
        }
    }
}
