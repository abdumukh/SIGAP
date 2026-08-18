<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('petugas', function (Blueprint $table) {
            $table->string('id_petugas', 20)->primary();
            $table->string('nama_petugas', 75);
            $table->string('no_hp', 15);
            $table->string('email', 100)->unique();
            $table->string('password', 255);
            $table->string('alamat', 255);
            $table->enum('status_petugas', ['aktif', 'nonaktif'])->default('aktif');
            $table->enum('role', ['petugas', 'ketua_tim'])->default('petugas');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('petugas');
    }
};
