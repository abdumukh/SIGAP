<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\AnggotaTim;
use App\Models\Armada;
use App\Models\Dokumentasi;
use App\Models\Korban;
use App\Models\Logistik;
use App\Models\Pengguna;
use App\Models\Penanganan;
use App\Models\Penugasan;
use App\Models\Petugas;
use App\Models\Tim;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class LaporanTest extends TestCase
{
    use RefreshDatabase;

    protected Pengguna $userA;
    protected Admin $admin;
    protected Petugas $ketuaTim;
    protected Petugas $petugas;
    protected Tim $tim;
    protected Armada $armada;
    protected Alarm $alarm;
    protected Penugasan $penugasan;
    protected Penanganan $penanganan;

    protected function setUp(): void
    {
        parent::setUp();

        $this->userA = Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-801'],
            [
                'nama'     => 'Masyarakat User A',
                'email'    => 'usera801@example.com',
                'password' => Hash::make('password123'),
                'no_hp'    => '081234567801',
                'alamat'   => 'Jl. Test A No. 1',
            ]
        );

        $this->admin = Admin::firstOrCreate(
            ['id_admin' => 'ADM-801'],
            [
                'nama_admin' => 'Admin Test 801',
                'email'      => 'admin801@sigap.go.id',
                'password'   => Hash::make('admin123'),
                'no_hp'      => '081198765801',
            ]
        );

        $this->ketuaTim = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-KT-801'],
            [
                'nama_petugas'   => 'Ketua Tim Test',
                'email'          => 'ketua801@sigap.go.id',
                'password'       => Hash::make('petugas123'),
                'no_hp'          => '085255667801',
                'alamat'         => 'Posko Test 801',
                'status_petugas' => 'aktif',
                'role'           => 'ketua_tim',
            ]
        );

        $this->petugas = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-PG-801'],
            [
                'nama_petugas'   => 'Petugas Test',
                'email'          => 'petugas801@sigap.go.id',
                'password'       => Hash::make('petugas123'),
                'no_hp'          => '085355667801',
                'alamat'         => 'Posko Test 802',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->tim = Tim::firstOrCreate(
            ['id_tim' => 'TIM-801'],
            [
                'nama_tim'   => 'Tim Evakuasi 1',
                'note'       => 'Tim penanganan banjir',
                'status_tim' => 'aktif',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AGT-801'],
            [
                'id_tim'         => $this->tim->id_tim,
                'id_petugas'     => $this->ketuaTim->id_petugas,
                'role_tim'       => 'ketua',
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AGT-802'],
            [
                'id_tim'         => $this->tim->id_tim,
                'id_petugas'     => $this->petugas->id_petugas,
                'role_tim'       => 'anggota',
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $this->armada = Armada::firstOrCreate(
            ['id_armada' => 'ARM-801'],
            [
                'nama_armada'     => 'Truk Evakuasi 1',
                'jenis_armada'    => 'Truk',
                'nomor_kendaraan' => 'B 1234 ABC',
                'status_armada'   => 'tersedia',
                'note'            => null,
            ]
        );

        $this->alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-801'],
            [
                'id_pengguna'   => $this->userA->id_pengguna,
                'jenis_darurat' => 'Banjir',
                'waktu_alarm'   => now(),
                'latitude'      => -6.2000000,
                'longitude'     => 106.8166660,
                'cuaca'         => 'Hujan',
                'lalu_lintas'   => 'Macet',
                'status_alarm'  => 'diverifikasi',
            ]
        );

        $this->penugasan = Penugasan::firstOrCreate(
            ['id_penugasan' => 'TGS-801'],
            [
                'id_alarm'          => $this->alarm->id_alarm,
                'id_tim'            => $this->tim->id_tim,
                'id_petugas_armada' => $this->petugas->id_petugas,
                'id_armada'         => $this->armada->id_armada,
                'id_ketua_tim'      => $this->ketuaTim->id_petugas,
                'waktu_penugasan'   => now(),
                'status_penugasan'  => 'berangkat',
                'note'              => null,
            ]
        );

        $this->penanganan = Penanganan::firstOrCreate(
            ['id_penanganan' => 'PNG-801'],
            [
                'id_alarm'        => $this->alarm->id_alarm,
                'id_penugasan'    => $this->penugasan->id_penugasan,
                'id_petugas'      => $this->petugas->id_petugas,
                'waktu_berangkat' => now()->subHour(),
                'waktu_tiba'      => now()->subMinutes(30),
                'status_penanganan' => 'selesai',
                'note'            => 'Penanganan selesai',
            ]
        );

        Dokumentasi::firstOrCreate(
            ['id_dokumentasi' => 'DOC-801'],
            [
                'id_penanganan'   => $this->penanganan->id_penanganan,
                'id_petugas'      => $this->petugas->id_petugas,
                'jenis_dokumentasi' => 'foto',
                'file_dokumentasi'  => 'dokumentasi/test.jpg',
                'waktu_upload'      => now(),
                'note'              => 'Foto lokasi',
            ]
        );

        Korban::firstOrCreate(
            ['id_korban' => 'KBN-801'],
            [
                'id_penanganan' => $this->penanganan->id_penanganan,
                'nama_korban'   => 'Korban Test',
                'jenis_kelamin' => 'L',
                'usia'          => 30,
                'kondisi'       => 'Luka ringan',
                'status_penanganan' => 'Ditangani',
                'note'          => null,
            ]
        );

        Logistik::firstOrCreate(
            ['id_logistik' => 'LOG-801'],
            [
                'id_penanganan' => $this->penanganan->id_penanganan,
                'nama_logistik' => 'Tenda',
                'jumlah'        => 10,
                'satuan'        => 'unit',
                'kondisi'       => 'Baik',
                'note'          => null,
            ]
        );
    }

    public function test_unauthenticated_cannot_access_laporan(): void
    {
        $response = $this->getJson('/api/laporan?type=alarm');

        $response->assertStatus(401);
    }

    public function test_masyarakat_cannot_access_petugas_report(): void
    {
        $token = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=petugas');

        $response->assertStatus(403)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses ke laporan tipe petugas.',
            ]);
    }

    public function test_admin_can_access_all_laporan_types(): void
    {
        $types = ['alarm', 'penugasan', 'penanganan', 'pengguna', 'petugas'];

        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        foreach ($types as $type) {
            $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                ->getJson("/api/laporan?type={$type}");

            $response->assertStatus(200)
                ->assertJson([
                    'status'  => 'success',
                    'data'    => ['type' => $type],
                ]);
        }
    }

    public function test_ketua_tim_can_access_laporan_alarm_and_penugasan(): void
    {
        $token = $this->ketuaTim->createToken('auth', ['ketua_tim'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=alarm');

        $response->assertStatus(200);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=penugasan');

        $response->assertStatus(200);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=penanganan');

        $response->assertStatus(200);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=petugas');

        $response->assertStatus(200);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=pengguna');

        $response->assertStatus(403);
    }

    public function test_petugas_can_access_alarm_penugasan_penanganan(): void
    {
        $token = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $types = ['alarm', 'penugasan', 'penanganan'];

        foreach ($types as $type) {
            $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                ->getJson("/api/laporan?type={$type}");

            $response->assertStatus(200);
        }

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=petugas');

        $response->assertStatus(403);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=pengguna');

        $response->assertStatus(403);
    }

    public function test_masyarakat_can_access_alarm_and_penanganan(): void
    {
        $token = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $types = ['alarm', 'penanganan'];

        foreach ($types as $type) {
            $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                ->getJson("/api/laporan?type={$type}");

            $response->assertStatus(200);
        }

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=penugasan');

        $response->assertStatus(403);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=petugas');

        $response->assertStatus(403);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=pengguna');

        $response->assertStatus(403);
    }

    public function test_laporan_alarm_basic_filter(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=alarm&status=diverifikasi');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals('alarm', $data['type']);
        $this->assertEquals(1, $data['total']);
        $this->assertEquals($this->alarm->id_alarm, $data['items'][0]['id_alarm']);
        $this->assertEquals('Banjir', $data['items'][0]['jenis_darurat']);
    }

    public function test_laporan_penugasan_filter_jenis_darurat(): void
    {
        $token = $this->ketuaTim->createToken('auth', ['ketua_tim'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=penugasan');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals('penugasan', $data['type']);
        $this->assertEquals(1, $data['total']);
        $this->assertEquals($this->penugasan->id_penugasan, $data['items'][0]['id_penugasan']);
        $this->assertEquals('Banjir', $data['items'][0]['alarm']['jenis_darurat']);
    }

    public function test_laporan_penanganan_filter_tim(): void
    {
        $token = $this->ketuaTim->createToken('auth', ['ketua_tim'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=penanganan&id_tim=' . $this->tim->id_tim);

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals('penanganan', $data['type']);
        $this->assertEquals(1, $data['total']);
        $this->assertEquals($this->penanganan->id_penanganan, $data['items'][0]['id_penanganan']);
        $this->assertEquals('Banjir', $data['items'][0]['alarm']['jenis_darurat']);
    }

    public function test_laporan_pengguna_filter_date(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $today = now()->format('Y-m-d');

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson("/api/laporan?type=pengguna&start_date={$today}&end_date={$today}");

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals('pengguna', $data['type']);
        $this->assertGreaterThanOrEqual(1, $data['total']);

        $item = $data['items'][0];
        $this->assertEquals($this->userA->id_pengguna, $item['id_pengguna']);
    }

    public function test_laporan_petugas_filter_role(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=petugas&role=ketua_tim');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals('petugas', $data['type']);
        $this->assertGreaterThanOrEqual(1, $data['total']);

        $item = $data['items'][0];
        $this->assertEquals($this->ketuaTim->id_petugas, $item['id_petugas']);
        $this->assertEquals('ketua_tim', $item['role']);
    }

    public function test_laporan_empty_result_no_error(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=alarm&start_date=2099-01-01');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals('alarm', $data['type']);
        $this->assertEquals(0, $data['total']);
        $this->assertIsArray($data['items']);
        $this->assertEmpty($data['items']);
    }

    public function test_laporan_type_param_missing_returns_422(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan');

        $response->assertStatus(422)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Parameter type wajib diisi (alarm, penugasan, penanganan, pengguna, petugas).',
            ]);
    }

    public function test_invalid_type_returns_forbidden(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=invalid_type');

        $response->assertStatus(403);
    }

    public function test_laporan_alarm_authorization_scope_petugas(): void
    {
        $token = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=alarm');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals(1, $data['total']);
        $this->assertEquals($this->alarm->id_alarm, $data['items'][0]['id_alarm']);
    }

    public function test_laporan_penugasan_authorization_scope_ketua_tim(): void
    {
        $token = $this->ketuaTim->createToken('auth', ['ketua_tim'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=penugasan');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals(1, $data['total']);
        $this->assertEquals($this->penugasan->id_penugasan, $data['items'][0]['id_penugasan']);
    }

    public function test_laporan_penanganan_authorization_scope_masyarakat(): void
    {
        $token = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/laporan?type=penanganan');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals(1, $data['total']);
        $this->assertEquals($this->penanganan->id_penanganan, $data['items'][0]['id_penanganan']);
    }
}