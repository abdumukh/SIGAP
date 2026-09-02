<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\AnggotaTim;
use App\Models\Armada;
use App\Models\Korban;
use App\Models\Pengguna;
use App\Models\Penanganan;
use App\Models\Penugasan;
use App\Models\Petugas;
use App\Models\Tim;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class KorbanTest extends TestCase
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
            ['id_admin' => 'ADM-771'],
            [
                'nama_admin' => 'Admin Korban 771',
                'email'      => 'adminkorban771@sigap.go.id',
                'password'   => Hash::make('password123'),
                'no_hp'      => '081177777771',
            ]
        );

        $this->masyarakat = Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-771'],
            [
                'nama'     => 'Masyarakat Korban 771',
                'email'    => 'masyarakat771@example.com',
                'password' => Hash::make('password123'),
                'no_hp'    => '081277777771',
                'alamat'   => 'Jl. Korban No. 1',
            ]
        );

        $this->ketuaTim = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-771'],
            [
                'nama_petugas'   => 'Ketua Tim 771',
                'email'          => 'ketua771@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085277777771',
                'alamat'         => 'Posko SIGAP 771',
                'status_petugas' => 'aktif',
                'role'           => 'ketua_tim',
            ]
        );

        $this->petugasArmada = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-772'],
            [
                'nama_petugas'   => 'Petugas Armada 772',
                'email'          => 'petugas772@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085277777772',
                'alamat'         => 'Posko SIGAP 772',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->petugasLain = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-773'],
            [
                'nama_petugas'   => 'Petugas Lain 773',
                'email'          => 'petugas773@sigap.go.id',
                'password'       => Hash::make('password123'),
                'no_hp'          => '085277777773',
                'alamat'         => 'Posko SIGAP 773',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->tim = Tim::firstOrCreate(
            ['id_tim' => 'TIM-771'],
            [
                'nama_tim'   => 'Tim Korban 771',
                'status_tim' => 'aktif',
                'note'       => 'Tim test korban',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-771'],
            [
                'id_tim'         => $this->tim->id_tim,
                'id_petugas'     => $this->ketuaTim->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-772'],
            [
                'id_tim'         => $this->tim->id_tim,
                'id_petugas'     => $this->petugasArmada->id_petugas,
                'tanggal_masuk'  => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $this->alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-771'],
            [
                'id_pengguna'   => $this->masyarakat->id_pengguna,
                'jenis_darurat' => 'Banjir Bandang',
                'waktu_alarm'   => now(),
                'latitude'      => -6.9100000,
                'longitude'     => 109.1100000,
                'cuaca'         => 'Hujan Lebat',
                'lalu_lintas'   => 'Macet',
                'status_alarm'  => 'diverifikasi',
            ]
        );

        $this->armada = Armada::firstOrCreate(
            ['id_armada' => 'ARM-771'],
            [
                'nama_armada'     => 'Truk Evakuasi 771',
                'jenis_armada'    => 'Truk Evakuasi',
                'nomor_kendaraan' => 'G 771 SGP',
                'status_armada'   => 'digunakan',
                'note'            => 'Armada test korban',
            ]
        );

        $this->penugasan = Penugasan::firstOrCreate(
            ['id_penugasan' => 'TGS-771'],
            [
                'id_alarm'          => $this->alarm->id_alarm,
                'id_tim'            => $this->tim->id_tim,
                'id_ketua_tim'      => $this->ketuaTim->id_petugas,
                'id_petugas_armada' => $this->petugasArmada->id_petugas,
                'id_armada'         => $this->armada->id_armada,
                'waktu_penugasan'   => now(),
                'status_penugasan'  => 'berangkat',
                'note'              => 'Penugasan test korban',
            ]
        );

        $this->penanganan = Penanganan::firstOrCreate(
            ['id_penanganan' => 'PNG-771'],
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

    public function test_petugas_can_create_korban(): void
    {
        $response = $this->withToken($this->petugasToken())->postJson('/api/korban', [
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'nama_korban'       => 'Budi Santoso',
            'jenis_kelamin'     => 'L',
            'usia'              => 35,
            'kondisi'           => 'Luka Ringan',
            'status_penanganan' => 'Dievakuasi ke RS',
            'note'              => 'Perlu perawatan medis lanjutan',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.nama_korban', 'Budi Santoso')
            ->assertJsonPath('data.id_penanganan', $this->penanganan->id_penanganan);

        $this->assertDatabaseHas('korban', [
            'id_penanganan' => $this->penanganan->id_penanganan,
            'nama_korban'   => 'Budi Santoso',
            'kondisi'       => 'Luka Ringan',
        ]);
    }

    public function test_masyarakat_cannot_create_korban(): void
    {
        $response = $this->withToken($this->masyarakatToken())->postJson('/api/korban', [
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'nama_korban'       => 'Budi Santoso',
            'jenis_kelamin'     => 'L',
            'usia'              => 35,
            'kondisi'           => 'Luka Ringan',
            'status_penanganan' => 'Dievakuasi ke RS',
        ]);

        $response->assertStatus(403);
    }

    public function test_petugas_can_list_korban(): void
    {
        Korban::create([
            'id_korban'         => 'KRB-771',
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'nama_korban'       => 'Siti Rahma',
            'jenis_kelamin'     => 'P',
            'usia'              => 28,
            'kondisi'           => 'Selamat',
            'status_penanganan' => 'Ditampung di Posko',
        ]);

        $response = $this->withToken($this->petugasToken())->getJson('/api/korban');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonCount(1, 'data');
    }

    public function test_petugas_can_delete_korban(): void
    {
        $korban = Korban::create([
            'id_korban'         => 'KRB-772',
            'id_penanganan'     => $this->penanganan->id_penanganan,
            'nama_korban'       => 'Korban Hapus',
            'jenis_kelamin'     => 'L',
            'usia'              => 40,
            'kondisi'           => 'Selamat',
            'status_penanganan' => 'Rawat Jalan',
        ]);

        $response = $this->withToken($this->petugasToken())->deleteJson('/api/korban/' . $korban->id_korban);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success');

        $this->assertDatabaseMissing('korban', [
            'id_korban' => 'KRB-772',
        ]);
    }
}
