<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreLogistikRequest;
use App\Http\Resources\LogistikResource;
use App\Models\Logistik;
use App\Services\AuthorizationService;
use App\Services\LogistikService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LogistikController extends Controller
{
    public function __construct(
        protected LogistikService $logistikService,
        protected AuthorizationService $authService,
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        if (!$this->authService->canListPenanganan($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Akses ditolak untuk role ini.',
            ], 403);
        }

        $list = $this->logistikService->getLogistikListForUser($request->user());

        return response()->json([
            'status' => 'success',
            'data'   => LogistikResource::collection($list),
        ]);
    }

    public function store(StoreLogistikRequest $request): JsonResponse
    {
        if (!$this->authService->canCreatePenanganan($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Hanya Petugas atau Ketua Tim yang dapat menambahkan data logistik.',
            ], 403);
        }

        $logistik = $this->logistikService->createLogistik($request->user(), $request->validated());

        return response()->json([
            'status'  => 'success',
            'message' => 'Data logistik berhasil ditambahkan',
            'data'    => new LogistikResource($logistik),
        ], 201);
    }

    public function show(Request $request, string $id): JsonResponse
    {
        if (!$this->authService->canListPenanganan($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Akses ditolak untuk role ini.',
            ], 403);
        }

        $logistik = $this->logistikService->getLogistikById($id);

        if (!$logistik) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data logistik tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => new LogistikResource($logistik),
        ]);
    }

    public function destroy(Request $request, string $id): JsonResponse
    {
        $logistik = $this->logistikService->getLogistikById($id);

        if (!$logistik) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data logistik tidak ditemukan',
            ], 404);
        }

        if (!$this->authService->canCreatePenanganan($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk menghapus data logistik.',
            ], 403);
        }

        $this->logistikService->deleteLogistik($logistik);

        return response()->json([
            'status'  => 'success',
            'message' => 'Data logistik berhasil dihapus',
        ]);
    }
}