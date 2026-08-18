<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreDokumentasiRequest;
use App\Http\Resources\DokumentasiResource;
use App\Services\AuthorizationService;
use App\Services\DokumentasiService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DokumentasiController extends Controller
{
    public function __construct(
        protected DokumentasiService $dokumentasiService,
        protected AuthorizationService $authService,
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        if (!$this->authService->canListDokumentasi($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Akses ditolak untuk role ini.',
            ], 403);
        }

        $list = $this->dokumentasiService->getDokumentasiListForUser($request->user());

        return response()->json([
            'status' => 'success',
            'data'   => DokumentasiResource::collection($list),
        ]);
    }

    public function store(StoreDokumentasiRequest $request): JsonResponse
    {
        if (!$this->authService->isPetugas($request->user()) && !$this->authService->isKetuaTim($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Hanya Petugas atau Ketua Tim yang dapat membuat dokumentasi.',
            ], 403);
        }

        $fileInput = $request->file('file_dokumentasi') ?? $request->input('file_dokumentasi');
        $dokumentasi = $this->dokumentasiService->createDokumentasi($request->user(), $request->validated(), $fileInput);

        return response()->json([
            'status'  => 'success',
            'message' => 'Dokumentasi berhasil dibuat',
            'data'    => new DokumentasiResource($dokumentasi),
        ], 201);
    }

    public function show(Request $request, string $id): JsonResponse
    {
        if (!$this->authService->canListDokumentasi($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Akses ditolak untuk role ini.',
            ], 403);
        }

        $dokumentasi = $this->dokumentasiService->getDokumentasiById($id);

        if (!$dokumentasi) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data dokumentasi tidak ditemukan',
            ], 404);
        }

        if (!$this->authService->canViewDokumentasi($request->user(), $dokumentasi)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses ke dokumentasi ini.',
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'data'   => new DokumentasiResource($dokumentasi),
        ]);
    }

    public function destroy(Request $request, string $id): JsonResponse
    {
        $dokumentasi = $this->dokumentasiService->getDokumentasiById($id);

        if (!$dokumentasi) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data dokumentasi tidak ditemukan',
            ], 404);
        }

        if (!$this->authService->canDeleteDokumentasi($request->user(), $dokumentasi)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk menghapus dokumentasi ini.',
            ], 403);
        }

        $this->dokumentasiService->deleteDokumentasi($dokumentasi);

        return response()->json([
            'status'  => 'success',
            'message' => 'Dokumentasi berhasil dihapus',
        ]);
    }
}
