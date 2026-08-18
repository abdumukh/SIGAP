<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('korban', function (Blueprint $table) {
            $table->string('id_korban', 20)->primary();
            $table->string('id_penanganan', 20);
            $table->string('nama_korban', 75);
            $table->enum('jenis_kelamin', ['L', 'P']);
            $table->unsignedTinyInteger('usia');
            $table->string('kondisi', 50);
            $table->string('status_penanganan', 50);
            $table->string('note', 255)->nullable();
            $table->timestamps();

            $table->foreign('id_penanganan')->references('id_penanganan')->on('penanganan')->onDelete('cascade')->onUpdate('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('korban');
    }
};
