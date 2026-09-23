<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\ReviewVerificationRequest;
use App\Models\AuditLog;
use App\Models\Technician;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminVerificationController extends Controller
{
    /**
     * List all technicians for verification management with status filtering.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Technician::query()
            ->with(['user', 'city', 'verifications'])
            ->withCount('verifications');

        if ($request->has('status') && $request->input('status') !== 'all') {
            $query->where('verification_status', $request->input('status'));
        }

        if ($request->has('search')) {
            $search = $request->input('search');
            $query->whereHas('user', function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                    ->orWhere('email', 'ilike', "%{$search}%")
                    ->orWhere('phone', 'ilike', "%{$search}%");
            });
        }

        $technicians = $query->latest()->paginate(15);

        return response()->json([
            'success' => true,
            'data' => [
                'technicians' => $technicians,
                'disclaimer' => 'Verified based on submitted and reviewed information.',
            ],
        ]);
    }

    /**
     * View detailed technician verification dossier.
     */
    public function show(string $technicianId): JsonResponse
    {
        $technician = Technician::with([
            'user',
            'city',
            'services.serviceCategory',
            'verifications.reviewer',
        ])->find($technicianId);

        if (! $technician) {
            return response()->json(['success' => false, 'message' => 'Technician not found'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'technician' => $technician,
                'disclaimer' => 'Verified based on submitted and reviewed information.',
            ],
        ]);
    }

    /**
     * Review technician verification (approve, reject, suspend).
     */
    public function review(ReviewVerificationRequest $request, string $technicianId): JsonResponse
    {
        $admin = $request->user();
        $validated = $request->validated();
        $action = $validated['action'];
        $reason = $validated['reason'] ?? null;

        $technician = Technician::find($technicianId);

        if (! $technician) {
            return response()->json(['success' => false, 'message' => 'Technician not found'], 404);
        }

        $oldStatus = $technician->verification_status;

        DB::transaction(function () use ($technician, $admin, $action, $reason, $oldStatus, $request) {
            if ($action === 'approve') {
                $technician->markVerified($admin->id);
                // Mark all pending verifications as approved
                $technician->verifications()
                    ->where('status', 'pending')
                    ->update([
                        'status' => 'approved',
                        'reviewed_by' => $admin->id,
                        'reviewed_at' => now(),
                    ]);
            } elseif ($action === 'reject') {
                $technician->markRejected($admin->id, $reason);
                $technician->verifications()
                    ->where('status', 'pending')
                    ->update([
                        'status' => 'rejected',
                        'rejection_reason' => $reason,
                        'reviewed_by' => $admin->id,
                        'reviewed_at' => now(),
                    ]);
            } elseif ($action === 'suspend') {
                $technician->markSuspended($admin->id, $reason);
            }

            // Write immutable audit log
            AuditLog::create([
                'user_id' => $admin->id,
                'auditable_type' => Technician::class,
                'auditable_id' => $technician->id,
                'event' => 'technician_verification_' . $action,
                'old_values' => ['verification_status' => $oldStatus],
                'new_values' => [
                    'verification_status' => $technician->verification_status,
                    'reason' => $reason,
                    'verified_by' => $admin->id,
                ],
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'created_at' => now(),
            ]);
        });

        $technician->refresh()->load(['user', 'verifications', 'city']);

        return response()->json([
            'success' => true,
            'message' => "Technician verification has been marked as {$technician->verification_status}.",
            'data' => [
                'technician' => $technician,
                'disclaimer' => 'Verified based on submitted and reviewed information.',
            ],
        ]);
    }
}
