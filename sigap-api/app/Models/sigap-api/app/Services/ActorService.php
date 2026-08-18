<?php

namespace App\Services;

use App\Models\Admin;
use App\Models\Pengguna;
use App\Models\Petugas;
use Illuminate\Contracts\Auth\Authenticatable;

class ActorService
{
    /**
     * Resolves the actor type string from an authenticated model instance.
     */
    public function resolveActor(?Authenticatable $user): string
    {
        if (!$user) {
            return 'guest';
        }

        if ($user instanceof Pengguna) {
            return 'masyarakat';
        }

        if ($user instanceof Admin) {
            return 'admin';
        }

        if ($user instanceof Petugas) {
            return $user->role === 'ketua_tim' ? 'ketua_tim' : 'petugas';
        }

        return 'unknown';
    }

    /**
     * Generates a new custom ID with prefix for Pengguna (e.g. USR-001, USR-002).
     */
    public function generatePenggunaId(): string
    {
        $latest = Pengguna::orderBy('id_pengguna', 'desc')->first();

        if (!$latest) {
            return 'USR-001';
        }

        // Extract numeric portion from ID like USR-001
        $number = (int) substr($latest->id_pengguna, 4);
        $nextNumber = $number + 1;

        return 'USR-' . str_pad((string) $nextNumber, 3, '0', STR_PAD_LEFT);
    }
}
