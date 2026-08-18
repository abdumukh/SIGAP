<?php

namespace App\Services;

use App\Models\Dokumentasi;
use App\Models\Penanganan;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class DokumentasiService
{
    public function __construct(
        protected AuthorizationService $authService,
        protected ActorService $actorService
    ) {
    }

    public function generateDokumentasiId(): string
    {
        $latest = Dokumentasi::orderBy('id_dokumentasi', 'desc')->first();

        if (!$latest) {
            return 'DOC-001';
        }

        $number = (int) substr($latest->id_dokumentasi, 4);

        return 'DOC-' . str_pad((string) ($number + 1), 3, '0', STR_PAD_LEFT);
    }

    public function getDokumentasiListForUser(Authenticatable $user): Collection
    {
        $actor = $this->actorService->resolveActor($user);

        if ($actor === 'admin') {
            return Dokumentasi::with(['penanganan', 'petugas'])
                ->orderByDesc('created_at')
                ->get();
        }

        return Dokumentasi::with(['penanganan', 'petugas'])
            ->where(function ($query) use ($user) {
                $query->where('id_petugas', $user->id_petugas)
                    ->orWhereHas('penanganan', function ($q) use ($user) {
                        $q->where('id_petugas', $user->id_petugas)
                            ->orWhereHas('penugasan', function ($pq) use ($user) {
                                $pq->where('id_ketua_tim', $user->id_petugas)
                                    ->orWhere('id_petugas_armada', $user->id_petugas)
                                    ->orWhereHas('tim.anggotaTim', function ($at) use ($user) {
                                        $at->where('id_petugas', $user->id_petugas)
                                            ->where('status_anggota', 'aktif');
                                    });
                            });
                    });
            })
            ->orderByDesc('created_at')
            ->get();
    }

    public function getDokumentasiById(string $idDokumentasi): ?Dokumentasi
    {
        return Dokumentasi::with(['penanganan', 'petugas'])
            ->where('id_dokumentasi', $idDokumentasi)
            ->first();
    }

    public function createDokumentasi(Authenticatable $user, array $data, mixed $fileInput = null): Dokumentasi
    {
        return DB::transaction(function () use ($user, $data, $fileInput) {
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

            $filePath = null;
            if ($fileInput instanceof UploadedFile) {
                $filePath = $fileInput->store('dokumentasi', 'public');
            } elseif (is_string($fileInput) && !empty($fileInput)) {
                $filePath = $fileInput;
            } else {
                $filePath = $data['file_dokumentasi'] ?? 'dokumentasi/default.jpg';
            }

            $dokumentasi = Dokumentasi::create([
                'id_dokumentasi'    => $this->generateDokumentasiId(),
                'id_penanganan'     => $penanganan->id_penanganan,
                'id_petugas'        => $user->id_petugas,
                'jenis_dokumentasi' => $data['jenis_dokumentasi'],
                'file_dokumentasi'  => $filePath,
                'waktu_upload'      => now(),
                'note'              => $data['note'] ?? null,
            ]);

            return $this->getDokumentasiById($dokumentasi->id_dokumentasi);
        });
    }

    public function deleteDokumentasi(Dokumentasi $dokumentasi): void
    {
        if ($dokumentasi->file_dokumentasi && Storage::disk('public')->exists($dokumentasi->file_dokumentasi)) {
            Storage::disk('public')->delete($dokumentasi->file_dokumentasi);
        }

        $dokumentasi->delete();
    }
}
