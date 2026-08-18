<?php

namespace Database\Seeders;

use App\Models\Admin;
use App\Models\Alarm;
use App\Models\AnggotaTim;
use App\Models\Armada;
use App\Models\Dokumentasi;
use App\Models\Korban;
use App\Models\Logistik;
use App\Models\Penanganan;
use App\Models\Pengguna;
use App\Models\Penugasan;
use App\Models\Petugas;
use App\Models\Tim;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Pengguna (Masyarakat)
        $pengguna = Pengguna::create([
            'id_pengguna' => 'USR-001',
            'nama'        => 'Budi Santoso',
            'no_hp'       => '081234567890',
            'alamat'      => 'Jl. Merdeka No. 12, Jakarta',
            'email'       => 'budi@example.com',
            'password'    => Hash::make('password123'),
        ]);

        // 2. Admin
        $admin = Admin::create([
            'id_admin'   => 'ADM-001',
            'nama_admin' => 'Admin Utama SIGAP',
            'email'      => 'admin@sigap.go.id',
            'password'   => Hash::make('admin123'),
            'no_hp'      => '081198765432',
        ]);

        // 3. Petugas (Ketua Tim & Petugas Armada)
        $ketuaTim = Petugas::create([
            'id_petugas'     => 'PET-001',
            'nama_petugas'   => 'Rahmat Hidayat (Ketua Tim)',
            'no_hp'          => '085211223344',
            'email'          => 'rahmat@sigap.go.id',
            'password'       => Hash::make('petugas123'),
            'alamat'         => 'Posko Utama SIGAP',
            'status_petugas' => 'aktif',
            'role'           => 'ketua_tim',
        ]);

        $petugasArmada = Petugas::create([
            'id_petugas'     => 'PET-002',
            'nama_petugas'   => 'Ahmad Rivai (Petugas Armada)',
            'no_hp'          => '085255667788',
            'email'          => 'ahmad@sigap.go.id',
            'password'       => Hash::make('petugas123'),
            'alamat'         => 'Posko Utama SIGAP',
            'status_petugas' => 'aktif',
            'role'           => 'petugas',
        ]);

        // 4. Tim
        $tim = Tim::create([
            'id_tim'     => 'TIM-001',
            'nama_tim'   => 'Tim Alpha Reaksi Cepat',
            'note'       => 'Tim khusus evakuasi bencana banjir dan kebakaran',
            'status_tim' => 'aktif',
        ]);

        // 5. Anggota Tim
        AnggotaTim::create([
            'id_anggota_tim' => 'AT-001',
            'id_tim'         => $tim->id_tim,
            'id_petugas'     => $ketuaTim->id_petugas,
            'tanggal_masuk'  => '2026-01-01',
            'status_anggota' => 'aktif',
        ]);

        AnggotaTim::create([
            'id_anggota_tim' => 'AT-002',
            'id_tim'         => $tim->id_tim,
            'id_petugas'     => $petugasArmada->id_petugas,
            'tanggal_masuk'  => '2026-01-01',
            'status_anggota' => 'aktif',
        ]);

        // 6. Alarm (Masyarakat kirim alarm)
        $alarm = Alarm::create([
            'id_alarm'      => 'ALM-001',
            'id_pengguna'   => $pengguna->id_pengguna,
            'jenis_darurat' => 'Banjir Bandang',
            'waktu_alarm'   => now(),
            'latitude'      => -6.2088000,
            'longitude'     => 106.8456000,
            'cuaca'         => 'Hujan Deras',
            'lalu_lintas'   => 'Padat Tergenang',
            'status_alarm'  => 'diverifikasi', // Admin sudah memverifikasi
        ]);

        // 7. Armada
        $armada = Armada::create([
            'id_armada'       => 'ARM-001',
            'nama_armada'     => 'Ambulans Rescue 01',
            'jenis_armada'    => 'Ambulans',
            'nomor_kendaraan' => 'B 9110 SGP',
            'status_armada'   => 'digunakan',
            'note'            => 'Kondisi prima siap evakuasi',
        ]);

        // 8. Penugasan (Admin tugaskan Tim Alpha)
        $penugasan = Penugasan::create([
            'id_penugasan'      => 'TGS-001',
            'id_alarm'          => $alarm->id_alarm,
            'id_tim'            => $tim->id_tim,
            'id_petugas_armada' => $petugasArmada->id_petugas,
            'id_armada'         => $armada->id_armada,
            'id_ketua_tim'      => $ketuaTim->id_petugas,
            'waktu_penugasan'   => now(),
            'status_penugasan'  => 'berangkat',
            'note'              => 'Penugasan evakuasi korban banjir di lokasi Merdeka',
        ]);

        // 9. Penanganan (Petugas menangani di lokasi)
        $penanganan = Penanganan::create([
            'id_penanganan'     => 'PNG-001',
            'id_alarm'          => $alarm->id_alarm,
            'id_penugasan'      => $penugasan->id_penugasan,
            'id_petugas'        => $petugasArmada->id_petugas,
            'waktu_berangkat'   => now()->subMinutes(30),
            'waktu_tiba'        => now()->subMinutes(15),
            'waktu_selesai'     => null,
            'status_penanganan' => 'di_lokasi',
            'note'              => 'Petugas sudah tiba dan sedang mengevakuasi korban',
        ]);

        // 10. Dokumentasi
        Dokumentasi::create([
            'id_dokumentasi'    => 'DOC-001',
            'id_penanganan'     => $penanganan->id_penanganan,
            'id_petugas'        => $petugasArmada->id_petugas,
            'jenis_dokumentasi' => 'foto',
            'file_dokumentasi'  => 'dokumentasi/foto_evakuasi_01.jpg',
            'waktu_upload'      => now(),
            'note'              => 'Foto evakuasi warga terdampak banjir',
        ]);

        // 11. Korban
        Korban::create([
            'id_korban'         => 'KRB-001',
            'id_penanganan'     => $penanganan->id_penanganan,
            'nama_korban'       => 'Siti Aminah',
            'jenis_kelamin'     => 'P',
            'usia'              => 45,
            'kondisi'           => 'Luka Ringan',
            'status_penanganan' => 'Sudah Dievakuasi ke Posko',
            'note'              => 'Diberikan pertolongan pertama',
        ]);

        // 12. Logistik
        Logistik::create([
            'id_logistik'   => 'LOG-001',
            'id_penanganan' => $penanganan->id_penanganan,
            'nama_logistik' => 'Perahu Karet Rescue',
            'jumlah'        => 2,
            'satuan'        => 'unit',
            'kondisi'       => 'Baik',
            'note'          => 'Digunakan untuk menyisir gang sempit',
        ]);
    }
}
