<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Notifikasi extends Model
{
    protected $table = 'notifikasi';
    protected $primaryKey = 'id_notifikasi';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id_notifikasi',
        'id_actor',
        'actor_role',
        'type',
        'title',
        'message',
        'data',
        'read_at',
    ];

    protected $casts = [
        'data' => 'array',
        'read_at' => 'datetime',
    ];

    public function scopeUnread($query)
    {
        return $query->whereNull('read_at');
    }

    public function scopeForActor($query, string $actorId, string $actorRole)
    {
        return $query->where('id_actor', $actorId)
                     ->where('actor_role', $actorRole);
    }
}
