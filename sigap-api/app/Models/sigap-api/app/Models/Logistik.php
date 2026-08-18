<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Logistik extends Model
{
    protected $table = 'logistik';
    protected $primaryKey = 'id_logistik';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_logistik',
        'id_penanganan',
        'nama_logistik',
        'jumlah',
        'satuan',
        'kondisi',
        'note',
    ];

    public function penanganan(): BelongsTo
    {
        return $this->belongsTo(Penanganan::class, 'id_penanganan', 'id_penanganan');
    }
}
