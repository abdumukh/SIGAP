<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MonitoringResource;
use App\Services\AuthorizationService;
use App\Services\MonitoringService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MonitoringController extends Controller
{
    protected MonitoringService $monitoringService;
    protected AuthorizationService $authorizationService;

    public function __construct(MonitoringService $monitoringService, AuthorizationService $authorizationService)
    {
        $this->monitoringService = $monitoringService;
        $this->authorizationService = $authorizationService;
    }

    /**
     * GET /api/monitoring
     * Monitoring & Statistik operasional penanganan darurat.
     *
     * Query Parameters:
     * - start_date (YYYY-MM-DD)
     * - end_date (YYYY-MM-DD)
     * - status (menunggu|diverifikasi|ditolak|selesai)
     * - jenis_darurat (string)
     * - id_tim (string)
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$this->authorizationService->canAccessMonitoring($user)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses ke monitoring.',
            ], 403);
        }

        $filters = [
            'start_date'     => $request->query('start_date'),
            'end_date'       => $request->query('end_date'),
            'status'         => $request->query('status'),
            'jenis_darurat'  => $request->query('jenis_darurat'),
            'id_tim'         => $request->query('id_tim'),
        ];

        $data = $this->monitoringService->getMonitoringData($user, $filters);

        return response()->json([
            'status'  => 'success',
            'message' => 'Data monitoring berhasil diambil',
            'data'    => [
                'statistik'       => $data['statistik'],
                'active_operations' => MonitoringResource::collection($data['active_operations']),
            ],
        ], 200);
    }
}