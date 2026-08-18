<?php

namespace App\Services;

use App\Models\Penanganan;
use App\Models\Penugasan;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
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
            return Penanganan::with(['alarm', 'penugasan', 'petugas'])
                ->orderByDesc('created_at')
                ->get();
        }

        return Penanganan::with(['alarm', 'penugasan', 'petugas'])
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
        return Penanganan::with(['alarm', 'penugasan', 'petugas'])
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

        return $this->getPenangananById($penanganan->id_penanganan);
    }
}
