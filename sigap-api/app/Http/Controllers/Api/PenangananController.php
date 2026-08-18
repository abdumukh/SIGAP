<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePenangananRequest;
use App\Http\Requests\UpdatePenangananRequest;
use App\Http\Resources\PenangananResource;
use App\Services\AuthorizationService;
use App\Services\PenangananService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PenangananController extends Controller
{
    public function __construct(
        protected PenangananService $penangananService,
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

        $list = $this->penangananService->getPenangananListForUser($request->user());

        return response()->json([
            'status' => 'success',
            'data'   => PenangananResource::collection($list),
        ]);
    }

    public function store(StorePenangananRequest $request): JsonResponse
    {
        if (!$this->authService->canCreatePenanganan($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Hanya Petugas atau Ketua Tim yang dapat membuat penanganan.',
            ], 403);
        }

        $penanganan = $this->penangananService->createPenanganan($request->user(), $request->validated());

        return response()->json([
            'status'  => 'success',
            'message' => 'Penanganan berhasil dibuat',
            'data'    => new PenangananResource($penanganan),
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

        $penanganan = $this->penangananService->getPenangananById($id);

        if (!$penanganan) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data penanganan tidak ditemukan',
            ], 404);
        }

        if (!$this->authService->canViewPenanganan($request->user(), $penanganan)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk melihat penanganan ini.',
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'data'   => new PenangananResource($penanganan),
        ]);
    }

    public function update(UpdatePenangananRequest $request, string $id): JsonResponse
    {
        $penanganan = $this->penangananService->getPenangananById($id);

        if (!$penanganan) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data penanganan tidak ditemukan',
            ], 404);
        }

        if (!$this->authService->canUpdatePenanganan($request->user(), $penanganan)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk mengubah penanganan ini.',
            ], 403);
        }

        $updatedPenanganan = $this->penangananService->updatePenangananStatus($penanganan, $request->validated());

        return response()->json([
            'status'  => 'success',
            'message' => 'Status penanganan berhasil diperbarui',
            'data'    => new PenangananResource($updatedPenanganan),
        ]);
    }
}
