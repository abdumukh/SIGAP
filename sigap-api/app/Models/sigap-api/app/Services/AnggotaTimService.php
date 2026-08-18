<?php

namespace App\Services;

use App\Models\AnggotaTim;
use App\Models\Petugas;
use App\Models\Tim;
use Illuminate\Database\Eloquent\Collection;

class AnggotaTimService
{
    /**
     * Generate custom unique ID for AnggotaTim (AT-001, AT-002, etc.)
     */
    public function generateAnggotaTimId(): string
    {
        $latest = AnggotaTim::orderBy('id_anggota_tim', 'desc')->first();

        if (!$latest) {
            return 'AT-001';
        }

        $number = (int) substr($latest->id_anggota_tim, 3);
        $nextNumber = $number + 1;

        return 'AT-' . str_pad((string) $nextNumber, 3, '0', STR_PAD_LEFT);
    }

    /**
     * Retrieve list of team members for a given team.
     */
    public function getAnggotaByTim(string $idTim): Collection
    {
        return AnggotaTim::where('id_tim', $idTim)
            ->with('petugas')
            ->orderBy('id_anggota_tim', 'asc')
            ->get();
    }

    /**
     * Find single AnggotaTim record by ID.
     */
    public function getAnggotaById(string $idAnggota): ?AnggotaTim
    {
        return AnggotaTim::where('id_anggota_tim', $idAnggota)
            ->with('petugas')
            ->first();
    }

    /**
     * Add a Petugas to a Team as AnggotaTim.
     */
    public function addAnggotaTim(Tim $tim, array $data): array
    {
        $idPetugas = $data['id_petugas'];

        // Verify Petugas exists
        $petugas = Petugas::where('id_petugas', $idPetugas)->first();
        if (!$petugas) {
            return [
                'success' => false,
                'message' => 'Data petugas tidak ditemukan',
                'code'    => 404,
            ];
        }

        // Check for active duplicate membership in the same team
        $exists = AnggotaTim::where('id_tim', $tim->id_tim)
            ->where('id_petugas', $idPetugas)
            ->where('status_anggota', 'aktif')
            ->exists();

        if ($exists) {
            return [
                'success' => false,
                'message' => 'Petugas sudah menjadi anggota aktif pada tim ini.',
                'code'    => 422,
            ];
        }

        $anggota = new AnggotaTim();
        $anggota->id_anggota_tim = $this->generateAnggotaTimId();
        $anggota->id_tim         = $tim->id_tim;
        $anggota->id_petugas     = $idPetugas;
        $anggota->tanggal_masuk  = $data['tanggal_masuk'] ?? now()->toDateString();
        $anggota->status_anggota = $data['status_anggota'] ?? 'aktif';
        $anggota->save();

        $anggota->load('petugas');

        return [
            'success' => true,
            'message' => 'Anggota tim berhasil ditambahkan',
            'code'    => 201,
            'data'    => $anggota,
        ];
    }

    /**
     * Update status of AnggotaTim (aktif / nonaktif).
     */
    public function updateStatusAnggota(AnggotaTim $anggota, string $status): AnggotaTim
    {
        $anggota->status_anggota = $status;
        $anggota->save();

        return $anggota;
    }

    /**
     * Remove / deactivate AnggotaTim.
     */
    public function removeAnggota(AnggotaTim $anggota): bool
    {
        $anggota->status_anggota = 'nonaktif';
        return $anggota->save();
    }
}
