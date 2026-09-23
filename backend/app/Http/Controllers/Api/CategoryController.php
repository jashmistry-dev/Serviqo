<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ServiceCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    /**
     * List all active service categories ordered by sort_order.
     */
    public function index(Request $request): JsonResponse
    {
        $categories = ServiceCategory::query()
            ->where('is_active', true)
            ->orderBy('sort_order', 'asc')
            ->orderBy('name', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Service categories retrieved successfully',
            'data' => [
                'categories' => $categories,
            ],
        ]);
    }

    /**
     * Get details of a specific service category by slug or ID.
     */
    public function show(string $slugOrId): JsonResponse
    {
        $category = ServiceCategory::query()
            ->where('slug', $slugOrId)
            ->orWhere('id', $slugOrId)
            ->first();

        if (! $category || ! $category->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Service category not found or inactive',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'category' => $category,
            ],
        ]);
    }
}
