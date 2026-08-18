<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\AnggotaTim;
use App\Models\Armada;
use App\Models\Pengguna;
use App\Models\Penanganan;
use App\Models\Penugasan;
use App\Models\Petugas;
use App\Models\Tim;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class PenangananTest extends TestCase
{
    use RefreshDatabase;

    protected Admin $admin;
    protected Pengguna $masyarakat;
    protected Petugas $ketuaTim;
    protected Petugas $petugasArmada;
    protected Petugas $petugasLain;
    protected Tim $tim;
    protected Alarm $alarm;
    protected Armada $armada;
    protected Penugasan $penugasan;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = Admin::firstOrCreate(
            ['id_admin' => 'ADM-991'],
            [
                'nama_admin' => 'Admin Penanganan 991',
                'email'      => 'adminpenanganan991@sigap.go.id',
                'password'   => Hash::make('password123'),
                'no_hp'      => '081199999991',
            ]
        );

        $this->masyarakat = Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-991'],
            [
                'nama'       => 'Masyarakat Penanganan 991',
                'email'      => 'masyarakat991@example.com',
                'password'   => Hash::make('password123'),
                'no_hp'      => '081299999991',
                'alamat'     => 'Jl. Penanganan No. 1',
            ]
        );

        $this->ketuaTim = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-991'],
            [
                'nama_petugas'   => 'Ketua Tim 991',
                'email'          => 'ketua991@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085299999991',
                'alamat'         => 'Posko SIGAP 991',
                'status_petugas' => 'aktif',
                'role'           => 'ketua_tim',
            ]
        );

        $this->petugasArmada = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-992'],
            [
                'nama_petugas'   => 'Petugas Armada 992',
                'email'          => 'petugas992@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085299999992',
                'alamat'         => 'Posko SIGAP 992',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->petugasLain = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-993'],
            [
                'nama_petugas'   => 'Petugas Lain 993',
                'email'          => 'petugas993@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085299999993',
                'alamat'         => 'Posko SIGAP 993',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->tim = Tim::firstOrCreate(
            ['id_tim' => 'TIM-991'],
            [
                'nama_tim'   => 'Tim Penanganan 991',
                'status_tim' => 'aktif',
                'note'       => 'Tim test penanganan',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-991'],
            [
                'id_tim'         => $this->tim->id_tim,
                'id_petugas'     => $this->ketuaTim->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-992'],
            [
                'id_tim'         => $this->tim->id_tim,
                'id_petugas'     => $this->petugasArmada->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $this->alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-991'],
            [
                'id_pengguna'   => $this->masyarakat->id_pengguna,
                'jenis_darurat' => 'Kebakaran',
                'waktu_alarm'   => now(),
                'latitude'      => -6.9100000,
                'longitude'     => 109.1100000,
                'cuaca'         => 'Cerah',
                'lalu_lintas'   => 'Lancar',
                'status_alarm'  => 'diverifikasi',
            ]
        );

        $this->armada = Armada::firstOrCreate(
            ['id_armada' => 'ARM-991'],
            [
                'nama_armada'     => 'Pemadam 991',
                'jenis_armada'    => 'Pemadam',
                'nomor_kendaraan' => 'G 991 SGP',
                'status_armada'   => 'digunakan',
                'note'            => 'Armada test',
            ]
        );

        $this->penugasan = Penugasan::firstOrCreate(
            ['id_penugasan' => 'TGS-991'],
            [
                'id_alarm'          => $this->alarm->id_alarm,
                'id_tim'            => $this->tim->id_tim,
                'id_ketua_tim'      => $this->ketuaTim->id_petugas,
                'id_petugas_armada' => $this->petugasArmada->id_petugas,
                'id_armada'         => $this->armada->id_armada,
                'waktu_penugasan'   => now(),
                'status_penugasan'  => 'menunggu',
                'note'              => 'Penugasan test penanganan',
            ]
        );
    }

    protected function adminToken(): string
    {
        return $this->admin->createToken('test', ['admin'])->plainTextToken;
    }

    protected function ketuaToken(): string
    {
        return $this->ketuaTim->createToken('test', ['ketua_tim'])->plainTextToken;
    }

    protected function petugasArmadaToken(): string
    {
        return $this->petugasArmada->createToken('test', ['petugas'])->plainTextToken;
    }

    protected function petugasLainToken(): string
    {
        return $this->petugasLain->createToken('test', ['petugas'])->plainTextToken;
    }

    protected function masyarakatToken(): string
    {
        return $this->masyarakat->createToken('test', ['masyarakat'])->plainTextToken;
    }

    /** Test 1: Petugas dapat membuat Penanganan dari Penugasan valid */
    public function test_petugas_can_create_penanganan_from_valid_penugasan(): void
    {
        $response = $this->withToken($this->petugasArmadaToken())->postJson('/api/penanganan', [
            'id_penugasan' => $this->penugasan->id_penugasan,
            'note'         => 'Meluncur ke lokasi',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.status_penanganan', 'menuju_lokasi')
            ->assertJsonPath('data.id_penugasan', $this->penugasan->id_penugasan);

        $this->assertNotNull($response->json('data.waktu_berangkat'));

        $this->assertDatabaseHas('penanganan', [
            'id_penugasan'      => $this->penugasan->id_penugasan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'status_penanganan' => 'menuju_lokasi',
        ]);
    }

    /** Test 2: Penanganan otomatis menggunakan id_alarm dari Penugasan */
    public function test_penanganan_automatically_uses_id_alarm_from_penugasan(): void
    {
        $response = $this->withToken($this->petugasArmadaToken())->postJson('/api/penanganan', [
            'id_penugasan' => $this->penugasan->id_penugasan,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.id_alarm', $this->alarm->id_alarm);

        $this->assertDatabaseHas('penanganan', [
            'id_penugasan' => $this->penugasan->id_penugasan,
            'id_alarm'     => $this->alarm->id_alarm,
        ]);
    }

    /** Test 3: Petugas yang tidak terkait dengan Penugasan tidak dapat membuat Penanganan */
    public function test_unrelated_petugas_cannot_create_penanganan(): void
    {
        $response = $this->withToken($this->petugasLainToken())->postJson('/api/penanganan', [
            'id_penugasan' => $this->penugasan->id_penugasan,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['id_penugasan']);
    }

    /** Test 4: Penugasan yang tidak ditemukan */
    public function test_non_existing_penugasan_returns_422(): void
    {
        $response = $this->withToken($this->petugasArmadaToken())->postJson('/api/penanganan', [
            'id_penugasan' => 'TGS-NOTFOUND',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['id_penugasan']);
    }

    /** Test 5: Penugasan yang sudah memiliki Penanganan tidak dapat dibuatkan Penanganan kedua */
    public function test_cannot_create_duplicate_penanganan_for_same_penugasan(): void
    {
        Penanganan::create([
            'id_penanganan'     => 'PNG-991',
            'id_alarm'          => $this->alarm->id_alarm,
            'id_penugasan'      => $this->penugasan->id_penugasan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'waktu_berangkat'   => now(),
            'status_penanganan' => 'menuju_lokasi',
        ]);

        $response = $this->withToken($this->petugasArmadaToken())->postJson('/api/penanganan', [
            'id_penugasan' => $this->penugasan->id_penugasan,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['id_penugasan']);
    }

    /** Test 6: Masyarakat tidak dapat membuat Penanganan */
    public function test_masyarakat_cannot_create_penanganan(): void
    {
        $response = $this->withToken($this->masyarakatToken())->postJson('/api/penanganan', [
            'id_penugasan' => $this->penugasan->id_penugasan,
        ]);

        $response->assertStatus(403);
    }

    /** Test 7: Admin tidak dapat menjalankan Penanganan atas nama Petugas */
    public function test_admin_cannot_create_penanganan(): void
    {
        $response = $this->withToken($this->adminToken())->postJson('/api/penanganan', [
            'id_penugasan' => $this->penugasan->id_penugasan,
        ]);

        $response->assertStatus(403);
    }

    /** Test 8: Petugas dapat melihat Penanganan yang memiliki akses */
    public function test_petugas_can_list_accessible_penanganan(): void
    {
        Penanganan::create([
            'id_penanganan'     => 'PNG-992',
            'id_alarm'          => $this->alarm->id_alarm,
            'id_penugasan'      => $this->penugasan->id_penugasan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'waktu_berangkat'   => now(),
            'status_penanganan' => 'menuju_lokasi',
        ]);

        $response = $this->withToken($this->petugasArmadaToken())->getJson('/api/penanganan');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success');

        $this->assertNotEmpty($response->json('data'));
    }

    /** Test 9: Data Penanganan yang tidak ada menghasilkan 404 */
    public function test_non_existing_penanganan_detail_returns_404(): void
    {
        $response = $this->withToken($this->petugasArmadaToken())->getJson('/api/penanganan/PNG-NOTFOUND');

        $response->assertStatus(404)
            ->assertJsonPath('message', 'Data penanganan tidak ditemukan');
    }

    /** Test 10: Status: menuju_lokasi -> di_lokasi berhasil */
    public function test_status_transition_from_menuju_lokasi_to_di_lokasi_succeeds(): void
    {
        $penanganan = Penanganan::create([
            'id_penanganan'     => 'PNG-993',
            'id_alarm'          => $this->alarm->id_alarm,
            'id_penugasan'      => $this->penugasan->id_penugasan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'waktu_berangkat'   => now(),
            'status_penanganan' => 'menuju_lokasi',
        ]);

        $response = $this->withToken($this->petugasArmadaToken())
            ->patchJson('/api/penanganan/' . $penanganan->id_penanganan, [
                'status_penanganan' => 'di_lokasi',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.status_penanganan', 'di_lokasi');
    }

    /** Test 11: Saat berubah ke di_lokasi, waktu_tiba harus terisi */
    public function test_waktu_tiba_is_set_when_status_changes_to_di_lokasi(): void
    {
        $penanganan = Penanganan::create([
            'id_penanganan'     => 'PNG-994',
            'id_alarm'          => $this->alarm->id_alarm,
            'id_penugasan'      => $this->penugasan->id_penugasan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'waktu_berangkat'   => now(),
            'status_penanganan' => 'menuju_lokasi',
        ]);

        $response = $this->withToken($this->petugasArmadaToken())
            ->patchJson('/api/penanganan/' . $penanganan->id_penanganan, [
                'status_penanganan' => 'di_lokasi',
            ]);

        $response->assertStatus(200);
        $this->assertNotNull($response->json('data.waktu_tiba'));

        $this->assertDatabaseHas('penanganan', [
            'id_penanganan' => $penanganan->id_penanganan,
            'status_penanganan' => 'di_lokasi',
        ]);

        $freshPenanganan = Penanganan::find($penanganan->id_penanganan);
        $this->assertNotNull($freshPenanganan->waktu_tiba);
    }

    /** Test 12: Status: di_lokasi -> selesai berhasil */
    public function test_status_transition_from_di_lokasi_to_selesai_succeeds(): void
    {
        $penanganan = Penanganan::create([
            'id_penanganan'     => 'PNG-995',
            'id_alarm'          => $this->alarm->id_alarm,
            'id_penugasan'      => $this->penugasan->id_penugasan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'waktu_berangkat'   => now(),
            'waktu_tiba'        => now(),
            'status_penanganan' => 'di_lokasi',
        ]);

        $response = $this->withToken($this->petugasArmadaToken())
            ->patchJson('/api/penanganan/' . $penanganan->id_penanganan, [
                'status_penanganan' => 'selesai',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.status_penanganan', 'selesai');
    }

    /** Test 13: Saat berubah ke selesai, waktu_selesai harus terisi */
    public function test_waktu_selesai_is_set_when_status_changes_to_selesai(): void
    {
        $penanganan = Penanganan::create([
            'id_penanganan'     => 'PNG-996',
            'id_alarm'          => $this->alarm->id_alarm,
            'id_penugasan'      => $this->penugasan->id_penugasan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'waktu_berangkat'   => now(),
            'waktu_tiba'        => now(),
            'status_penanganan' => 'di_lokasi',
        ]);

        $response = $this->withToken($this->petugasArmadaToken())
            ->patchJson('/api/penanganan/' . $penanganan->id_penanganan, [
                'status_penanganan' => 'selesai',
            ]);

        $response->assertStatus(200);
        $this->assertNotNull($response->json('data.waktu_selesai'));

        $freshPenanganan = Penanganan::find($penanganan->id_penanganan);
        $this->assertNotNull($freshPenanganan->waktu_selesai);
    }

    /** Test 14: Tidak boleh: menuju_lokasi -> selesai */
    public function test_invalid_transition_menuju_lokasi_to_selesai_returns_422(): void
    {
        $penanganan = Penanganan::create([
            'id_penanganan'     => 'PNG-997',
            'id_alarm'          => $this->alarm->id_alarm,
            'id_penugasan'      => $this->penugasan->id_penugasan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'waktu_berangkat'   => now(),
            'status_penanganan' => 'menuju_lokasi',
        ]);

        $response = $this->withToken($this->petugasArmadaToken())
            ->patchJson('/api/penanganan/' . $penanganan->id_penanganan, [
                'status_penanganan' => 'selesai',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['status_penanganan']);
    }

    /** Test 15: Tidak boleh: selesai -> di_lokasi */
    public function test_invalid_transition_selesai_to_di_lokasi_returns_422(): void
    {
        $penanganan = Penanganan::create([
            'id_penanganan'     => 'PNG-998',
            'id_alarm'          => $this->alarm->id_alarm,
            'id_penugasan'      => $this->penugasan->id_penugasan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'waktu_berangkat'   => now(),
            'waktu_tiba'        => now(),
            'waktu_selesai'     => now(),
            'status_penanganan' => 'selesai',
        ]);

        $response = $this->withToken($this->petugasArmadaToken())
            ->patchJson('/api/penanganan/' . $penanganan->id_penanganan, [
                'status_penanganan' => 'di_lokasi',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['status_penanganan']);
    }

    /** Test 16: Petugas lain tidak dapat mengubah Penanganan milik petugas lain */
    public function test_other_petugas_cannot_update_penanganan_belonging_to_another(): void
    {
        $penanganan = Penanganan::create([
            'id_penanganan'     => 'PNG-999',
            'id_alarm'          => $this->alarm->id_alarm,
            'id_penugasan'      => $this->penugasan->id_penugasan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'waktu_berangkat'   => now(),
            'status_penanganan' => 'menuju_lokasi',
        ]);

        $response = $this->withToken($this->petugasLainToken())
            ->patchJson('/api/penanganan/' . $penanganan->id_penanganan, [
                'status_penanganan' => 'di_lokasi',
            ]);

        $response->assertStatus(403);
    }

    /** Test 17: Admin dapat melihat daftar Penanganan apabila sesuai authorization project */
    public function test_admin_can_list_penanganan(): void
    {
        Penanganan::create([
            'id_penanganan'     => 'PNG-1000',
            'id_alarm'          => $this->alarm->id_alarm,
            'id_penugasan'      => $this->penugasan->id_penugasan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'waktu_berangkat'   => now(),
            'status_penanganan' => 'menuju_lokasi',
        ]);

        $response = $this->withToken($this->adminToken())->getJson('/api/penanganan');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success');

        $this->assertNotEmpty($response->json('data'));
    }

    /** Test 18: Admin dapat melihat detail Penanganan apabila sesuai authorization project */
    public function test_admin_can_view_penanganan_detail(): void
    {
        $penanganan = Penanganan::create([
            'id_penanganan'     => 'PNG-1001',
            'id_alarm'          => $this->alarm->id_alarm,
            'id_penugasan'      => $this->penugasan->id_penugasan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'waktu_berangkat'   => now(),
            'status_penanganan' => 'menuju_lokasi',
        ]);

        $response = $this->withToken($this->adminToken())->getJson('/api/penanganan/' . $penanganan->id_penanganan);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.id_penanganan', $penanganan->id_penanganan);
    }
}
