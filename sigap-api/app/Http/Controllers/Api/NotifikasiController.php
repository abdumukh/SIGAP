<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\NotifikasiResource;
use App\Services\ActorService;
use App\Services\NotifikasiService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotifikasiController extends Controller
{
    public function __construct(
        protected NotifikasiService $notifikasiService,
        protected ActorService $actorService,
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        $perPage = (int) $request->query('per_page', 15);
        $notifications = $this->notifikasiService->getNotifikasiListForUser(
            $request->user(),
            $this->actorService->resolveActor($request->user()),
            $perPage
        );

        return response()->json([
            'status' => 'success',
            'data'   => NotifikasiResource::collection($notifications),
        ]);
    }

    public function show(Request $request, string $idNotifikasi): JsonResponse
    {
        $notifikasi = $this->notifikasiService->getNotifikasiById($idNotifikasi);

        if (!$notifikasi) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Notifikasi tidak ditemukan',
            ], 404);
        }

        $userRole = $this->actorService->resolveActor($request->user());
        $actorId = $this->resolveActorId($request->user(), $userRole);

        if ($notifikasi->id_actor !== $actorId || $notifikasi->actor_role !== $userRole) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Akses tidak diizinkan.',
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'data'   => new NotifikasiResource($notifikasi),
        ]);
    }

    public function markAsRead(Request $request, string $idNotifikasi): JsonResponse
    {
        $notifikasi = $this->notifikasiService->getNotifikasiById($idNotifikasi);

        if (!$notifikasi) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Notifikasi tidak ditemukan',
            ], 404);
        }

        $userRole = $this->actorService->resolveActor($request->user());
        $actorId = $this->resolveActorId($request->user(), $userRole);

        if ($notifikasi->id_actor !== $actorId || $notifikasi->actor_role !== $userRole) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Akses tidak diizinkan.',
            ], 403);
        }

        $updated = $this->notifikasiService->markAsRead($notifikasi);

        return response()->json([
            'status'  => 'success',
            'message' => 'Notifikasi ditandai sebagai dibaca',
            'data'    => new NotifikasiResource($updated),
        ]);
    }

    public function markAllAsRead(Request $request): JsonResponse
    {
        $userRole = $this->actorService->resolveActor($request->user());
        $count = $this->notifikasiService->markAllAsRead($request->user(), $userRole);

        return response()->json([
            'status'  => 'success',
            'message' => "{$count} notifikasi ditandai sebagai dibaca",
            'data'    => ['updated_count' => $count],
        ]);
    }

    public function unreadCount(Request $request): JsonResponse
    {
        $userRole = $this->actorService->resolveActor($request->user());
        $count = $this->notifikasiService->getUnreadCount($request->user(), $userRole);

        return response()->json([
            'status' => 'success',
            'data'   => ['unread_count' => $count],
        ]);
    }

    private function resolveActorId($user, string $role): string
    {
        return match ($role) {
            'masyarakat' => $user->id_pengguna,
            'admin' => $user->id_admin,
            'ketua_tim', 'petugas' => $user->id_petugas,
            default => '',
        };
    }
}
