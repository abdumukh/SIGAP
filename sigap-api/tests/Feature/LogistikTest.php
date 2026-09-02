<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\AnggotaTim;
use App\Models\Armada;
use App\Models\Logistik;
use App\Models\Pengguna;
use App\Models\Penanganan;
use App\Models\Penugasan;
use App\Models\Petugas;
use App\Models\Tim;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class LogistikTest extends TestCase
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
            ['id_admin' => 'ADM-772'],
            [
                'nama_admin' => 'Admin Logistik 772',
                'email'      => 'adminlogistik772@sigap.go.id',
                'password'   => Hash::make('password123'),
                'no_hp'      => '081177777772',
            ]
        );

        $this->masyarakat = Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-772'],
            [
                'nama'     => 'Masyarakat Logistik 772',
                'email'    => 'masyarakat772@example.com',
                'password' => Hash::make('password123'),
                'no_hp'    => '081277777772',
                'alamat'   => 'Jl. Logistik No. 1',
            ]
        );

        $this->ketuaTim = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-774'],
            [
                'nama_petugas'   => 'Ketua Tim 774',
                'email'          => 'ketua774@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085277777774',
                'alamat'         => 'Posko SIGAP 774',
                'status_petugas' => 'aktif',
                'role'           => 'ketua_tim',
            ]
        );

        $this->petugasArmada = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-775'],
            [
                'nama_petugas'   => 'Petugas Armada 775',
                'email'          => 'petugas775@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085277777775',
                'alamat'         => 'Posko SIGAP 775',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->petugasLain = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-776'],
            [
                'nama_petugas'   => 'Petugas Lain 776',
                'email'          => 'petugas776@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085277777776',
                'alamat'         => 'Posko SIGAP 776',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->tim = Tim::firstOrCreate(
            ['id_tim' => 'TIM-772'],
            [
                'nama_tim'   => 'Tim Logistik 772',
                'status_tim' => 'aktif',
                'note'       => 'Tim test logistik',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-773'],
            [
                'id_tim'         => $this->tim->id_tim,
                'id_petugas'     => $this->ketuaTim->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-774'],
            [
                'id_tim'         => $this->tim->id_tim,
                'id_petugas'     => $this->petugasArmada->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $this->alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-772'],
            [
                'id_pengguna'   => $this->masyarakat->id_pengguna,
                'jenis_darurat' => 'Kebakaran',
                'waktu_alarm'   => now(),
                'latitude'      => -6.9200000,
                'longitude'     => 109.1200000,
                'cuaca'         => 'Cerah',
                'lalu_lintas'   => 'Lancar',
                'status_alarm'  => 'diverifikasi',
            ]
        );

        $this->armada = Armada::firstOrCreate(
            ['id_armada' => 'ARM-772'],
            [
                'nama_armada'     => 'Pemadam 772',
                'jenis_armada'    => 'Pemadam Kebakaran',
                'nomor_kendaraan' => 'G 772 SGP',
                'status_armada'   => 'digunakan',
                'note'            => 'Armada test logistik',
            ]
        );

        $this->penugasan = Penugasan::firstOrCreate(
            ['id_penugasan' => 'TGS-772'],
            [
                'id_alarm'          => $this->alarm->id_alarm,
                'id_tim'            => $this->tim->id_tim,
                'id_ketua_tim'      => $this->ketuaTim->id_petugas,
                'id_petugas_armada' => $this->petugasArmada->id_petugas,
                'id_armada'         => $this->armada->id_armada,
                'waktu_penugasan'   => now(),
                'status_penugasan'  => 'berangkat',
                'note'              => 'Penugasan test logistik',
            ]
        );

        $this->penanganan = Penanganan::firstOrCreate(
            ['id_penanganan' => 'PNG-772'],
            [
                'id_alarm'          => $this->alarm->id_alarm,
                'id_penugasan'      => $this->penugasan->id_penugasan,
                'id_petugas'        => $this->petugasArmada->id_petugas,
                'waktu_berangkat'   => now(),
                'status_penanganan' => 'di_lokasi',
                'note'              => 'Sudah di lokasi',
            ]
        );
    }

    protected function adminToken(): string
    {
        return $this->admin->createToken('test', ['admin'])->plainTextToken;
    }

    protected function petugasToken(): string
    {
        return $this->petugasArmada->createToken('test', ['petugas'])->plainTextToken;
    }

    protected function masyarakatToken(): string
    {
        return $this->masyarakat->createToken('test', ['masyarakat'])->plainTextToken;
    }

    public function test_petugas_can_create_logistik(): void
    {
        $response = $this->withToken($this->petugasToken())->postJson('/api/logistik', [
            'id_penanganan' => $this->penanganan->id_penanganan,
            'nama_logistik' => 'Selang Pemadam',
            'jumlah'        => 4,
            'satuan'        => 'Unit',
            'kondisi'       => 'Baik',
            'note'          => 'Digunakan untuk memadamkan api',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.nama_logistik', 'Selang Pemadam')
            ->assertJsonPath('data.id_penanganan', $this->penanganan->id_penanganan);

        $this->assertDatabaseHas('logistik', [
            'id_penanganan' => $this->penanganan->id_penanganan,
            'nama_logistik' => 'Selang Pemadam',
            'jumlah'        => 4,
        ]);
    }

    public function test_masyarakat_cannot_create_logistik(): void
    {
        $response = $this->withToken($this->masyarakatToken())->postJson('/api/logistik', [
            'id_penanganan' => $this->penanganan->id_penanganan,
            'nama_logistik' => 'Selang Pemadam',
            'jumlah'        => 4,
            'satuan'        => 'Unit',
            'kondisi'       => 'Baik',
        ]);

        $response->assertStatus(403);
    }

    public function test_petugas_can_list_logistik(): void
    {
        Logistik::create([
            'id_logistik'   => 'LOG-771',
            'id_penanganan' => $this->penanganan->id_penanganan,
            'nama_logistik' => 'Masker Gas',
            'jumlah'        => 10,
            'satuan'        => 'Pcs',
            'kondisi'       => 'Baik',
        ]);

        $response = $this->withToken($this->petugasToken())->getJson('/api/logistik');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonCount(1, 'data');
    }

    public function test_petugas_can_delete_logistik(): void
    {
        $logistik = Logistik::create([
            'id_logistik'   => 'LOG-772',
            'id_penanganan' => $this->penanganan->id_penanganan,
            'nama_logistik' => 'Logistik Hapus',
            'jumlah'        => 5,
            'satuan'        => 'Unit',
            'kondisi'       => 'Rusak',
        ]);

        $response = $this->withToken($this->petugasToken())->deleteJson('/api/logistik/' . $logistik->id_logistik);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success');

        $this->assertDatabaseMissing('logistik', [
            'id_logistik' => 'LOG-772',
        ]);
    }
}