<?php

namespace App\Services;

use App\Models\Alarm;
use App\Models\AnggotaTim;
use App\Models\Dokumentasi;
use App\Models\Notifikasi;
use App\Models\Penanganan;
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

    /**
     * Verifies if current user can create a Penanganan (Petugas & Ketua Tim only).
     */
    public function canCreatePenanganan(?Authenticatable $user): bool
    {
        if (!$user) {
            return false;
        }

        return $this->isPetugas($user) || $this->isKetuaTim($user);
    }

    /**
     * Verifies if current user can list Penanganan (Admin, Petugas, Ketua Tim).
     */
    public function canListPenanganan(?Authenticatable $user): bool
    {
        if (!$user) {
            return false;
        }

        return !$this->isMasyarakat($user);
    }

    /**
     * Verifies if current user can view detail of a Penanganan.
     */
    public function canViewPenanganan(?Authenticatable $user, Penanganan $penanganan): bool
    {
        if (!$user) {
            return false;
        }

        if ($this->isAdmin($user)) {
            return true;
        }

        if ($this->isMasyarakat($user)) {
            return false;
        }

        if ($penanganan->id_petugas === $user->id_petugas) {
            return true;
        }

        if ($penanganan->penugasan) {
            return $this->canPetugasExecutePenugasan($user, $penanganan->penugasan);
        }

        return false;
    }

    /**
     * Verifies if current user can update status of a Penanganan (Assigned Petugas only).
     */
    public function canUpdatePenanganan(?Authenticatable $user, Penanganan $penanganan): bool
    {
        if (!$user) {
            return false;
        }

        if (!$this->isPetugas($user) && !$this->isKetuaTim($user)) {
            return false;
        }

        return $penanganan->id_petugas === $user->id_petugas;
    }

    /**
     * Verifies if current user can create a Dokumentasi for the given Penanganan.
     */
    public function canCreateDokumentasi(?Authenticatable $user, Penanganan $penanganan): bool
    {
        if (!$user) {
            return false;
        }

        if (!$this->isPetugas($user) && !$this->isKetuaTim($user)) {
            return false;
        }

        if ($penanganan->id_petugas === $user->id_petugas) {
            return true;
        }

        if ($penanganan->penugasan) {
            return $this->canPetugasExecutePenugasan($user, $penanganan->penugasan);
        }

        return false;
    }

    /**
     * Verifies if current user can update Penugasan status (Admin only).
     */
    public function canUpdatePenugasanStatus(?Authenticatable $user): bool
    {
        return $this->canManageTim($user);
    }

    /**
     * Verifies if current user can list Penugasan (Admin, Petugas, Ketua Tim).
     */
    public function canListPenugasan(?Authenticatable $user): bool
    {
        if (!$user) {
            return false;
        }

        return !$this->isMasyarakat($user);
    }

    /**
     * Verifies if current user can view detail of a Penugasan.
     */
    public function canViewPenugasan(?Authenticatable $user, Penugasan $penugasan): bool
    {
        if (!$user) {
            return false;
        }

        if ($this->isAdmin($user)) {
            return true;
        }

        if ($this->isMasyarakat($user)) {
            return false;
        }

        return $this->canPetugasExecutePenugasan($user, $penugasan);
    }

    /**
     * Verifies if current user can list Dokumentasi.
     */
    public function canListDokumentasi(?Authenticatable $user): bool
    {
        if (!$user) {
            return false;
        }

        return !$this->isMasyarakat($user);
    }

    /**
     * Verifies if current user can list notifikasi.
     */
    public function canListNotifikasi(?Authenticatable $user): bool
    {
        if (!$user) {
            return false;
        }

        return !$this->isMasyarakat($user);
    }

    /**
     * Verifies if current user can view notifikasi detail.
     */
    public function canViewNotifikasi(?Authenticatable $user, Notifikasi $notifikasi): bool
    {
        if (!$user) {
            return false;
        }

        if ($this->isAdmin($user)) {
            return true;
        }

        if ($this->isMasyarakat($user)) {
            return $notifikasi->id_actor === $user->id_pengguna
                && $notifikasi->actor_role === 'masyarakat';
        }

        if (!$this->isPetugas($user) && !$this->isKetuaTim($user)) {
            return false;
        }

        return $notifikasi->id_actor === $user->id_petugas
            && ($notifikasi->actor_role === 'petugas' || $notifikasi->actor_role === 'ketua_tim');
    }

    /**
     * Verifies if current user can mark notifikasi as read.
     */
    public function canMarkNotifikasiRead(?Authenticatable $user, Notifikasi $notifikasi): bool
    {
        if (!$user) {
            return false;
        }

        if ($this->isAdmin($user)) {
            return true;
        }

        if ($this->isMasyarakat($user)) {
            return $notifikasi->id_actor === $user->id_pengguna
                && $notifikasi->actor_role === 'masyarakat';
        }

        if (!$this->isPetugas($user) && !$this->isKetuaTim($user)) {
            return false;
        }

        return $notifikasi->id_actor === $user->id_petugas
            && ($notifikasi->actor_role === 'petugas' || $notifikasi->actor_role === 'ketua_tim');
    }

    /**
     * Verifies if current user can mark all notifikasi as read.
     */
    public function canMarkAllNotifikasiRead(?Authenticatable $user): bool
    {
        if (!$user) {
            return false;
        }

        return !$this->isMasyarakat($user);
    }

    /**
     * Verifies if current user can view a Dokumentasi detail.
     */
    public function canViewDokumentasi(?Authenticatable $user, Dokumentasi $dokumentasi): bool
    {
        if (!$user) {
            return false;
        }

        if ($this->isAdmin($user)) {
            return true;
        }

        if ($this->isMasyarakat($user)) {
            return false;
        }

        if ($dokumentasi->id_petugas === $user->id_petugas) {
            return true;
        }

        if ($dokumentasi->penanganan) {
            return $this->canViewPenanganan($user, $dokumentasi->penanganan);
        }

        return false;
    }

    /**
     * Verifies if current user can delete a Dokumentasi.
     */
    public function canDeleteDokumentasi(?Authenticatable $user, Dokumentasi $dokumentasi): bool
    {
        if (!$user) {
            return false;
        }

        if ($this->isAdmin($user)) {
            return true;
        }

        if (!$this->isPetugas($user) && !$this->isKetuaTim($user)) {
            return false;
        }

        return $dokumentasi->id_petugas === $user->id_petugas;
    }

    /**
     * Verifies if current user can access monitoring menu.
     */
    public function canAccessMonitoring(?Authenticatable $user): bool
    {
        if (!$user) {
            return false;
        }

        return !$this->isMasyarakat($user);
    }

    /**
     * Verifies if current user can access specific laporan type based on Section 12.
     */
    public function canAccessLaporanType(?Authenticatable $user, string $type): bool
    {
        if (!$user) {
            return false;
        }

        $actor = $this->actorService->resolveActor($user);

        return match ($actor) {
            'admin' => in_array($type, ['alarm', 'penugasan', 'penanganan', 'pengguna', 'petugas'], true),
            'ketua_tim' => in_array($type, ['alarm', 'penugasan', 'penanganan', 'petugas'], true),
            'petugas' => in_array($type, ['alarm', 'penugasan', 'penanganan'], true),
            'masyarakat' => in_array($type, ['alarm', 'penanganan'], true),
            default => false,
        };
    }
}
