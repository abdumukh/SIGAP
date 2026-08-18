<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTimRequest;
use App\Http\Requests\UpdateTimRequest;
use App\Http\Resources\TimResource;
use App\Services\AuthorizationService;
use App\Services\TimService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TimController extends Controller
{
    protected TimService $timService;
    protected AuthorizationService $authService;

    public function __construct(TimService $timService, AuthorizationService $authService)
    {
        $this->timService  = $timService;
        $this->authService = $authService;
    }

    public function index(Request $request): JsonResponse
    {
        if (!$this->authService->canManageTim($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk mengelola tim.',
            ], 403);
        }

        $teams = $this->timService->getTimList();

        return response()->json([
            'status' => 'success',
            'data'   => TimResource::collection($teams),
        ], 200);
    }

    public function store(StoreTimRequest $request): JsonResponse
    {
        if (!$this->authService->canManageTim($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk membuat tim.',
            ], 403);
        }

        $tim = $this->timService->createTim($request->validated());

        return response()->json([
            'status'  => 'success',
            'message' => 'Tim berhasil dibuat',
            'data'    => new TimResource($tim),
        ], 201);
    }

    public function show(Request $request, string $id): JsonResponse
    {
        if (!$this->authService->canManageTim($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses ke data tim.',
            ], 403);
        }

        $tim = $this->timService->getTimById($id);

        if (!$tim) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data tim tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => new TimResource($tim),
        ], 200);
    }

    public function update(UpdateTimRequest $request, string $id): JsonResponse
    {
        if (!$this->authService->canManageTim($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk mengubah tim.',
            ], 403);
        }

        $tim = $this->timService->getTimById($id);

        if (!$tim) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data tim tidak ditemukan',
            ], 404);
        }

        $updatedTim = $this->timService->updateTim($tim, $request->validated());

        return response()->json([
            'status'  => 'success',
            'message' => 'Data tim berhasil diperbarui',
            'data'    => new TimResource($updatedTim),
        ], 200);
    }

    public function destroy(Request $request, string $id): JsonResponse
    {
        if (!$this->authService->canManageTim($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk menghapus tim.',
            ], 403);
        }

        $tim = $this->timService->getTimById($id);

        if (!$tim) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data tim tidak ditemukan',
            ], 404);
        }

        $this->timService->deleteTim($tim);

        return response()->json([
            'status'  => 'success',
            'message' => 'Tim berhasil dinonaktifkan',
            'data'    => new TimResource($tim),
        ], 200);
    }
}
