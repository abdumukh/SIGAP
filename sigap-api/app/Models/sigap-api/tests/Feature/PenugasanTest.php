<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\AnggotaTim;
use App\Models\Armada;
use App\Models\Pengguna;
use App\Models\Petugas;
use App\Models\Penugasan;
use App\Models\Tim;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class PenugasanTest extends TestCase
{
    use DatabaseTransactions;

    protected Admin $admin;
    protected Pengguna $masyarakat;
    protected Petugas $ketuaTim;
    protected Petugas $petugasArmada;
    protected Tim $tim;
    protected Alarm $alarm;
    protected Armada $armada;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = Admin::firstOrCreate(
            ['id_admin' => 'ADM-881'],
            [
                'nama_admin' => 'Admin Penugasan 881',
                'email' => 'adminpenugasan881@sigap.go.id',
                'password' => Hash::make('password123'),
                'no_hp' => '081188888881',
            ]
        );

        $this->masyarakat = Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-881'],
            [
                'nama' => 'Masyarakat Penugasan 881',
                'email' => 'masyarakat881@example.com',
                'password' => Hash::make('password123'),
                'no_hp' => '081288888881',
                'alamat' => 'Jl. Penugasan No. 1',
            ]
        );

        $this->ketuaTim = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-881'],
            [
                'nama_petugas' => 'Ketua Tim 881',
                'email' => 'ketua881@sigap.go.id',
                'password' => Hash::make('password123'),
                'no_hp' => '085288888881',
                'alamat' => 'Posko SIGAP 881',
                'status_petugas' => 'aktif',
                'role' => 'ketua_tim',
            ]
        );

        $this->petugasArmada = Petugas::firstOrCreate(
            ['id_petugas' => 'PET-882'],
            [
                'nama_petugas' => 'Petugas Armada 882',
                'email' => 'petugas882@sigap.go.id',
                'password' => Hash::make('password123'),
                'no_hp' => '085288888882',
                'alamat' => 'Posko SIGAP 882',
                'status_petugas' => 'aktif',
                'role' => 'petugas',
            ]
        );

        $this->tim = Tim::firstOrCreate(
            ['id_tim' => 'TIM-881'],
            [
                'nama_tim' => 'Tim Penugasan 881',
                'status_tim' => 'aktif',
                'note' => 'Tim test penugasan',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-881'],
            [
                'id_tim' => $this->tim->id_tim,
                'id_petugas' => $this->ketuaTim->id_petugas,
                'tanggal_masuk' => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        AnggotaTim::firstOrCreate(
            ['id_anggota_tim' => 'AT-882'],
            [
                'id_tim' => $this->tim->id_tim,
                'id_petugas' => $this->petugasArmada->id_petugas,
                'tanggal_masuk' => now()->toDateString(),
                'status_anggota' => 'aktif',
            ]
        );

        $this->alarm = Alarm::firstOrCreate(
            ['id_alarm' => 'ALM-881'],
            [
                'id_pengguna' => $this->masyarakat->id_pengguna,
                'jenis_darurat' => 'Banjir',
                'waktu_alarm' => now(),
                'latitude' => -6.9000000,
                'longitude' => 109.1000000,
                'cuaca' => 'Hujan',
                'lalu_lintas' => 'Padat',
                'status_alarm' => 'diverifikasi',
            ]
        );

        $this->armada = Armada::firstOrCreate(
            ['id_armada' => 'ARM-881'],
            [
                'nama_armada' => 'Ambulans 881',
                'jenis_armada' => 'Ambulans',
                'nomor_kendaraan' => 'G 881 SGP',
                'status_armada' => 'tersedia',
                'note' => 'Armada test',
            ]
        );
    }

    protected function adminToken(): string
    {
        return $this->admin->createToken('test', ['admin'])->plainTextToken;
    }

    public function test_admin_can_create_penugasan(): void
    {
        $response = $this->withToken($this->adminToken())->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
            'id_petugas_armada' => $this->petugasArmada->id_petugas,
            'id_armada' => $this->armada->id_armada,
            'note' => 'Penugasan test',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.status_penugasan', 'menunggu');

        $this->assertDatabaseHas('penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
            'status_penugasan' => 'menunggu',
        ]);

        $this->assertDatabaseHas('armada', [
            'id_armada' => $this->armada->id_armada,
            'status_armada' => 'digunakan',
        ]);
    }

    public function test_admin_can_create_penugasan_without_armada_pair(): void
    {
        $response = $this->withToken($this->adminToken())->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.status_penugasan', 'menunggu');
    }

    public function test_unauthenticated_cannot_create_penugasan(): void
    {
        $this->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
        ])->assertStatus(401);
    }

    public function test_masyarakat_cannot_create_penugasan(): void
    {
        $token = $this->masyarakat->createToken('test', ['masyarakat'])->plainTextToken;

        $this->withToken($token)->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
        ])->assertStatus(403);
    }

    public function test_ketua_tim_cannot_create_penugasan(): void
    {
        $token = $this->ketuaTim->createToken('test', ['ketua_tim'])->plainTextToken;

        $this->withToken($token)->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
        ])->assertStatus(403);
    }

    public function test_petugas_cannot_create_penugasan(): void
    {
        $token = $this->petugasArmada->createToken('test', ['petugas'])->plainTextToken;

        $this->withToken($token)->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
        ])->assertStatus(403);
    }

    public function test_unverified_alarm_cannot_be_assigned(): void
    {
        $this->alarm->update(['status_alarm' => 'menunggu']);

        $this->withToken($this->adminToken())->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
        ])->assertStatus(422)->assertJsonValidationErrors(['id_alarm']);
    }

    public function test_non_existing_alarm_returns_422(): void
    {
        $this->withToken($this->adminToken())->postJson('/api/penugasan', [
            'id_alarm' => 'ALM-NOTFOUND',
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
        ])->assertStatus(422)->assertJsonValidationErrors(['id_alarm']);
    }

    public function test_inactive_team_cannot_be_assigned(): void
    {
        $this->tim->update(['status_tim' => 'nonaktif']);

        $this->withToken($this->adminToken())->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
        ])->assertStatus(422)->assertJsonValidationErrors(['id_tim']);
    }

    public function test_non_ketua_cannot_be_selected_as_ketua(): void
    {
        $this->withToken($this->adminToken())->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->petugasArmada->id_petugas,
        ])->assertStatus(422)->assertJsonValidationErrors(['id_ketua_tim']);
    }

    public function test_ketua_must_be_active_member_of_team(): void
    {
        $otherKetua = Petugas::create([
            'id_petugas' => 'PET-883',
            'nama_petugas' => 'Ketua Lain 883',
            'email' => 'ketua883@sigap.go.id',
            'password' => Hash::make('password123'),
            'no_hp' => '085288888883',
            'alamat' => 'Posko SIGAP 883',
            'status_petugas' => 'aktif',
            'role' => 'ketua_tim',
        ]);

        $this->withToken($this->adminToken())->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $otherKetua->id_petugas,
        ])->assertStatus(422)->assertJsonValidationErrors(['id_ketua_tim']);
    }

    public function test_armada_and_petugas_must_be_provided_together(): void
    {
        $this->withToken($this->adminToken())->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
            'id_armada' => $this->armada->id_armada,
        ])->assertStatus(422)->assertJsonValidationErrors(['id_armada']);
    }

    public function test_unavailable_armada_cannot_be_assigned(): void
    {
        $this->armada->update(['status_armada' => 'perawatan']);

        $this->withToken($this->adminToken())->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
            'id_petugas_armada' => $this->petugasArmada->id_petugas,
            'id_armada' => $this->armada->id_armada,
        ])->assertStatus(422)->assertJsonValidationErrors(['id_armada']);
    }

    public function test_petugas_armada_must_be_active_member_of_team(): void
    {
        AnggotaTim::where('id_tim', $this->tim->id_tim)
            ->where('id_petugas', $this->petugasArmada->id_petugas)
            ->update(['status_anggota' => 'nonaktif']);

        $this->withToken($this->adminToken())->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
            'id_petugas_armada' => $this->petugasArmada->id_petugas,
            'id_armada' => $this->armada->id_armada,
        ])->assertStatus(422)->assertJsonValidationErrors(['id_petugas_armada']);
    }

    public function test_duplicate_active_assignment_is_rejected(): void
    {
        Penugasan::create([
            'id_penugasan' => 'TGS-881',
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
            'waktu_penugasan' => now(),
            'status_penugasan' => 'menunggu',
        ]);

        $this->withToken($this->adminToken())->postJson('/api/penugasan', [
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
        ])->assertStatus(422)->assertJsonValidationErrors(['id_alarm']);
    }

    public function test_admin_can_list_penugasan(): void
    {
        Penugasan::create([
            'id_penugasan' => 'TGS-882',
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
            'waktu_penugasan' => now(),
            'status_penugasan' => 'menunggu',
        ]);

        $this->withToken($this->adminToken())
            ->getJson('/api/penugasan')
            ->assertStatus(200)
            ->assertJsonPath('status', 'success');
    }

    public function test_admin_can_view_penugasan_detail(): void
    {
        $penugasan = Penugasan::create([
            'id_penugasan' => 'TGS-883',
            'id_alarm' => $this->alarm->id_alarm,
            'id_tim' => $this->tim->id_tim,
            'id_ketua_tim' => $this->ketuaTim->id_petugas,
            'waktu_penugasan' => now(),
            'status_penugasan' => 'menunggu',
        ]);

        $this->withToken($this->adminToken())
            ->getJson('/api/penugasan/' . $penugasan->id_penugasan)
            ->assertStatus(200)
            ->assertJsonPath('data.id_penugasan', 'TGS-883');
    }

    public function test_non_existing_penugasan_returns_404(): void
    {
        $this->withToken($this->adminToken())
            ->getJson('/api/penugasan/TGS-NOTFOUND')
            ->assertStatus(404)
            ->assertJsonPath('message', 'Data penugasan tidak ditemukan');
    }
}
