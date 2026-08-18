<?php

use App\Http\Controllers\Api\AlarmController;
use App\Http\Controllers\Api\AnggotaTimController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TimController;
use App\Http\Controllers\Api\PenugasanController;
use App\Http\Controllers\Api\PenangananController;
use App\Http\Controllers\Api\DokumentasiController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

Route::middleware('auth:sanctum')->group(function () {
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

    Route::apiResource('penugasan', PenugasanController::class)->only(['index', 'store', 'show']);
    Route::apiResource('penanganan', PenangananController::class)->only(['index', 'store', 'show', 'update']);
    Route::apiResource('dokumentasi', DokumentasiController::class)->only(['index', 'store', 'show', 'destroy']);
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
