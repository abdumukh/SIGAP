<?php

namespace Tests\Feature;

use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DemoAccountTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    private array $accounts = [
        [
            'email'    => 'masyarakat@sigap.test',
            'password' => 'Sigap123!',
            'actor'    => 'masyarakat',
            'label'    => 'Masyarakat',
        ],
        [
            'email'    => 'admin@sigap.test',
            'password' => 'Sigap123!',
            'actor'    => 'admin',
            'label'    => 'Admin',
        ],
        [
            'email'    => 'ketua@sigap.test',
            'password' => 'Sigap123!',
            'actor'    => 'ketua_tim',
            'label'    => 'Ketua Tim',
        ],
        [
            'email'    => 'petugas@sigap.test',
            'password' => 'Sigap123!',
            'actor'    => 'petugas',
            'label'    => 'Petugas',
        ],
    ];

    public function test_all_demo_accounts_exist_in_database(): void
    {
        foreach ($this->accounts as $account) {
            $this->assertDatabaseHas(
                match ($account['actor']) {
                    'masyarakat' => 'pengguna',
                    'admin'      => 'admin',
                    default      => 'petugas',
                },
                ['email' => $account['email']]
            );
        }
    }

    /**
     * @dataProvider accountProvider
     */
    public function test_demo_account_can_login(array $account): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email'    => $account['email'],
            'password' => $account['password'],
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status'  => 'success',
                'message' => 'Login berhasil',
                'data'    => [
                    'actor'      => $account['actor'],
                    'token_type' => 'Bearer',
                ],
            ]);

        $this->assertArrayHasKey('token', $response->json('data'));
        $this->assertArrayNotHasKey('password', $response->json('data.user'));
    }

    /**
     * @dataProvider accountProvider
     */
    public function test_demo_account_can_access_profile(array $account): void
    {
        $login = $this->postJson('/api/auth/login', [
            'email'    => $account['email'],
            'password' => $account['password'],
        ]);

        $token = $login->json('data.token');

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/auth/me');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'actor' => $account['actor'],
                ],
            ]);
    }

    public function test_demo_accounts_use_different_emails(): void
    {
        $emails = array_column($this->accounts, 'email');
        $this->assertCount(4, array_unique($emails), 'All demo accounts must have unique emails');
    }

    public function test_demo_accounts_use_unified_password(): void
    {
        $passwords = array_unique(array_column($this->accounts, 'password'));
        $this->assertCount(1, $passwords, 'All demo accounts must share the same password');
        $this->assertEquals('Sigap123!', $passwords[0]);
    }

    public static function accountProvider(): array
    {
        return [
            'masyarakat' => [[
                'email'    => 'masyarakat@sigap.test',
                'password' => 'Sigap123!',
                'actor'    => 'masyarakat',
                'label'    => 'Masyarakat',
            ]],
            'admin' => [[
                'email'    => 'admin@sigap.test',
                'password' => 'Sigap123!',
                'actor'    => 'admin',
                'label'    => 'Admin',
            ]],
            'ketua_tim' => [[
                'email'    => 'ketua@sigap.test',
                'password' => 'Sigap123!',
                'actor'    => 'ketua_tim',
                'label'    => 'Ketua Tim',
            ]],
            'petugas' => [[
                'email'    => 'petugas@sigap.test',
                'password' => 'Sigap123!',
                'actor'    => 'petugas',
                'label'    => 'Petugas',
            ]],
        ];
    }
}
