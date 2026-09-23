<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Technician\UpdateTechnicianProfileRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TechnicianProfileController extends Controller
{
    /**
     * Get the authenticated technician's profile with skills and verification status.
     */
    public function show(Request $request): JsonResponse
    {
        $user = $request->user()->load([
            'technician.city',
            'technician.services.serviceCategory',
            'technician.verifications',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Technician profile retrieved successfully',
            'data' => [
                'user' => $user,
                'technician' => $user->technician,
            ],
        ]);
    }

    /**
     * Update the authenticated technician's profile details.
     */
    public function update(UpdateTechnicianProfileRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        DB::transaction(function () use ($user, $validated) {
            $userUpdates = [];
            if (isset($validated['name'])) {
                $userUpdates['name'] = $validated['name'];
            }
            if (isset($validated['phone'])) {
                $userUpdates['phone'] = $validated['phone'];
            }
            if (! empty($userUpdates)) {
                $user->update($userUpdates);
            }

            $technicianFields = [
                'bio',
                'experience_years',
                'visiting_charge',
                'city_id',
                'address',
                'pincode',
            ];

            $technicianData = [];
            foreach ($technicianFields as $field) {
                if (array_key_exists($field, $validated)) {
                    $technicianData[$field] = $validated[$field];
                }
            }

            if (! empty($technicianData)) {
                $user->technician()->updateOrCreate(
                    ['user_id' => $user->id],
                    $technicianData
                );
            }
        });

        $user->refresh()->load([
            'technician.city',
            'technician.services.serviceCategory',
            'technician.verifications',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Technician profile updated successfully',
            'data' => [
                'user' => $user,
                'technician' => $user->technician,
            ],
        ]);
    }

    /**
     * Toggle the technician's on-duty availability.
     * Business rule: Only verified technicians can toggle availability online.
     */
    public function toggleAvailability(Request $request): JsonResponse
    {
        $technician = $request->user()->technician;

        if (! $technician) {
            return response()->json([
                'success' => false,
                'message' => 'Technician profile not found.',
            ], 404);
        }

        $request->validate([
            'is_available' => ['required', 'boolean'],
        ]);

        $desiredStatus = (bool) $request->input('is_available');

        // Business Rule: Unverified or suspended technicians cannot go online
        if ($desiredStatus && ! $technician->isVerified()) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot go online. Technician verification is required before accepting service requests.',
                'verification_status' => $technician->verification_status,
            ], 422);
        }

        $technician->update(['is_available' => $desiredStatus]);

        return response()->json([
            'success' => true,
            'message' => $desiredStatus ? 'You are now online and available for service requests.' : 'You are now offline.',
            'data' => [
                'is_available' => $technician->is_available,
            ],
        ]);
    }
}
