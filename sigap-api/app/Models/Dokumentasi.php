<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Dokumentasi extends Model
{
    protected $table = 'dokumentasi';
    protected $primaryKey = 'id_dokumentasi';
    public $incrementing = false;
    protected $keyType = 'string';
    protected $casts = [
        'waktu_upload' => 'datetime',
    ];

    protected $fillable = [
        'id_dokumentasi',
        'id_penanganan',
        'id_petugas',
        'jenis_dokumentasi',
        'file_dokumentasi',
        'waktu_upload',
        'note',
    ];

    public function penanganan(): BelongsTo
    {
        return $this->belongsTo(Penanganan::class, 'id_penanganan', 'id_penanganan');
    }

    public function petugas(): BelongsTo
    {
        return $this->belongsTo(Petugas::class, 'id_petugas', 'id_petugas');
    }
}
