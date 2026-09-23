<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\CityController;
use App\Http\Controllers\Api\CustomerProfileController;
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

// Role-protected route groups
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('/ping', function () {
        return response()->json([
            'message' => 'Admin authorized successfully.',
            'user' => request()->user(),
        ]);
    });
});

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

Route::middleware(['auth:sanctum', 'role:technician'])->prefix('technician')->group(function () {
    Route::get('/ping', function () {
        return response()->json([
            'message' => 'Technician authorized successfully.',
            'user' => request()->user(),
        ]);
    });
});