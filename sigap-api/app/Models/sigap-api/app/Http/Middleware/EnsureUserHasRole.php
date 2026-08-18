<?php

namespace App\Http\Middleware;

use App\Services\ActorService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserHasRole
{
    protected ActorService $actorService;

    public function __construct(ActorService $actorService)
    {
        $this->actorService = $actorService;
    }

    /**
     * Handle an incoming request and authorize user actor role.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     * @param  string  ...$roles
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Unauthenticated. Token tidak valid atau kedaluwarsa.',
            ], 401);
        }

        $currentActor = $this->actorService->resolveActor($user);

        // Sanctum Ability Check: Ensure token ability matches the actual DB actor identity
        if (method_exists($user, 'tokenCan') && $user->currentAccessToken()) {
            if (!$user->tokenCan($currentActor)) {
                return response()->json([
                    'status'  => 'error',
                    'message' => 'Forbidden. Akses ditolak untuk role ini.',
                ], 403);
            }
        }

        // Role Authorization Check: Ensure current actor is in allowed roles list
        if (!in_array($currentActor, $roles, true)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Forbidden. Akses ditolak untuk role ini.',
            ], 403);
        }

        return $next($request);
    }
}
