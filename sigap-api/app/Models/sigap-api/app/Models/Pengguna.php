<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Pengguna extends Authenticatable
{
    use HasApiTokens;

    protected $table = 'pengguna';
    protected $primaryKey = 'id_pengguna';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_pengguna',
        'nama',
        'no_hp',
        'alamat',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
    ];

    public function alarm(): HasMany
    {
        return $this->hasMany(Alarm::class, 'id_pengguna', 'id_pengguna');
    }
}
