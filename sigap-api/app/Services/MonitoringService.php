<?php

namespace App\Services;

use App\Models\Alarm;
use App\Models\AnggotaTim;
use App\Models\Korban;
use App\Models\Logistik;
use App\Models\Penanganan;
use App\Models\Penugasan;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Support\Facades\DB;

class MonitoringService
{
    protected ActorService $actorService;

    public function __construct(ActorService $actorService)
    {
        $this->actorService = $actorService;
    }

    /**
     * Get active operations monitoring list & summary stats based on authenticated user role.
     */
    public function getMonitoringData(Authenticatable $user, array $filters = []): array
    {
        $actor = $this->actorService->resolveActor($user);

        // Build base queries with filter
        $alarmQuery = Alarm::query();
        $penugasanQuery = Penugasan::query();
        $penangananQuery = Penanganan::query();

        // Filter: start_date & end_date
        if (!empty($filters['start_date'])) {
            $alarmQuery->whereDate('waktu_alarm', '>=', $filters['start_date']);
            $penugasanQuery->whereDate('waktu_penugasan', '>=', $filters['start_date']);
            $penangananQuery->whereDate('created_at', '>=', $filters['start_date']);
        }

        if (!empty($filters['end_date'])) {
            $alarmQuery->whereDate('waktu_alarm', '<=', $filters['end_date']);
            $penugasanQuery->whereDate('waktu_penugasan', '<=', $filters['end_date']);
            $penangananQuery->whereDate('created_at', '<=', $filters['end_date']);
        }

        // Filter: jenis_darurat
        if (!empty($filters['jenis_darurat'])) {
            $alarmQuery->where('jenis_darurat', $filters['jenis_darurat']);
            $penugasanQuery->whereHas('alarm', function ($q) use ($filters) {
                $q->where('jenis_darurat', $filters['jenis_darurat']);
            });
            $penangananQuery->whereHas('alarm', function ($q) use ($filters) {
                $q->where('jenis_darurat', $filters['jenis_darurat']);
            });
        }

        // Filter: status (alarm status or penanganan status)
        if (!empty($filters['status'])) {
            $alarmQuery->where('status_alarm', $filters['status']);
        }

        // Role-based scope for Ketua Tim / Petugas
        if ($actor === 'ketua_tim' || $actor === 'petugas') {
            $petugasId = $user->id_petugas;

            // Scope penugasan
            $penugasanQuery->where(function ($q) use ($petugasId) {
                $q->where('id_ketua_tim', $petugasId)
                    ->orWhere('id_petugas_armada', $petugasId)
                    ->orWhereHas('tim.anggotaTim', function ($at) use ($petugasId) {
                        $at->where('id_petugas', $petugasId)
                            ->where('status_anggota', 'aktif');
                    });
            });

            // Scope penanganan
            $penangananQuery->where(function ($q) use ($petugasId) {
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

            // Scope alarm linked to assigned penugasan
            $alarmQuery->whereHas('penugasan', function ($p) use ($petugasId) {
                $p->where('id_ketua_tim', $petugasId)
                    ->orWhere('id_petugas_armada', $petugasId)
                    ->orWhereHas('tim.anggotaTim', function ($at) use ($petugasId) {
                        $at->where('id_petugas', $petugasId)
                            ->where('status_anggota', 'aktif');
                    });
            });
        }

        // Filter: id_tim
        if (!empty($filters['id_tim'])) {
            $penugasanQuery->where('id_tim', $filters['id_tim']);
            $penangananQuery->whereHas('penugasan', function ($q) use ($filters) {
                $q->where('id_tim', $filters['id_tim']);
            });
            $alarmQuery->whereHas('penugasan', function ($q) use ($filters) {
                $q->where('id_tim', $filters['id_tim']);
            });
        }

        // Summary Statistics Aggregations
        $totalAlarm = (clone $alarmQuery)->count();
        $alarmByStatus = (clone $alarmQuery)
            ->select('status_alarm', DB::raw('count(*) as count'))
            ->groupBy('status_alarm')
            ->pluck('count', 'status_alarm')
            ->toArray();

        $alarmByJenis = (clone $alarmQuery)
            ->select('jenis_darurat', DB::raw('count(*) as count'))
            ->groupBy('jenis_darurat')
            ->pluck('count', 'jenis_darurat')
            ->toArray();

        $penugasanAktif = (clone $penugasanQuery)
            ->whereIn('status_penugasan', ['menunggu', 'diterima', 'berangkat'])
            ->count();

        $penangananAktif = (clone $penangananQuery)
            ->whereIn('status_penanganan', ['menuju_lokasi', 'di_lokasi'])
            ->count();

        $penangananSelesai = (clone $penangananQuery)
            ->where('status_penanganan', 'selesai')
            ->count();

        // Fetch active operations detail list
        $activeOperations = (clone $alarmQuery)
            ->with([
                'pengguna',
                'penugasan' => function ($query) {
                    $query->with(['tim.anggotaTim.petugas', 'armada', 'ketuaTim', 'petugasArmada'])
                        ->latest('waktu_penugasan');
                },
                'penanganan' => function ($query) {
                    $query->with(['petugas', 'dokumentasi', 'korban', 'logistik']);
                },
            ])
            ->orderByDesc('waktu_alarm')
            ->get();

        // Count Korban & Logistik across active penanganan scope
        $penangananIds = (clone $penangananQuery)->pluck('id_penanganan');
        $totalKorban = Korban::whereIn('id_penanganan', $penangananIds)->count();
        $totalLogistik = Logistik::whereIn('id_penanganan', $penangananIds)->sum('jumlah');

        return [
            'statistik' => [
                'total_alarm'         => $totalAlarm,
                'alarm_by_status'     => [
                    'menunggu'     => $alarmByStatus['menunggu'] ?? 0,
                    'diverifikasi' => $alarmByStatus['diverifikasi'] ?? 0,
                    'ditolak'      => $alarmByStatus['ditolak'] ?? 0,
                    'selesai'      => $alarmByStatus['selesai'] ?? 0,
                ],
                'alarm_by_jenis'      => $alarmByJenis,
                'penugasan_aktif'     => $penugasanAktif,
                'penanganan_aktif'    => $penangananAktif,
                'penanganan_selesai'  => $penangananSelesai,
                'total_korban'        => $totalKorban,
                'total_logistik'      => (int) $totalLogistik,
            ],
            'active_operations' => $activeOperations,
        ];
    }
}
