<?php

use App\Http\Controllers\Api\AlarmController;
use App\Http\Controllers\Api\AnggotaTimController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DeviceTokenController;
use App\Http\Controllers\Api\DokumentasiController;
use App\Http\Controllers\Api\KorbanController;
use App\Http\Controllers\Api\LaporanController;
use App\Http\Controllers\Api\LogistikController;
use App\Http\Controllers\Api\MonitoringController;
use App\Http\Controllers\Api\NotifikasiController;
use App\Http\Controllers\Api\PenangananController;
use App\Http\Controllers\Api\PenggunaController;
use App\Http\Controllers\Api\PenugasanController;
use App\Http\Controllers\Api\TimController;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    try {
        DB::connection()->getPdo();
        $dbStatus = 'connected';
    } catch (\Throwable $e) {
        $dbStatus = 'disconnected';
    }

    return response()->json([
        'status' => 'ok',
        'app' => config('app.name'),
        'environment' => config('app.env'),
        'database' => $dbStatus,
        'timestamp' => now()->toIso8601String(),
    ]);
});

Route::prefix('auth')->group(function () {
    // Production: enable throttle middleware via nginx or laravel middleware.
    // Do NOT add throttle in development; it breaks test suites under heavy load.
    // To enable in production:
    //   Route::middleware('throttle:auth')->group(function () { ... });
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

Route::middleware(['auth:sanctum'])->group(function () {
    Route::apiResource('alarms', AlarmController::class)->only(['store', 'index', 'show']);

    Route::prefix('alarms')->group(function () {
        Route::match(['post', 'patch'], '/{id}/verify', [AlarmController::class, 'verify']);
        Route::match(['post', 'patch'], '/{id}/reject', [AlarmController::class, 'reject']);
        Route::match(['post', 'patch'], '/{id}/complete', [AlarmController::class, 'complete']);
        Route::patch('/{id}/status', [AlarmController::class, 'updateStatus']);
    });

    Route::apiResource('tim', TimController::class);
    Route::get('/tim/{id}/anggota', [AnggotaTimController::class, 'index']);
    Route::post('/tim/{id}/anggota', [AnggotaTimController::class, 'store']);
    Route::patch('/tim/{id}/anggota/{idAnggota}', [AnggotaTimController::class, 'update']);
    Route::delete('/tim/{id}/anggota/{idAnggota}', [AnggotaTimController::class, 'destroy']);

    Route::apiResource('penugasan', PenugasanController::class)->only(['index', 'store', 'show', 'update']);
    Route::apiResource('penanganan', PenangananController::class)->only(['index', 'store', 'show', 'update']);
    Route::apiResource('dokumentasi', DokumentasiController::class)->only(['index', 'store', 'show', 'destroy']);
    Route::apiResource('korban', KorbanController::class)->only(['index', 'store', 'show', 'destroy']);
    Route::apiResource('logistik', LogistikController::class)->only(['index', 'store', 'show', 'destroy']);

    Route::prefix('notifikasi')->group(function () {
        Route::get('/', [NotifikasiController::class, 'index']);
        Route::get('/unread-count', [NotifikasiController::class, 'unreadCount']);
        Route::patch('/read-all', [NotifikasiController::class, 'markAllAsRead']);
        Route::get('/{id}', [NotifikasiController::class, 'show']);
        Route::patch('/{id}/read', [NotifikasiController::class, 'markAsRead']);
    });

    Route::apiResource('pengguna', PenggunaController::class);

    Route::post('/device-tokens', [DeviceTokenController::class, 'store']);
    Route::delete('/device-tokens', [DeviceTokenController::class, 'destroy']);

    Route::get('/monitoring', [MonitoringController::class, 'index']);
    Route::get('/laporan', [LaporanController::class, 'index']);
});

Route::middleware('auth:sanctum')->prefix('test-role')->group(function () {
    Route::get('/admin', function () {
        return response()->json(['status' => 'success', 'message' => 'Admin area accessed successfully']);
    })->middleware('role:admin');

    Route::get('/masyarakat', function () {
        return response()->json(['status' => 'success', 'message' => 'Masyarakat area accessed successfully']);
    })->middleware('role:masyarakat');

    Route::get('/ketua-tim', function () {
        return response()->json(['status' => 'success', 'message' => 'Ketua Tim area accessed successfully']);
    })->middleware('role:ketua_tim');

    Route::get('/petugas', function () {
        return response()->json(['status' => 'success', 'message' => 'Petugas area accessed successfully']);
    })->middleware('role:petugas');

    Route::get('/staff', function () {
        return response()->json(['status' => 'success', 'message' => 'Staff area accessed successfully']);
    })->middleware('role:admin,ketua_tim,petugas');
});
