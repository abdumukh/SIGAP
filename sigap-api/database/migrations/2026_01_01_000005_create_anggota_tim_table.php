<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('anggota_tim', function (Blueprint $table) {
            $table->string('id_anggota_tim', 20)->primary();
            $table->string('id_tim', 20);
            $table->string('id_petugas', 20);
            $table->date('tanggal_masuk');
            $table->enum('status_anggota', ['aktif', 'nonaktif'])->default('aktif');
            $table->timestamps();

            $table->foreign('id_tim')->references('id_tim')->on('tim')->onDelete('cascade')->onUpdate('cascade');
            $table->foreign('id_petugas')->references('id_petugas')->on('petugas')->onDelete('cascade')->onUpdate('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('anggota_tim');
    }
};
