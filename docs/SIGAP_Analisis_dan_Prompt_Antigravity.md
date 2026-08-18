# Analisis Sistem SIGAP & Panduan Prompt untuk Google Antigravity

Dokumen ini merangkum hasil analisis dari `rancanganSIGAP.docx` (flowchart, use case, ERD, class diagram, struktur tabel) dan `struktudatabases.docx` (isinya duplikat dari bagian tabel di file pertama), lalu menerjemahkannya menjadi cara kerja dan kumpulan prompt yang bisa langsung dipakai di **Google Antigravity**.

## 0. Stack Teknologi yang Dipakai

| Bagian | Teknologi |
|---|---|
| Editor | Antigravity |
| Backend/API | Laravel (PHP) |
| Database | MySQL |
| DB Management | phpMyAdmin |
| Mobile App | Flutter (Dart) |
| Komunikasi | REST API / JSON |
| Autentikasi | Laravel Sanctum |
| GPS | GPS perangkat mobile (Flutter geolocator) |
| Penyimpanan foto/video | Laravel Storage |
| Version Control | Git |

Arsitekturnya: **Laravel = backend API murni (REST, stateless dengan Sanctum token)**, dan **Flutter = satu aplikasi mobile dengan 4 tampilan/role berbeda** (Masyarakat, Admin, Ketua Tim, Petugas) yang mengonsumsi API tersebut. Semua prompt di bawah sudah disesuaikan dengan stack ini.

---

## 1. Ringkasan Analisis Sistem

**SIGAP** = Sistem Informasi Gawat darurat dan Penanganan (nama diasumsikan dari konteks) — aplikasi pelaporan & penanganan kondisi darurat berbasis lokasi.

### 1.1 Aktor & Peran
| Aktor | Peran utama |
|---|---|
| **Masyarakat** | Login/registrasi, kirim alarm (Darurat/Evakuasi/Laporan), pantau status penanganan |
| **Admin** | Verifikasi alarm, pilih tim, kelola tim & anggota tim, monitoring, lihat laporan |
| **Ketua Tim** | Terima/tolak penugasan, pilih petugas atau kerahkan seluruh tim, monitoring |
| **Petugas** | Terima/tolak penugasan, update status (berangkat → tiba → penanganan), upload dokumentasi |

### 1.2 Alur Kerja Inti (dari flowchart)
1. **Masyarakat** login → pilih jenis alarm (Darurat/Evakuasi/Laporan) → data (lokasi GPS, waktu, cuaca, lalu lintas) tersimpan ke database → menunggu status → pantau progres.
2. **Admin** menerima alarm → verifikasi valid/tidak → jika valid, pilih tim → kirim penugasan → monitoring.
3. **Ketua Tim** menerima penugasan → terima/tolak → jika terima, pilih jenis respon: kerahkan seluruh tim (semua anggota menerima) atau pilih petugas tertentu → kirim penugasan ke petugas.
4. **Petugas** menerima penugasan → terima/tolak → jika terima: berangkat → tiba lokasi → penanganan → upload dokumentasi (foto/video) → monitoring status.

### 1.3 Fitur Utama (dari Use Case Diagram)
- Login/Registrasi
- Kirim Alarm (include: data user, waktu, GPS, cuaca, lalu lintas → trigger notifikasi alarm ke Petugas)
- Verifikasi Alarm (Admin)
- Kelola Tim & Kelola Anggota Tim (Admin)
- Penugasan (Admin/Ketua Tim)
- Dokumentasi (Petugas)
- Status Penanganan
- Monitoring (Admin & Ketua Tim; include lokasi petugas, extend status penanganan)
- Laporan (extend: laporan alarm, laporan penanganan, laporan petugas, laporan pengguna, laporan penugasan)

### 1.4 Struktur Database (12 Tabel)

| # | Tabel | Field Kunci | Relasi |
|---|---|---|---|
| 1 | `pengguna` | PK `id_pengguna`, UNIQUE `email` | 1:N → `alarm` |
| 2 | `admin` | PK `id_admin`, UNIQUE `email` | 1:N → `alarm` (verifikasi) |
| 3 | `petugas` | PK `id_petugas`, UNIQUE `email`, `status_petugas` ENUM(aktif,nonaktif) | 1:N → `anggota_tim`, `penugasan`, `penanganan`, `dokumentasi` |
| 4 | `tim` | PK `id_tim`, `status_tim` ENUM(aktif,nonaktif) | 1:N → `anggota_tim` |
| 5 | `anggota_tim` | PK `id_anggota_tim`, FK `id_tim`, FK `id_petugas` | tabel penghubung Tim–Petugas |
| 6 | `alarm` | PK `id_alarm`, FK `id_pengguna`, lat/long, cuaca, lalu_lintas, `status_alarm` ENUM(menunggu,diverifikasi,ditolak,selesai) | 1:N → `penugasan`; 1:0..1 → `penanganan` |
| 7 | `penugasan` | PK `id_penugasan`, FK `id_alarm`, `id_tim`, `id_petugas_armada`, `id_armada`, `id_ketua_tim`, `status_penugasan` ENUM(menunggu,diterima,ditolak,berangkat,selesai) | ⚠️ `id_petugas_armada` & `id_ketua_tim` sama-sama FK ke `petugas` tapi fungsi beda |
| 8 | `armada` | PK `id_armada`, UNIQUE `nomor_kendaraan`, `status_armada` ENUM(tersedia,digunakan,perawatan) | 1:N → `penugasan` |
| 9 | `penanganan` | PK `id_penanganan`, FK `id_alarm`, `id_penugasan`, `id_petugas`, `status_penanganan` ENUM(menuju_lokasi,di_lokasi,selesai) | 1:N → `dokumentasi`, `korban`, `logistik` |
| 10 | `dokumentasi` | PK `id_dokumentasi`, FK `id_penanganan`, `id_petugas`, `jenis_dokumentasi` ENUM(foto,video) | — |
| 11 | `korban` | PK `id_korban`, FK `id_penanganan`, `jenis_kelamin` ENUM(L,P) | satu penanganan → banyak korban |
| 12 | `logistik` | PK `id_logistik`, FK `id_penanganan` | satu penanganan → banyak logistik |

**Prefix ID:** USR (pengguna), ADM (admin), PET (petugas), TIM, AT (anggota tim), ALM (alarm), TGS (penugasan), ARM (armada), PNG (penanganan), DOC (dokumentasi), KRB (korban), LOG (logistik).

---

## 2. Cara Memakai Antigravity untuk Proyek Ini

Antigravity bekerja berbasis **agent** yang paling efektif kalau diberi konteks lengkap di awal, lalu dipecah ke tugas-tugas bertahap (bukan satu prompt raksasa untuk seluruh sistem). Caranya:

1. **Buat "Knowledge Base" dulu** — sebelum prompt pertama, upload/tempel ke Antigravity: skema database (bagian 1.4 di atas), daftar aktor & flow (bagian 1.2), daftar fitur (1.3), dan stack teknologi (bagian 0). Ini akan jadi rujukan agent di semua task selanjutnya, jadi agent tidak "menebak-nebak" struktur data atau salah pilih framework.
2. **Kerjakan sebagai dua proyek terpisah tapi satu workspace** — folder `sigap-api` (Laravel) dan `sigap-mobile` (Flutter). Ini penting supaya Antigravity tidak mencampur kode PHP dan Dart dalam satu struktur folder.
3. **Mulai dari Planning Mode** — minta agent membuat rencana (task list/artifact) dulu sebelum menulis kode, supaya kamu bisa cek urutan pengerjaan sebelum agent mulai coding.
4. **Pecah per fase** — jangan minta "buatkan semua sistem SIGAP" dalam satu prompt. Urutan yang disarankan:
   - Fase 1: Setup Laravel + skema database (migration) + phpMyAdmin
   - Fase 2: Autentikasi Sanctum & role-based access (4 role)
   - Fase 3: API Modul Alarm (kirim, verifikasi)
   - Fase 4: API Modul Tim & Penugasan
   - Fase 5: API Modul Penanganan, Dokumentasi, Korban, Logistik
   - Fase 6: API Modul Monitoring & Laporan
   - Fase 7: Setup Flutter + koneksi API + Auth
   - Fase 8: UI Flutter per role (Masyarakat, Admin, Ketua Tim, Petugas)
5. **Minta agent verifikasi sendiri** — di tiap fase, minta agent menjalankan/mengetes hasilnya (`php artisan migrate`, `php artisan serve`, `flutter run`, tes endpoint pakai Postman/curl) sebelum lanjut ke fase berikutnya.
6. **Review artifact yang dihasilkan** (walkthrough, task list, diff) sebelum approve — jangan auto-approve semua perubahan besar, terutama migration yang mengubah struktur tabel.

---

## 3. Prompt Siap Pakai untuk Antigravity

Salin blok-blok di bawah ini secara berurutan (satu per giliran chat/task).

### Prompt 0 — Konteks Awal (kirim sekali di awal project/session)

```
Saya sedang membangun sistem bernama SIGAP (Sistem Informasi Gawat Darurat dan Penanganan).
Ini adalah konteks penuh sistem yang harus kamu jadikan acuan di semua task berikutnya.

AKTOR & PERAN:
- Masyarakat: login/registrasi, mengirim alarm (Darurat/Evakuasi/Laporan), memantau status penanganan.
- Admin: menerima & memverifikasi alarm, memilih tim untuk penugasan, mengelola tim & anggota tim, monitoring, melihat laporan.
- Ketua Tim: menerima/menolak penugasan dari admin, memilih jenis respon (kerahkan seluruh tim ATAU pilih petugas tertentu), monitoring.
- Petugas: menerima/menolak penugasan, update status (berangkat → tiba lokasi → penanganan), upload dokumentasi (foto/video), mencatat data korban & logistik.

ALUR UTAMA:
1. Masyarakat kirim alarm dengan data: jenis darurat, lokasi (lat/long), waktu, cuaca, lalu lintas -> status_alarm = menunggu.
2. Admin verifikasi -> jika valid: status_alarm = diverifikasi, admin pilih tim, buat penugasan (status_penugasan = menunggu). Jika tidak valid: status_alarm = ditolak.
3. Ketua tim terima penugasan -> terima/tolak. Jika terima: pilih kerahkan seluruh tim (semua anggota tim menerima) atau pilih petugas spesifik -> penugasan diteruskan ke petugas -> status_penugasan = diterima.
4. Petugas terima/tolak penugasan -> jika terima: status_penugasan = berangkat -> tiba lokasi -> mulai penanganan (status_penanganan = menuju_lokasi -> di_lokasi -> selesai) -> upload dokumentasi -> catat data korban (jika ada) dan logistik yang digunakan -> status_penugasan = selesai.

SKEMA DATABASE (12 tabel, gunakan PERSIS seperti ini, jangan ubah nama field):

1. pengguna: id_pengguna (PK, VARCHAR20), nama (VARCHAR75), no_hp (VARCHAR15), alamat (VARCHAR255), email (VARCHAR100, UNIQUE), password (VARCHAR255, hashed)

2. admin: id_admin (PK, VARCHAR20), nama_admin (VARCHAR75), email (VARCHAR100, UNIQUE), password (VARCHAR255, hashed), no_hp (VARCHAR15)

3. petugas: id_petugas (PK, VARCHAR20), nama_petugas (VARCHAR75), no_hp (VARCHAR15), email (VARCHAR100, UNIQUE), password (VARCHAR255, hashed), alamat (VARCHAR255), status_petugas (ENUM: aktif, nonaktif)

4. tim: id_tim (PK, VARCHAR20), nama_tim (VARCHAR50), note (VARCHAR255), status_tim (ENUM: aktif, nonaktif)

5. anggota_tim: id_anggota_tim (PK, VARCHAR20), id_tim (FK -> tim), id_petugas (FK -> petugas), tanggal_masuk (DATE), status_anggota (ENUM: aktif, nonaktif)

6. alarm: id_alarm (PK, VARCHAR20), id_pengguna (FK -> pengguna), jenis_darurat (VARCHAR30), waktu_alarm (DATETIME), latitude (DECIMAL 10,7), longitude (DECIMAL 10,7), cuaca (VARCHAR50), lalu_lintas (VARCHAR50), status_alarm (ENUM: menunggu, diverifikasi, ditolak, selesai)

7. penugasan: id_penugasan (PK, VARCHAR20), id_alarm (FK -> alarm), id_tim (FK -> tim), id_petugas_armada (FK -> petugas), id_armada (FK -> armada), id_ketua_tim (FK -> petugas), waktu_penugasan (DATETIME), status_penugasan (ENUM: menunggu, diterima, ditolak, berangkat, selesai), note (VARCHAR255).
   CATATAN: id_petugas_armada dan id_ketua_tim SAMA-SAMA foreign key ke tabel petugas, tapi fungsinya berbeda (satu adalah pengemudi/pemegang armada, satu adalah ketua tim yang bertanggung jawab). Jangan digabung jadi satu kolom.

8. armada: id_armada (PK, VARCHAR20), nama_armada (VARCHAR50), jenis_armada (VARCHAR30), nomor_kendaraan (VARCHAR12, UNIQUE), status_armada (ENUM: tersedia, digunakan, perawatan), note (VARCHAR255)

9. penanganan: id_penanganan (PK, VARCHAR20), id_alarm (FK -> alarm), id_penugasan (FK -> penugasan), id_petugas (FK -> petugas), waktu_berangkat (DATETIME), waktu_tiba (DATETIME), waktu_selesai (DATETIME), status_penanganan (ENUM: menuju_lokasi, di_lokasi, selesai), note (VARCHAR255)

10. dokumentasi: id_dokumentasi (PK, VARCHAR20), id_penanganan (FK -> penanganan), id_petugas (FK -> petugas), jenis_dokumentasi (ENUM: foto, video), file_dokumentasi (VARCHAR255), waktu_upload (DATETIME), note (VARCHAR255)

11. korban: id_korban (PK, VARCHAR20), id_penanganan (FK -> penanganan), nama_korban (VARCHAR75), jenis_kelamin (ENUM: L, P), usia (TINYINT UNSIGNED), kondisi (VARCHAR50), status_penanganan (VARCHAR50), note (VARCHAR255)

12. logistik: id_logistik (PK, VARCHAR20), id_penanganan (FK -> penanganan), nama_logistik (VARCHAR75), jumlah (SMALLINT UNSIGNED), satuan (VARCHAR20), kondisi (VARCHAR30), note (VARCHAR255)

RELASI KESELURUHAN:
- pengguna 1:N alarm
- admin 1:N alarm (memverifikasi)
- alarm 1:N penugasan
- alarm 1:0..1 penanganan
- tim 1:N anggota_tim, petugas 1:N anggota_tim
- tim 1:N penugasan, armada 1:N penugasan, petugas N:N penugasan (lewat id_petugas_armada & id_ketua_tim)
- penugasan 1:0..1 penanganan
- petugas 1:N penanganan
- penanganan 1:N dokumentasi, penanganan 1:N korban, penanganan 1:N logistik
- petugas 1:N dokumentasi

Format ID pakai prefix: USR- (pengguna), ADM- (admin), PET- (petugas), TIM-, AT- (anggota tim), ALM- (alarm), TGS- (penugasan), ARM- (armada), PNG- (penanganan), DOC- (dokumentasi), KRB- (korban), LOG- (logistik), diikuti nomor urut 3 digit, contoh: USR-001.

Tolong simpan konteks ini dan gunakan sebagai acuan tetap untuk semua task pengembangan SIGAP yang akan saya berikan setelah ini. Jangan mulai coding dulu — cukup konfirmasi kamu sudah paham strukturnya.
```

### Prompt 1 — Setup Proyek Laravel & Skema Database (MySQL)

```
Buatkan proyek backend Laravel baru bernama "sigap-api" (Laravel versi terbaru yang stabil, PHP 8.2+).
Konfigurasikan koneksi database ke MySQL lokal (asumsikan database bernama `sigap_db`, akan saya buka lewat phpMyAdmin) di file .env.

Buat migration untuk 12 tabel berikut sesuai skema SIGAP yang sudah saya berikan, dengan nama tabel dan kolom PERSIS seperti ini (huruf kecil, snake_case): pengguna, admin, petugas, tim, anggota_tim, alarm, penugasan, armada, penanganan, dokumentasi, korban, logistik.
- Gunakan tipe kolom sesuai spesifikasi (VARCHAR, DATETIME, DECIMAL(10,7), ENUM, TINYINT UNSIGNED, SMALLINT UNSIGNED).
- Primary key semua tabel pakai string VARCHAR(20) (bukan auto-increment integer), karena formatnya custom (contoh: USR-001).
- Buat foreign key constraint sesuai relasi yang sudah dijelaskan, termasuk kasus khusus di tabel `penugasan` (id_petugas_armada DAN id_ketua_tim, keduanya foreign key terpisah ke tabel petugas).
- Buat Eloquent Model untuk tiap tabel lengkap dengan relasi (hasOne/hasMany/belongsTo/belongsToMany) sesuai skema.

Setelah migration dibuat, jalankan `php artisan migrate` dan tunjukkan hasilnya. Buat juga Seeder dengan 1-2 baris data dummy per tabel mengikuti alur: pengguna kirim alarm -> admin verifikasi -> penugasan -> penanganan, supaya saya bisa cek relasinya langsung lewat phpMyAdmin.
```

### Prompt 2 — Autentikasi Laravel Sanctum & Role-Based Access

```
Tambahkan autentikasi API menggunakan Laravel Sanctum untuk 4 role: masyarakat (tabel pengguna), admin, petugas, dan ketua_tim.
Catatan: ketua tim tetap disimpan di tabel `petugas` — bedakan perannya lewat kolom baru `role` atau relasi ke `anggota_tim`/`penugasan.id_ketua_tim`. Tambahkan migration kecil kalau perlu kolom `role` di tabel petugas (ENUM: petugas, ketua_tim).

Kebutuhan:
- Endpoint terpisah: POST /api/pengguna/register, POST /api/pengguna/login untuk masyarakat; POST /api/staff/login untuk admin & petugas/ketua_tim (bedakan lewat email yang terdaftar di tabel masing-masing).
- Password di-hash otomatis (bcrypt bawaan Laravel).
- Sanctum token dikembalikan saat login, dipakai sebagai Bearer token di semua request berikutnya.
- Buat Middleware/Gate untuk role-guard: masyarakat hanya akses endpoint miliknya, admin/petugas/ketua_tim dibedakan lewat middleware `role:admin`, `role:petugas`, `role:ketua_tim`.
- Endpoint GET /api/me mengembalikan data user yang sedang login beserta role-nya.
- Endpoint POST /api/logout untuk revoke token.

Setelah selesai, test dengan curl/Postman: register+login sebagai masyarakat, login sebagai admin, dan pastikan role-guard menolak akses lintas-role (misalnya petugas tidak bisa akses endpoint khusus admin).
```

### Prompt 3 — REST API Modul Alarm & Verifikasi

```
Buat REST API Alarm di Laravel (sigap-api), format response JSON konsisten (status, message, data):
- [Masyarakat] POST /api/alarm — kirim alarm baru. Body: jenis_darurat, latitude, longitude, cuaca, lalu_lintas. id_pengguna diambil dari token login, waktu_alarm otomatis now(), status_alarm default 'menunggu', id_alarm auto-generate format ALM-001, ALM-002, dst.
- [Masyarakat] GET /api/alarm/riwayat — lihat riwayat & status alarm milik sendiri.
- [Admin] GET /api/admin/alarm?status=menunggu — list alarm masuk, bisa difilter status.
- [Admin] PATCH /api/admin/alarm/{id}/verifikasi — body: keputusan (diterima/ditolak), update status_alarm jadi 'diverifikasi' atau 'ditolak'.

Tambahkan Form Request untuk validasi input, dan pastikan otorisasi: masyarakat hanya bisa lihat alarm miliknya, hanya admin yang bisa verifikasi.
Test end-to-end pakai curl/Postman: kirim alarm sebagai masyarakat -> muncul di list admin -> verifikasi -> status berubah dan masyarakat bisa lihat perubahannya di riwayat.
```

### Prompt 4 — REST API Modul Tim, Anggota Tim & Penugasan

```
Buat REST API berikut di Laravel sesuai skema SIGAP:
1. [Admin] CRUD /api/admin/tim (tabel tim) dan CRUD /api/admin/anggota-tim (assign petugas ke tim, cek petugas tidak dobel di tim yang sama & aktif).
2. [Admin] POST /api/admin/penugasan — buat penugasan dari alarm yang sudah 'diverifikasi': pilih id_tim & id_armada, generate id_penugasan format TGS-001, status_penugasan default 'menunggu'.
3. [Ketua Tim] PATCH /api/ketua-tim/penugasan/{id}/respon — body: keputusan (terima/tolak). Jika terima, body tambahan: mode ('seluruh_tim' atau 'pilih_petugas') dan id_petugas_armada jika mode pilih_petugas. id_ketua_tim otomatis dari user login. Update status_penugasan jadi 'diterima' atau 'ditolak'.
4. [Petugas] GET /api/petugas/penugasan — list penugasan yang ditujukan ke petugas ybs (baik lewat mode seluruh_tim maupun pilih_petugas).
5. [Petugas] PATCH /api/petugas/penugasan/{id}/respon — terima/tolak, jika terima ubah status_penugasan jadi 'berangkat'.

Pastikan di kode, id_ketua_tim dan id_petugas_armada ditangani sebagai dua foreign key terpisah ke tabel petugas dengan peran berbeda — jangan digabung jadi satu relasi.
Test alur penuh: admin buat penugasan -> ketua tim terima & kerahkan tim -> petugas terima -> status jadi 'berangkat'.
```

### Prompt 5 — REST API Modul Penanganan, Dokumentasi, Korban, Logistik

```
Buat REST API Penanganan untuk role Petugas di Laravel:
- POST /api/petugas/penanganan — mulai penanganan dari penugasan yang sudah 'berangkat', generate id_penanganan format PNG-001, status_penanganan awal 'menuju_lokasi', waktu_berangkat = now().
- PATCH /api/petugas/penanganan/{id}/status — update status_penanganan (menuju_lokasi -> di_lokasi -> selesai), otomatis isi waktu_tiba saat masuk 'di_lokasi' dan waktu_selesai saat 'selesai'. Saat status jadi 'selesai', otomatis update status_penugasan terkait jadi 'selesai' juga.
- POST /api/petugas/penanganan/{id}/dokumentasi — upload file foto/video pakai Laravel Storage (simpan di storage/app/public/dokumentasi, kembalikan URL public), simpan jenis_dokumentasi, file_dokumentasi, waktu_upload. Generate id_dokumentasi format DOC-001.
- POST /api/petugas/penanganan/{id}/korban — tambah data korban (bisa dipanggil berkali-kali untuk banyak korban dalam satu penanganan). Generate id_korban format KRB-001.
- POST /api/petugas/penanganan/{id}/logistik — catat logistik yang dipakai (bisa berkali-kali). Generate id_logistik format LOG-001.

Pastikan `php artisan storage:link` sudah dijalankan supaya file bisa diakses publik lewat URL.
Test: dari satu penugasan 'berangkat', buat 1 penanganan, ubah status sampai 'selesai', upload 2 dokumentasi, catat 2 korban, catat 2 logistik — verifikasi semuanya tersimpan dengan relasi & file yang benar.
```

### Prompt 6 — REST API Monitoring & Laporan

```
Buat REST API Monitoring dan Laporan di Laravel:
- GET /api/admin/monitoring dan GET /api/ketua-tim/monitoring — tampilkan alarm yang sedang aktif (status diverifikasi/berjalan), lokasi (latitude/longitude) petugas/tim yang sedang bertugas, dan status_penanganan berjalan saat ini.
- GET /api/laporan/alarm, /api/laporan/penanganan, /api/laporan/petugas, /api/laporan/pengguna, /api/laporan/penugasan — masing-masing endpoint terima query param `dari_tanggal`, `sampai_tanggal`, `status` untuk filter.
- Middleware: hanya admin yang boleh akses /api/laporan/pengguna dan /api/laporan/petugas (data sensitif). Ketua tim & petugas hanya bisa lihat laporan yang relevan dengan tim/dirinya sendiri.

Test tiap endpoint laporan dengan beberapa kombinasi filter tanggal & status memakai data dari seeder/hasil testing sebelumnya.
```

### Prompt 7 — Setup Aplikasi Flutter & Koneksi API

```
Buatkan proyek Flutter baru bernama "sigap_mobile" (Dart, null-safety, gunakan state management Provider atau Riverpod — pilih salah satu dan konsisten).
Struktur folder rapi: lib/models, lib/services (API client pakai package `dio` atau `http`), lib/screens (dipisah per role: masyarakat/, admin/, ketua_tim/, petugas/), lib/widgets (komponen reusable), lib/providers atau lib/controllers.

Buat:
1. Base API service yang menyimpan base URL Laravel (buat konstanta yang mudah diganti, contoh: http://10.0.2.2:8000/api untuk emulator Android) dan otomatis menyisipkan Bearer token Sanctum di header request setelah login.
2. Model Dart untuk semua entitas SIGAP (Pengguna, Admin, Petugas, Tim, AnggotaTim, Alarm, Penugasan, Armada, Penanganan, Dokumentasi, Korban, Logistik) dengan fromJson/toJson.
3. Halaman Login & Register yang membedakan alur masyarakat vs staff (admin/petugas/ketua_tim), memanggil endpoint Sanctum dari Prompt 2, dan menyimpan token pakai flutter_secure_storage.
4. Setelah login sukses, arahkan (routing) ke dashboard sesuai role user.

Tambahkan permission untuk lokasi (package `geolocator` + `permission_handler`) dan permission kamera/galeri (package `image_picker`) di AndroidManifest.xml & Info.plist karena akan dipakai di fitur alarm dan dokumentasi.
Jalankan `flutter pub get` dan pastikan project bisa di-build tanpa error.
```

### Prompt 8 — UI Flutter per Role

```
Bangun UI/screen Flutter untuk 4 role berikut, konsumsi API Laravel yang sudah dibuat di Prompt 3-6:

1. Masyarakat: tombol besar kirim alarm dengan 3 pilihan (Darurat/Evakuasi/Laporan) yang otomatis ambil lokasi GPS saat ini (geolocator), lalu kirim ke POST /api/alarm. Halaman riwayat alarm dengan status real-time (menunggu/diverifikasi/ditolak/selesai).

2. Admin: list alarm masuk dengan tombol verifikasi/tolak, halaman kelola tim & anggota tim (CRUD sederhana), form buat penugasan (pilih alarm terverifikasi + tim + armada), halaman monitoring (peta atau list lokasi tim aktif), halaman laporan dengan filter tanggal.

3. Ketua Tim: list penugasan masuk dengan tombol terima/tolak, jika terima muncul pilihan "Kerahkan Seluruh Tim" atau "Pilih Petugas" (dropdown anggota tim aktif), halaman monitoring timnya sendiri.

4. Petugas: list penugasan masuk dengan tombol terima/tolak, setelah terima tombol update status berangkat -> tiba lokasi -> mulai penanganan -> selesai, form upload dokumentasi (pilih dari kamera/galeri pakai image_picker, upload ke endpoint Storage), form tambah data korban (bisa berkali-kali/dynamic list), form tambah logistik (bisa berkali-kali/dynamic list).

Gunakan desain simple, kontras tinggi, tombol besar dan mudah ditekan (karena dipakai di lapangan/situasi darurat, kemungkinan satu tangan atau kondisi panik). Tampilkan loading state & error handling (misal GPS mati, koneksi API gagal) di setiap aksi.
Setelah selesai, jalankan `flutter run` dan tunjukkan hasilnya di emulator/preview untuk tiap role.
```

---

### Tips Tambahan
- Kirim **Prompt 0** dulu di awal session Antigravity sebagai konteks tetap, baru lanjut Prompt 1 sampai 8 secara berurutan — satu prompt per giliran, jangan digabung.
- Kalau Antigravity punya fitur upload file/context, kamu bisa langsung upload dua file docx aslinya (atau file ini) sebagai referensi tambahan selain Prompt 0.
- Karena base URL API di Flutter (`10.0.2.2:8000`) hanya berlaku untuk emulator Android, kalau kamu tes di HP fisik, minta agent ganti ke IP lokal komputer kamu (misal `192.168.x.x:8000`) dan pastikan `php artisan serve --host=0.0.0.0`.
- Selalu minta agent **menjalankan & menguji** hasil tiap fase (migrate, serve, curl, flutter run) sebelum lanjut ke prompt berikutnya, supaya bug tidak menumpuk antara backend Laravel dan mobile Flutter.
