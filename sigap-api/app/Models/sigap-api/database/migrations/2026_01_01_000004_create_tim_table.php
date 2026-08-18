<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tim', function (Blueprint $table) {
            $table->string('id_tim', 20)->primary();
            $table->string('nama_tim', 50);
            $table->string('note', 255)->nullable();
            $table->enum('status_tim', ['aktif', 'nonaktif'])->default('aktif');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tim');
    }
};
