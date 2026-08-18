# MASTER SPECIFICATION SIGAP
## Sistem Informasi Gawat Darurat dan Penanganan

**Status:** Master Specification  
**Versi:** 1.0  
**Dokumen sumber:** `SIGAP.drawio`, `SIGAP_Analisis_dan_Prompt_Antigravity.md`, `Panduan_Setup_SIGAP_Tanpa_AndroidStudio.md`  
**Tujuan:** Menjadi satu sumber acuan utama untuk pengembangan SIGAP di Antigravity.

---

# 1. ATURAN SUMBER KEBENARAN

Dokumen ini menyatukan rancangan visual, spesifikasi teknis, dan panduan implementasi SIGAP.

Urutan prioritas:

1. `SIGAP.drawio` — acuan utama untuk aktor, use case, flowchart, activity, ERD, dan class diagram.
2. `SIGAP_Analisis_dan_Prompt_Antigravity.md` — acuan stack, struktur database, fase pengembangan, dan prompt implementasi.
3. `Panduan_Setup_SIGAP_Tanpa_AndroidStudio.md` — acuan environment, testing, jaringan lokal, dan build Flutter.
4. Kode yang sudah dibuat — harus mengikuti tiga sumber di atas.

Jika terjadi konflik:
- Jangan mengambil keputusan sendiri.
- Jangan mengubah rancangan bisnis secara otomatis.
- Tandai sebagai `SPECIFICATION CONFLICT`.
- Minta keputusan pemilik project sebelum melakukan perubahan yang berdampak pada database, authentication, API, atau UI.

---

# 2. IDENTITAS PROJECT

**Nama:** SIGAP  
**Kepanjangan:** Sistem Informasi Gawat Darurat dan Penanganan.

SIGAP merupakan aplikasi pelaporan dan penanganan kondisi darurat berbasis lokasi.

Rancangan memiliki empat aktor utama:

1. Masyarakat
2. Admin
3. Ketua Tim
4. Petugas

---

# 3. STACK TEKNOLOGI

## Backend

- Laravel
- PHP 8.2+
- REST API stateless
- Laravel Sanctum
- MySQL
- phpMyAdmin
- Laravel Storage

## Mobile

- Flutter
- Dart
- `geolocator`
- HP Android fisik
- USB Debugging

## Environment

- Laragon atau XAMPP
- Composer
- Git
- Android SDK Command-line Tools
- JDK
- Tidak menggunakan Android Studio sebagai IDE/development environment.

---

# 4. ARSITEKTUR

```text
SIGAP/
├── docs/
│   ├── SIGAP.drawio
│   ├── SIGAP_Analisis_dan_Prompt_Antigravity.md
│   ├── Panduan_Setup_SIGAP_Tanpa_AndroidStudio.md
│   └── MASTER_SPECIFICATION_SIGAP.md
│
├── sigap-api/
│   └── Laravel REST API
│
└── sigap_mobile/
    └── Flutter Mobile App
```

Alur komunikasi:

```text
HP Android
    │
    │ HTTP/JSON + Bearer Token
    ▼
Flutter sigap_mobile
    │
    │ REST API
    ▼
Laravel sigap-api
    │
    ▼
MySQL sigap_db
```

Ketika testing menggunakan HP fisik, HP dan laptop harus berada pada jaringan yang sama.

Laravel harus dapat diakses melalui IP lokal laptop, bukan `localhost` dari HP.

---

# 5. AKTOR DAN TANGGUNG JAWAB

## 5.1 Masyarakat

Fungsi utama:

- Registrasi
- Login
- Mengirim alarm
- Memilih jenis alarm
- Melihat status penanganan
- Melihat riwayat/status kejadian
- Melihat laporan yang menjadi hak akses masyarakat

Flow utama:

```text
Login/Register
    ↓
Dashboard
    ↓
Pilih jenis alarm
    ├── Darurat
    ├── Evakuasi
    └── Laporan
    ↓
Kirim alarm
    ↓
Sistem menyimpan alarm
    ↓
Menunggu status
    ↓
Lihat progres penanganan
```

---

## 5.2 Admin

Fungsi utama:

- Login
- Menerima alarm
- Verifikasi alarm
- Menolak alarm
- Kelola Tim
- Kelola Anggota Tim
- Membuat penugasan
- Monitoring
- Laporan

Flow verifikasi:

```text
Alarm masuk
    ↓
Admin menerima notifikasi
    ↓
Membuka detail alarm
    ↓
Verifikasi
    ↓
Alarm valid?
 ├── Tidak → Tolak alarm
 └── Ya
       ↓
     Pilih tim
       ↓
     Kirim penugasan
       ↓
     Monitoring
```

---

## 5.3 Ketua Tim

Ketua Tim mempunyai alur bisnis tersendiri.

Fungsi utama:

- Login
- Menerima penugasan
- Menolak penugasan
- Memilih respon
- Mengerahkan seluruh tim
- Memilih petugas tertentu
- Monitoring
- Laporan

Flow:

```text
Menerima penugasan
    ↓
Terima?
 ├── Tidak → Kirim penolakan
 └── Ya
       ↓
    Jenis respon?
       ├── Kerahkan tim
       │      ↓
       │   Semua anggota menerima
       │
       └── Pilih petugas
              ↓
           Kirim penugasan
```

---

## 5.4 Petugas

Fungsi utama:

- Login
- Menerima penugasan
- Menerima/menolak tugas
- Berangkat
- Tiba di lokasi
- Melakukan penanganan
- Upload dokumentasi
- Membuat laporan penanganan
- Monitoring
- Laporan

Flow:

```text
Menerima penugasan
    ↓
Terima?
 ├── Tidak → Kirim penolakan
 └── Ya
       ↓
     GPS aktif
       ↓
     Berangkat
       ↓
     Tiba lokasi
       ↓
     Penanganan
       ↓
     Upload data/dokumentasi
       ↓
     Laporan penanganan
```

---

# 6. USE CASE

Fitur utama berdasarkan rancangan:

| Aktor | Fitur |
|---|---|
| Masyarakat | Login/Registrasi, Kirim Alarm, Status Penanganan |
| Admin | Login/Registrasi, Verifikasi Alarm, Kelola Tim, Kelola Anggota Tim, Penugasan, Monitoring, Laporan |
| Ketua Tim | Login/Registrasi, Penugasan, Monitoring, Laporan |
| Petugas | Login/Registrasi, Penugasan, Dokumentasi, Monitoring, Laporan |

Informasi pendukung alarm/monitoring:

- GPS/lokasi
- Cuaca
- Lalu lintas
- Waktu
- Data user
- Lokasi petugas
- Notifikasi alarm

---

# 7. DATABASE — 12 TABEL

Database bisnis SIGAP terdiri dari 12 tabel:

1. `pengguna`
2. `admin`
3. `petugas`
4. `tim`
5. `anggota_tim`
6. `alarm`
7. `penugasan`
8. `armada`
9. `penanganan`
10. `dokumentasi`
11. `korban`
12. `logistik`

## 7.1 Prefix ID

| Entitas | Prefix |
|---|---|
| pengguna | `USR-` |
| admin | `ADM-` |
| petugas | `PET-` |
| tim | `TIM-` |
| anggota_tim | `AT-` |
| alarm | `ALM-` |
| penugasan | `TGS-` |
| armada | `ARM-` |
| penanganan | `PNG-` |
| dokumentasi | `DOC-` |
| korban | `KRB-` |
| logistik | `LOG-` |

Contoh:

```text
USR-001
ADM-001
PET-001
TIM-001
AT-001
ALM-001
TGS-001
ARM-001
PNG-001
DOC-001
KRB-001
LOG-001
```

Semua primary key bisnis menggunakan `VARCHAR(20)` dan tidak menggunakan auto-increment integer.

---

# 8. ENTITAS DAN RELASI

## Pengguna

Menyimpan data masyarakat.

Relasi:

```text
PENGGUNA 1 ─── N ALARM
```

## Admin

Berperan dalam proses verifikasi alarm dan pengelolaan operasional.

## Petugas

Menyimpan data petugas lapangan.

Relasi:

```text
PETUGAS 1 ─── N ANGGOTA_TIM
PETUGAS 1 ─── N PENUGASAN
PETUGAS 1 ─── N PENANGANAN
PETUGAS 1 ─── N DOKUMENTASI
```

## Tim

Menyimpan kelompok/tim penanganan.

```text
TIM 1 ─── N ANGGOTA_TIM
TIM 1 ─── N PENUGASAN
```

## Anggota Tim

Penghubung antara Tim dan Petugas.

```text
TIM
  │
  └── ANGGOTA_TIM ── PETUGAS
```

## Alarm

```text
PENGGUNA 1 ─── N ALARM
ALARM 1 ─── N PENUGASAN
ALARM 1 ─── 0..1 PENANGANAN
```

Status alarm:

```text
menunggu
diverifikasi
ditolak
selesai
```

## Penugasan

Kolom penting:

```text
id_penugasan
id_alarm
id_tim
id_petugas_armada
id_armada
id_ketua_tim
waktu_penugasan
status_penugasan
keterangan
```

PENTING:

`id_petugas_armada` dan `id_ketua_tim` adalah dua foreign key berbeda yang sama-sama mengacu ke `petugas`.

Keduanya tidak boleh digabung.

Status penugasan:

```text
menunggu
diterima
ditolak
berangkat
selesai
```

## Armada

Status:

```text
tersedia
digunakan
perawatan
```

## Penanganan

Relasi:

```text
PENUGASAN → PENANGANAN
PENANGANAN 1 ─── N DOKUMENTASI
PENANGANAN 1 ─── N KORBAN
PENANGANAN 1 ─── N LOGISTIK
```

Status:

```text
menuju_lokasi
di_lokasi
selesai
```

## Dokumentasi

Jenis:

```text
foto
video
```

## Korban

Menyimpan:

- nama korban
- jenis kelamin
- usia
- kondisi
- status penanganan
- keterangan

## Logistik

Menyimpan:

- nama logistik
- jumlah
- satuan
- kondisi
- keterangan

---

# 9. CLASS/DOMAIN BEHAVIOR

Implementasi tidak boleh hanya membuat CRUD. Behavior harus mengikuti rancangan.

## Pengguna

```text
kirimAlarm()
lihatStatusPenanganan()
lihatRiwayat()
```

## Admin

```text
verifikasiAlarm()
kelolaTim()
kelolaAnggotaTim()
lihatMonitoring()
lihatLaporan()
```

## Petugas

```text
menerimaPenugasan()
konfirmasiPenugasan()
berangkat()
kirimDokumentasi()
buatLaporanPenanganan()
```

## Tim

```text
tambahAnggota()
hapusAnggota()
lihatAnggota()
```

## AnggotaTim

```text
tambahAnggota()
pindahTim()
nonaktifkanAnggota()
```

## Alarm

```text
kirimAlarm()
verifikasi()
ubahStatus()
```

## Penugasan

```text
buatPenugasan()
pilihPetugasArmada()
pilihArmada()
konfirmasiPenugasan()
ubahStatusPenugasan()
```

## Armada

```text
ubahStatus()
lihatStatus()
```

## Penanganan

```text
mulaiPenanganan()
catatKedatangan()
tambahCatatan()
selesaiPenanganan()
```

## Dokumentasi

```text
uploadDokumentasi()
hapusDokumentasi()
lihatDokumentasi()
```

## Logistik

```text
tambahLogistik()
ubahLogistik()
lihatLogistik()
```

---

# 10. ALUR BISNIS UTAMA

## 10.1 Alarm

```text
Masyarakat
   ↓
Login
   ↓
Dashboard
   ↓
Pilih jenis alarm
   ↓
Ambil data lokasi/waktu/dll
   ↓
Kirim alarm
   ↓
Database
   ↓
Notifikasi Admin
```

## 10.2 Verifikasi

```text
Admin
   ↓
Notifikasi alarm
   ↓
Detail alarm
   ↓
Verifikasi
   ↓
Valid?
 ├── Tidak → Tolak
 └── Ya → Terima
```

## 10.3 Penugasan

```text
Alarm terverifikasi
   ↓
Admin memilih tim
   ↓
Konfirmasi
   ↓
Kirim penugasan ke Ketua Tim
   ↓
Ketua Tim menerima
   ↓
Pilih:
 ├── Kerahkan seluruh tim
 └── Pilih petugas
        ↓
     Pilih armada
        ↓
     Petugas menerima tugas
```

## 10.4 Penanganan

```text
Petugas menerima
   ↓
Terima tugas
   ↓
GPS aktif
   ↓
Berangkat
   ↓
Tiba lokasi
   ↓
Penanganan
   ↓
Dokumentasi
   ↓
Korban / Logistik
   ↓
Laporan penanganan
   ↓
Selesai
```

---

# 11. MONITORING

## Admin

Informasi monitoring:

- jenis/level darurat
- lokasi kejadian
- waktu kejadian
- tim yang ditugaskan
- armada
- posisi GPS armada
- status penanganan
- dokumentasi
- laporan penanganan

## Ketua Tim

Informasi monitoring:

- jenis/level darurat
- lokasi kejadian
- anggota tim
- armada
- posisi GPS armada
- status penanganan
- dokumentasi

Akses monitoring harus dibatasi sesuai aktor.

---

# 12. LAPORAN

## Admin

Dapat mengakses:

- laporan alarm
- laporan penugasan
- laporan penanganan
- laporan pengguna
- laporan petugas

## Ketua Tim

Dapat mengakses:

- laporan alarm
- laporan penugasan
- laporan penanganan
- laporan petugas

## Petugas

Dapat mengakses:

- laporan alarm
- laporan penanganan
- laporan penugasan

## Masyarakat

Dapat mengakses:

- laporan alarm
- laporan penanganan

Laporan mendukung filter dan hasil yang berasal dari database.

---

# 13. AUTHENTICATION — SPECIFICATION CONFLICT YANG HARUS DISELESAIKAN

Ada satu keputusan desain yang belum boleh diambil otomatis.

Rancangan memiliki empat aktor:

```text
Masyarakat
Admin
Ketua Tim
Petugas
```

Tetapi database memiliki:

```text
pengguna
admin
petugas
```

dan tidak memiliki tabel `ketua_tim` tersendiri.

Pada rancangan penugasan terdapat:

```text
id_ketua_tim → petugas.id_petugas
```

Sementara spesifikasi teknis sebelumnya mengizinkan pembedaan Ketua Tim melalui:

```text
role
```

atau melalui relasi tim/penugasan.

### ATURAN

Sebelum Fase 2:

- jangan membuat tabel `ketua_tim`
- jangan menghapus atau menambah kolom secara otomatis
- jangan memutuskan mekanisme role secara sepihak
- tampilkan pilihan desain kepada pemilik project

Keputusan ini harus dibuat sebelum implementasi Sanctum dan middleware role.

---

# 14. API PRINCIPLE

API harus mengikuti alur bisnis, bukan hanya struktur tabel.

Kelompok endpoint minimal:

```text
/api/auth
/api/alarm
/api/tim
/api/anggota-tim
/api/penugasan
/api/penanganan
/api/dokumentasi
/api/korban
/api/logistik
/api/monitoring
/api/laporan
```

Authorization harus berbasis aktor dan hak akses yang ditentukan dalam rancangan.

Jangan membuat endpoint tambahan yang mengubah business flow tanpa persetujuan.

---

# 15. FLUTTER

Struktur:

```text
lib/
├── models/
├── services/
├── screens/
│   ├── masyarakat/
│   ├── admin/
│   ├── ketua_tim/
│   └── petugas/
├── widgets/
└── providers/
```

Aplikasi mobile merupakan satu aplikasi Flutter dengan tampilan berbeda berdasarkan aktor.

Fitur penting:

- authentication
- alarm
- status penanganan
- penugasan
- monitoring
- dokumentasi
- laporan
- GPS
- notifikasi sesuai kebutuhan alur

---

# 16. TESTING

## Backend

Setiap fase backend harus diuji sebelum lanjut.

Gunakan:

- PHPUnit/Pest sesuai konfigurasi Laravel
- Postman
- curl
- phpMyAdmin

## Mobile

Gunakan HP Android fisik.

Perintah utama:

```bash
flutter doctor
flutter devices
flutter pub get
flutter analyze
flutter run
```

Testing harus mempertimbangkan:

- GPS
- kamera
- upload file
- jaringan lokal
- authentication token

---

# 17. LOCAL NETWORK

Untuk testing HP fisik:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

Flutter pada HP harus menggunakan:

```text
http://IP-LAPTOP:8000
```

Bukan:

```text
http://localhost:8000
```

HP dan laptop harus berada pada jaringan yang sama.

---

# 18. DEVELOPMENT PHASES

## Fase 1
Setup Laravel + migration 12 tabel + model + seeder.

**Status:** sudah dikerjakan.

## Fase 2
Sanctum + authentication + authorization.

**Status:** belum dimulai.

## Fase 3
API Alarm:

- kirim alarm
- riwayat
- verifikasi

## Fase 4
API Tim, Anggota Tim, dan Penugasan.

## Fase 5
API Penanganan, Dokumentasi, Korban, dan Logistik.

## Fase 6
API Monitoring dan Laporan.

## Fase 7
Flutter:

- setup
- koneksi API
- authentication
- model
- services

## Fase 8
UI Flutter:

- Masyarakat
- Admin
- Ketua Tim
- Petugas

---

# 19. ATURAN ANTIGRAVITY

Antigravity wajib:

1. Membaca Master Specification sebelum setiap fase.
2. Tidak mengubah business flow tanpa persetujuan.
3. Tidak mengubah nama tabel/field tanpa persetujuan.
4. Tidak membuat tabel bisnis baru tanpa persetujuan.
5. Tidak menghapus field karena dianggap tidak diperlukan.
6. Tidak mengganti custom string ID menjadi integer auto-increment.
7. Tidak menggabungkan `id_ketua_tim` dan `id_petugas_armada`.
8. Tidak mencampur backend Laravel dan Flutter.
9. Tidak mengerjakan fase berikutnya sebelum fase sebelumnya diverifikasi.
10. Menampilkan perubahan penting sebelum eksekusi.
11. Jika menemukan konflik spesifikasi, berhenti dan minta keputusan.
12. Memprioritaskan `SIGAP.drawio` untuk business flow dan ERD.

---

# 20. DEFINITION OF DONE

Sebuah fase hanya dianggap selesai jika:

- kode berhasil dibuat
- tidak ada error yang diketahui
- migration/test terkait berhasil
- endpoint terkait dapat diuji
- authorization sesuai aktor
- behavior mengikuti flow rancangan
- tidak ada perubahan spesifikasi tanpa persetujuan
- acceptance criteria fase terpenuhi

---

# 21. CURRENT PROJECT STATUS

```text
[✓] Rancangan SIGAP
[✓] Database specification
[✓] Development plan
[✓] Laravel project
[✓] 12 migration
[✓] 12 model
[✓] Seeder
[✓] Database migration
[✓] Dummy data
[ ] Final authentication decision
[ ] Sanctum
[ ] Role authorization
[ ] API Alarm
[ ] API Tim & Penugasan
[ ] API Penanganan
[ ] API Monitoring & Laporan
[ ] Flutter
[ ] UI 4 aktor
[ ] Integration testing
[ ] Release APK
```

---

# 22. NEXT DECISION

**Jangan mulai Fase 2 sebelum keputusan berikut dibuat:**

> Bagaimana aktor `Ketua Tim` direpresentasikan pada authentication dan authorization, mengingat rancangan ERD menggunakan tabel `petugas` dan `penugasan.id_ketua_tim`, sementara tabel `ketua_tim` tidak berdiri sendiri?

Setelah keputusan ini disetujui, baru:

```text
Authentication
      ↓
Sanctum
      ↓
Role/Actor Authorization
      ↓
API
      ↓
Flutter
```

---

# 23. MASTER RULE

SIGAP bukan sekadar aplikasi CRUD.

Implementasi harus merepresentasikan:

```text
Laporan darurat
      ↓
Verifikasi
      ↓
Penugasan
      ↓
Respon Ketua Tim
      ↓
Respon Petugas
      ↓
GPS / perjalanan
      ↓
Penanganan
      ↓
Dokumentasi
      ↓
Korban & Logistik
      ↓
Laporan
      ↓
Monitoring
```

Setiap fitur baru harus dapat dijelaskan hubungannya dengan flow tersebut.

**END OF MASTER SPECIFICATION**
