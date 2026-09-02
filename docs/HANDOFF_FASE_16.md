# HANDOFF FASE 16 — DEPLOY LARAVEL API + FIREBASE

## Status
**PREPARED** (auto-deploy BLOCKED — butuh akses Render account manual oleh user)

## Target
Online Rp0

## Hosting
**Render.com Free Web Service** (PHP)
- URL target: `https://sigap-api.onrender.com` (setelah deploy)
- Root dir: `sigap-api`
- Build: `composer install --no-dev --optimize-autoloader && php artisan config:cache && php artisan route:cache && php artisan view:cache`
- Start: `php artisan serve --host=0.0.0.0 --port=$PORT`
- Health check path: `/up` (Laravel default) dan `/api/health` (custom JSON)

## Production API
**URL**: `https://sigap-api.onrender.com` (target, **belum aktif — butuh deploy manual**)

**Health endpoint**: `https://sigap-api.onrender.com/api/health` (returns JSON: status, app, environment, database, timestamp)

## Database
**Supabase PostgreSQL** (Fase 15 COMPLETE)
- 21 tabel (12 bisnis + 9 sistem)
- 236 baseline tests
- 20/20 migrations Ran
- Session Pooler (port 5432, sslmode=require)
- 0 demo data (clean state)

## Firebase
**READY** (env-based, menunggu credential)

Laravel FCM HTTP v1 implementation sudah ready. Saat ini `FCM_*` env vars kosong, jadi FCM skip dengan log. Tidak ada error.

Saat FCM production ready:
1. Upload service account JSON ke Render Secret Files
2. Set `FCM_SERVICE_ACCOUNT_PATH=/etc/secrets/firebase-service-account.json`
3. Set `FCM_PROJECT_ID=<project-id>`
4. Redeploy → FCM aktif otomatis

## Deployment
**Status**: BLOCKED — Butuh user manual action:
1. Push GitHub: `git add && git commit && git push origin main`
2. Sign-up Render.com (gratis, no CC)
3. Connect GitHub repo
4. Create Web Service (plan: Free)
5. Set env vars di Render Dashboard (DB password, APP_KEY, FCM optional)
6. Tunggu deploy ~5 menit
7. Verify `https://sigap-api.onrender.com/api/health`

Dokumentasi lengkap: `docs/FASE_16_DEPLOYMENT.md`

## Security
✅ APP_DEBUG=false (di render.yaml)
✅ APP_ENV=production
✅ HTTPS auto (Render Let's Encrypt)
✅ SSL ke Supabase (sslmode=require)
✅ DB password via env var only
✅ .env di .gitignore
✅ Firebase JSON di .gitignore
✅ CORS restrictive
✅ Sanctum token-based auth
✅ Role-based authorization (4 role: masyarakat/admin/ketua_tim/petugas)
✅ Password hashing (bcrypt 12 rounds)
✅ Rate limiting (AUTH=10/min, API=120/min)
✅ Mass assignment protected ($fillable)
✅ Validation via FormRequest
✅ Tidak ada hardcoded secrets di source code

## Testing

### Backend
```
Tests:    237 passed (711 assertions)
Failed:   0
Skipped:   0
```
**Baseline**: 236 → 237 (naik 1 karena HealthCheckTest)
**Assertions**: 709 → 711 (naik 2)

### Flutter
```
flutter test: 208 passed, 0 failed, 0 skipped
flutter analyze: 0 issues
```

### Functional Test
- ✅ Live Supabase test (Fase 15)
- ✅ Backend regression test (237 passed)
- ✅ Flutter regression test (208 passed)
- ⚠️ Public HTTPS test (BLOCKED — butil deploy)

## Online API Test
**STATUS: BLOCKED**

Tidak bisa dilakukan karena:
1. Saya tidak punya akses akun Render user
2. Saya tidak bisa push ke GitHub dari environment ini
3. Saya tidak bisa verify HTTPS endpoint live

**Untuk verify setelah deploy manual**:
```bash
curl https://sigap-api.onrender.com/api/health
# Expected: {"status":"ok","database":"connected",...}
```

## Free Tier Limitations

| Limit | Impact |
|-------|--------|
| Sleep setelah 15 min idle | First request butuh ~1 menit (cold start) |
| Ephemeral filesystem | File dokumentasi hilang saat restart/sleep |
| 750 instance hours/bulan | Cukup untuk SIGAP skala kecil |
| 1 instance only | Single point of failure |
| Outbound SMTP (25/465/587) blocked | OK — SIGAP tidak kirim email |
| No persistent disk | Workaround: Supabase Storage (Fase 17+) |

## Known Limitations

1. **Cold start**: 1 menit wake time setelah idle. Untuk emergency system, ini bisa di-mitigasi dengan keep-alive pinger eksternal (cron-job.org free).
2. **Ephemeral files**: Upload dokumentasi (foto, video) hilang saat service restart. **WAJIB** migrasi ke Supabase Storage di Fase berikutnya.
3. **No shell access**: Debug harus via log stream.
4. **Free subdomain only**: Custom domain butuh paid plan.
5. **No backup otomatis**: Supabase backup perlu setup manual.

## External Dependencies (BLOCKED)

1. **Render.com account** — Butuh user sign-up manual (no CC, free tier permanent)
2. **GitHub push** — Butuh user push manual
3. **Supabase credential** — Sudah ada dari Fase 15, tinggal input ke Render env vars
4. **FCM service account JSON** — Belum tersedia, optional untuk Fase 16 (FCM auto-disabled jika kosong)
5. **APP_KEY** — Butuh generate manual via `php artisan key:generate --show`

## Next Phase
**Fase 17**: Production hardening
- Migrate dokumentasi ke Supabase Storage
- Custom domain (optional, butuh paid plan)
- Backup strategy
- FCM live validation
- Sentry/monitoring
- CI/CD via GitHub Actions

---

## RINGKASAN AKHIR

| Aspek | Status |
|-------|--------|
| Target Rp0 | ✅ TERCAPAI (semua komponen free) |
| Hosting selection | ✅ Render.com (research lengkap, dibandingkan 4 kandidat lain) |
| Code ready | ✅ 237 tests pass, no secrets in repo |
| Health check | ✅ `/api/health` endpoint added |
| Database | ✅ Supabase connected (Fase 15) |
| Firebase prep | ✅ Env-based, ready untuk credential |
| Auto deploy | ❌ BLOCKED (perlu user manual di Render Dashboard) |
| Public HTTPS test | ❌ BLOCKED (perlu deploy dulu) |
| Backend regression | ✅ 237 passed |
| Flutter regression | ✅ 208 passed, 0 analyze issues |
| Security audit | ✅ PASS |

**FASE 16: PREPARED — code siap, deploy aktual butuh user eksekusi manual di Render Dashboard + push ke GitHub**

**Biaya: Rp0 / $0 / bulan**

**STOP** — tidak lanjut ke Fase 17.
