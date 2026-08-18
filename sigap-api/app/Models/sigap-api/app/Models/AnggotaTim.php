<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AnggotaTim extends Model
{
    protected $table = 'anggota_tim';
    protected $primaryKey = 'id_anggota_tim';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_anggota_tim',
        'id_tim',
        'id_petugas',
        'tanggal_masuk',
        'status_anggota',
    ];

    protected $casts = [
        'tanggal_masuk' => 'date',
    ];

    public function tim(): BelongsTo
    {
        return $this->belongsTo(Tim::class, 'id_tim', 'id_tim');
    }

    public function petugas(): BelongsTo
    {
        return $this->belongsTo(Petugas::class, 'id_petugas', 'id_petugas');
    }
}
