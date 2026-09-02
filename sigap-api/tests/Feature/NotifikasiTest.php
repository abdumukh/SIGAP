<?php

namespace Tests\Feature;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\Notifikasi;
use App\Models\Pengguna;
use App\Models\Petugas;
use App\Models\Tim;
use App\Models\Penugasan;
use App\Models\Penanganan;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class NotifikasiTest extends TestCase
{
    use RefreshDatabase;

    protected Pengguna $masyarakat;
    protected Admin $admin;
    protected Petugas $ketuaTim;
    protected Petugas $petugas;
    protected Tim $tim;

    protected function setUp(): void
    {
        parent::setUp();

        $this->masyarakat = Pengguna::firstOrCreate(
            ['id_pengguna' => 'USR-881'],
            [
                'nama'     => 'Masyarakat Test',
                'email'    => 'masyarakat881@example.com',
                'password' => Hash::make('password123'),
                'no_hp'    => '081234567881',
                'alamat'   => 'Jl. Test No. 1',
            ]
        );

        $this->admin = Admin::firstOrCreate(
            ['id_admin' => 'ADM-881'],
            [
                'nama_admin' => 'Admin Test',
                'email'      => 'admin881@sigap.go.id',
                'password'   => Hash::make('admin123'),
                'no_hp'      => '081198765881',
            ]
        );

        $this->ketuaTim = Petugas::firstOrCreate(
            ['id_petugas' => 'PTG-881'],
            [
                'nama_petugas'   => 'Ketua Tim Test',
                'email'          => 'ketuatiim881@sigap.go.id',
                'password'       => Hash::make('petugas123'),
                'no_hp'          => '085255667881',
                'alamat'         => 'Posko Test 881',
                'status_petugas' => 'aktif',
                'role'           => 'ketua_tim',
            ]
        );

        $this->petugas = Petugas::firstOrCreate(
            ['id_petugas' => 'PTG-882'],
            [
                'nama_petugas'   => 'Petugas Test',
                'email'          => 'petugas882@sigap.go.id',
                'password'       => Hash::make('petugas123'),
                'no_hp'          => '085255667882',
                'alamat'         => 'Posko Test 882',
                'status_petugas' => 'aktif',
                'role'           => 'petugas',
            ]
        );

        $this->tim = Tim::create([
            'id_tim'     => 'TIM-881',
            'nama_tim'   => 'Tim Test 881',
            'status_tim' => 'aktif',
        ]);

        \App\Models\AnggotaTim::create([
            'id_anggota_tim' => 'ATG-881',
            'id_tim'         => $this->tim->id_tim,
            'id_petugas'     => $this->ketuaTim->id_petugas,
            'tanggal_masuk'  => now(),
            'status_anggota' => 'aktif',
        ]);

        \App\Models\AnggotaTim::create([
            'id_anggota_tim' => 'ATG-882',
            'id_tim'         => $this->tim->id_tim,
            'id_petugas'     => $this->petugas->id_petugas,
            'tanggal_masuk'  => now(),
            'status_anggota' => 'aktif',
        ]);
    }

    public function test_authenticated_admin_can_list_notifications(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        Notifikasi::create([
            'id_notifikasi' => 'NTF-881',
            'id_actor'      => $this->admin->id_admin,
            'actor_role'    => 'admin',
            'type'          => 'ALARM_CREATED',
            'title'         => 'Laporan Baru',
            'message'       => 'Laporan baru masuk.',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/notifikasi');

        $response->assertOk()
            ->assertJsonPath('status', 'success');
    }

    public function test_unauthenticated_cannot_list_notifications(): void
    {
        $response = $this->getJson('/api/notifikasi');
        $response->assertStatus(401);
    }

    public function test_user_cannot_see_another_users_notifications(): void
    {
        $token = $this->masyarakat->createToken('auth', ['masyarakat'])->plainTextToken;

        // Notification for a different user
        Notifikasi::create([
            'id_notifikasi' => 'NTF-882',
            'id_actor'      => 'USR-999',
            'actor_role'    => 'masyarakat',
            'type'          => 'ALARM_VERIFIED',
            'title'         => 'Laporan Diverifikasi',
            'message'       => 'Laporan telah diverifikasi.',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/notifikasi');

        $response->assertOk()
            ->assertJsonPath('data', []);
    }

    public function test_user_can_view_own_notification(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $notif = Notifikasi::create([
            'id_notifikasi' => 'NTF-883',
            'id_actor'      => $this->admin->id_admin,
            'actor_role'    => 'admin',
            'type'          => 'PENUGASAN_CREATED',
            'title'         => 'Penugasan Baru',
            'message'       => 'Penugasan baru dibuat.',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson("/api/notifikasi/{$notif->id_notifikasi}");

        $response->assertOk()
            ->assertJsonPath('data.id_notifikasi', 'NTF-883');
    }

    public function test_user_cannot_view_another_users_notification(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        // Notification for a different admin
        $notif = Notifikasi::create([
            'id_notifikasi' => 'NTF-884',
            'id_actor'      => 'ADM-999',
            'actor_role'    => 'admin',
            'type'          => 'ALARM_CREATED',
            'title'         => 'Laporan Baru',
            'message'       => 'Laporan baru masuk.',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson("/api/notifikasi/{$notif->id_notifikasi}");

        $response->assertForbidden();
    }

    public function test_user_can_mark_notification_as_read(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $notif = Notifikasi::create([
            'id_notifikasi' => 'NTF-885',
            'id_actor'      => $this->admin->id_admin,
            'actor_role'    => 'admin',
            'type'          => 'PENANGANAN_COMPLETED',
            'title'         => 'Penanganan Selesai',
            'message'       => 'Penanganan telah selesai.',
            'read_at'       => null,
        ]);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->patchJson("/api/notifikasi/{$notif->id_notifikasi}/read");

        $response->assertOk();
        $notif->refresh();
        $this->assertNotNull($notif->read_at);
    }

    public function test_user_can_mark_all_notifications_as_read(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        // Create multiple unread notifications
        for ($i = 1; $i <= 3; $i++) {
            Notifikasi::create([
                'id_notifikasi' => 'NTF-89' . $i,
                'id_actor'      => $this->admin->id_admin,
                'actor_role'    => 'admin',
                'type'          => 'ALARM_CREATED',
                'title'         => "Laporan Baru {$i}",
                'message'       => "Laporan {$i} masuk.",
            ]);
        }

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->patchJson('/api/notifikasi/read-all');

        $response->assertOk()
            ->assertJsonPath('data.updated_count', 3);
    }

    public function test_unread_count_is_correct(): void
    {
        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        // 2 unread, 1 read
        Notifikasi::create([
            'id_notifikasi' => 'NTF-891',
            'id_actor'      => $this->admin->id_admin,
            'actor_role'    => 'admin',
            'type'          => 'ALARM_CREATED',
            'title'         => 'Laporan 1',
            'message'       => 'Pesan 1',
        ]);
        Notifikasi::create([
            'id_notifikasi' => 'NTF-892',
            'id_actor'      => $this->admin->id_admin,
            'actor_role'    => 'admin',
            'type'          => 'ALARM_CREATED',
            'title'         => 'Laporan 2',
            'message'       => 'Pesan 2',
        ]);
        Notifikasi::create([
            'id_notifikasi' => 'NTF-893',
            'id_actor'      => $this->admin->id_admin,
            'actor_role'    => 'admin',
            'type'          => 'ALARM_CREATED',
            'title'         => 'Laporan 3',
            'message'       => 'Pesan 3',
            'read_at'       => now(),
        ]);

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/notifikasi/unread-count');

        $response->assertOk()
            ->assertJsonPath('data.unread_count', 2);
    }

    public function test_notification_generated_after_alarm_created(): void
    {
        $token = $this->masyarakat->createToken('auth', ['masyarakat'])->plainTextToken;

        $this->postJson('/api/alarms', [
            'jenis_darurat' => 'Kebakaran',
            'latitude'      => -6.2088000,
            'longitude'     => 106.8456000,
        ], ['Authorization' => 'Bearer ' . $token]);

        // Admin should have notification
        $adminNotif = Notifikasi::where('id_actor', $this->admin->id_admin)
            ->where('type', 'ALARM_CREATED')
            ->first();
        $this->assertNotNull($adminNotif);
        $this->assertEquals('admin', $adminNotif->actor_role);

        // Ketua Tim should have notification
        $ketuaNotif = Notifikasi::where('id_actor', $this->ketuaTim->id_petugas)
            ->where('type', 'ALARM_CREATED')
            ->first();
        $this->assertNotNull($ketuaNotif);
        $this->assertEquals('ketua_tim', $ketuaNotif->actor_role);
    }

    public function test_notification_generated_after_alarm_verified(): void
    {
        $alarm = Alarm::create([
            'id_alarm'      => 'ALM-881',
            'id_pengguna'   => $this->masyarakat->id_pengguna,
            'jenis_darurat' => 'Kebakaran',
            'latitude'      => -6.2088000,
            'longitude'     => 106.8456000,
            'waktu_alarm'   => now(),
            'status_alarm'  => 'menunggu',
        ]);

        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $this->withHeader('Authorization', 'Bearer ' . $token)
            ->patchJson("/api/alarms/{$alarm->id_alarm}/verify");

        $notif = Notifikasi::where('id_actor', $this->masyarakat->id_pengguna)
            ->where('type', 'ALARM_VERIFIED')
            ->first();
        $this->assertNotNull($notif);
        $this->assertEquals('masyarakat', $notif->actor_role);
    }

    public function test_notification_generated_after_alarm_rejected(): void
    {
        $alarm = Alarm::create([
            'id_alarm'      => 'ALM-882',
            'id_pengguna'   => $this->masyarakat->id_pengguna,
            'jenis_darurat' => 'Kecelakaan',
            'latitude'      => -6.2088000,
            'longitude'     => 106.8456000,
            'waktu_alarm'   => now(),
            'status_alarm'  => 'menunggu',
        ]);

        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $this->withHeader('Authorization', 'Bearer ' . $token)
            ->patchJson("/api/alarms/{$alarm->id_alarm}/reject");

        $notif = Notifikasi::where('id_actor', $this->masyarakat->id_pengguna)
            ->where('type', 'ALARM_REJECTED')
            ->first();
        $this->assertNotNull($notif);
        $this->assertEquals('masyarakat', $notif->actor_role);
    }

    public function test_notification_generated_after_penugasan_created(): void
    {
        $alarm = Alarm::create([
            'id_alarm'      => 'ALM-883',
            'id_pengguna'   => $this->masyarakat->id_pengguna,
            'jenis_darurat' => 'Medis Darurat',
            'latitude'      => -6.2088000,
            'longitude'     => 106.8456000,
            'waktu_alarm'   => now(),
            'status_alarm'  => 'diverifikasi',
        ]);

        $token = $this->admin->createToken('auth', ['admin'])->plainTextToken;

        $this->postJson('/api/penugasan', [
            'id_alarm'      => $alarm->id_alarm,
            'id_tim'        => $this->tim->id_tim,
            'id_ketua_tim'  => $this->ketuaTim->id_petugas,
        ], ['Authorization' => 'Bearer ' . $token]);

        // Masyarakat should get notification
        $masyNotif = Notifikasi::where('id_actor', $this->masyarakat->id_pengguna)
            ->where('type', 'PENUGASAN_CREATED')
            ->first();
        $this->assertNotNull($masyNotif);
        $this->assertEquals('masyarakat', $masyNotif->actor_role);

        // Ketua Tim should get notification
        $ketuaNotif = Notifikasi::where('id_actor', $this->ketuaTim->id_petugas)
            ->where('type', 'PENUGASAN_CREATED')
            ->first();
        $this->assertNotNull($ketuaNotif);
        $this->assertEquals('ketua_tim', $ketuaNotif->actor_role);
    }

    public function test_notification_generated_when_penanganan_starts(): void
    {
        $alarm = Alarm::create([
            'id_alarm'      => 'ALM-884',
            'id_pengguna'   => $this->masyarakat->id_pengguna,
            'jenis_darurat' => 'Banjir',
            'latitude'      => -6.2088000,
            'longitude'     => 106.8456000,
            'waktu_alarm'   => now(),
            'status_alarm'  => 'diverifikasi',
        ]);

        Penugasan::create([
            'id_penugasan'     => 'TGS-881',
            'id_alarm'         => $alarm->id_alarm,
            'id_tim'           => $this->tim->id_tim,
            'id_ketua_tim'     => $this->ketuaTim->id_petugas,
            'waktu_penugasan'  => now(),
            'status_penugasan' => 'menunggu',
        ]);

        $token = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $this->postJson('/api/penanganan', [
            'id_penugasan' => 'TGS-881',
        ], ['Authorization' => 'Bearer ' . $token]);

        $masyNotif = Notifikasi::where('id_actor', $this->masyarakat->id_pengguna)
            ->where('type', 'PENANGANAN_STARTED')
            ->first();
        $this->assertNotNull($masyNotif);
        $this->assertEquals('masyarakat', $masyNotif->actor_role);
    }

    public function test_notification_generated_when_penanganan_arrives(): void
    {
        $alarm = Alarm::create([
            'id_alarm'      => 'ALM-885',
            'id_pengguna'   => $this->masyarakat->id_pengguna,
            'jenis_darurat' => 'Gempa',
            'latitude'      => -6.2088000,
            'longitude'     => 106.8456000,
            'waktu_alarm'   => now(),
            'status_alarm'  => 'diverifikasi',
        ]);

        Penugasan::create([
            'id_penugasan'     => 'TGS-882',
            'id_alarm'         => $alarm->id_alarm,
            'id_tim'           => $this->tim->id_tim,
            'id_ketua_tim'     => $this->ketuaTim->id_petugas,
            'waktu_penugasan'  => now(),
            'status_penugasan' => 'menunggu',
        ]);

        $penanganan = Penanganan::create([
            'id_penanganan'     => 'PNG-881',
            'id_alarm'          => $alarm->id_alarm,
            'id_penugasan'      => 'TGS-882',
            'id_petugas'        => $this->petugas->id_petugas,
            'waktu_berangkat'   => now(),
            'status_penanganan' => 'menuju_lokasi',
        ]);

        $token = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $this->patchJson("/api/penanganan/{$penanganan->id_penanganan}", [
            'status_penanganan' => 'di_lokasi',
        ], ['Authorization' => 'Bearer ' . $token]);

        $masyNotif = Notifikasi::where('id_actor', $this->masyarakat->id_pengguna)
            ->where('type', 'PENANGANAN_ARRIVED')
            ->first();
        $this->assertNotNull($masyNotif);
        $this->assertEquals('masyarakat', $masyNotif->actor_role);
    }

    public function test_notification_generated_when_penanganan_completes(): void
    {
        $alarm = Alarm::create([
            'id_alarm'      => 'ALM-886',
            'id_pengguna'   => $this->masyarakat->id_pengguna,
            'jenis_darurat' => 'Kebakaran',
            'latitude'      => -6.2088000,
            'longitude'     => 106.8456000,
            'waktu_alarm'   => now(),
            'status_alarm'  => 'diverifikasi',
        ]);

        Penugasan::create([
            'id_penugasan'     => 'TGS-883',
            'id_alarm'         => $alarm->id_alarm,
            'id_tim'           => $this->tim->id_tim,
            'id_ketua_tim'     => $this->ketuaTim->id_petugas,
            'waktu_penugasan'  => now(),
            'status_penugasan' => 'menunggu',
        ]);

        $penanganan = Penanganan::create([
            'id_penanganan'     => 'PNG-882',
            'id_alarm'          => $alarm->id_alarm,
            'id_penugasan'      => 'TGS-883',
            'id_petugas'        => $this->petugas->id_petugas,
            'waktu_berangkat'   => now(),
            'waktu_tiba'        => now(),
            'status_penanganan' => 'di_lokasi',
        ]);

        $token = $this->petugas->createToken('auth', ['petugas'])->plainTextToken;

        $this->patchJson("/api/penanganan/{$penanganan->id_penanganan}", [
            'status_penanganan' => 'selesai',
        ], ['Authorization' => 'Bearer ' . $token]);

        $masyNotif = Notifikasi::where('id_actor', $this->masyarakat->id_pengguna)
            ->where('type', 'PENANGANAN_COMPLETED')
            ->first();
        $this->assertNotNull($masyNotif);
        $this->assertEquals('masyarakat', $masyNotif->actor_role);

        $adminNotif = Notifikasi::where('id_actor', $this->admin->id_admin)
            ->where('type', 'PENANGANAN_COMPLETED')
            ->first();
        $this->assertNotNull($adminNotif);
        $this->assertEquals('admin', $adminNotif->actor_role);
    }
}