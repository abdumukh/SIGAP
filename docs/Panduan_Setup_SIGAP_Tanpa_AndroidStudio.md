# Panduan Lengkap: Setup, Uji Coba, dan Install Aplikasi SIGAP
### (Tanpa Android Studio)

Dokumen ini melengkapi file `SIGAP_Analisis_dan_Prompt_Antigravity.md` — isinya adalah **langkah teknis dari nol** (install tools) sampai **aplikasi Flutter ter-install di HP**, dengan catatan khusus: **tidak pakai Android Studio sama sekali**. Sebagai gantinya kita pakai kombinasi: Editor **Antigravity**, **Flutter SDK murni**, **Android SDK Command-line Tools** (bukan Android Studio), dan **HP fisik** untuk testing (bukan emulator, karena emulator biasanya diatur lewat AVD Manager di Android Studio).

---

## Bagian A — Persiapan Software (dilakukan manual sekali di awal)

Antigravity/agent bisa menjalankan perintah terminal untuk hal-hal di dalam project (composer install, migration, flutter pub get, dsb), **tapi instalasi tools inti di sistem operasi (PHP, MySQL, Flutter SDK, Android SDK, JDK) sebaiknya kamu lakukan sendiri dulu di luar Antigravity**, karena ini menyangkut environment variable & installer OS-level.

### A.1 Untuk Backend (Laravel + MySQL + phpMyAdmin)
Cara paling praktis (satu paket, tidak perlu install PHP/MySQL/phpMyAdmin terpisah):

| Tools | Fungsi | Link resmi |
|---|---|---|
| **Laragon** (Windows) atau **XAMPP** (Windows/Mac/Linux) | Paket PHP + MySQL + phpMyAdmin + Apache/Nginx dalam satu installer | laragon.org / apachefriends.org |
| **Composer** | Package manager PHP, dipakai untuk install Laravel | getcomposer.org |
| **Git** | Version control | git-scm.com |

**Langkah:**
1. Install Laragon/XAMPP → jalankan, nyalakan service **MySQL** dan **Apache**.
2. Buka `http://localhost/phpmyadmin` di browser → buat database baru bernama `sigap_db`.
3. Install Composer (cek dengan `composer -V` di terminal).
4. Install Git (cek dengan `git --version`).

### A.2 Untuk Mobile (Flutter TANPA Android Studio)
Ini bagian yang perlu perhatian khusus karena biasanya tutorial Flutter menyuruh install Android Studio. Kita skip itu dan pakai **command-line tools saja**:

| Tools | Fungsi |
|---|---|
| **Flutter SDK** | Download langsung dari flutter.dev (bukan lewat Android Studio) |
| **JDK (Java Development Kit) 17** | Wajib untuk build Android, install terpisah (misal Temurin/Adoptium) |
| **Android SDK Command-line Tools** | Versi ringan dari Android SDK, tanpa IDE — download dari developer.android.com/studio (scroll ke bagian "Command line tools only") |
| **Antigravity / VS Code** | Sebagai editor kode (sudah kamu pakai) |

**Langkah instalasi (garis besar, sesuaikan OS kamu):**

1. **Download & extract Flutter SDK** ke folder tetap, misal `C:\flutter` (Windows) atau `~/flutter` (Mac/Linux).
2. **Tambahkan Flutter ke PATH** environment variable sistem, supaya perintah `flutter` bisa dipanggil dari terminal mana saja.
3. **Install JDK 17**, catat lokasi install-nya (`JAVA_HOME`).
4. **Download Android SDK Command-line Tools** (file zip kecil, bukan Android Studio yang 1GB+), extract ke folder misal `~/Android/sdk/cmdline-tools/latest`.
5. Set environment variable `ANDROID_HOME` / `ANDROID_SDK_ROOT` mengarah ke folder SDK tadi, tambahkan `platform-tools` dan `cmdline-tools/latest/bin` ke PATH.
6. Jalankan `sdkmanager` dari terminal untuk install komponen yang dibutuhkan:
   ```
   sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   sdkmanager --licenses
   ```
   (ketik `y` untuk menyetujui semua lisensi)
7. Jalankan **`flutter doctor`** di terminal — ini adalah command pengecekan bawaan Flutter. Pastikan semua centang hijau **kecuali baris "Android Studio"** (boleh merah/warning, tidak masalah karena memang tidak dipakai). Yang penting: Flutter SDK ✅, Android toolchain ✅, Connected device (nanti setelah HP disambung) ✅.
8. Karena tanpa Android Studio berarti **tanpa AVD Manager (emulator)**, cara testing yang dipakai adalah **HP Android fisik**:
   - Di HP: Settings → About phone → tap "Nomor bentukan/Build number" 7x sampai muncul "Anda sekarang developer".
   - Masuk ke Settings → System → Developer options → aktifkan **USB Debugging**.
   - Sambungkan HP ke komputer via kabel USB, pilih mode "File Transfer/MTP" atau "USB debugging" saat muncul prompt di HP.
   - Cek dengan `flutter devices` di terminal — HP kamu harus muncul di daftar.

> Kalau nanti butuh emulator tanpa Android Studio, sebenarnya masih bisa lewat `avdmanager` (bagian dari cmdline-tools) untuk membuat AVD via terminal — tapi ini opsional, **testing di HP fisik jauh lebih simpel** untuk kasus SIGAP karena butuh GPS & kamera asli yang tidak selalu akurat di emulator.

### A.3 Setup Editor Antigravity
- Buka folder project (nanti akan ada 2 folder: `sigap-api` dan `sigap_mobile`) di Antigravity.
- Pastikan Antigravity punya akses terminal/shell untuk menjalankan perintah `composer`, `php artisan`, `flutter`, dll — ini yang akan dipakai di semua prompt.

---

## Bagian B — Alur Kerja End-to-End (urutan yang harus diikuti)

Gunakan prompt dari file `SIGAP_Analisis_dan_Prompt_Antigravity.md` di titik-titik yang ditandai di bawah.

```
[1] Install tools (Bagian A)               <- kamu lakukan manual, sekali saja
        |
[2] Kirim Prompt 0 (konteks)                <- ke Antigravity
        |
[3] Kirim Prompt 1 (setup Laravel + DB)     <- Antigravity buat project sigap-api
        |
[4] Uji coba backend tahap awal             <- lihat Bagian C.1
        |
[5] Kirim Prompt 2 - 6 (API modul)          <- satu per satu, uji tiap tahap
        |
[6] Kirim Prompt 7 (setup Flutter)          <- Antigravity buat project sigap_mobile
        |
[7] Sambungkan HP, jalankan flutter run     <- lihat Bagian C.2
        |
[8] Kirim Prompt 8 (UI per role)            <- uji tiap role di HP langsung
        |
[9] Build APK release & install ke HP       <- lihat Bagian D
```

---

## Bagian C — Cara Uji Coba di Tiap Tahap

### C.1 Uji Coba Backend Laravel (setelah Prompt 1-6)
Backend Laravel diuji **tanpa perlu aplikasi mobile dulu**, cukup pakai tool testing API:

1. Jalankan server: di terminal folder `sigap-api`, jalankan:
   ```
   php artisan serve
   ```
   Default akan jalan di `http://127.0.0.1:8000`.
2. Buka **phpMyAdmin** (`http://localhost/phpmyadmin`) → cek tabel `sigap_db` sudah terbentuk sesuai migration, dan data seeder sudah masuk.
3. Install **Postman** (postman.com, gratis) atau pakai extension "Thunder Client" di VS Code/Antigravity kalau tersedia, untuk mengetes tiap endpoint tanpa perlu bikin UI dulu:
   - Test `POST http://127.0.0.1:8000/api/pengguna/register` dengan body JSON contoh.
   - Test `POST http://127.0.0.1:8000/api/pengguna/login` → salin token Sanctum yang dikembalikan.
   - Test endpoint lain dengan menambahkan header `Authorization: Bearer <token>`.
4. Minta Antigravity juga menjalankan test otomatis (kalau kamu pakai PHPUnit/Pest) sebagai lapisan verifikasi tambahan — cukup minta di prompt: *"buatkan juga automated test untuk endpoint ini dan jalankan"*.

**Baru lanjut ke Flutter setelah semua endpoint di Postman merespons dengan benar.**

### C.2 Uji Coba Aplikasi Flutter (setelah Prompt 7-8)
1. Sambungkan HP via USB (pastikan USB Debugging aktif, lihat Bagian A.2 poin 8).
2. Di terminal folder `sigap_mobile`, jalankan:
   ```
   flutter devices
   ```
   Pastikan HP kamu terdeteksi (muncul nama device-nya).
3. Jalankan aplikasi langsung ke HP:
   ```
   flutter run
   ```
   Ini akan compile lalu otomatis install & membuka aplikasi di HP kamu — **ini menggantikan fungsi "Run" di Android Studio**, sepenuhnya lewat terminal.
4. Setiap kali ada perubahan kode dan aplikasi masih berjalan, tekan `r` di terminal untuk **hot reload** (perubahan langsung terlihat tanpa restart penuh) — ini fitur bawaan Flutter CLI, sama seperti di Android Studio.
5. Karena backend Laravel jalan di komputer (`php artisan serve`) dan Flutter jalan di HP fisik yang beda device, base URL API di kode Flutter **harus** memakai **IP lokal komputer**, bukan `localhost` atau `10.0.2.2` (itu khusus emulator):
   - Cek IP komputer: `ipconfig` (Windows) atau `ifconfig`/`ip a` (Mac/Linux), cari alamat seperti `192.168.1.x`.
   - Pastikan HP dan komputer terhubung ke **WiFi yang sama**.
   - Jalankan Laravel dengan: `php artisan serve --host=0.0.0.0 --port=8000`.
   - Base URL di Flutter jadi: `http://192.168.1.x:8000/api`.
   - Sampaikan detail ini ke Antigravity di Prompt 7 kalau IP kamu sudah tahu, atau minta agent membuatnya jadi konfigurasi yang gampang diganti (file config/`.env` Flutter).
6. Test alur end-to-end langsung di HP: kirim alarm sebagai masyarakat → cek muncul di sisi admin (bisa pakai HP kedua/akun beda, atau logout-login gonta-ganti role) → dst sesuai flow.

---

## Bagian D — Build & Install Aplikasi (Final, Tanpa Android Studio)

Setelah aplikasi selesai dan sudah diuji lewat `flutter run`, langkah untuk **menghasilkan file APK yang bisa diinstall permanen** (tidak perlu komputer nyala terus):

1. Di terminal folder `sigap_mobile`, jalankan:
   ```
   flutter build apk --release
   ```
   Proses ini murni command-line, **tidak butuh Android Studio sama sekali** — build tools sudah cukup dari SDK command-line yang diinstall di Bagian A.2.
2. Hasil file APK akan ada di:
   ```
   sigap_mobile/build/app/outputs/flutter-apk/app-release.apk
   ```
3. **Cara install ke HP** (pilih salah satu):
   - **Cara A (via kabel, tercepat):** dengan HP masih tersambung USB, jalankan:
     ```
     flutter install
     ```
     atau
     ```
     adb install build/app/outputs/flutter-apk/app-release.apk
     ```
   - **Cara B (tanpa kabel):** salin file `app-release.apk` ke HP lewat Google Drive/WhatsApp/kabel data biasa, lalu buka file itu langsung dari File Manager di HP dan tap **Install** (HP akan minta izin "Install dari sumber tidak dikenal" untuk APK non-Play Store, aktifkan sekali saja).
4. Untuk membagikan ke pengguna lain (misal tim petugas di lapangan), cukup bagikan file `app-release.apk` itu langsung — tidak perlu upload ke Play Store dulu untuk tahap uji coba/internal.

> Catatan: kalau nanti ingin publish resmi ke Google Play Store, prosesnya beda lagi (perlu app signing key, Play Console, dsb) — tapi itu di luar cakupan uji coba internal ini, kabari saya kalau sudah sampai tahap itu.

---

## Ringkasan Perbedaan dengan Cara "Biasa" (yang pakai Android Studio)

| Fungsi di Android Studio | Pengganti tanpa Android Studio |
|---|---|
| SDK Manager (GUI) | `sdkmanager` via terminal |
| AVD Manager (emulator) | HP fisik via USB debugging (atau `avdmanager` kalau tetap mau emulator) |
| Tombol "Run" hijau | `flutter run` di terminal |
| Logcat (lihat log error) | `flutter run` otomatis menampilkan log real-time di terminal yang sama |
| Build > Generate APK | `flutter build apk --release` |
| Install lewat Device Manager | `flutter install` / `adb install` / salin file APK manual |

Semua langkah di atas 100% bisa dijalankan dari terminal yang diakses Antigravity — jadi kamu bisa minta agent menjalankan sebagian besar perintah ini langsung, kamu hanya perlu melakukan hal-hal fisik (sambung kabel USB, aktifkan USB debugging, install file APK di layar HP).
