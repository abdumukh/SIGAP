<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Korban extends Model
{
    protected $table = 'korban';
    protected $primaryKey = 'id_korban';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_korban',
        'id_penanganan',
        'nama_korban',
        'jenis_kelamin',
        'usia',
        'kondisi',
        'status_penanganan',
        'note',
    ];

    public function penanganan(): BelongsTo
    {
        return $this->belongsTo(Penanganan::class, 'id_penanganan', 'id_penanganan');
    }
}
