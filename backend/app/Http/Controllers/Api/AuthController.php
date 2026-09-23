<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterCustomerRequest;
use App\Http\Requests\Auth\RegisterTechnicianRequest;
use App\Models\Customer;
use App\Models\Technician;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Symfony\Component\HttpFoundation\Response;

class AuthController extends Controller
{
    /**
     * Register a new Customer.
     */
    public function registerCustomer(RegisterCustomerRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $result = DB::transaction(function () use ($validated) {
            $user = User::create([
                'name' => $validated['name'],
                'email' => strtolower($validated['email']),
                'phone' => $validated['phone'],
                'password' => Hash::make($validated['password']),
                'role' => 'customer',
                'is_active' => true,
            ]);

            $customer = Customer::create([
                'user_id' => $user->id,
                'alternate_phone' => $validated['alternate_phone'] ?? null,
                'address_line1' => $validated['address_line1'] ?? null,
                'address_line2' => $validated['address_line2'] ?? null,
                'city_id' => $validated['city_id'] ?? null,
                'pincode' => $validated['pincode'] ?? null,
            ]);

            $token = $user->createToken('serviqo-customer-token')->plainTextToken;

            return compact('user', 'customer', 'token');
        });

        return response()->json([
            'message' => 'Customer registration successful.',
            'token' => $result['token'],
            'user' => $result['user'],
            'profile' => $result['customer'],
        ], Response::HTTP_CREATED);
    }

    /**
     * Register a new Technician.
     */
    public function registerTechnician(RegisterTechnicianRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $result = DB::transaction(function () use ($validated) {
            $user = User::create([
                'name' => $validated['name'],
                'email' => strtolower($validated['email']),
                'phone' => $validated['phone'],
                'password' => Hash::make($validated['password']),
                'role' => 'technician',
                'is_active' => true,
            ]);

            $technician = Technician::create([
                'user_id' => $user->id,
                'bio' => $validated['bio'] ?? null,
                'experience_years' => $validated['experience_years'],
                'visiting_charge' => $validated['visiting_charge'],
                'verification_status' => 'pending',
                'is_available' => false,
                'subscription_tier' => 'free',
                'city_id' => $validated['city_id'] ?? null,
                'address' => $validated['address'] ?? null,
                'pincode' => $validated['pincode'] ?? null,
            ]);

            $token = $user->createToken('serviqo-technician-token')->plainTextToken;

            return compact('user', 'technician', 'token');
        });

        return response()->json([
            'message' => 'Technician registration successful. Please submit verification documents to begin receiving service requests.',
            'token' => $result['token'],
            'user' => $result['user'],
            'profile' => $result['technician'],
        ], Response::HTTP_CREATED);
    }

    /**
     * Authenticate a user and issue a Sanctum token.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $loginInput = $validated['email'];

        // Support login by email or phone
        $user = User::where('email', strtolower($loginInput))
            ->orWhere('phone', $loginInput)
            ->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'message' => 'Invalid email or password.',
            ], Response::HTTP_UNAUTHORIZED);
        }

        // Check if account is active / not suspended
        if (! $user->isActive()) {
            return response()->json([
                'message' => 'Your account has been deactivated or suspended. Please contact support.',
            ], Response::HTTP_FORBIDDEN);
        }

        // Verify role if specified (e.g. Admin portal requires admin role)
        if (! empty($validated['expected_role']) && $user->role !== $validated['expected_role']) {
            return response()->json([
                'message' => "Unauthorized role. This portal requires '{$validated['expected_role']}' privileges.",
            ], Response::HTTP_FORBIDDEN);
        }

        $deviceName = $validated['device_name'] ?? 'serviqo-client';
        $token = $user->createToken($deviceName)->plainTextToken;

        // Load role-specific profile
        $profile = null;
        if ($user->isCustomer()) {
            $profile = $user->customer()->with('city')->first();
        } elseif ($user->isTechnician()) {
            $profile = $user->technician()->with('city')->first();
        }

        return response()->json([
            'message' => 'Login successful.',
            'token' => $token,
            'user' => $user,
            'profile' => $profile,
        ], Response::HTTP_OK);
    }

    /**
     * Revoke the current token.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully.',
        ], Response::HTTP_OK);
    }

    /**
     * Return current authenticated user profile.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        $profile = null;
        if ($user->isCustomer()) {
            $profile = $user->customer()->with('city')->first();
        } elseif ($user->isTechnician()) {
            $profile = $user->technician()->with('city')->first();
        }

        return response()->json([
            'user' => $user,
            'profile' => $profile,
        ], Response::HTTP_OK);
    }
}