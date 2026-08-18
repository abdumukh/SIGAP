<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('dokumentasi', function (Blueprint $table) {
            $table->string('id_dokumentasi', 20)->primary();
            $table->string('id_penanganan', 20);
            $table->string('id_petugas', 20);
            $table->enum('jenis_dokumentasi', ['foto', 'video']);
            $table->string('file_dokumentasi', 255);
            $table->dateTime('waktu_upload');
            $table->string('note', 255)->nullable();
            $table->timestamps();

            $table->foreign('id_penanganan')->references('id_penanganan')->on('penanganan')->onDelete('cascade')->onUpdate('cascade');
            $table->foreign('id_petugas')->references('id_petugas')->on('petugas')->onDelete('cascade')->onUpdate('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('dokumentasi');
    }
};
