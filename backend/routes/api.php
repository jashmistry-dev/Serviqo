<?php

use App\Http\Controllers\Api\AdminVerificationController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\CityController;
use App\Http\Controllers\Api\CustomerProfileController;
use App\Http\Controllers\Api\TechnicianProfileController;
use App\Http\Controllers\Api\TechnicianSkillController;
use App\Http\Controllers\Api\TechnicianVerificationController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — Serviqo Local Service Marketplace
|--------------------------------------------------------------------------
*/

// Authentication endpoints
Route::prefix('auth')->group(function () {
    Route::post('/register/customer', [AuthController::class, 'registerCustomer']);
    Route::post('/register/technician', [AuthController::class, 'registerTechnician']);
    Route::post('/login', [AuthController::class, 'login']);

    // Authenticated session management
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
    });
});

// Public Discovery Endpoints
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/categories/{slugOrId}', [CategoryController::class, 'show']);
Route::get('/cities', [CityController::class, 'index']);

// Role-protected: Super Admin
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('/ping', function () {
        return response()->json([
            'message' => 'Admin authorized successfully.',
            'user' => request()->user(),
        ]);
    });

    // Technician Verification Management
    Route::get('/verifications', [AdminVerificationController::class, 'index']);
    Route::get('/verifications/{technicianId}', [AdminVerificationController::class, 'show']);
    Route::post('/verifications/{technicianId}/review', [AdminVerificationController::class, 'review']);
});

// Role-protected: Customer
Route::middleware(['auth:sanctum', 'role:customer'])->prefix('customer')->group(function () {
    Route::get('/ping', function () {
        return response()->json([
            'message' => 'Customer authorized successfully.',
            'user' => request()->user(),
        ]);
    });

    // Customer profile management
    Route::get('/profile', [CustomerProfileController::class, 'show']);
    Route::put('/profile', [CustomerProfileController::class, 'update']);
});

// Role-protected: Technician
Route::middleware(['auth:sanctum', 'role:technician'])->prefix('technician')->group(function () {
    Route::get('/ping', function () {
        return response()->json([
            'message' => 'Technician authorized successfully.',
            'user' => request()->user(),
        ]);
    });

    // Profile & Availability
    Route::get('/profile', [TechnicianProfileController::class, 'show']);
    Route::put('/profile', [TechnicianProfileController::class, 'update']);
    Route::post('/availability', [TechnicianProfileController::class, 'toggleAvailability']);

    // Skills & Services
    Route::get('/skills', [TechnicianSkillController::class, 'index']);
    Route::post('/skills', [TechnicianSkillController::class, 'store']);
    Route::delete('/skills/{categoryId}', [TechnicianSkillController::class, 'destroy']);

    // Verification Documents
    Route::get('/verifications', [TechnicianVerificationController::class, 'index']);
    Route::post('/verifications', [TechnicianVerificationController::class, 'store']);
});