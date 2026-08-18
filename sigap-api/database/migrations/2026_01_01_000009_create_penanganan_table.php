<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('penanganan', function (Blueprint $table) {
            $table->string('id_penanganan', 20)->primary();
            $table->string('id_alarm', 20);
            $table->string('id_penugasan', 20);
            $table->string('id_petugas', 20);
            $table->dateTime('waktu_berangkat')->nullable();
            $table->dateTime('waktu_tiba')->nullable();
            $table->dateTime('waktu_selesai')->nullable();
            $table->enum('status_penanganan', ['menuju_lokasi', 'di_lokasi', 'selesai'])->default('menuju_lokasi');
            $table->string('note', 255)->nullable();
            $table->timestamps();

            $table->foreign('id_alarm')->references('id_alarm')->on('alarm')->onDelete('cascade')->onUpdate('cascade');
            $table->foreign('id_penugasan')->references('id_penugasan')->on('penugasan')->onDelete('cascade')->onUpdate('cascade');
            $table->foreign('id_petugas')->references('id_petugas')->on('petugas')->onDelete('cascade')->onUpdate('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('penanganan');
    }
};
