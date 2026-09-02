<?php

namespace App\Services;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\Pengguna;
use App\Models\Penanganan;
use App\Models\Penugasan;
use App\Models\Petugas;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Support\Collection;

class LaporanService
{
    protected ActorService $actorService;

    public function __construct(ActorService $actorService)
    {
        $this->actorService = $actorService;
    }

    /**
     * Get reports list based on report type, filters, and authenticated user role.
     */
    public function getLaporan(Authenticatable $user, string $type, array $filters = []): array
    {
        $actor = $this->actorService->resolveActor($user);

        return match ($type) {
            'alarm'      => $this->getLaporanAlarm($user, $actor, $filters),
            'penugasan'  => $this->getLaporanPenugasan($user, $actor, $filters),
            'penanganan' => $this->getLaporanPenanganan($user, $actor, $filters),
            'pengguna'   => $this->getLaporanPengguna($filters),
            'petugas'    => $this->getLaporanPetugas($filters),
            default      => ['items' => [], 'total' => 0],
        };
    }

    private function getLaporanAlarm(Authenticatable $user, string $actor, array $filters): array
    {
        $query = Alarm::with(['pengguna', 'penugasan', 'penanganan']);

        if ($actor === 'masyarakat') {
            $query->where('id_pengguna', $user->id_pengguna);
        } elseif ($actor === 'ketua_tim' || $actor === 'petugas') {
            $petugasId = $user->id_petugas;
            $query->whereHas('penugasan', function ($q) use ($petugasId) {
                $q->where('id_ketua_tim', $petugasId)
                    ->orWhere('id_petugas_armada', $petugasId)
                    ->orWhereHas('tim.anggotaTim', function ($at) use ($petugasId) {
                        $at->where('id_petugas', $petugasId)
                            ->where('status_anggota', 'aktif');
                    });
            });
        }

        if (!empty($filters['start_date'])) {
            $query->whereDate('waktu_alarm', '>=', $filters['start_date']);
        }
        if (!empty($filters['end_date'])) {
            $query->whereDate('waktu_alarm', '<=', $filters['end_date']);
        }
        if (!empty($filters['status'])) {
            $query->where('status_alarm', $filters['status']);
        }
        if (!empty($filters['jenis_darurat'])) {
            $query->where('jenis_darurat', $filters['jenis_darurat']);
        }

        $items = $query->orderByDesc('waktu_alarm')->get();

        return [
            'type'  => 'alarm',
            'total' => $items->count(),
            'items' => $items,
        ];
    }

    private function getLaporanPenugasan(Authenticatable $user, string $actor, array $filters): array
    {
        $query = Penugasan::with(['alarm', 'tim', 'ketuaTim', 'petugasArmada', 'armada']);

        if ($actor === 'ketua_tim') {
            $petugasId = $user->id_petugas;
            $query->where(function ($q) use ($petugasId) {
                $q->where('id_ketua_tim', $petugasId)
                    ->orWhereHas('tim.anggotaTim', function ($at) use ($petugasId) {
                        $at->where('id_petugas', $petugasId)
                            ->where('status_anggota', 'aktif');
                    });
            });
        } elseif ($actor === 'petugas') {
            $petugasId = $user->id_petugas;
            $query->where(function ($q) use ($petugasId) {
                $q->where('id_petugas_armada', $petugasId)
                    ->orWhereHas('tim.anggotaTim', function ($at) use ($petugasId) {
                        $at->where('id_petugas', $petugasId)
                            ->where('status_anggota', 'aktif');
                    });
            });
        }

        if (!empty($filters['start_date'])) {
            $query->whereDate('waktu_penugasan', '>=', $filters['start_date']);
        }
        if (!empty($filters['end_date'])) {
            $query->whereDate('waktu_penugasan', '<=', $filters['end_date']);
        }
        if (!empty($filters['status'])) {
            $query->where('status_penugasan', $filters['status']);
        }
        if (!empty($filters['id_tim'])) {
            $query->where('id_tim', $filters['id_tim']);
        }

        $items = $query->orderByDesc('waktu_penugasan')->get();

        return [
            'type'  => 'penugasan',
            'total' => $items->count(),
            'items' => $items,
        ];
    }

    private function getLaporanPenanganan(Authenticatable $user, string $actor, array $filters): array
    {
        $query = Penanganan::with(['alarm', 'penugasan', 'petugas', 'dokumentasi', 'korban', 'logistik']);

        if ($actor === 'masyarakat') {
            $penggunaId = $user->id_pengguna;
            $query->whereHas('alarm', function ($q) use ($penggunaId) {
                $q->where('id_pengguna', $penggunaId);
            });
        } elseif ($actor === 'ketua_tim' || $actor === 'petugas') {
            $petugasId = $user->id_petugas;
            $query->where(function ($q) use ($petugasId) {
                $q->where('id_petugas', $petugasId)
                    ->orWhereHas('penugasan', function ($p) use ($petugasId) {
                        $p->where('id_ketua_tim', $petugasId)
                            ->orWhere('id_petugas_armada', $petugasId)
                            ->orWhereHas('tim.anggotaTim', function ($at) use ($petugasId) {
                                $at->where('id_petugas', $petugasId)
                                    ->where('status_anggota', 'aktif');
                            });
                    });
            });
        }

        if (!empty($filters['start_date'])) {
            $query->whereDate('created_at', '>=', $filters['start_date']);
        }
        if (!empty($filters['end_date'])) {
            $query->whereDate('created_at', '<=', $filters['end_date']);
        }
        if (!empty($filters['status'])) {
            $query->where('status_penanganan', $filters['status']);
        }

        $items = $query->orderByDesc('created_at')->get();

        return [
            'type'  => 'penanganan',
            'total' => $items->count(),
            'items' => $items,
        ];
    }

    private function getLaporanPengguna(array $filters): array
    {
        $query = Pengguna::query();

        if (!empty($filters['start_date'])) {
            $query->whereDate('created_at', '>=', $filters['start_date']);
        }
        if (!empty($filters['end_date'])) {
            $query->whereDate('created_at', '<=', $filters['end_date']);
        }

        $items = $query->orderBy('nama')->get();

        return [
            'type'  => 'pengguna',
            'total' => $items->count(),
            'items' => $items,
        ];
    }

    private function getLaporanPetugas(array $filters): array
    {
        $query = Petugas::with(['anggotaTim.tim']);

        if (!empty($filters['status'])) {
            $query->where('status_petugas', $filters['status']);
        }
        if (!empty($filters['role'])) {
            $query->where('role', $filters['role']);
        }

        $items = $query->orderBy('nama_petugas')->get();

        return [
            'type'  => 'petugas',
            'total' => $items->count(),
            'items' => $items,
        ];
    }
}
