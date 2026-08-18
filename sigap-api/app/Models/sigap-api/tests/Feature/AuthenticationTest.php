<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\Pengguna;
use App\Models\Petugas;
use Tests\TestCase;

class AuthenticationTest extends TestCase
{
    /**
     * 1. Test Masyarakat register creates custom USR-xxx ID and returns 201.
     */
    public function test_masyarakat_can_register(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'nama'                  => 'Siti Rahma',
            'no_hp'                 => '081299887766',
            'alamat'                => 'Jl. Sudirman No. 45',
            'email'                 => 'siti.rahma@example.com',
            'password'              => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'status'  => 'success',
                'message' => 'Registrasi berhasil. Silakan login.',
            ]);

        $this->assertDatabaseHas('pengguna', [
            'email' => 'siti.rahma@example.com',
        ]);

        $pengguna = Pengguna::where('email', 'siti.rahma@example.com')->first();
        $this->assertNotNull($pengguna);
        $this->assertStringStartsWith('USR-', $pengguna->id_pengguna);

        // Clean up test record to preserve dev database
        $pengguna->delete();
    }

    /**
     * 2. Test Masyarakat login (budi@example.com / password123).
     * 12. Password not in response.
     * 13. Actor masyarakat correct.
     */
    public function test_masyarakat_can_login(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email'    => 'budi@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'actor'      => 'masyarakat',
                    'token_type' => 'Bearer',
                ],
            ]);

        $this->assertArrayHasKey('token', $response->json('data'));
        $this->assertArrayNotHasKey('password', $response->json('data.user'));
    }

    /**
     * 3. Test Admin login (admin@sigap.go.id / admin123).
     * 14. Actor admin correct.
     */
    public function test_admin_can_login(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email'    => 'admin@sigap.go.id',
            'password' => 'admin123',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'actor' => 'admin',
                ],
            ]);

        $this->assertArrayNotHasKey('password', $response->json('data.user'));
    }

    /**
     * 4. Test Petugas login (ahmad@sigap.go.id / petugas123).
     * 15. Actor petugas correct.
     */
    public function test_petugas_can_login(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email'    => 'ahmad@sigap.go.id',
            'password' => 'petugas123',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'actor' => 'petugas',
                ],
            ]);

        $this->assertArrayNotHasKey('password', $response->json('data.user'));
    }

    /**
     * 5. Test Ketua Tim login (rahmat@sigap.go.id / petugas123).
     * 16. Actor ketua_tim correct.
     */
    public function test_ketua_tim_can_login(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email'    => 'rahmat@sigap.go.id',
            'password' => 'petugas123',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'actor' => 'ketua_tim',
                ],
            ]);

        $this->assertArrayNotHasKey('password', $response->json('data.user'));
    }

    /**
     * 6. Test login with wrong password returns 401.
     */
    public function test_login_with_wrong_password_returns_401(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email'    => 'budi@example.com',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Email atau password salah',
            ]);
    }

    /**
     * 7. Test login with non-existing email returns 401.
     */
    public function test_login_with_non_existing_email_returns_401(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email'    => 'nonexisting@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Email atau password salah',
            ]);
    }

    /**
     * 8. Test /me with valid token returns 200 and profile.
     */
    public function test_me_with_valid_token_returns_200(): void
    {
        $login = $this->postJson('/api/auth/login', [
            'email'    => 'budi@example.com',
            'password' => 'password123',
        ]);

        $token = $login->json('data.token');

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/auth/me');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'actor' => 'masyarakat',
                ],
            ]);

        $this->assertArrayNotHasKey('password', $response->json('data.user'));
    }

    /**
     * 9. Test /me without token returns 401.
     */
    public function test_me_without_token_returns_401(): void
    {
        $response = $this->getJson('/api/auth/me');

        $response->assertStatus(401);
    }

    /**
     * 10. Test logout with valid token returns 200.
     * 11. Test token after logout becomes invalid (401).
     */
    public function test_logout_invalidates_token(): void
    {
        $login = $this->postJson('/api/auth/login', [
            'email'    => 'budi@example.com',
            'password' => 'password123',
        ]);

        $token = $login->json('data.token');

        // Logout
        $logoutResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/auth/logout');

        $logoutResponse->assertStatus(200)
            ->assertJson([
                'status'  => 'success',
                'message' => 'Logout berhasil',
            ]);

        // Reset auth guard state for next request
        $this->app['auth']->forgetGuards();

        // Try accessing /me again with revoked token
        $meResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/auth/me');

        $meResponse->assertStatus(401);
    }
}
