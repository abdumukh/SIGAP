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

class MonitoringTest extends TestCase
{
    use RefreshDatabase;

    protected Pengguna $userA;
    protected Admin $admin;
    protected Petugas $ketuaTim;
    protected Petugas $petugas;
    protected Petugas $petugasB;
    protected Tim $tim;
    protected Armada $armada;
    protected Alarm $alarm;
    protected Penugasan $penugasan;
    protected Penanganan $penanganan;

    protected function setUp(): void
    {
        parent::setUp();

        $this->userA = Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-901'],
            [
                'nama'     => 'Masyarakat User A',
                'email'    => 'usera901@example.com',
                'password' => Hash::make('password123'),
                'no_hp'    => '081234567901',
                'alamat'   => 'Jl. Test A No. 1',
            ]
        );

        $this->admin = Admin::firstOrCreate(
            ['id_admin' => 'ADM-901'],
            [
                'nama_admin' => 'Admin Test 901',
                'email'      => 'admin901@sigap.go.id',
                'password'   => Hash::make('admin123'),
                'no_hp'      => '081198765901',
            ]
        );

        $this->ketuaTim = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-KT-901'],
            [
                'nama_petugas'   => 'Ketua Tim Test',
                'email'          => 'ketua901@sigap.go.id',
                'password'       => Hash::make('petugas123'),
                'no_hp'          => '085255667901',
                'alamat'         => 'Posko Test 901',
                'status_petugas' => 'aktif',
                'role'           => 'ketua_tim',
            ]
        );

        $this->petugas = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-PG-901'],
            [
                'nama_petugas'   => 'Petugas Test',
                'email'          => 'petugas901@sigap.go.id',
                'password'       => Hash::make('petugas123'),
                'no_hp'          => '085355667901',
                'alamat'         => 'Posko Test 902',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->petugasB = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-PG-902'],
            [
                'nama_petugas'   => 'Petugas B Test',
                'email'          => 'petugasb902@sigap.go.id',
                'password'       => Hash::make('petugas123'),
                'no_hp'          => '085455667902',
                'alamat'         => 'Posko Test 903',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->tim = Tim::firstOrCreate(
            ['id_tim' => 'TIM-901'],
            [
                'nama_tim'   => 'Tim Evakuasi 1',
                'note'       => 'Tim penanganan banjir',
                'status_tim' => 'aktif',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AGT-901'],
            [
                'id_tim'         => $this->tim->id_tim,
                'id_petugas'     => $this->ketuaTim->id_petugas,
                'role_tim' => 'ketua', 'tanggal_masuk' => now()->toDateString(), 'status_anggota' => 'aktif',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AGT-902'],
            [
                'id_tim'         => $this->tim->id_tim,
                'id_petugas'     => $this->petugas->id_petugas,
                'role_tim'       => 'anggota',
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $this->armada = Armada::firstOrCreate(
            ['id_armada' => 'ARM-901'],
            [
                'nama_armada'     => 'Truk Evakuasi 1',
                'jenis_armada'    => 'Truk',
                'nomor_kendaraan' => 'B 1234 ABC',
                'status_armada'   => 'tersedia',
                'note'            => null,
            ]
        );

        $this->alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-901'],
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
            ['id_penugasan' => 'TGS-901'],
            [
                'id_alarm'          => $this->alarm->id_alarm,
                'id_tim'            => $this->tim->id_tim,
                'id_petugas_armada' => $this->petugas->id_petugas,
                'id_armada'         => $this->armada->id_armada,
                'id_ketua_tim'      => $this->ketuaTim->id_petugas,
                'waktu_penugasan'   => now(),
                'status_penugasan'  => 'diterima',
                'note'              => null,
            ]
        );

        $this->penanganan = Penanganan::firstOrCreate(
            ['id_penanganan' => 'PNG-901'],
            [
                'id_alarm'        => $this->alarm->id_alarm,
                'id_penugasan'    => $this->penugasan->id_penugasan,
                'id_petugas'      => $this->petugas->id_petugas,
                'waktu_berangkat' => now()->subHour(),
                'waktu_tiba'      => now()->subMinutes(30),
                'status_penanganan' => 'di_lokasi',
                'note'            => 'Penanganan berlangsung',
            ]
        );

        Dokumentasi::firstOrCreate(
            ['id_dokumentasi' => 'DOC-901'],
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
            ['id_korban' => 'KBN-901'],
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
            ['id_logistik' => 'LOG-901'],
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

    public function test_unauthenticated_cannot_access_monitoring(): void
    {
        $response = $this->getJson('/api/monitoring');

        $response->assertStatus(401);
    }

    public function test_masyarakat_cannot_access_monitoring(): void
    {
        $token = $this->userA->createToken('auth', ['masyarakat'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring');

        $response->assertStatus(403)
            ->assertJson([
                'status'  => 'error',
                'message' => 'Forbidden. Anda tidak memiliki akses ke monitoring.',
            ]);
    }

    public function test_admin_can_access_monitoring(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring');

        $response->assertStatus(200)
            ->assertJson([
                'status'  => 'success',
                'message' => 'Data monitoring berhasil diambil',
            ]);

        $data = $response->json('data');
        $this->assertArrayHasKey('statistik', $data);
        $this->assertArrayHasKey('active_operations', $data);
        $this->assertEquals(1, $data['statistik']['total_alarm']);
        $this->assertEquals(1, $data['statistik']['penugasan_aktif']);
        $this->assertEquals(1, $data['statistik']['penanganan_aktif']);
        $this->assertEquals(0, $data['statistik']['penanganan_selesai']);
        $this->assertEquals(1, $data['statistik']['total_korban']);
        $this->assertEquals(10, $data['statistik']['total_logistik']);
    }

    public function test_ketua_tim_can_access_monitoring(): void
    {
        $token = $this->ketuaTim->createToken('auth', ['ketua_tim'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring');

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);

        $data = $response->json('data');
        $this->assertArrayHasKey('statistik', $data);
        $this->assertEquals(1, $data['statistik']['total_alarm']);
    }

    public function test_petugas_can_access_monitoring(): void
    {
        $token = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring');

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);
    }

    public function test_ketua_tim_only_sees_own_team_data(): void
    {
        // Create another team with different alarm
        $timB = Tim::firstOrCreate(
            ['id_tim' => 'TIM-902'],
            [
                'nama_tim'   => 'Tim Pemadam',
                'note'       => 'Tim kebakaran',
                'status_tim' => 'aktif',
            ]
        );

        $alarmB = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-902'],
            [
                'id_pengguna'   => $this->userA->id_pengguna,
                'jenis_darurat' => 'Kebakaran',
                'waktu_alarm'   => now(),
                'latitude'      => -6.3000000,
                'longitude'     => 106.9000000,
                'status_alarm'  => 'diverifikasi',
            ]
        );

        Penugasan::firstOrCreate(
            ['id_penugasan' => 'TGS-902'],
            [
                'id_alarm'          => $alarmB->id_alarm,
                'id_tim'            => $timB->id_tim,
                'id_ketua_tim'      => $this->ketuaTim->id_petugas,
                'waktu_penugasan'   => now(),
                'status_penugasan'  => 'diterima',
                'note'              => null,
            ]
        );

        Penanganan::firstOrCreate(
            ['id_penanganan' => 'PNG-902'],
            [
                'id_alarm'        => $alarmB->id_alarm,
                'id_penugasan'    => 'TGS-902',
                'id_petugas'      => $this->petugas->id_petugas,
                'status_penanganan' => 'menuju_lokasi',
            ]
        );

        $token = $this->ketuaTim->createToken('auth', ['ketua_tim'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring');

        $response->assertStatus(200);

        $data = $response->json('data');
        // Ketua Tim should see both alarms since they are ketua of both
        $this->assertEquals(2, $data['statistik']['total_alarm']);
    }

    public function test_petugas_only_sees_assigned_data(): void
    {
        // Create another alarm assigned to petugasB
        $timB = Tim::firstOrCreate(
            ['id_tim' => 'TIM-902'],
            [
                'nama_tim'   => 'Tim Pemadam',
                'note'       => 'Tim kebakaran',
                'status_tim' => 'aktif',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AGT-903'],
            [
                'id_tim'         => $timB->id_tim,
                'id_petugas'     => $this->petugasB->id_petugas,
                'role_tim'       => 'anggota',
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $alarmB = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-902'],
            [
                'id_pengguna'   => $this->userA->id_pengguna,
                'jenis_darurat' => 'Kebakaran',
                'waktu_alarm'   => now(),
                'latitude'      => -6.3000000,
                'longitude'     => 106.9000000,
                'status_alarm'  => 'diverifikasi',
            ]
        );

        Penugasan::firstOrCreate(
            ['id_penugasan' => 'TGS-902'],
            [
                'id_alarm'          => $alarmB->id_alarm,
                'id_tim'            => $timB->id_tim,
                'id_ketua_tim'      => $this->ketuaTim->id_petugas,
                'id_petugas_armada' => $this->petugasB->id_petugas,
                'id_armada'         => $this->armada->id_armada,
                'waktu_penugasan'   => now(),
                'status_penugasan'  => 'diterima',
                'note'              => null,
            ]
        );

        Penanganan::firstOrCreate(
            ['id_penanganan' => 'PNG-902'],
            [
                'id_alarm'        => $alarmB->id_alarm,
                'id_penugasan'    => 'TGS-902',
                'id_petugas'      => $this->petugasB->id_petugas,
                'status_penanganan' => 'menuju_lokasi',
            ]
        );

        $token = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring');

        $response->assertStatus(200);

        $data = $response->json('data');
        // Petugas should only see their assigned data (ALM-901)
        $this->assertEquals(1, $data['statistik']['total_alarm']);
    }

    public function test_monitoring_filter_start_date(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $tomorrow = now()->addDay()->format('Y-m-d');
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring?start_date=' . $tomorrow);

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals(0, $data['statistik']['total_alarm']);
    }

    public function test_monitoring_filter_end_date(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $yesterday = now()->subDay()->format('Y-m-d');
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring?end_date=' . $yesterday);

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals(0, $data['statistik']['total_alarm']);
    }

    public function test_monitoring_filter_status(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring?status=diverifikasi');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals(1, $data['statistik']['total_alarm']);
        $this->assertEquals(1, $data['statistik']['alarm_by_status']['diverifikasi']);
    }

    public function test_monitoring_filter_jenis_darurat(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring?jenis_darurat=Banjir');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals(1, $data['statistik']['total_alarm']);
        $this->assertArrayHasKey('Banjir', $data['statistik']['alarm_by_jenis']);
    }

    public function test_monitoring_filter_id_tim(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring?id_tim=' . $this->tim->id_tim);

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals(1, $data['statistik']['total_alarm']);
    }

    public function test_monitoring_empty_result_no_error(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        // Use future date filter to get empty result
        $futureDate = now()->addYear()->format('Y-m-d');
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring?start_date=' . $futureDate);

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals(0, $data['statistik']['total_alarm']);
        $this->assertEquals(0, $data['statistik']['penugasan_aktif']);
        $this->assertEquals(0, $data['statistik']['penanganan_aktif']);
        $this->assertEquals(0, $data['statistik']['total_korban']);
        $this->assertEquals(0, $data['statistik']['total_logistik']);
        $this->assertIsArray($data['active_operations']);
        $this->assertEmpty($data['active_operations']);
    }

    public function test_monitoring_active_operations_structure(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertIsArray($data['active_operations']);
        $this->assertCount(1, $data['active_operations']);

        $op = $data['active_operations'][0];
        $this->assertEquals($this->alarm->id_alarm, $op['id_alarm']);
        $this->assertEquals('Banjir', $op['jenis_darurat']);
        $this->assertArrayHasKey('pelapor', $op);
        $this->assertArrayHasKey('penugasan', $op);
        $this->assertArrayHasKey('penanganan', $op);
    }

    public function test_monitoring_alarm_by_status_aggregation(): void
    {
        Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-902'],
            [
                'id_pengguna'   => $this->userA->id_pengguna,
                'jenis_darurat' => 'Kebakaran',
                'waktu_alarm'   => now(),
                'latitude'      => -6.3000000,
                'longitude'     => 106.9000000,
                'status_alarm'  => 'menunggu',
            ]
        );

        Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-903'],
            [
                'id_pengguna'   => $this->userA->id_pengguna,
                'jenis_darurat' => 'Pohon Tumbang',
                'waktu_alarm'   => now(),
                'latitude'      => -6.4000000,
                'longitude'     => 106.9500000,
                'status_alarm'  => 'selesai',
            ]
        );

        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals(3, $data['statistik']['total_alarm']);
        $this->assertEquals(1, $data['statistik']['alarm_by_status']['menunggu']);
        $this->assertEquals(1, $data['statistik']['alarm_by_status']['diverifikasi']);
        $this->assertEquals(0, $data['statistik']['alarm_by_status']['ditolak']);
        $this->assertEquals(1, $data['statistik']['alarm_by_status']['selesai']);
    }

    public function test_invalid_date_filter_handled(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/monitoring?start_date=invalid-date');

        $response->assertStatus(200); // Should not error, just ignore invalid
    }
}