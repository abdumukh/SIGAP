<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('armada', function (Blueprint $table) {
            $table->string('id_armada', 20)->primary();
            $table->string('nama_armada', 50);
            $table->string('jenis_armada', 30);
            $table->string('nomor_kendaraan', 12)->unique();
            $table->enum('status_armada', ['tersedia', 'digunakan', 'perawatan'])->default('tersedia');
            $table->string('note', 255)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('armada');
    }
};
