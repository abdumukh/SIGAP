<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\LaporanResource;
use App\Services\AuthorizationService;
use App\Services\LaporanService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LaporanController extends Controller
{
    protected LaporanService $laporanService;
    protected AuthorizationService $authorizationService;

    public function __construct(LaporanService $laporanService, AuthorizationService $authorizationService)
    {
        $this->laporanService = $laporanService;
        $this->authorizationService = $authorizationService;
    }

    /**
     * GET /api/laporan?type={type}
     * Laporan penanganan darurat berdasarkan tipe dan filter.
     *
     * Query Parameters:
     * - type (alarm|penugasan|penanganan|pengguna|petugas) - required
     * - start_date (YYYY-MM-DD)
     * - end_date (YYYY-MM-DD)
     * - status (string)
     * - jenis_darurat (string)
     * - id_tim (string)
     * - role (petugas|ketua_tim) - for petugas report filter
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $type = $request->query('type');
        if (!$type) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Parameter type wajib diisi (alarm, penugasan, penanganan, pengguna, petugas).',
            ], 422);
        }

        if (!$this->authorizationService->canAccessLaporanType($user, $type)) {
            return response()->json([
                'status'  => 'error',
                'message' => "Forbidden. Anda tidak memiliki akses ke laporan tipe {$type}.",
            ], 403);
        }

        $filters = [
            'start_date'     => $request->query('start_date'),
            'end_date'       => $request->query('end_date'),
            'status'         => $request->query('status'),
            'jenis_darurat'  => $request->query('jenis_darurat'),
            'id_tim'         => $request->query('id_tim'),
            'role'           => $request->query('role'),
        ];

        $data = $this->laporanService->getLaporan($user, $type, $filters);

        return response()->json([
            'status'  => 'success',
            'message' => "Laporan {$type} berhasil diambil",
            'data'    => new LaporanResource($data),
        ], 200);
    }
}