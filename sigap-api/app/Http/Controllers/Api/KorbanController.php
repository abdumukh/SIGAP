<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreKorbanRequest;
use App\Http\Resources\KorbanResource;
use App\Models\Korban;
use App\Services\AuthorizationService;
use App\Services\KorbanService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class KorbanController extends Controller
{
    public function __construct(
        protected KorbanService $korbanService,
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

        $list = $this->korbanService->getKorbanListForUser($request->user());

        return response()->json([
            'status' => 'success',
            'data'   => KorbanResource::collection($list),
        ]);
    }

    public function store(StoreKorbanRequest $request): JsonResponse
    {
        if (!$this->authService->canCreatePenanganan($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Hanya Petugas atau Ketua Tim yang dapat menambahkan data korban.',
            ], 403);
        }

        $korban = $this->korbanService->createKorban($request->user(), $request->validated());

        return response()->json([
            'status'  => 'success',
            'message' => 'Data korban berhasil ditambahkan',
            'data'    => new KorbanResource($korban),
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

        $korban = $this->korbanService->getKorbanById($id);

        if (!$korban) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data korban tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => new KorbanResource($korban),
        ]);
    }

    public function destroy(Request $request, string $id): JsonResponse
    {
        $korban = $this->korbanService->getKorbanById($id);

        if (!$korban) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data korban tidak ditemukan',
            ], 404);
        }

        if (!$this->authService->canCreatePenanganan($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk menghapus data korban.',
            ], 403);
        }

        $this->korbanService->deleteKorban($korban);

        return response()->json([
            'status'  => 'success',
            'message' => 'Data korban berhasil dihapus',
        ]);
    }
}
