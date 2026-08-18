<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Petugas extends Authenticatable
{
    use HasApiTokens;

    protected $table = 'petugas';
    protected $primaryKey = 'id_petugas';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_petugas',
        'nama_petugas',
        'no_hp',
        'email',
        'password',
        'alamat',
        'status_petugas',
        'role',
    ];

    protected $hidden = [
        'password',
    ];

    public function anggotaTim(): HasMany
    {
        return $this->hasMany(AnggotaTim::class, 'id_petugas', 'id_petugas');
    }

    public function penugasanArmada(): HasMany
    {
        return $this->hasMany(Penugasan::class, 'id_petugas_armada', 'id_petugas');
    }

    public function penugasanKetua(): HasMany
    {
        return $this->hasMany(Penugasan::class, 'id_ketua_tim', 'id_petugas');
    }

    public function penanganan(): HasMany
    {
        return $this->hasMany(Penanganan::class, 'id_petugas', 'id_petugas');
    }

    public function dokumentasi(): HasMany
    {
        return $this->hasMany(Dokumentasi::class, 'id_petugas', 'id_petugas');
    }
}
