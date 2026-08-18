<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\Pengguna;
use App\Models\Petugas;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AlarmTest extends TestCase
{
    use DatabaseTransactions;

    protected Pengguna $userA;
    protected Pengguna $userB;
    protected Admin $admin;
    protected Petugas $petugas;

    protected function setUp(): void
    {
        parent::setUp();

        $this->userA = Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-881'],
            [
                'nama'     => 'Masyarakat User A',
                'email'    => 'usera881@example.com',
                'password' => Hash::make('password123'),
                'no_hp'    => '081234567881',
                'alamat'   => 'Jl. Test A No. 1',
            ]
        );

        $this->userB = Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-882'],
            [
                'nama'     => 'Masyarakat User B',
                'email'    => 'userb882@example.com',
                'password' => Hash::make('password123'),
                'no_hp'    => '081234567882',
                'alamat'   => 'Jl. Test B No. 2',
            ]
        );

        $this->admin = Admin::firstOrCreate(
            ['id_admin' => 'ADM-881'],
            [
                'nama_admin' => 'Admin Test 881',
                'email'      => 'admin881@sigap.go.id',
                'password'   => Hash::make('admin123'),
                'no_hp'      => '081198765881',
            ]
        );

        $this->petugas = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-881'],
            [
                'nama_petugas'   => 'Petugas Test 881',
                'email'          => 'petugas881@sigap.go.id',
                'password'       => Hash::make('petugas123'),
                'no_hp'          => '085255667881',
                'alamat'         => 'Posko Test 881',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );
    }

    public function test_masyarakat_can_create_alarm(): void
    {
        $token = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/alarms', [
                'jenis_darurat' => 'Kebakaran',
                'latitude'      => -6.2088000,
                'longitude'     => 106.8456000,
                'cuaca'         => 'Cerah',
                'lalu_lintas'   => 'Lancar',
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'status'  => 'success',
                'message' => 'Alarm darurat berhasil dikirim',
                'data'    => [
                    'id_pengguna'   => 'USR-881',
                    'jenis_darurat' => 'Kebakaran',
                    'status_alarm'  => 'menunggu',
                ],
            ]);

        $this->assertDatabaseHas('alarm', [
            'id_pengguna'   => 'USR-881',
            'jenis_darurat' => 'Kebakaran',
        ]);

        $alarmId = $response->json('data.id_alarm');
        $this->assertStringStartsWith('ALM-', $alarmId);
    }

    public function test_unauthenticated_cannot_create_alarm(): void
    {
        $response = $this->postJson('/api/alarms', [
            'jenis_darurat' => 'Kebakaran',
            'latitude'      => -6.2088000,
            'longitude'     => 106.8456000,
        ]);

        $response->assertStatus(401);
    }

    public function test_masyarakat_can_list_own_alarms(): void
    {
        Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-881'],
            [
                'id_pengguna'   => 'USR-881',
                'jenis_darurat' => 'Banjir',
                'waktu_alarm'   => now(),
                'latitude'      => -6.2000000,
                'longitude'     => 106.8166660,
                'status_alarm'  => 'menunggu',
            ]
        );

        $tokenA = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenA)
            ->getJson('/api/alarms');

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);

        $data = $response->json('data');
        $this->assertIsArray($data);
        $ids = array_column($data, 'id_alarm');
        $this->assertContains('ALM-881', $ids);
    }

    public function test_masyarakat_cannot_see_other_masyarakat_alarms_in_list(): void
    {
        Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-882'],
            [
                'id_pengguna'   => 'USR-882',
                'jenis_darurat' => 'Pohon Tumbang',
                'waktu_alarm'   => now(),
                'latitude'      => -6.3000000,
                'longitude'     => 106.9000000,
                'status_alarm'  => 'menunggu',
            ]
        );

        $tokenA = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenA)
            ->getJson('/api/alarms');

        $response->assertStatus(200);
        $ids = array_column($response->json('data'), 'id_alarm');
        $this->assertNotContains('ALM-882', $ids);
    }

    public function test_masyarakat_can_view_own_alarm_detail(): void
    {
        Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-881'],
            [
                'id_pengguna'   => 'USR-881',
                'jenis_darurat' => 'Banjir',
                'waktu_alarm'   => now(),
                'latitude'      => -6.2000000,
                'longitude'     => 106.8166660,
                'status_alarm'  => 'menunggu',
            ]
        );

        $tokenA = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenA)
            ->getJson('/api/alarms/ALM-881');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'id_alarm'      => 'ALM-881',
                    'id_pengguna'   => 'USR-881',
                    'jenis_darurat' => 'Banjir',
                ],
            ]);
    }

    public function test_masyarakat_cannot_view_other_masyarakat_alarm_detail(): void
    {
        Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-882'],
            [
                'id_pengguna'   => 'USR-882',
                'jenis_darurat' => 'Pohon Tumbang',
                'waktu_alarm'   => now(),
                'latitude'      => -6.3000000,
                'longitude'     => 106.9000000,
                'status_alarm'  => 'menunggu',
            ]
        );

        $tokenA = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenA)
            ->getJson('/api/alarms/ALM-882');

        $response->assertStatus(403)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses ke alarm ini.',
            ]);
    }

    public function test_admin_can_view_all_alarms_and_details(): void
    {
        Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-882'],
            [
                'id_pengguna'   => 'USR-882',
                'jenis_darurat' => 'Pohon Tumbang',
                'waktu_alarm'   => now(),
                'latitude'      => -6.3000000,
                'longitude'     => 106.9000000,
                'status_alarm'  => 'menunggu',
            ]
        );

        $tokenAdmin = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        // Admin index list
        $indexResponse = $this->withHeader('Authorization', 'Bearer ' . $tokenAdmin)
            ->getJson('/api/alarms');

        $indexResponse->assertStatus(200);
        $ids = array_column($indexResponse->json('data'), 'id_alarm');
        $this->assertContains('ALM-882', $ids);

        // Admin show detail
        $showResponse = $this->withHeader('Authorization', 'Bearer ' . $tokenAdmin)
            ->getJson('/api/alarms/ALM-882');

        $showResponse->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'id_alarm' => 'ALM-882',
                ],
            ]);
    }

    public function test_validation_invalid_returns_422(): void
    {
        $tokenA = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenA)
            ->postJson('/api/alarms', [
                // Missing jenis_darurat, latitude, longitude
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['jenis_darurat', 'latitude', 'longitude']);
    }

    public function test_non_existing_alarm_returns_404(): void
    {
        $tokenA = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenA)
            ->getJson('/api/alarms/ALM-NONEXISTENT');

        $response->assertStatus(404)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Data alarm tidak ditemukan',
            ]);
    }

    public function test_response_does_not_expose_sensitive_data(): void
    {
        $tokenA = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenA)
            ->getJson('/api/alarms');

        $response->assertStatus(200);

        $jsonString = json_encode($response->json());
        $this->assertStringNotContainsString('password', $jsonString);
        $this->assertStringNotContainsString('remember_token', $jsonString);
    }

    // ==========================================
    // FASE 3.2: STATUS WORKFLOW TESTS
    // ==========================================

    public function test_petugas_can_verify_alarm(): void
    {
        $alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-883'],
            [
                'id_pengguna'   => 'USR-881',
                'jenis_darurat' => 'Kecelakaan Lalu Lintas',
                'waktu_alarm'   => now(),
                'latitude'      => -6.2100000,
                'longitude'     => 106.8500000,
                'status_alarm'  => 'menunggu',
            ]
        );

        $tokenPetugas = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenPetugas)
            ->postJson("/api/alarms/{$alarm->id_alarm}/verify");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'id_alarm'     => 'ALM-883',
                    'status_alarm' => 'diverifikasi',
                ],
            ]);

        $this->assertDatabaseHas('alarm', [
            'id_alarm'     => 'ALM-883',
            'status_alarm' => 'diverifikasi',
        ]);
    }

    public function test_petugas_can_reject_alarm(): void
    {
        $alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-884'],
            [
                'id_pengguna'   => 'USR-881',
                'jenis_darurat' => 'Laporan Palsu',
                'waktu_alarm'   => now(),
                'latitude'      => -6.2100000,
                'longitude'     => 106.8500000,
                'status_alarm'  => 'menunggu',
            ]
        );

        $tokenPetugas = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenPetugas)
            ->postJson("/api/alarms/{$alarm->id_alarm}/reject");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'id_alarm'     => 'ALM-884',
                    'status_alarm' => 'ditolak',
                ],
            ]);

        $this->assertDatabaseHas('alarm', [
            'id_alarm'     => 'ALM-884',
            'status_alarm' => 'ditolak',
        ]);
    }

    public function test_petugas_can_complete_verified_alarm(): void
    {
        $alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-885'],
            [
                'id_pengguna'   => 'USR-881',
                'jenis_darurat' => 'Kebakaran Ruko',
                'waktu_alarm'   => now(),
                'latitude'      => -6.2100000,
                'longitude'     => 106.8500000,
                'status_alarm'  => 'diverifikasi',
            ]
        );

        $tokenPetugas = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenPetugas)
            ->postJson("/api/alarms/{$alarm->id_alarm}/complete");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'id_alarm'     => 'ALM-885',
                    'status_alarm' => 'selesai',
                ],
            ]);

        $this->assertDatabaseHas('alarm', [
            'id_alarm'     => 'ALM-885',
            'status_alarm' => 'selesai',
        ]);
    }

    public function test_masyarakat_cannot_update_alarm_status(): void
    {
        $alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-886'],
            [
                'id_pengguna'   => 'USR-881',
                'jenis_darurat' => 'Banjir',
                'waktu_alarm'   => now(),
                'latitude'      => -6.2100000,
                'longitude'     => 106.8500000,
                'status_alarm'  => 'menunggu',
            ]
        );

        $tokenA = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenA)
            ->postJson("/api/alarms/{$alarm->id_alarm}/verify");

        $response->assertStatus(403);
    }

    public function test_invalid_status_transition_returns_422(): void
    {
        // Direct transition from menunggu -> selesai is invalid
        $alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-887'],
            [
                'id_pengguna'   => 'USR-881',
                'jenis_darurat' => 'Gempa',
                'waktu_alarm'   => now(),
                'latitude'      => -6.2100000,
                'longitude'     => 106.8500000,
                'status_alarm'  => 'menunggu',
            ]
        );

        $tokenPetugas = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenPetugas)
            ->postJson("/api/alarms/{$alarm->id_alarm}/complete");

        $response->assertStatus(422)
            ->assertJson(['status' => 'error']);
    }

    public function test_completed_alarm_cannot_be_modified(): void
    {
        $alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-888'],
            [
                'id_pengguna'   => 'USR-881',
                'jenis_darurat' => 'Banjir',
                'waktu_alarm'   => now(),
                'latitude'      => -6.2100000,
                'longitude'     => 106.8500000,
                'status_alarm'  => 'selesai',
            ]
        );

        $tokenPetugas = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenPetugas)
            ->postJson("/api/alarms/{$alarm->id_alarm}/verify");

        $response->assertStatus(422)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Alarm yang sudah selesai tidak dapat diubah kembali.',
            ]);
    }

    public function test_rejected_alarm_cannot_be_reprocessed(): void
    {
        $alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-889'],
            [
                'id_pengguna'   => 'USR-881',
                'jenis_darurat' => 'Laporan Palsu',
                'waktu_alarm'   => now(),
                'latitude'      => -6.2100000,
                'longitude'     => 106.8500000,
                'status_alarm'  => 'ditolak',
            ]
        );

        $tokenPetugas = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenPetugas)
            ->postJson("/api/alarms/{$alarm->id_alarm}/verify");

        $response->assertStatus(422)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Alarm yang sudah ditolak tidak dapat diproses kembali.',
            ]);
    }

    public function test_unauthenticated_cannot_access_status_endpoints(): void
    {
        $response = $this->postJson('/api/alarms/ALM-881/verify');

        $response->assertStatus(401);
    }

    public function test_admin_can_update_status_following_policy(): void
    {
        $alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-890'],
            [
                'id_pengguna'   => 'USR-881',
                'jenis_darurat' => 'Banjir Bandang',
                'waktu_alarm'   => now(),
                'latitude'      => -6.2100000,
                'longitude'     => 106.8500000,
                'status_alarm'  => 'menunggu',
            ]
        );

        $tokenAdmin = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $tokenAdmin)
            ->postJson("/api/alarms/{$alarm->id_alarm}/verify");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data'   => [
                    'id_alarm'     => 'ALM-890',
                    'status_alarm' => 'diverifikasi',
                ],
            ]);
    }
}
