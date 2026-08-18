<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\AnggotaTim;
use App\Models\Armada;
use App\Models\Dokumentasi;
use App\Models\Pengguna;
use App\Models\Penanganan;
use App\Models\Penugasan;
use App\Models\Petugas;
use App\Models\Tim;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class DokumentasiTest extends TestCase
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
    protected Penanganan $penanganan;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = Admin::firstOrCreate(
            ['id_admin' => 'ADM-701'],
            [
                'nama_admin' => 'Admin Dokumentasi 701',
                'email'      => 'admindok701@sigap.go.id',
                'password'   => Hash::make('password123'),
                'no_hp'      => '081170170170',
            ]
        );

        $this->masyarakat = Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-701'],
            [
                'nama'     => 'Masyarakat Dok 701',
                'email'    => 'masyarakat701@example.com',
                'password' => Hash::make('password123'),
                'no_hp'    => '081270170170',
                'alamat'   => 'Jl. Dok No. 1',
            ]
        );

        $this->ketuaTim = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-701'],
            [
                'nama_petugas'   => 'Ketua Tim Dok 701',
                'email'          => 'ketua701@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085270170170',
                'alamat'         => 'Posko SIGAP 701',
                'status_petugas' => 'aktif',
                'role'           => 'ketua_tim',
            ]
        );

        $this->petugasArmada = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-702'],
            [
                'nama_petugas'   => 'Petugas Armada 702',
                'email'          => 'petugas702@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085270170171',
                'alamat'         => 'Posko SIGAP 702',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->petugasLain = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-703'],
            [
                'nama_petugas'   => 'Petugas Lain 703',
                'email'          => 'petugas703@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085270170172',
                'alamat'         => 'Posko SIGAP 703',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->tim = Tim::firstOrCreate(
            ['id_tim' => 'TIM-701'],
            [
                'nama_tim'   => 'Tim Dokumentasi 701',
                'status_tim' => 'aktif',
                'note'       => 'Tim test dokumentasi',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-701'],
            [
                'id_tim'         => $this->tim->id_tim,
                'id_petugas'     => $this->ketuaTim->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-702'],
            [
                'id_tim'         => $this->tim->id_tim,
                'id_petugas'     => $this->petugasArmada->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $this->alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-701'],
            [
                'id_pengguna'   => $this->masyarakat->id_pengguna,
                'jenis_darurat' => 'Longsor',
                'waktu_alarm'   => now(),
                'latitude'      => -6.9200000,
                'longitude'     => 109.1200000,
                'cuaca'         => 'Hujan',
                'lalu_lintas'   => 'Padat',
                'status_alarm'  => 'diverifikasi',
            ]
        );

        $this->armada = Armada::firstOrCreate(
            ['id_armada' => 'ARM-701'],
            [
                'nama_armada'     => 'Ambulans 701',
                'jenis_armada'    => 'Ambulans',
                'nomor_kendaraan' => 'G 701 SGP',
                'status_armada'   => 'digunakan',
                'note'            => 'Armada test',
            ]
        );

        $this->penugasan = Penugasan::firstOrCreate(
            ['id_penugasan' => 'TGS-701'],
            [
                'id_alarm'          => $this->alarm->id_alarm,
                'id_tim'            => $this->tim->id_tim,
                'id_ketua_tim'      => $this->ketuaTim->id_petugas,
                'id_petugas_armada' => $this->petugasArmada->id_petugas,
                'id_armada'         => $this->armada->id_armada,
                'waktu_penugasan'   => now(),
                'status_penugasan'  => 'berangkat',
                'note'              => 'Penugasan test dokumentasi',
            ]
        );

        $this->penanganan = Penanganan::firstOrCreate(
            ['id_penanganan' => 'PNG-701'],
            [
                'id_alarm'          => $this->alarm->id_alarm,
                'id_penugasan'      => $this->penugasan->id_penugasan,
                'id_petugas'        => $this->petugasArmada->id_petugas,
                'waktu_berangkat'   => now(),
                'status_penanganan' => 'di_lokasi',
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

    /** Test 1: Petugas dapat membuat dokumentasi */
    public function test_petugas_can_create_dokumentasi(): void
    {
        $response = $this->withToken($this->petugasArmadaToken())->postJson('/api/dokumentasi', [
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'jenis_dokumentasi' => 'foto',
            'file_dokumentasi'  => 'dokumentasi/foto_lokasi_01.jpg',
            'note'              => 'Foto evakuasi di lokasi',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.jenis_dokumentasi', 'foto')
            ->assertJsonPath('data.id_penanganan', $this->penanganan->id_penanganan);

        $this->assertNotNull($response->json('data.waktu_upload'));

        $this->assertDatabaseHas('dokumentasi', [
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'jenis_dokumentasi' => 'foto',
            'file_dokumentasi'  => 'dokumentasi/foto_lokasi_01.jpg',
        ]);
    }

    /** Test 2: Ketua Tim yang terkait dapat membuat dokumentasi */
    public function test_ketua_tim_can_create_dokumentasi(): void
    {
        $response = $this->withToken($this->ketuaToken())->postJson('/api/dokumentasi', [
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'jenis_dokumentasi' => 'video',
            'file_dokumentasi'  => 'dokumentasi/video_evakuasi.mp4',
            'note'              => 'Video proses evakuasi',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.jenis_dokumentasi', 'video');
    }

    /** Test 3: Masyarakat tidak dapat membuat dokumentasi */
    public function test_masyarakat_cannot_create_dokumentasi(): void
    {
        $response = $this->withToken($this->masyarakatToken())->postJson('/api/dokumentasi', [
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'jenis_dokumentasi' => 'foto',
            'file_dokumentasi'  => 'dokumentasi/foto.jpg',
        ]);

        $response->assertStatus(403);
    }

    /** Test 4: Admin tidak dapat membuat dokumentasi */
    public function test_admin_cannot_create_dokumentasi(): void
    {
        $response = $this->withToken($this->adminToken())->postJson('/api/dokumentasi', [
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'jenis_dokumentasi' => 'foto',
            'file_dokumentasi'  => 'dokumentasi/foto.jpg',
        ]);

        $response->assertStatus(403);
    }

    /** Test 5: Penanganan yang tidak ditemukan mengembalikan 422 */
    public function test_invalid_penanganan_returns_422(): void
    {
        $response = $this->withToken($this->petugasArmadaToken())->postJson('/api/dokumentasi', [
            'id_penanganan'     => 'PNG-NOTFOUND',
            'jenis_dokumentasi' => 'foto',
            'file_dokumentasi'  => 'dokumentasi/foto.jpg',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['id_penanganan']);
    }

    /** Test 6: Petugas yang tidak terkait tidak dapat membuat dokumentasi */
    public function test_unrelated_petugas_cannot_create_dokumentasi(): void
    {
        $response = $this->withToken($this->petugasLainToken())->postJson('/api/dokumentasi', [
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'jenis_dokumentasi' => 'foto',
            'file_dokumentasi'  => 'dokumentasi/foto.jpg',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['id_penanganan']);
    }

    /** Test 7: User yang terotorisasi dapat melihat daftar dokumentasi */
    public function test_dokumentasi_can_be_listed_by_authorized_user(): void
    {
        Dokumentasi::create([
            'id_dokumentasi'    => 'DOC-701',
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'jenis_dokumentasi' => 'foto',
            'file_dokumentasi'  => 'dokumentasi/test.jpg',
            'waktu_upload'      => now(),
        ]);

        $response = $this->withToken($this->petugasArmadaToken())->getJson('/api/dokumentasi');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success');

        $this->assertNotEmpty($response->json('data'));
    }

    /** Test 8: User tidak terotorisasi (Masyarakat) tidak dapat mengakses daftar dokumentasi */
    public function test_unauthorized_user_cannot_access_dokumentasi(): void
    {
        $response = $this->withToken($this->masyarakatToken())->getJson('/api/dokumentasi');

        $response->assertStatus(403);
    }

    /** Test 9: Data dokumentasi yang tidak ada menghasilkan 404 */
    public function test_non_existing_dokumentasi_returns_404(): void
    {
        $response = $this->withToken($this->petugasArmadaToken())->getJson('/api/dokumentasi/DOC-NOTFOUND');

        $response->assertStatus(404)
            ->assertJsonPath('message', 'Data dokumentasi tidak ditemukan');
    }

    /** Test 10: Dokumentasi menyimpan relasi Penanganan dengan benar */
    public function test_dokumentasi_stores_correct_penanganan_relation(): void
    {
        $response = $this->withToken($this->petugasArmadaToken())->postJson('/api/dokumentasi', [
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'jenis_dokumentasi' => 'foto',
            'file_dokumentasi'  => 'dokumentasi/foto.jpg',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.penanganan.id_penanganan', $this->penanganan->id_penanganan);
    }

    /** Test 11: Validasi menolak data tidak valid */
    public function test_validation_rejects_invalid_data(): void
    {
        $response = $this->withToken($this->petugasArmadaToken())->postJson('/api/dokumentasi', [
            'id_penanganan' => $this->penanganan->id_penanganan,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['jenis_dokumentasi', 'file_dokumentasi']);
    }

    /** Test 12: Upload file fisik/fake dapat diproses */
    public function test_file_upload_validation_works(): void
    {
        Storage::fake('public');

        $file = UploadedFile::fake()->create('evakuasi.jpg', 100, 'image/jpeg');

        $response = $this->withToken($this->petugasArmadaToken())->postJson('/api/dokumentasi', [
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'jenis_dokumentasi' => 'foto',
            'file_dokumentasi'  => $file,
        ]);

        $response->assertStatus(201);
        $this->assertStringContainsString('dokumentasi/', $response->json('data.file_dokumentasi'));
    }

    /** Test 13: Pemilik dapat menghapus dokumentasinya sendiri */
    public function test_owner_can_delete_own_dokumentasi(): void
    {
        $dokumentasi = Dokumentasi::create([
            'id_dokumentasi'    => 'DOC-702',
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'jenis_dokumentasi' => 'foto',
            'file_dokumentasi'  => 'dokumentasi/test.jpg',
            'waktu_upload'      => now(),
        ]);

        $this->withToken($this->petugasArmadaToken())
            ->deleteJson('/api/dokumentasi/' . $dokumentasi->id_dokumentasi)
            ->assertStatus(200)
            ->assertJsonPath('status', 'success');

        $this->assertDatabaseMissing('dokumentasi', [
            'id_dokumentasi' => $dokumentasi->id_dokumentasi,
        ]);
    }

    /** Test 14: Petugas lain tidak boleh menghapus dokumentasi orang lain */
    public function test_unrelated_petugas_cannot_delete_others_dokumentasi(): void
    {
        $dokumentasi = Dokumentasi::create([
            'id_dokumentasi'    => 'DOC-703',
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'id_petugas'        => $this->petugasArmada->id_petugas,
            'jenis_dokumentasi' => 'foto',
            'file_dokumentasi'  => 'dokumentasi/test2.jpg',
            'waktu_upload'      => now(),
        ]);

        $this->withToken($this->petugasLainToken())
            ->deleteJson('/api/dokumentasi/' . $dokumentasi->id_dokumentasi)
            ->assertStatus(403);

        $this->assertDatabaseHas('dokumentasi', [
            'id_dokumentasi' => $dokumentasi->id_dokumentasi,
        ]);
    }
}
