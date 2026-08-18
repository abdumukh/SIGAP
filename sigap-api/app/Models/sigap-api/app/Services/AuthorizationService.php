<?php

namespace App\Services;

use App\Models\Alarm;
use App\Models\AnggotaTim;
use App\Models\Penugasan;
use Illuminate\Contracts\Auth\Authenticatable;

class AuthorizationService
{
    protected ActorService $actorService;

    public function __construct(ActorService $actorService)
    {
        $this->actorService = $actorService;
    }

    public function isAdmin(?Authenticatable $user): bool
    {
        return $this->actorService->resolveActor($user) === 'admin';
    }

    public function isMasyarakat(?Authenticatable $user): bool
    {
        return $this->actorService->resolveActor($user) === 'masyarakat';
    }

    public function isKetuaTim(?Authenticatable $user): bool
    {
        return $this->actorService->resolveActor($user) === 'ketua_tim';
    }

    public function isPetugas(?Authenticatable $user): bool
    {
        return $this->actorService->resolveActor($user) === 'petugas';
    }

    /**
     * Layer 2 Operational Authorization: Verifies if a Masyarakat user owns the target Alarm.
     */
    public function canMasyarakatAccessAlarm(?Authenticatable $user, Alarm $alarm): bool
    {
        if (!$user || !$this->isMasyarakat($user)) {
            return false;
        }

        return $alarm->id_pengguna === $user->id_pengguna;
    }

    /**
     * Verifies if current user actor is authorized to perform status changes on alarms (Petugas, Ketua Tim, Admin).
     */
    public function canChangeAlarmStatus(?Authenticatable $user): bool
    {
        if (!$user) {
            return false;
        }

        return !$this->isMasyarakat($user);
    }

    /**
     * Verifies if current user actor is authorized to manage Teams & Team Members (Admin only).
     */
    public function canManageTim(?Authenticatable $user): bool
    {
        if (!$user) {
            return false;
        }

        return $this->isAdmin($user);
    }

    /**
     * Layer 2 Operational Authorization: Verifies if a Ketua Tim is assigned to lead the target Penugasan.
     */
    public function canKetuaTimManagePenugasan(?Authenticatable $user, Penugasan $penugasan): bool
    {
        if (!$user) {
            return false;
        }

        if ($this->isAdmin($user)) {
            return true;
        }

        if (!$this->isKetuaTim($user)) {
            return false;
        }

        return $penugasan->id_ketua_tim === $user->id_petugas;
    }

    /**
     * Layer 2 Operational Authorization: Verifies if a Petugas / Team Member is assigned to the target Penugasan.
     */
    public function canPetugasExecutePenugasan(?Authenticatable $user, Penugasan $penugasan): bool
    {
        if (!$user) {
            return false;
        }

        if ($this->isAdmin($user)) {
            return true;
        }

        $actor = $this->actorService->resolveActor($user);
        if ($actor !== 'petugas' && $actor !== 'ketua_tim') {
            return false;
        }

        // Direct assignment check as armada driver or team leader
        if ($penugasan->id_petugas_armada === $user->id_petugas || $penugasan->id_ketua_tim === $user->id_petugas) {
            return true;
        }

        // Team membership check
        return AnggotaTim::where('id_tim', $penugasan->id_tim)
            ->where('id_petugas', $user->id_petugas)
            ->where('status_anggota', 'aktif')
            ->exists();
    }
}
