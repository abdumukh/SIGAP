<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Armada extends Model
{
    protected $table = 'armada';
    protected $primaryKey = 'id_armada';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_armada',
        'nama_armada',
        'jenis_armada',
        'nomor_kendaraan',
        'status_armada',
        'note',
    ];

    public function penugasan(): HasMany
    {
        return $this->hasMany(Penugasan::class, 'id_armada', 'id_armada');
    }
}
