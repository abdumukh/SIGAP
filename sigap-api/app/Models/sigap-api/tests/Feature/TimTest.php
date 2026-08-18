<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\AnggotaTim;
use App\Models\Pengguna;
use App\Models\Petugas;
use App\Models\Tim;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class TimTest extends TestCase
{
    use DatabaseTransactions;

    protected Admin $admin;
    protected Pengguna $masyarakat;
    protected Petugas $petugas;
    protected Petugas $ketuaTim;
    protected Tim $timA;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = Admin::firstOrCreate(
            ['id_admin' => 'ADM-771'],
            [
                'nama_admin' => 'Admin Tim Test',
                'email'      => 'admintim771@sigap.go.id',
                'password'   => Hash::make('password123'),
                'no_hp'      => '081199997711',
            ]
        );

        $this->masyarakat = Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-771'],
            [
                'nama'     => 'Masyarakat Tim Test',
                'email'    => 'masyarakattim771@example.com',
                'password' => Hash::make('password123'),
                'no_hp'    => '081299997711',
                'alamat'   => 'Jl. Tim Test No. 1',
            ]
        );

        $this->petugas = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-771'],
            [
                'nama_petugas'   => 'Petugas Alpha 771',
                'email'          => 'petugas771@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085299997711',
                'alamat'         => 'Posko Utama 771',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->ketuaTim = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-772'],
            [
                'nama_petugas'   => 'Ketua Tim Bravo 772',
                'email'          => 'ketuatim772@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085299997722',
                'alamat'         => 'Posko Utama 772',
                'status_petugas' => 'aktif',
                'role'           => 'ketua_tim',
            ]
        );

        $this->timA = Tim::firstOrCreate(
            ['id_tim' => 'TIM-771'],
            [
                'nama_tim'   => 'Tim Reaksi Cepat 771',
                'note'       => 'Tim Evakuasi Utama',
                'status_tim' => 'aktif',
            ]
        );
    }

    // 1. admin can list teams
    public function test_admin_can_list_teams(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/tim');

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);

        $data = $response->json('data');
        $this->assertIsArray($data);
        $ids = array_column($data, 'id_tim');
        $this->assertContains('TIM-771', $ids);
    }

    // 2. admin can create team
    public function test_admin_can_create_team(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/tim', [
                'nama_tim'   => 'Tim Rescue Damkar 772',
                'note'       => 'Tim Penangan Kebakaran',
                'status_tim' => 'aktif',
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'status'  => 'success',
                'message' => 'Tim berhasil dibuat',
                'data'    => [
                    'nama_tim'   => 'Tim Rescue Damkar 772',
                    'status_tim' => 'aktif',
                ],
            ]);

        $timId = $response->json('data.id_tim');
        $this->assertStringStartsWith('TIM-', $timId);
        $this->assertDatabaseHas('tim', ['id_tim' => $timId, 'nama_tim' => 'Tim Rescue Damkar 772']);
    }

    // 3. admin can view team detail
    public function test_admin_can_view_team_detail(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson("/api/tim/{$this->timA->id_tim}");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'id_tim'   => 'TIM-771',
                    'nama_tim' => 'Tim Reaksi Cepat 771',
                ],
            ]);
    }

    // 4. admin can update team
    public function test_admin_can_update_team(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->patchJson("/api/tim/{$this->timA->id_tim}", [
                'nama_tim' => 'Tim Reaksi Cepat 771 Updated',
                'note'     => 'Catatan Diperbarui',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'status'  => 'success',
                'message' => 'Data tim berhasil diperbarui',
                'data'    => [
                    'id_tim'   => 'TIM-771',
                    'nama_tim' => 'Tim Reaksi Cepat 771 Updated',
                    'note'     => 'Catatan Diperbarui',
                ],
            ]);

        $this->assertDatabaseHas('tim', [
            'id_tim'   => 'TIM-771',
            'nama_tim' => 'Tim Reaksi Cepat 771 Updated',
        ]);
    }

    // 5. admin can deactivate/delete team
    public function test_admin_can_deactivate_or_delete_team(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->deleteJson("/api/tim/{$this->timA->id_tim}");

        $response->assertStatus(200)
            ->assertJson([
                'status'  => 'success',
                'message' => 'Tim berhasil dinonaktifkan',
                'data'    => [
                    'id_tim'     => 'TIM-771',
                    'status_tim' => 'nonaktif',
                ],
            ]);

        $this->assertDatabaseHas('tim', [
            'id_tim'     => 'TIM-771',
            'status_tim' => 'nonaktif',
        ]);
    }

    // 6. masyarakat cannot manage teams
    public function test_masyarakat_cannot_manage_teams(): void
    {
        $token = $this->masyarakat->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/tim', [
                'nama_tim' => 'Tim Ilegal Masyarakat',
            ]);

        $response->assertStatus(403);
    }

    // 7. petugas cannot manage teams
    public function test_petugas_cannot_manage_teams(): void
    {
        $token = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/tim', [
                'nama_tim' => 'Tim Ilegal Petugas',
            ]);

        $response->assertStatus(403);
    }

    // 8. ketua tim cannot manage teams
    public function test_ketua_tim_cannot_manage_teams(): void
    {
        $token = $this->ketuaTim->createToken('auth', ['ketua_tim'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/tim', [
                'nama_tim' => 'Tim Ilegal Ketua Tim',
            ]);

        $response->assertStatus(403);
    }

    // 9. validation invalid returns 422
    public function test_validation_invalid_team_returns_422(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/tim', [
                // missing nama_tim
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['nama_tim']);
    }

    // 10. non existing team returns 404
    public function test_non_existing_team_returns_404(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/tim/TIM-NONEXISTENT');

        $response->assertStatus(404)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Data tim tidak ditemukan',
            ]);
    }

    // 11. admin can list team members
    public function test_admin_can_list_team_members(): void
    {
        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-771'],
            [
                'id_tim'         => $this->timA->id_tim,
                'id_petugas'     => $this->petugas->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson("/api/tim/{$this->timA->id_tim}/anggota");

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);

        $data = $response->json('data');
        $this->assertIsArray($data);
        $ids = array_column($data, 'id_anggota_tim');
        $this->assertContains('AT-771', $ids);
    }

    // 12. admin can add petugas to team
    public function test_admin_can_add_petugas_to_team(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson("/api/tim/{$this->timA->id_tim}/anggota", [
                'id_petugas'     => $this->petugas->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'status'  => 'success',
                'message' => 'Anggota tim berhasil ditambahkan',
                'data'    => [
                    'id_tim'     => 'TIM-771',
                    'id_petugas' => 'PET-771',
                ],
            ]);

        $idAnggota = $response->json('data.id_anggota_tim');
        $this->assertStringStartsWith('AT-', $idAnggota);
        $this->assertDatabaseHas('anggota_tim', [
            'id_anggota_tim' => $idAnggota,
            'id_tim'         => 'TIM-771',
            'id_petugas'     => 'PET-771',
        ]);
    }

    // 13. duplicate active member is rejected
    public function test_duplicate_active_member_is_rejected(): void
    {
        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-772'],
            [
                'id_tim'         => $this->timA->id_tim,
                'id_petugas'     => $this->petugas->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson("/api/tim/{$this->timA->id_tim}/anggota", [
                'id_petugas' => $this->petugas->id_petugas,
            ]);

        $response->assertStatus(422)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Petugas sudah menjadi anggota aktif pada tim ini.',
            ]);
    }

    // 14. invalid team for member returns 404
    public function test_invalid_team_for_member_returns_404(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/tim/TIM-NONEXISTENT/anggota', [
                'id_petugas' => $this->petugas->id_petugas,
            ]);

        $response->assertStatus(404)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Data tim tidak ditemukan',
            ]);
    }

    // 15. invalid petugas for member returns 422
    public function test_invalid_petugas_for_member_returns_422(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson("/api/tim/{$this->timA->id_tim}/anggota", [
                'id_petugas' => 'PET-NONEXISTENT',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['id_petugas']);
    }

    // 16. admin can update member status
    public function test_admin_can_update_member_status(): void
    {
        $anggota = AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-773'],
            [
                'id_tim'         => $this->timA->id_tim,
                'id_petugas'     => $this->petugas->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->patchJson("/api/tim/{$this->timA->id_tim}/anggota/{$anggota->id_anggota_tim}", [
                'status_anggota' => 'nonaktif',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'status'  => 'success',
                'message' => 'Status anggota tim berhasil diperbarui',
                'data'    => [
                    'id_anggota_tim' => 'AT-773',
                    'status_anggota' => 'nonaktif',
                ],
            ]);

        $this->assertDatabaseHas('anggota_tim', [
            'id_anggota_tim' => 'AT-773',
            'status_anggota' => 'nonaktif',
        ]);
    }

    // 17. admin can remove/deactivate member
    public function test_admin_can_remove_deactivate_member(): void
    {
        $anggota = AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-774'],
            [
                'id_tim'         => $this->timA->id_tim,
                'id_petugas'     => $this->petugas->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->deleteJson("/api/tim/{$this->timA->id_tim}/anggota/{$anggota->id_anggota_tim}");

        $response->assertStatus(200)
            ->assertJson([
                'status'  => 'success',
                'message' => 'Anggota tim berhasil dinonaktifkan',
                'data'    => [
                    'id_anggota_tim' => 'AT-774',
                    'status_anggota' => 'nonaktif',
                ],
            ]);

        $this->assertDatabaseHas('anggota_tim', [
            'id_anggota_tim' => 'AT-774',
            'status_anggota' => 'nonaktif',
        ]);
    }

    // 18. masyarakat cannot manage members
    public function test_masyarakat_cannot_manage_members(): void
    {
        $token = $this->masyarakat->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson("/api/tim/{$this->timA->id_tim}/anggota", [
                'id_petugas' => $this->petugas->id_petugas,
            ]);

        $response->assertStatus(403);
    }

    // 19. petugas cannot manage members
    public function test_petugas_cannot_manage_members(): void
    {
        $token = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson("/api/tim/{$this->timA->id_tim}/anggota", [
                'id_petugas' => $this->petugas->id_petugas,
            ]);

        $response->assertStatus(403);
    }

    // 20. ketua tim cannot manage members
    public function test_ketua_tim_cannot_manage_members(): void
    {
        $token = $this->ketuaTim->createToken('auth', ['ketua_tim'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson("/api/tim/{$this->timA->id_tim}/anggota", [
                'id_petugas' => $this->petugas->id_petugas,
            ]);

        $response->assertStatus(403);
    }

    // 21. response does not expose sensitive petugas data
    public function test_response_does_not_expose_sensitive_petugas_data(): void
    {
        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-775'],
            [
                'id_tim'         => $this->timA->id_tim,
                'id_petugas'     => $this->petugas->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson("/api/tim/{$this->timA->id_tim}/anggota");

        $response->assertStatus(200);

        $jsonString = json_encode($response->json());
        $this->assertStringNotContainsString('password', $jsonString);
        $this->assertStringNotContainsString('remember_token', $jsonString);
    }
}
