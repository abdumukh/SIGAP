<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePenugasanRequest;
use App\Http\Requests\UpdatePenugasanRequest;
use App\Http\Resources\PenugasanResource;
use App\Services\AuthorizationService;
use App\Services\PenugasanService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PenugasanController extends Controller
{
    public function __construct(
        protected PenugasanService $penugasanService,
        protected AuthorizationService $authService,
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        if (!$this->authService->canListPenugasan($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Akses ditolak untuk role ini.',
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'data'   => PenugasanResource::collection(
                $this->penugasanService->getPenugasanListForUser($request->user())
            ),
        ]);
    }

    public function store(StorePenugasanRequest $request): JsonResponse
    {
        if (!$this->authService->canManageTim($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Hanya Admin yang dapat membuat penugasan.',
            ], 403);
        }

        $penugasan = $this->penugasanService->createPenugasan($request->validated());

        return response()->json([
            'status'  => 'success',
            'message' => 'Penugasan berhasil dibuat',
            'data'    => new PenugasanResource($penugasan),
        ], 201);
    }

    public function show(Request $request, string $id): JsonResponse
    {
        if (!$this->authService->canListPenugasan($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Akses ditolak untuk role ini.',
            ], 403);
        }

        $penugasan = $this->penugasanService->getPenugasanById($id);

        if (!$penugasan) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data penugasan tidak ditemukan',
            ], 404);
        }

        if (!$this->authService->canViewPenugasan($request->user(), $penugasan)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk melihat penugasan ini.',
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'data'   => new PenugasanResource($penugasan),
        ]);
    }

    public function update(UpdatePenugasanRequest $request, string $id): JsonResponse
    {
        if (!$this->authService->canUpdatePenugasanStatus($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Hanya Admin yang dapat memperbarui status penugasan.',
            ], 403);
        }

        try {
            $penugasan = $this->penugasanService->updatePenugasanStatus($id, $request->validated());
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
                'errors'  => $e->errors(),
            ], 422);
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'Status penugasan berhasil diperbarui',
            'data'    => new PenugasanResource($penugasan),
        ]);
    }
}
