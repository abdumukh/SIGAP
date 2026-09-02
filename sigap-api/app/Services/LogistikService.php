<?php

namespace App\Services;

use App\Models\Logistik;
use App\Models\Penanganan;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class LogistikService
{
    public function __construct(
        protected AuthorizationService $authService,
        protected ActorService $actorService
    ) {
    }

    public function generateLogistikId(): string
    {
        $latest = Logistik::orderBy('id_logistik', 'desc')->first();

        if (!$latest) {
            return 'LOG-001';
        }

        $number = (int) substr($latest->id_logistik, 4);

        return 'LOG-' . str_pad((string) ($number + 1), 3, '0', STR_PAD_LEFT);
    }

    public function getLogistikListForUser(Authenticatable $user): Collection
    {
        $actor = $this->actorService->resolveActor($user);

        if ($actor === 'admin') {
            return Logistik::with(['penanganan'])
                ->orderByDesc('created_at')
                ->get();
        }

        return Logistik::with(['penanganan'])
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

    public function getLogistikByPenanganan(string $idPenanganan): Collection
    {
        return Logistik::where('id_penanganan', $idPenanganan)
            ->orderByDesc('created_at')
            ->get();
    }

    public function getLogistikById(string $idLogistik): ?Logistik
    {
        return Logistik::with(['penanganan'])
            ->where('id_logistik', $idLogistik)
            ->first();
    }

    public function createLogistik(Authenticatable $user, array $data): Logistik
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

            $logistik = Logistik::create([
                'id_logistik'   => $this->generateLogistikId(),
                'id_penanganan' => $penanganan->id_penanganan,
                'nama_logistik' => $data['nama_logistik'],
                'jumlah'        => $data['jumlah'],
                'satuan'        => $data['satuan'],
                'kondisi'       => $data['kondisi'],
                'note'          => $data['note'] ?? null,
            ]);

            return $this->getLogistikById($logistik->id_logistik);
        });
    }

    public function updateLogistik(Logistik $logistik, array $data): Logistik
    {
        $logistik->update($data);

        return $this->getLogistikById($logistik->id_logistik);
    }

    public function deleteLogistik(Logistik $logistik): void
    {
        $logistik->delete();
    }
}
