<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Penanganan extends Model
{
    protected $table = 'penanganan';
    protected $primaryKey = 'id_penanganan';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_penanganan',
        'id_alarm',
        'id_penugasan',
        'id_petugas',
        'waktu_berangkat',
        'waktu_tiba',
        'waktu_selesai',
        'status_penanganan',
        'note',
    ];

    public function alarm(): BelongsTo
    {
        return $this->belongsTo(Alarm::class, 'id_alarm', 'id_alarm');
    }

    public function penugasan(): BelongsTo
    {
        return $this->belongsTo(Penugasan::class, 'id_penugasan', 'id_penugasan');
    }

    public function petugas(): BelongsTo
    {
        return $this->belongsTo(Petugas::class, 'id_petugas', 'id_petugas');
    }

    public function dokumentasi(): HasMany
    {
        return $this->hasMany(Dokumentasi::class, 'id_penanganan', 'id_penanganan');
    }

    public function korban(): HasMany
    {
        return $this->hasMany(Korban::class, 'id_penanganan', 'id_penanganan');
    }

    public function logistik(): HasMany
    {
        return $this->hasMany(Logistik::class, 'id_penanganan', 'id_penanganan');
    }
}
