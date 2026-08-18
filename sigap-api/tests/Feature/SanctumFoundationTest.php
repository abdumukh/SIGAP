<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\Pengguna;
use App\Models\Petugas;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class SanctumFoundationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }
    public function test_personal_access_tokens_table_exists(): void
    {
        $this->assertTrue(Schema::hasTable('personal_access_tokens'));
    }

    public function test_pengguna_can_create_sanctum_token(): void
    {
        $pengguna = Pengguna::first();
        $this->assertNotNull($pengguna, 'Pengguna dummy record not found');

        $token = $pengguna->createToken('test_pengguna_token', ['masyarakat'])->plainTextToken;
        $this->assertIsString($token);
        $this->assertStringContainsString('|', $token);
    }

    public function test_admin_can_create_sanctum_token(): void
    {
        $admin = Admin::first();
        $this->assertNotNull($admin, 'Admin dummy record not found');

        $token = $admin->createToken('test_admin_token', ['admin'])->plainTextToken;
        $this->assertIsString($token);
        $this->assertStringContainsString('|', $token);
    }

    public function test_petugas_and_ketua_tim_can_create_sanctum_token(): void
    {
        $ketuaTim = Petugas::where('role', 'ketua_tim')->first();
        $this->assertNotNull($ketuaTim, 'Ketua Tim dummy record not found');

        $tokenKetua = $ketuaTim->createToken('test_ketua_token', ['ketua_tim'])->plainTextToken;
        $this->assertIsString($tokenKetua);

        $petugasArmada = Petugas::where('role', 'petugas')->first();
        $this->assertNotNull($petugasArmada, 'Petugas Armada dummy record not found');

        $tokenPetugas = $petugasArmada->createToken('test_petugas_token', ['petugas'])->plainTextToken;
        $this->assertIsString($tokenPetugas);
    }
}
