<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\Pengguna;
use App\Models\Petugas;
use App\Services\AuthorizationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthorizationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        // Seed basic fixtures required for roles
        Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-999'],
            [
                'nama'     => 'Masyarakat Test User',
                'email'    => 'user999@example.com',
                'password' => Hash::make('password123'),
                'no_hp'    => '08123456789',
                'alamat'   => 'Jl. Test No. 1',
            ]
        );

        Admin::firstOrCreate(
            ['id_admin' => 'ADM-999'],
            [
                'nama_admin' => 'Admin Test User',
                'email'      => 'admin999@example.com',
                'password'   => Hash::make('password123'),
                'no_hp'      => '08123456788',
            ]
        );

        Petugas::firstOrCreate(
            ['id_petugas' => 'PET-999'],
            [
                'nama_petugas'   => 'Ketua Tim Test User',
                'email'          => 'ketua999@example.com',
                'password'       => Hash::make('password123'),
                'no_hp'          => '08123456787',
                'alamat'         => 'Jl. Posko No. 1',
                'status_petugas' => 'aktif',
                'role'           => 'ketua_tim',
            ]
        );

        Petugas::firstOrCreate(
            ['id_petugas' => 'PET-998'],
            [
                'nama_petugas'   => 'Petugas Member Test User',
                'email'          => 'petugas998@example.com',
                'password'       => Hash::make('password123'),
                'no_hp'          => '08123456786',
                'alamat'         => 'Jl. Posko No. 2',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );
    }

    public function test_admin_allowed_for_admin_role(): void
    {
        $admin = Admin::where('id_admin', 'ADM-999')->first();
        $token = $admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/test-role/admin');

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);
    }

    public function test_admin_denied_for_non_admin_role(): void
    {
        $admin = Admin::where('id_admin', 'ADM-999')->first();
        $token = $admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/test-role/masyarakat');

        $response->assertStatus(403)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Forbidden. Akses ditolak untuk role ini.',
            ]);
    }

    public function test_masyarakat_allowed_for_masyarakat_role(): void
    {
        $user = Pengguna::where('id_pengguna', 'USR-999')->first();
        $token = $user->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/test-role/masyarakat');

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);
    }

    public function test_masyarakat_denied_for_admin_role(): void
    {
        $user = Pengguna::where('id_pengguna', 'USR-999')->first();
        $token = $user->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/test-role/admin');

        $response->assertStatus(403)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Forbidden. Akses ditolak untuk role ini.',
            ]);
    }

    public function test_petugas_allowed_for_petugas_role(): void
    {
        $petugas = Petugas::where('id_petugas', 'PET-998')->first();
        $token = $petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/test-role/petugas');

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);
    }

    public function test_petugas_denied_for_ketua_tim_role(): void
    {
        $petugas = Petugas::where('id_petugas', 'PET-998')->first();
        $token = $petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/test-role/ketua-tim');

        $response->assertStatus(403)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Forbidden. Akses ditolak untuk role ini.',
            ]);
    }

    public function test_ketua_tim_allowed_for_ketua_tim_role(): void
    {
        $ketua = Petugas::where('id_petugas', 'PET-999')->first();
        $token = $ketua->createToken('auth', ['ketua_tim'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/test-role/ketua-tim');

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);
    }

    public function test_ketua_tim_denied_for_petugas_role(): void
    {
        $ketua = Petugas::where('id_petugas', 'PET-999')->first();
        $token = $ketua->createToken('auth', ['ketua_tim'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/test-role/petugas');

        $response->assertStatus(403)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Forbidden. Akses ditolak untuk role ini.',
            ]);
    }

    public function test_unauthenticated_returns_401(): void
    {
        $response = $this->getJson('/api/test-role/admin');

        $response->assertStatus(401);
    }

    public function test_mismatched_sanctum_ability_returns_403(): void
    {
        // Issue token with 'petugas' ability for a Pengguna (masyarakat) model
        $user = Pengguna::where('id_pengguna', 'USR-999')->first();
        $token = $user->createToken('auth', ['petugas'])->plainTextToken;

        // Even though route allows 'petugas', token ability does not match actual DB actor 'masyarakat'
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/test-role/petugas');

        $response->assertStatus(403)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Forbidden. Akses ditolak untuk role ini.',
            ]);
    }

    public function test_correct_ability_and_correct_actor_allowed(): void
    {
        $admin = Admin::where('id_admin', 'ADM-999')->first();
        $token = $admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/test-role/admin');

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);
    }

    public function test_operational_authorization_foundation(): void
    {
        $user = Pengguna::where('id_pengguna', 'USR-999')->first();
        $otherUser = Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-998'],
            [
                'nama'     => 'Other User',
                'email'    => 'other998@example.com',
                'password' => Hash::make('password123'),
                'no_hp'    => '08123456780',
                'alamat'   => 'Jl. Other',
            ]
        );

        $alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-999'],
            [
                'id_pengguna'   => 'USR-999',
                'jenis_darurat' => 'Kebakaran',
                'waktu_alarm'   => now(),
                'latitude'      => -6.2000000,
                'longitude'     => 106.8166660,
                'status_alarm'  => 'menunggu',
            ]
        );

        $authService = app(AuthorizationService::class);

        // USR-999 owns ALM-999 -> true
        $this::assertTrue($authService->canMasyarakatAccessAlarm($user, $alarm));

        // USR-998 does not own ALM-999 -> false
        $this::assertFalse($authService->canMasyarakatAccessAlarm($otherUser, $alarm));
    }
}
