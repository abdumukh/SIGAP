<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('penugasan', function (Blueprint $table) {
            $table->string('id_penugasan', 20)->primary();
            $table->string('id_alarm', 20);
            $table->string('id_tim', 20);
            $table->string('id_petugas_armada', 20)->nullable();
            $table->string('id_armada', 20)->nullable();
            $table->string('id_ketua_tim', 20)->nullable();
            $table->dateTime('waktu_penugasan');
            $table->enum('status_penugasan', ['menunggu', 'diterima', 'ditolak', 'berangkat', 'selesai'])->default('menunggu');
            $table->string('note', 255)->nullable();
            $table->timestamps();

            $table->foreign('id_alarm')->references('id_alarm')->on('alarm')->onDelete('cascade')->onUpdate('cascade');
            $table->foreign('id_tim')->references('id_tim')->on('tim')->onDelete('cascade')->onUpdate('cascade');
            $table->foreign('id_petugas_armada')->references('id_petugas')->on('petugas')->onDelete('set null')->onUpdate('cascade');
            $table->foreign('id_armada')->references('id_armada')->on('armada')->onDelete('set null')->onUpdate('cascade');
            $table->foreign('id_ketua_tim')->references('id_petugas')->on('petugas')->onDelete('set null')->onUpdate('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('penugasan');
    }
};
