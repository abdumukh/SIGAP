<?php

namespace App\Services;

use App\Models\Korban;
use App\Models\Penanganan;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class KorbanService
{
    public function __construct(
        protected AuthorizationService $authService,
        protected ActorService $actorService
    ) {
    }

    public function generateKorbanId(): string
    {
        $latest = Korban::orderBy('id_korban', 'desc')->first();

        if (!$latest) {
            return 'KRB-001';
        }

        $number = (int) substr($latest->id_korban, 4);

        return 'KRB-' . str_pad((string) ($number + 1), 3, '0', STR_PAD_LEFT);
    }

    public function getKorbanListForUser(Authenticatable $user): Collection
    {
        $actor = $this->actorService->resolveActor($user);

        if ($actor === 'admin') {
            return Korban::with(['penanganan'])
                ->orderByDesc('created_at')
                ->get();
        }

        return Korban::with(['penanganan'])
            ->whereHas('penanganan', function ($query) use ($user) {
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

    public function getKorbanByPenanganan(string $idPenanganan): Collection
    {
        return Korban::where('id_penanganan', $idPenanganan)
            ->orderByDesc('created_at')
            ->get();
    }

    public function getKorbanById(string $idKorban): ?Korban
    {
        return Korban::with(['penanganan'])
            ->where('id_korban', $idKorban)
            ->first();
    }

    public function createKorban(Authenticatable $user, array $data): Korban
    {
        return DB::transaction(function () use ($user, $data) {
            /** @var Penanganan|null $penanganan */
            $penanganan = Penanganan::where('id_penanganan', $data['id_penanganan'])
                ->lockForUpdate()
                ->first();

            if (!$penanganan) {
                throw ValidationException::withMessages([
                    'id_penanganan' => ['Penanganan tidak ditemukan.'],
                ]);
            }

            if (!$this->authService->canCreateDokumentasi($user, $penanganan)) {
                throw ValidationException::withMessages([
                    'id_penanganan' => ['Petugas tidak memiliki akses ke penanganan ini.'],
                ]);
            }

            $korban = Korban::create([
                'id_korban'         => $this->generateKorbanId(),
                'id_penanganan'     => $penanganan->id_penanganan,
                'nama_korban'       => $data['nama_korban'],
                'jenis_kelamin'     => $data['jenis_kelamin'],
                'usia'              => $data['usia'],
                'kondisi'           => $data['kondisi'],
                'status_penanganan' => $data['status_penanganan'],
                'note'              => $data['note'] ?? null,
            ]);

            return $this->getKorbanById($korban->id_korban);
        });
    }

    public function updateKorban(Korban $korban, array $data): Korban
    {
        $korban->update($data);

        return $this->getKorbanById($korban->id_korban);
    }

    public function deleteKorban(Korban $korban): void
    {
        $korban->delete();
    }
}
