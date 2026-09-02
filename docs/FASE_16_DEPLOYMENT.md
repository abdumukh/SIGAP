# FASE 16 — DEPLOYMENT GUIDE

**Project**: SIGAP — Sistem Informasi Gawat Darurat dan Penanganan BPBD Kabupaten Tegal
**Phase**: 16 — Deploy Laravel API + Firebase FCM production
**Target**: Online Rp0
**Date**: 2026-09-02
**Status**: PREPARED (auto-deploy BLOCKED — requires manual Render account)

---

## 1. HOSTING YANG DIPILIH

**Render.com** — Free Web Service (PHP)

### Alasan Pemilihan

| Kriteria | Render.com | Keterangan |
|----------|-----------|------------|
| Biaya | **$0/bulan** | Permanen free tier |
| Kartu kredit | **Tidak perlu** | Cukup sign-up via email/GitHub |
| PHP 8.2 support | ✅ | Runtime PHP native |
| Laravel support | ✅ | `composer install` di build command |
| HTTPS | ✅ Auto | Let's Encrypt otomatis |
| External PostgreSQL | ✅ | Outbound ke Supabase pooler |
| Deployment | ✅ | Git push atau `render.yaml` |
| Free subdomain | ✅ | `*.onrender.com` |
| Cold start | ⚠️ | Sleep setelah 15 menit idle (1 menit wake) |
| Ephemeral filesystem | ⚠️ | File uploaded akan hilang saat restart/sleep |
| Build minutes | 500/bulan | Cukup untuk SIGAP |
| Free instance hours | 750/bulan | Cukup untuk SIGAP |

### Kandidat yang Dievaluasi

| Platform | Free? | CC? | PHP | Verdict |
|----------|-------|-----|-----|---------|
| **Render.com** | ✅ | ❌ | ✅ | **DIPILIH** |
| Railway | $1/bulan | ⚠️ | ✅ | Runner-up, perlu GitHub verification |
| Fly.io | ❌ | ✅ Wajib | ✅ | TIDAK (wajib CC) |
| Koyeb | ❌ ($29+ minimum) | N/A | ✅ | TIDAK (berbayar) |
| Heroku | ❌ (no free tier) | N/A | ✅ | TIDAK |

### Limitasi Render Free Tier

1. **Spinning down setelah 15 menit idle** — service sleep, request berikutnya butuh ~1 menit untuk wake up
2. **Ephemeral filesystem** — file upload (`storage/app/public/dokumentasi/*`) hilang saat restart/deploy/sleep
3. **750 free instance hours per bulan** — cukup untuk SIGAP skala kecil
4. **500 build pipeline minutes per bulan** — cukup untuk 30+ deploys
5. **No persistent disk** — file storage butuh solusi external untuk production
6. **Outbound ke port 5432 (PostgreSQL)** — aktif dan tanpa limit khusus
7. **Outbound ke port 25/465/587 (SMTP)** — DIBLOKIR (tidak jadi masalah karena SIGAP tidak kirim email)
8. **Free Render Postgres** — expire 30 hari (TIDAK dipakai karena SIGAP pakai Supabase)

---

## 2. ARSITEKTUR PRODUCTION

```
Flutter Mobile
   │
   │ HTTPS
   ▼
Render.com (Free Web Service)
   │
   │ PHP 8.2 + Laravel 12 + PHP built-in server
   │ URL: https://sigap-api.onrender.com
   │
   ├─ /api/auth/login, /api/auth/me, /api/auth/logout
   ├─ /api/alarms/* (CRUD + verify/reject/complete)
   ├─ /api/tim/* (team management)
   ├─ /api/penugasan/* (assignment)
   ├─ /api/penanganan/* (handling)
   ├─ /api/dokumentasi/* (documentation upload)
   ├─ /api/korban/* (victim data)
   ├─ /api/logistik/* (logistics)
   ├─ /api/notifikasi/* (in-app notifications)
   ├─ /api/monitoring, /api/laporan
   ├─ /api/pengguna, /api/device-tokens
   ├─ /api/test-role/{admin,masyarakat,ketua-tim,petugas,staff}
   └─ /api/health (JSON health check)
   │
   │ PostgreSQL (outbound TCP 5432)
   ▼
Supabase Session Pooler
   │
   │ sslmode=require
   ▼
Supabase PostgreSQL (12 business tables + 9 system tables)

Render.com (Laravel)
   │
   │ HTTPS outbound ke FCM
   ▼
Firebase Cloud Messaging HTTP v1
   │
   ▼
Android device (FCM token)
```

---

## 3. DEPLOYMENT STEPS (MANUAL — Butuh Akses Render)

### Prasyarat
- Akun Render.com (sign-up via GitHub, **tidak perlu CC**)
- Repository SIGAP sudah di-push ke GitHub: `https://github.com/abdumukh/SIGAP.git`
- Database Supabase sudah live (Fase 15 COMPLETE)
- Koneksi internet stabil

### Step A — Push Repository ke GitHub

```bash
cd D:\DATA-DATA\Documents\KULIAH\PKL\sigap\SIGAP
git add render.yaml .gitignore sigap-api/tests/Feature/HealthCheckTest.php \
        sigap-api/routes/api.php sigap-api/.env.example
git commit -m "Fase 16: Render deploy config + /api/health endpoint"
git push origin main
```

### Step B — Buat Service di Render

1. Login ke https://dashboard.render.com
2. Klik **New** → **Web Service**
3. Pilih **"Build and deploy from a Git repository"**
4. Klik **"Connect GitHub"** dan authorize
5. Pilih repository `abdumukh/SIGAP`
6. Isi detail:
   - **Name**: `sigap-api`
   - **Region**: Singapore (ap-southeast-1, terdekat Indonesia)
   - **Branch**: `main`
   - **Root Directory**: `sigap-api`
   - **Runtime**: `PHP`
   - **Build Command**:
     ```
     composer install --no-dev --optimize-autoloader && php artisan config:cache && php artisan route:cache && php artisan view:cache
     ```
   - **Start Command**:
     ```
     php artisan serve --host=0.0.0.0 --port=$PORT
     ```
   - **Plan**: `Free`
7. Klik **"Create Web Service"**

### Step C — Environment Variables di Render

Di Render Dashboard → Service → **Environment** → tambahkan variabel-variabel berikut:

| Key | Value | Catatan |
|-----|-------|---------|
| `APP_ENV` | `production` | |
| `APP_DEBUG` | `false` | WAJIB |
| `APP_KEY` | `<generate dengan php artisan key:generate --show>` | **JANGAN SHARE** |
| `APP_URL` | `https://sigap-api.onrender.com` | |
| `APP_TIMEZONE` | `Asia/Jakarta` | |
| `APP_LOCALE` | `id` | |
| `DB_CONNECTION` | `pgsql` | |
| `DB_HOST` | `<dari Supabase Session Pooler>` | **JANGAN SHARE** |
| `DB_PORT` | `5432` | |
| `DB_DATABASE` | `postgres` | |
| `DB_USERNAME` | `postgres.<REF>` | **JANGAN SHARE** |
| `DB_PASSWORD` | `<dari Supabase>` | **JANGAN SHARE** |
| `DB_SSLMODE` | `require` | |
| `SESSION_DRIVER` | `database` | |
| `CACHE_STORE` | `database` | |
| `QUEUE_CONNECTION` | `database` | |
| `FILESYSTEM_DISK` | `local` | |
| `LOG_CHANNEL` | `stderr` | Logs keluar ke Render dashboard |
| `SANCTUM_STATEFUL_DOMAINS` | `sigap-api.onrender.com,localhost,127.0.0.1` | |
| `CORS_ALLOWED_ORIGINS` | `https://sigap-api.onrender.com` | Restrictive untuk mobile |
| `FCM_SERVICE_ACCOUNT_PATH` | (kosongkan untuk sekarang) | Akan diisi saat FCM production |
| `FCM_PROJECT_ID` | (kosongkan untuk sekarang) | |
| `FCM_SERVER_KEY` | (kosongkan untuk sekarang) | |

**Generate APP_KEY** lokal:
```bash
cd sigap-api
php artisan key:generate --show
# Output: base64:xxxxx (contoh)
# Copy ke Render env var APP_KEY
```

**Dapatkan DB credential Supabase**:
1. Login ke https://supabase.com/dashboard
2. Pilih project SIGAP
3. **Settings** → **Database**
4. **Connection string** → **Session Pooler** → copy bagian host, port, database, username, password

### Step D — Tunggu Deploy Selesai

- Render otomatis clone repo + build + start service
- Build time: ~3-5 menit (composer install + cache)
- Tunggu sampai status **"Live"**

### Step E — Verifikasi Health

Buka browser:
```
https://sigap-api.onrender.com/api/health
```

Response expected:
```json
{
  "status": "ok",
  "app": "SIGAP API",
  "environment": "production",
  "database": "connected",
  "timestamp": "2026-09-02T10:30:00+07:00"
}
```

**WAJIB tunggu ~1 menit** untuk first request (cold start).

---

## 4. ENVIRONMENT VARIABLES (Production)

| Variable | Value (Render) | Sumber |
|----------|----------------|--------|
| `APP_ENV` | `production` | hardcoded di `render.yaml` |
| `APP_DEBUG` | `false` | hardcoded di `render.yaml` |
| `APP_KEY` | `<32-char base64>` | generate manual |
| `APP_URL` | `https://sigap-api.onrender.com` | setelah deploy |
| `DB_CONNECTION` | `pgsql` | hardcoded di `render.yaml` |
| `DB_HOST` | `aws-0-ap-southeast-1.pooler.supabase.com` | Supabase Session Pooler |
| `DB_PORT` | `5432` | hardcoded |
| `DB_DATABASE` | `postgres` | hardcoded |
| `DB_USERNAME` | `postgres.<PROJECT_REF>` | Supabase |
| `DB_PASSWORD` | `<secret>` | Supabase generated |
| `DB_SSLMODE` | `require` | hardcoded |
| `SESSION_DRIVER` | `database` | hardcoded (pakai Supabase) |
| `CACHE_STORE` | `database` | hardcoded (pakai Supabase) |
| `QUEUE_CONNECTION` | `database` | hardcoded (pakai Supabase) |
| `FILESYSTEM_DISK` | `local` | hardcoded |
| `LOG_CHANNEL` | `stderr` | hardcoded (Render log capture) |
| `SANCTUM_STATEFUL_DOMAINS` | `sigap-api.onrender.com,localhost,127.0.0.1` | manual |
| `CORS_ALLOWED_ORIGINS` | `https://sigap-api.onrender.com` | manual |
| `FCM_*` | (kosong) | belum ready |

---

## 5. SUPABASE CONNECTION

- **Type**: Session Pooler (port 5432, NOT Transaction Pooler port 6543)
- **SSL**: `sslmode=require` (mandatory)
- **Alasan pakai Session Pooler**:
  - Mendukung prepared statements (Penting untuk Laravel Eloquent)
  - Persistent connection untuk long-running requests
  - Transaction Pooler di port 6543 BISA drop prepared statements

---

## 6. FIREBASE FCM CONFIGURATION

### Status: READY (env-based, menunggu credential)

Laravel sudah support FCM HTTP v1 (preferred) + Legacy fallback. Konfigurasi via env:

| Variable | Purpose |
|----------|---------|
| `FCM_SERVICE_ACCOUNT_PATH` | Path ke service account JSON (mis. `/var/www/sigap/firebase-service-account.json`) |
| `FCM_PROJECT_ID` | Firebase project ID |
| `FCM_SERVER_KEY` | Legacy fallback (deprecated) |

### Cara Setup FCM Production

1. Buka Firebase Console https://console.firebase.google.com
2. Pilih/add project SIGAP
3. **Project Settings** → **Service Accounts** → **Generate New Private Key**
4. Download JSON file → **JANGAN commit ke Git**
5. Upload ke Render Dashboard:
   - Service → **Environment** → **Secret Files**
   - Filename: `firebase-service-account.json`
   - Path: `/etc/secrets/firebase-service-account.json`
6. Set `FCM_SERVICE_ACCOUNT_PATH=/etc/secrets/firebase-service-account.json`
7. Set `FCM_PROJECT_ID=<project-id-dari-firebase>`
8. Redeploy

### FCM Behavior tanpa credential

```php
// FcmNotificationService::isConfigured() return false
// sendEmergencyAlert() → Log::info("FCM: skipped (not configured). Pending external Firebase setup.")
// TIDAK error, TIDAK crash — service jalan normal
// In-app notification (table notifikasi) tetap tersimpan di Supabase
```

---

## 7. STORAGE

### Status: EPHEMERAL (keterbatasan Render Free)

| Aspek | Status |
|-------|--------|
| `storage/app/public/dokumentasi/*` | **Hilang saat restart/sleep** |
| `storage/framework/sessions/*` | Hilang (tapi pakai DB session, OK) |
| `storage/logs/laravel.log` | Hilang (tapi pakai `LOG_CHANNEL=stderr` ke Render log) |
| `public/storage` (symlink) | Hilang (perlu re-create di build) |

### Mitigasi untuk Dokumentasi Files

**JANGAN** gunakan local `public` disk untuk production-grade. Opsi:

| Opsi | Biaya | Status |
|------|-------|--------|
| **Supabase Storage** | Free 1 GB | **REKOMENDASI** (S3-compatible, free tier) |
| Cloudflare R2 | Free 10 GB | Alternatif |
| Local public disk | Gratis tapi ephemeral | OK untuk development |

**Catatan**: Migrasi ke Supabase Storage adalah Fase 17+. Untuk sekarang, dokumentasi file akan hilang saat service restart. Ini limitation yang harus diterima di free tier.

---

## 8. QUEUE & SCHEDULER

| Aspek | Status |
|-------|--------|
| Queue jobs (`ShouldQueue`) | **Tidak ada** di codebase |
| Background workers | **Tidak dibutuhkan** |
| Scheduler (cron) | **Tidak ada scheduled tasks** |
| Sync execution | Ya — semua proses synchronous di request |

### Notification Flow (Synchronous)

1. User create alarm → `AlarmService::create`
2. Setelah DB commit → `EmergencyNotificationDispatcher::dispatchNewAlarm`
3. `FcmNotificationService::sendEmergencyAlert` dipanggil langsung (sync)
4. FCM HTTP request ke Google API (timeout ~10 detik)
5. Response return ke user

**Verdict**: Sync OK untuk free tier. Tidak butuh `php artisan queue:work`.

---

## 9. SECURITY

### Hardening yang Diterapkan

| Item | Status |
|------|--------|
| `APP_DEBUG=false` | ✅ di `render.yaml` |
| `APP_ENV=production` | ✅ |
| HTTPS only (Render auto) | ✅ |
| SSL ke Supabase (`sslmode=require`) | ✅ |
| Database password via env var (no hardcode) | ✅ |
| CORS restrictive (`CORS_ALLOWED_ORIGINS`) | ✅ |
| `.env` di `.gitignore` | ✅ |
| Firebase JSON tidak di-commit | ✅ |
| APP_KEY via env var | ✅ (generate manual) |
| No secrets in `render.yaml` | ✅ (hanya non-secret defaults) |
| Laravel Sanctum token-based auth | ✅ |
| Rate limiting (`AUTH_RATE_LIMIT=10`) | ✅ |
| Mass assignment protection (`$fillable`) | ✅ (sudah ada di Fase 1-15) |
| Validation via FormRequest | ✅ |
| Password hashing (`Hash::make` di models) | ✅ |
| Authorization via `role:` middleware | ✅ |

### Yang TIDAK Boleh Dilakukan

- ❌ Commit `.env` ke Git
- ❌ Hardcode `DB_PASSWORD` di source
- ❌ Commit `firebase-service-account.json`
- ❌ Set `APP_DEBUG=true` di production
- ❌ Buka CORS wildcard (`*`) untuk mobile
- ❌ Disable SSL ke Supabase

---

## 10. API TEST RESULT

### Local Tests (pre-deploy)

```
Tests:    237 passed (711 assertions)
Duration: ~16s
Failed:   0
Skipped:  0
```

**Catatan**: Jumlah test naik dari 236 → 237 karena penambahan `HealthCheckTest`. Assertions naik 709 → 711 (2 assertion baru).

### Post-Deploy Public Tests (Manual — butuh Render account)

Setelah deploy sukses, jalankan dari terminal lokal:

```bash
# 1. Health check
curl https://sigap-api.onrender.com/api/health

# 2. Register masyarakat
curl -X POST https://sigap-api.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"nama":"Test User","no_hp":"081230000001","alamat":"Test","email":"test-deploy@sigap.test","password":"Test123!","password_confirmation":"Test123!"}'

# 3. Login
TOKEN=$(curl -s -X POST https://sigap-api.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test-deploy@sigap.test","password":"Test123!"}' | jq -r '.data.token')

# 4. Get me
curl https://sigap-api.onrender.com/api/auth/me -H "Authorization: Bearer $TOKEN"

# 5. Logout
curl -X POST https://sigap-api.onrender.com/api/auth/logout -H "Authorization: Bearer $TOKEN"
```

**Catatan**: First request setelah idle 15 menit akan butuh ~1 menit cold start.

---

## 11. KNOWN LIMITATIONS

| # | Limitasi | Severity | Mitigasi |
|---|----------|----------|----------|
| 1 | Sleep setelah 15 menit idle | Medium | Acceptable — first request delay ~1 min |
| 2 | Filesystem ephemeral | High untuk dokumentasi | Migrasi ke Supabase Storage di Fase 17+ |
| 3 | 750 instance hours/bulan | Low | Cukup untuk skala SIGAP |
| 4 | Cold start 1 menit | Medium | Acceptable untuk emergency system (cache via keep-alive pinger) |
| 5 | Free subdomain only | Low | Custom domain butuh paid plan |
| 6 | 1 instance only | Low | Single instance cukup untuk MVP |
| 7 | No background workers | OK | Tidak ada async job di SIGAP |
| 8 | No SSH/shell | Low | Gunakan Render log stream |

---

## 12. CARA REDEPLOY

### Auto Deploy
- Push ke GitHub `main` branch → Render otomatis rebuild + redeploy
- Default: autoDeploy aktif

### Manual Deploy
1. Login Render Dashboard
2. Pilih service `sigap-api`
3. Klik **"Manual Deploy"** → **"Deploy latest commit"**

### Rollback
1. Render Dashboard → Service → **"Events"**
2. Pilih commit sebelumnya
3. Klik **"Rollback to this commit"**

---

## 13. CARA MELIHAT LOG

1. Render Dashboard → Service → **"Logs"**
2. Live tail atau filter by time
3. Logs dari `LOG_CHANNEL=stderr` muncul di sini
4. Logs dari query SQL, error, FCM skipped, dll — semua visible

---

## 14. BIAYA

| Item | Biaya |
|------|-------|
| Render.com Free | **$0** |
| Supabase Free | **$0** (500 MB DB, 1 GB storage, 2 GB egress) |
| Firebase FCM | **$0** (unlimited) |
| Domain custom | $0 (pakai `*.onrender.com`) |
| SSL | $0 (Render auto Let's Encrypt) |
| **TOTAL** | **Rp0 / $0** |

---

## 15. CHECKLIST DEPLOYMENT

- [x] Repository sudah berisi `render.yaml`
- [x] Repository berisi `.gitignore` exclude secrets
- [x] `.env.example` updated dengan template production
- [x] `/api/health` endpoint ditambahkan
- [x] 237 backend tests passed
- [x] 208 Flutter tests passed
- [x] Flutter analyze 0 issues
- [ ] **Push ke GitHub** (manual — butuh akses user)
- [ ] **Buat Render service** (manual — butuh akun Render)
- [ ] **Set env vars di Render** (manual — butuh Supabase credential)
- [ ] **Verify health endpoint** (setelah deploy)
- [ ] **Run API smoke test** (setelah deploy)

---

## 16. NEXT STEPS (Fase 17+)

1. **Migrate dokumentasi ke Supabase Storage** — fix ephemeral FS
2. **Custom domain** (e.g. `api.sigap-tegal.id`) — optional
3. **Upgrade Render ke Starter plan** — eliminate cold start, get persistent disk
4. **Setup Cloudflare** sebagai CDN + DDoS protection
5. **Firebase production validation** — credential + device test
6. **Setup monitoring** (Sentry / Better Stack / Logtail)
7. **CI/CD** via GitHub Actions
8. **Backup strategy** untuk Supabase

---

**Status akhir**: PREPARED. Code siap deploy. Deploy aktual membutuhkan user untuk manual create Render service (butuh akses akun Render) dan isi Supabase credential di env vars.
