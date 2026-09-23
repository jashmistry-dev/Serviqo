<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\City;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CityController extends Controller
{
    /**
     * List all active operating cities.
     */
    public function index(Request $request): JsonResponse
    {
        $cities = City::query()
            ->where('is_active', true)
            ->orderBy('name', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Cities retrieved successfully',
            'data' => [
                'cities' => $cities,
            ],
        ]);
    }
}
