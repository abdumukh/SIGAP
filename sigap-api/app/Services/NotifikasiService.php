<?php

namespace App\Services;

use App\Models\Notifikasi;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Pagination\LengthAwarePaginator;

class NotifikasiService
{
    public function generateNotifikasiId(): string
    {
        $latest = Notifikasi::orderBy('id_notifikasi', 'desc')->first();

        if (!$latest) {
            return 'NTF-001';
        }

        $number = (int) substr($latest->id_notifikasi, 4);

        return 'NTF-' . str_pad((string) ($number + 1), 3, '0', STR_PAD_LEFT);
    }

    public function createNotifikasi(string $actorId, string $actorRole, string $type, string $title, string $message, ?array $data = null): Notifikasi
    {
        return Notifikasi::create([
            'id_notifikasi' => $this->generateNotifikasiId(),
            'id_actor'      => $actorId,
            'actor_role'    => $actorRole,
            'type'          => $type,
            'title'         => $title,
            'message'       => $message,
            'data'          => $data,
        ]);
    }

    public function getNotifikasiListForUser(Authenticatable $user, string $actorRole, int $perPage = 15): LengthAwarePaginator
    {
        $actorId = $this->resolveActorId($user);
        $actorRoleName = $this->resolveActorRole($user, $actorRole);

        return Notifikasi::forActor($actorId, $actorRoleName)
            ->orderByDesc('created_at')
            ->paginate($perPage);
    }

    public function getNotifikasiById(string $idNotifikasi): ?Notifikasi
    {
        return Notifikasi::where('id_notifikasi', $idNotifikasi)->first();
    }

    public function markAsRead(Notifikasi $notifikasi): Notifikasi
    {
        if (is_null($notifikasi->read_at)) {
            $notifikasi->read_at = now();
            $notifikasi->save();
        }

        return $notifikasi;
    }

    public function markAllAsRead(Authenticatable $user, string $actorRole): int
    {
        $actorId = $this->resolveActorId($user);
        $actorRoleName = $this->resolveActorRole($user, $actorRole);

        return Notifikasi::forActor($actorId, $actorRoleName)
            ->unread()
            ->update(['read_at' => now()]);
    }

    public function getUnreadCount(Authenticatable $user, string $actorRole): int
    {
        $actorId = $this->resolveActorId($user);
        $actorRoleName = $this->resolveActorRole($user, $actorRole);

        return Notifikasi::forActor($actorId, $actorRoleName)
            ->unread()
            ->count();
    }

    private function resolveActorId(Authenticatable $user): string
    {
        $actorService = app(ActorService::class);
        $actor = $actorService->resolveActor($user);

        return match ($actor) {
            'masyarakat' => $user->id_pengguna,
            'admin' => $user->id_admin,
            'ketua_tim', 'petugas' => $user->id_petugas,
            default => '',
        };
    }

    private function resolveActorRole(Authenticatable $user, string $actorRole): string
    {
        $actorService = app(ActorService::class);
        return $actorService->resolveActor($user);
    }
}
