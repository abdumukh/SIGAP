<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Tim extends Model
{
    protected $table = 'tim';
    protected $primaryKey = 'id_tim';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_tim',
        'nama_tim',
        'note',
        'status_tim',
    ];

    public function anggotaTim(): HasMany
    {
        return $this->hasMany(AnggotaTim::class, 'id_tim', 'id_tim');
    }

    public function penugasan(): HasMany
    {
        return $this->hasMany(Penugasan::class, 'id_tim', 'id_tim');
    }
}
