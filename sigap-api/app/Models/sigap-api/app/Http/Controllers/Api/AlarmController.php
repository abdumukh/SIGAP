<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreAlarmRequest;
use App\Http\Requests\UpdateAlarmStatusRequest;
use App\Http\Resources\AlarmResource;
use App\Models\Pengguna;
use App\Services\AlarmService;
use App\Services\AuthorizationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AlarmController extends Controller
{
    protected AlarmService $alarmService;
    protected AuthorizationService $authorizationService;

    public function __construct(AlarmService $alarmService, AuthorizationService $authorizationService)
    {
        $this->alarmService = $alarmService;
        $this->authorizationService = $authorizationService;
    }

    /**
     * POST /api/alarms
     * Kirim alarm darurat baru oleh Masyarakat.
     */
    public function store(StoreAlarmRequest $request): JsonResponse
    {
        $user = $request->user();

        if (!$user instanceof Pengguna || !$this->authorizationService->isMasyarakat($user)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Hanya masyarakat yang dapat mengirimkan alarm.',
            ], 403);
        }

        $alarm = $this->alarmService->createAlarm($user, $request->validated());

        return response()->json([
            'status'  => 'success',
            'message' => 'Alarm darurat berhasil dikirim',
            'data'    => new AlarmResource($alarm),
        ], 201);
    }

    /**
     * GET /api/alarms
     * Daftar alarm sesuai actor terautentikasi (Masyarakat hanya miliknya, Admin & Petugas melihat semua).
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $alarms = $this->alarmService->getAlarmsForUser($user);

        return response()->json([
            'status'  => 'success',
            'message' => 'Daftar alarm berhasil diambil',
            'data'    => AlarmResource::collection($alarms),
        ], 200);
    }

    /**
     * GET /api/alarms/{id}
     * Detail alarm dengan verifikasi otorisasi kepemilikan/role.
     */
    public function show(Request $request, string $id): JsonResponse
    {
        $alarm = $this->alarmService->getAlarmById($id);

        if (!$alarm) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data alarm tidak ditemukan',
            ], 404);
        }

        $user = $request->user();

        // Layer 2 Operational Ownership Check for Masyarakat actor
        if ($this->authorizationService->isMasyarakat($user)) {
            if (!$this->authorizationService->canMasyarakatAccessAlarm($user, $alarm)) {
                return response()->json([
                    'status'  => 'error',
                    'message' => 'Forbidden. Anda tidak memiliki akses ke alarm ini.',
                ], 403);
            }
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'Detail alarm berhasil diambil',
            'data'    => new AlarmResource($alarm),
        ], 200);
    }

    /**
     * POST/PATCH /api/alarms/{id}/verify
     * Verifikasi alarm oleh Petugas, Ketua Tim, atau Admin.
     */
    public function verify(Request $request, string $id): JsonResponse
    {
        $alarm = $this->alarmService->getAlarmById($id);

        if (!$alarm) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data alarm tidak ditemukan',
            ], 404);
        }

        $result = $this->alarmService->verifyAlarm($alarm, $request->user());

        if (!$result['success']) {
            return response()->json([
                'status'  => 'error',
                'message' => $result['message'],
            ], $result['code']);
        }

        return response()->json([
            'status'  => 'success',
            'message' => $result['message'],
            'data'    => new AlarmResource($result['alarm']),
        ], 200);
    }

    /**
     * POST/PATCH /api/alarms/{id}/reject
     * Tolak alarm oleh Petugas, Ketua Tim, atau Admin.
     */
    public function reject(Request $request, string $id): JsonResponse
    {
        $alarm = $this->alarmService->getAlarmById($id);

        if (!$alarm) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data alarm tidak ditemukan',
            ], 404);
        }

        $result = $this->alarmService->rejectAlarm($alarm, $request->user());

        if (!$result['success']) {
            return response()->json([
                'status'  => 'error',
                'message' => $result['message'],
            ], $result['code']);
        }

        return response()->json([
            'status'  => 'success',
            'message' => $result['message'],
            'data'    => new AlarmResource($result['alarm']),
        ], 200);
    }

    /**
     * POST/PATCH /api/alarms/{id}/complete
     * Selesaikan alarm yang sudah diverifikasi.
     */
    public function complete(Request $request, string $id): JsonResponse
    {
        $alarm = $this->alarmService->getAlarmById($id);

        if (!$alarm) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data alarm tidak ditemukan',
            ], 404);
        }

        $result = $this->alarmService->completeAlarm($alarm, $request->user());

        if (!$result['success']) {
            return response()->json([
                'status'  => 'error',
                'message' => $result['message'],
            ], $result['code']);
        }

        return response()->json([
            'status'  => 'success',
            'message' => $result['message'],
            'data'    => new AlarmResource($result['alarm']),
        ], 200);
    }

    /**
     * PATCH /api/alarms/{id}/status
     * Transisi status alarm generik dengan validasi Form Request.
     */
    public function updateStatus(UpdateAlarmStatusRequest $request, string $id): JsonResponse
    {
        $alarm = $this->alarmService->getAlarmById($id);

        if (!$alarm) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data alarm tidak ditemukan',
            ], 404);
        }

        $result = $this->alarmService->transitionStatus($alarm, $request->status_alarm, $request->user());

        if (!$result['success']) {
            return response()->json([
                'status'  => 'error',
                'message' => $result['message'],
            ], $result['code']);
        }

        return response()->json([
            'status'  => 'success',
            'message' => $result['message'],
            'data'    => new AlarmResource($result['alarm']),
        ], 200);
    }
}
