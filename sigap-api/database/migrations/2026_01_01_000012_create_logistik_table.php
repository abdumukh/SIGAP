<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('logistik', function (Blueprint $table) {
            $table->string('id_logistik', 20)->primary();
            $table->string('id_penanganan', 20);
            $table->string('nama_logistik', 75);
            $table->unsignedSmallInteger('jumlah');
            $table->string('satuan', 20);
            $table->string('kondisi', 30);
            $table->string('note', 255)->nullable();
            $table->timestamps();

            $table->foreign('id_penanganan')->references('id_penanganan')->on('penanganan')->onDelete('cascade')->onUpdate('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('logistik');
    }
};
