<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    protected AuthService $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    /**
     * POST /api/auth/register
     * Registrasi akun Masyarakat baru.
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $pengguna = $this->authService->registerMasyarakat($request->validated());

        return response()->json([
            'status'  => 'success',
            'message' => 'Registrasi berhasil. Silakan login.',
            'data'    => [
                'user' => $pengguna,
            ],
        ], 201);
    }

    /**
     * POST /api/auth/login
     * Login multi-model (Masyarakat, Admin, Ketua Tim, Petugas).
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->login($request->email, $request->password);

        if (!$result) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Email atau password salah',
            ], 401);
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'Login berhasil',
            'data'    => $result,
        ], 200);
    }

    /**
     * GET /api/auth/me
     * Ambil data profil & aktor user terautentikasi.
     */
    public function me(Request $request): JsonResponse
    {
        $profile = $this->authService->getProfile($request->user());

        return response()->json([
            'status'  => 'success',
            'message' => 'Authenticated user',
            'data'    => $profile,
        ], 200);
    }

    /**
     * POST /api/auth/logout
     * Revoke token Sanctum aktif.
     */
    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request->user());

        return response()->json([
            'status'  => 'success',
            'message' => 'Logout berhasil',
        ], 200);
    }
}
