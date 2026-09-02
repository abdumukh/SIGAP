<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\Armada;
use App\Models\Pengguna;
use App\Models\Penanganan;
use App\Models\Penugasan;
use App\Models\Petugas;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * End-to-end integration test for SIGAP operasional flow.
 *
 * Simulates the complete lifecycle as defined in MASTER_SPECIFICATION:
 *
 *   MASYARAKAT  -> POST /api/auth/login
 *               -> POST /api/alarms
 *   ADMIN       -> POST /api/auth/login
 *               -> POST /api/alarms/{id}/verify
 *               -> POST /api/penugasan
 *   KETUA TIM   -> POST /api/auth/login
 *               -> GET  /api/penugasan
 *   PETUGAS     -> POST /api/auth/login
 *               -> POST /api/penanganan
 *               -> PATCH /api/penanganan/{id} (transition ke di_lokasi, selesai)
 *               -> POST /api/dokumentasi
 *               -> POST /api/korban
 *               -> POST /api/logistik
 *   ADMIN       -> GET  /api/monitoring (verifies statistik reflect actual data)
 *   ADMIN       -> GET  /api/laporan?type=alarm (verifies rekap data)
 *
 * Uses the seeded demo accounts (masyarakat@sigap.test, admin@sigap.test, etc).
 */
class EndToEndFlowTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    public function test_full_operational_flow_login_alarm_verify_penugasan_penanganan_monitoring(): void
    {
        // === STEP 1: MASYARAKAT LOGIN ===
        $loginMasyarakat = $this->postJson('/api/auth/login', [
            'email'    => 'masyarakat@sigap.test',
            'password' => 'Sigap123!',
        ]);
        $loginMasyarakat->assertStatus(200)
            ->assertJson(['data' => ['actor' => 'masyarakat']]);
        $tokenMasyarakat = $loginMasyarakat->json('data.token');
        $this->assertNotEmpty($tokenMasyarakat);

        // === STEP 2: MASYARAKAT GET PROFILE ===
        $this->withHeader('Authorization', 'Bearer ' . $tokenMasyarakat)
            ->getJson('/api/auth/me')
            ->assertStatus(200)
            ->assertJson(['data' => ['actor' => 'masyarakat']]);

        // === STEP 3: MASYARAKAT CREATE ALARM ===
        $alarmResponse = $this->withHeader('Authorization', 'Bearer ' . $tokenMasyarakat)
            ->postJson('/api/alarms', [
                'jenis_darurat' => 'Kebakaran',
                'latitude'      => -6.2088000,
                'longitude'     => 106.8456000,
                'cuaca'         => 'Cerah',
                'lalu_lintas'   => 'Lancar',
            ]);
        $alarmResponse->assertStatus(201)
            ->assertJson(['data' => ['status_alarm' => 'menunggu']]);
        $alarmId = $alarmResponse->json('data.id_alarm');
        $this->assertStringStartsWith('ALM-', $alarmId);

        // === STEP 4: ADMIN LOGIN ===
        $loginAdmin = $this->postJson('/api/auth/login', [
            'email'    => 'admin@sigap.test',
            'password' => 'Sigap123!',
        ]);
        $loginAdmin->assertStatus(200)
            ->assertJson(['data' => ['actor' => 'admin']]);
        $tokenAdmin = $loginAdmin->json('data.token');

        // === STEP 5: ADMIN VERIFY ALARM ===
        $verifyResponse = $this->withHeader('Authorization', 'Bearer ' . $tokenAdmin)
            ->postJson("/api/alarms/{$alarmId}/verify");
        $verifyResponse->assertStatus(200)
            ->assertJson(['data' => ['status_alarm' => 'diverifikasi']]);

        // === STEP 6: ADMIN CREATE PENUGASAN ===
        // Use seeded TIM-001 with PET-001 (ketua) and PET-002 (petugas) already as anggota
        $penugasanResponse = $this->withHeader('Authorization', 'Bearer ' . $tokenAdmin)
            ->postJson('/api/penugasan', [
                'id_alarm'         => $alarmId,
                'id_tim'           => 'TIM-001',
                'id_ketua_tim'     => 'PET-001',
                'id_petugas_armada' => 'PET-002',
                'id_armada'         => 'ARM-001',
                'waktu_penugasan'   => now()->toIso8601String(),
                'status_penugasan'  => 'menunggu',
            ]);
        $penugasanResponse->assertStatus(201);
        $penugasanId = $penugasanResponse->json('data.id_penugasan');
        $this->assertStringStartsWith('TGS-', $penugasanId);

        // === STEP 7: KETUA TIM LOGIN ===
        $loginKT = $this->postJson('/api/auth/login', [
            'email'    => 'ketua@sigap.test',
            'password' => 'Sigap123!',
        ]);
        $loginKT->assertStatus(200)
            ->assertJson(['data' => ['actor' => 'ketua_tim']]);
        $tokenKT = $loginKT->json('data.token');

        // Ketua tim should see the assignment via /api/penugasan
        $this->withHeader('Authorization', 'Bearer ' . $tokenKT)
            ->getJson('/api/penugasan')
            ->assertStatus(200)
            ->assertJsonFragment(['id_penugasan' => $penugasanId]);

        // === STEP 8: PETUGAS LOGIN ===
        $loginPT = $this->postJson('/api/auth/login', [
            'email'    => 'petugas@sigap.test',
            'password' => 'Sigap123!',
        ]);
        $loginPT->assertStatus(200)
            ->assertJson(['data' => ['actor' => 'petugas']]);
        $tokenPT = $loginPT->json('data.token');

        // === STEP 9: PETUGAS CREATE PENANGANAN ===
        $penangananResponse = $this->withHeader('Authorization', 'Bearer ' . $tokenPT)
            ->postJson('/api/penanganan', [
                'id_penugasan'      => $penugasanId,
                'waktu_berangkat'   => now()->toIso8601String(),
                'status_penanganan' => 'menuju_lokasi',
                'note'              => 'Tim sedang menuju lokasi',
            ]);
        $penangananResponse->assertStatus(201);
        $penangananId = $penangananResponse->json('data.id_penanganan');
        $this->assertStringStartsWith('PNG-', $penangananId);

        // === STEP 10: PETUGAS TRANSITION PENANGANAN ke di_lokasi ===
        $this->withHeader('Authorization', 'Bearer ' . $tokenPT)
            ->patchJson("/api/penanganan/{$penangananId}", [
                'status_penanganan' => 'di_lokasi',
            ])
            ->assertStatus(200)
            ->assertJsonFragment(['status_penanganan' => 'di_lokasi']);

        // === STEP 11: PETUGAS UPLOAD DOKUMENTASI ===
        $this->withHeader('Authorization', 'Bearer ' . $tokenPT)
            ->postJson('/api/dokumentasi', [
                'id_penanganan'     => $penangananId,
                'jenis_dokumentasi' => 'foto',
                'file_dokumentasi'  => 'integration_test_doc_001.jpg',
                'waktu_upload'      => now()->toIso8601String(),
                'note'              => 'Foto dokumentasi E2E',
            ])
            ->assertStatus(201);

        // === STEP 12: PETUGAS ADD KORBAN ===
        $this->withHeader('Authorization', 'Bearer ' . $tokenPT)
            ->postJson('/api/korban', [
                'id_penanganan'    => $penangananId,
                'nama_korban'      => 'Korban E2E',
                'jenis_kelamin'    => 'L',
                'usia'             => 30,
                'kondisi'          => 'Luka ringan',
                'status_penanganan'=> 'Ditangani',
                'note'             => null,
            ])
            ->assertStatus(201);

        // === STEP 13: PETUGAS ADD LOGISTIK ===
        $this->withHeader('Authorization', 'Bearer ' . $tokenPT)
            ->postJson('/api/logistik', [
                'id_penanganan' => $penangananId,
                'nama_logistik' => 'Tenda E2E',
                'jumlah'        => 5,
                'satuan'        => 'unit',
                'kondisi'       => 'Baik',
                'note'          => null,
            ])
            ->assertStatus(201);

        // === STEP 14: PETUGAS TRANSITION PENANGANAN ke selesai ===
        $this->withHeader('Authorization', 'Bearer ' . $tokenPT)
            ->patchJson("/api/penanganan/{$penangananId}", [
                'status_penanganan' => 'selesai',
            ])
            ->assertStatus(200)
            ->assertJsonFragment(['status_penanganan' => 'selesai']);

        // === STEP 15: ADMIN VERIFY MONITORING REFLECTS DATA ===
        // Note: seeded ALM-001 (diverifikasi) + new ALM-xxx (diverifikasi) = 2 total
        // We don't assert exact total since seeded data exists; we just verify response structure.
        $monitoringResponse = $this->withHeader('Authorization', 'Bearer ' . $tokenAdmin)
            ->getJson('/api/monitoring');
        $monitoringResponse->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'statistik' => [
                        'total_alarm',
                        'alarm_by_status',
                        'alarm_by_jenis',
                        'penugasan_aktif',
                        'penanganan_aktif',
                        'penanganan_selesai',
                        'total_korban',
                        'total_logistik',
                    ],
                    'active_operations',
                ],
            ]);
        $this->assertGreaterThanOrEqual(1, $monitoringResponse->json('data.statistik.penanganan_selesai'),
            'Penanganan selesai should reflect actual data');

        // === STEP 16: ADMIN VERIFY LAPORAN ALARM ===
        $laporanAlarm = $this->withHeader('Authorization', 'Bearer ' . $tokenAdmin)
            ->getJson('/api/laporan?type=alarm');
        $laporanAlarm->assertStatus(200);
        $laporanItems = $laporanAlarm->json('data.items');
        $this->assertIsArray($laporanItems);
        $this->assertNotEmpty($laporanItems, 'Laporan alarm should not be empty');
        $alarmIds = array_column($laporanItems, 'id_alarm');
        $this->assertContains($alarmId, $alarmIds, 'Laporan should include the newly created alarm');

        // === STEP 17: MASYARAKAT VERIFY ROLE-LEVEL ISOLATION ON MONITORING ===
        // Masyarakat should be DENIED access to /api/monitoring (403)
        $this->withHeader('Authorization', 'Bearer ' . $tokenMasyarakat)
            ->getJson('/api/monitoring')
            ->assertStatus(403);

        // === STEP 18: MASYARAKAT VERIFY ROLE-LEVEL ISOLATION ON LAPORAN PENUGASAN ===
        // Masyarakat should be DENIED access to /api/laporan?type=penugasan (403)
        $this->withHeader('Authorization', 'Bearer ' . $tokenMasyarakat)
            ->getJson('/api/laporan?type=penugasan')
            ->assertStatus(403);

        // === STEP 19: VERIFY UNAUTHENTICATED ACCESS IS REJECTED ===
        $this->getJson('/api/monitoring')
            ->assertStatus(401);
        $this->getJson('/api/laporan?type=alarm')
            ->assertStatus(401);
    }

    public function test_logout_invalidates_token_end_to_end(): void
    {
        // Login admin
        $login = $this->postJson('/api/auth/login', [
            'email'    => 'admin@sigap.test',
            'password' => 'Sigap123!',
        ]);
        $token = $login->json('data.token');

        // Profile works while authenticated
        $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/auth/me')
            ->assertStatus(200);

        // Logout
        $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/auth/logout')
            ->assertStatus(200);

        // Profile now fails (token revoked)
        $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/auth/me')
            ->assertStatus(401);
    }

    public function test_invalid_token_yields_401(): void
    {
        $this->withHeader('Authorization', 'Bearer INVALID-TOKEN-12345')
            ->getJson('/api/auth/me')
            ->assertStatus(401);
    }

    public function test_all_four_roles_can_login_and_resolve_actor(): void
    {
        $accounts = [
            ['email' => 'masyarakat@sigap.test', 'actor' => 'masyarakat'],
            ['email' => 'admin@sigap.test', 'actor' => 'admin'],
            ['email' => 'ketua@sigap.test', 'actor' => 'ketua_tim'],
            ['email' => 'petugas@sigap.test', 'actor' => 'petugas'],
        ];

        foreach ($accounts as $account) {
            $login = $this->postJson('/api/auth/login', [
                'email'    => $account['email'],
                'password' => 'Sigap123!',
            ]);
            $login->assertStatus(200)
                ->assertJson(['data' => ['actor' => $account['actor']]]);
            $token = $login->json('data.token');

            $me = $this->withHeader('Authorization', 'Bearer ' . $token)
                ->getJson('/api/auth/me');
            $me->assertStatus(200)
                ->assertJson(['data' => ['actor' => $account['actor']]]);
        }
    }
}
