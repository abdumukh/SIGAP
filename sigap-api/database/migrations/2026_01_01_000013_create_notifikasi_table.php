<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifikasi', function (Blueprint $table) {
            $table->string('id_notifikasi', 20)->primary();
            $table->string('id_actor', 20);
            $table->enum('actor_role', ['masyarakat', 'admin', 'ketua_tim', 'petugas']);
            $table->string('type', 50);
            $table->string('title', 255);
            $table->text('message');
            $table->json('data')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();

            $table->index(['id_actor', 'actor_role']);
            $table->index('type');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifikasi');
    }
};
