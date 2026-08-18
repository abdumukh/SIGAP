<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Alarm extends Model
{
    protected $table = 'alarm';
    protected $primaryKey = 'id_alarm';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $casts = [
        'waktu_alarm' => 'datetime',
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
    ];

    protected $fillable = [
        'id_alarm',
        'id_pengguna',
        'jenis_darurat',
        'waktu_alarm',
        'latitude',
        'longitude',
        'cuaca',
        'lalu_lintas',
        'status_alarm',
    ];

    public function pengguna(): BelongsTo
    {
        return $this->belongsTo(Pengguna::class, 'id_pengguna', 'id_pengguna');
    }

    public function penugasan(): HasMany
    {
        return $this->hasMany(Penugasan::class, 'id_alarm', 'id_alarm');
    }

    public function penanganan(): HasOne
    {
        return $this->hasOne(Penanganan::class, 'id_alarm', 'id_alarm');
    }
}
