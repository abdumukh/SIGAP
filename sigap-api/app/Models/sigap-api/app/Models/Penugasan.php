<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Penugasan extends Model
{
    protected $table = 'penugasan';
    protected $primaryKey = 'id_penugasan';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $casts = [
        'waktu_penugasan' => 'datetime',
    ];

    protected $fillable = [
        'id_penugasan',
        'id_alarm',
        'id_tim',
        'id_petugas_armada',
        'id_armada',
        'id_ketua_tim',
        'waktu_penugasan',
        'status_penugasan',
        'note',
    ];

    public function alarm(): BelongsTo
    {
        return $this->belongsTo(Alarm::class, 'id_alarm', 'id_alarm');
    }

    public function tim(): BelongsTo
    {
        return $this->belongsTo(Tim::class, 'id_tim', 'id_tim');
    }

    public function petugasArmada(): BelongsTo
    {
        return $this->belongsTo(Petugas::class, 'id_petugas_armada', 'id_petugas');
    }

    public function armada(): BelongsTo
    {
        return $this->belongsTo(Armada::class, 'id_armada', 'id_armada');
    }

    public function ketuaTim(): BelongsTo
    {
        return $this->belongsTo(Petugas::class, 'id_ketua_tim', 'id_petugas');
    }

    public function penanganan(): HasOne
    {
        return $this->hasOne(Penanganan::class, 'id_penugasan', 'id_penugasan');
    }
}
