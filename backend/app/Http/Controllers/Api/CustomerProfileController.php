<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Customer\UpdateCustomerProfileRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CustomerProfileController extends Controller
{
    /**
     * Get the authenticated customer's profile.
     */
    public function show(Request $request): JsonResponse
    {
        $user = $request->user()->load(['customer.city']);

        return response()->json([
            'success' => true,
            'message' => 'Customer profile retrieved successfully',
            'data' => [
                'user' => $user,
                'customer' => $user->customer,
            ],
        ]);
    }

    /**
     * Update the authenticated customer's profile.
     */
    public function update(UpdateCustomerProfileRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        DB::transaction(function () use ($user, $validated) {
            // Update user table fields
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

            // Update or create customer table fields
            $customerFields = [
                'alternate_phone',
                'address_line1',
                'address_line2',
                'city_id',
                'pincode',
                'latitude',
                'longitude',
            ];

            $customerData = [];
            foreach ($customerFields as $field) {
                if (array_key_exists($field, $validated)) {
                    $customerData[$field] = $validated[$field];
                }
            }

            if (! empty($customerData)) {
                $user->customer()->updateOrCreate(
                    ['user_id' => $user->id],
                    $customerData
                );
            }
        });

        $user->refresh()->load(['customer.city']);

        return response()->json([
            'success' => true,
            'message' => 'Customer profile updated successfully',
            'data' => [
                'user' => $user,
                'customer' => $user->customer,
            ],
        ]);
    }
}
