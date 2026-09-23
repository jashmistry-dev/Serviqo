<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (! $user) {
            return response()->json([
                'message' => 'Unauthenticated.',
            ], Response::HTTP_UNAUTHORIZED);
        }

        if (! $user->isActive()) {
            return response()->json([
                'message' => 'Your account is inactive or suspended. Please contact support.',
            ], Response::HTTP_FORBIDDEN);
        }

        // Split comma-separated roles if passed as role:customer,technician
        $allowedRoles = [];
        foreach ($roles as $roleGroup) {
            foreach (explode(',', $roleGroup) as $r) {
                $allowedRoles[] = trim($r);
            }
        }

        if (! empty($allowedRoles) && ! in_array($user->role, $allowedRoles, true)) {
            return response()->json([
                'message' => 'Unauthorized. You do not have permission to access this resource.',
            ], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}