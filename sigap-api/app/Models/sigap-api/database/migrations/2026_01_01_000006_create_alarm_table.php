<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('alarm', function (Blueprint $table) {
            $table->string('id_alarm', 20)->primary();
            $table->string('id_pengguna', 20);
            $table->string('jenis_darurat', 30);
            $table->dateTime('waktu_alarm');
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->string('cuaca', 50)->nullable();
            $table->string('lalu_lintas', 50)->nullable();
            $table->enum('status_alarm', ['menunggu', 'diverifikasi', 'ditolak', 'selesai'])->default('menunggu');
            $table->timestamps();

            $table->foreign('id_pengguna')->references('id_pengguna')->on('pengguna')->onDelete('cascade')->onUpdate('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('alarm');
    }
};
