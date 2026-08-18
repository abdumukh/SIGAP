<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\AddAnggotaTimRequest;
use App\Http\Requests\UpdateAnggotaTimRequest;
use App\Http\Resources\AnggotaTimResource;
use App\Services\AnggotaTimService;
use App\Services\AuthorizationService;
use App\Services\TimService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnggotaTimController extends Controller
{
    protected AnggotaTimService $anggotaService;
    protected TimService $timService;
    protected AuthorizationService $authService;

    public function __construct(
        AnggotaTimService $anggotaService,
        TimService $timService,
        AuthorizationService $authService
    ) {
        $this->anggotaService = $anggotaService;
        $this->timService     = $timService;
        $this->authService    = $authService;
    }

    public function index(Request $request, string $id): JsonResponse
    {
        if (!$this->authService->canManageTim($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses ke data anggota tim.',
            ], 403);
        }

        $tim = $this->timService->getTimById($id);
        if (!$tim) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data tim tidak ditemukan',
            ], 404);
        }

        $members = $this->anggotaService->getAnggotaByTim($id);

        return response()->json([
            'status' => 'success',
            'data'   => AnggotaTimResource::collection($members),
        ], 200);
    }

    public function store(AddAnggotaTimRequest $request, string $id): JsonResponse
    {
        if (!$this->authService->canManageTim($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk menambah anggota tim.',
            ], 403);
        }

        $tim = $this->timService->getTimById($id);
        if (!$tim) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data tim tidak ditemukan',
            ], 404);
        }

        $result = $this->anggotaService->addAnggotaTim($tim, $request->validated());

        if (!$result['success']) {
            return response()->json([
                'status'  => 'error',
                'message' => $result['message'],
            ], $result['code']);
        }

        return response()->json([
            'status'  => 'success',
            'message' => $result['message'],
            'data'    => new AnggotaTimResource($result['data']),
        ], 201);
    }

    public function update(UpdateAnggotaTimRequest $request, string $id, string $idAnggota): JsonResponse
    {
        if (!$this->authService->canManageTim($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk mengubah anggota tim.',
            ], 403);
        }

        $tim = $this->timService->getTimById($id);
        if (!$tim) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data tim tidak ditemukan',
            ], 404);
        }

        $anggota = $this->anggotaService->getAnggotaById($idAnggota);
        if (!$anggota || $anggota->id_tim !== $id) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data anggota tim tidak ditemukan pada tim ini',
            ], 404);
        }

        $updated = $this->anggotaService->updateStatusAnggota($anggota, $request->validated()['status_anggota']);

        return response()->json([
            'status'  => 'success',
            'message' => 'Status anggota tim berhasil diperbarui',
            'data'    => new AnggotaTimResource($updated),
        ], 200);
    }

    public function destroy(Request $request, string $id, string $idAnggota): JsonResponse
    {
        if (!$this->authService->canManageTim($request->user())) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses untuk menghapus anggota tim.',
            ], 403);
        }

        $tim = $this->timService->getTimById($id);
        if (!$tim) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data tim tidak ditemukan',
            ], 404);
        }

        $anggota = $this->anggotaService->getAnggotaById($idAnggota);
        if (!$anggota || $anggota->id_tim !== $id) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Data anggota tim tidak ditemukan pada tim ini',
            ], 404);
        }

        $this->anggotaService->removeAnggota($anggota);

        return response()->json([
            'status'  => 'success',
            'message' => 'Anggota tim berhasil dinonaktifkan',
            'data'    => new AnggotaTimResource($anggota),
        ], 200);
    }
}
