<?php

namespace App\Services;

use App\Models\Admin;
use App\Models\Pengguna;
use App\Models\Petugas;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Support\Facades\Hash;

class AuthService
{
    protected ActorService $actorService;

    public function __construct(ActorService $actorService)
    {
        $this->actorService = $actorService;
    }

    /**
     * Register a new Masyarakat user in 'pengguna' table.
     */
    public function registerMasyarakat(array $data): Pengguna
    {
        $idPengguna = $this->actorService->generatePenggunaId();

        return Pengguna::create([
            'id_pengguna' => $idPengguna,
            'nama'        => $data['nama'],
            'no_hp'       => $data['no_hp'],
            'alamat'      => $data['alamat'],
            'email'       => $data['email'],
            'password'    => Hash::make($data['password']),
        ]);
    }

    /**
     * Authenticates user against multi-model sources (pengguna, admin, petugas).
     */
    public function login(string $email, string $password): ?array
    {
        $user = $this->findUserByEmail($email);

        if (!$user || !Hash::check($password, $user->password)) {
            return null;
        }

        $actor = $this->actorService->resolveActor($user);
        $token = $user->createToken('sigap_auth_token', [$actor])->plainTextToken;

        return [
            'token'      => $token,
            'token_type' => 'Bearer',
            'actor'      => $actor,
            'user'       => $user,
        ];
    }

    /**
     * Resolves authenticated profile and actor identity.
     */
    public function getProfile(Authenticatable $user): array
    {
        return [
            'actor' => $this->actorService->resolveActor($user),
            'user'  => $user,
        ];
    }

    /**
     * Revokes current active Sanctum token.
     */
    public function logout(Authenticatable $user): void
    {
        if (method_exists($user, 'currentAccessToken') && $user->currentAccessToken()) {
            $user->currentAccessToken()->delete();
        }
    }

    /**
     * Multi-model user search order: 1. pengguna, 2. admin, 3. petugas.
     */
    protected function findUserByEmail(string $email): ?Authenticatable
    {
        $pengguna = Pengguna::where('email', $email)->first();
        if ($pengguna) {
            return $pengguna;
        }

        $admin = Admin::where('email', $email)->first();
        if ($admin) {
            return $admin;
        }

        $petugas = Petugas::where('email', $email)->first();
        if ($petugas) {
            return $petugas;
        }

        return null;
    }
}
