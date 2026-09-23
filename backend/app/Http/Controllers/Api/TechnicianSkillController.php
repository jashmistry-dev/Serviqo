<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Technician\AddSkillRequest;
use App\Models\TechnicianService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TechnicianSkillController extends Controller
{
    /**
     * List technician's service skills.
     */
    public function index(Request $request): JsonResponse
    {
        $technician = $request->user()->technician;

        if (! $technician) {
            return response()->json(['success' => false, 'message' => 'Technician profile not found'], 404);
        }

        $services = $technician->services()->with('serviceCategory')->get();

        return response()->json([
            'success' => true,
            'data' => [
                'services' => $services,
            ],
        ]);
    }

    /**
     * Add or update a service skill for the technician.
     */
    public function store(AddSkillRequest $request): JsonResponse
    {
        $technician = $request->user()->technician;
        $validated = $request->validated();

        $service = TechnicianService::updateOrCreate(
            [
                'technician_id' => $technician->id,
                'service_category_id' => $validated['service_category_id'],
            ],
            [
                'custom_visiting_charge' => $validated['custom_visiting_charge'] ?? null,
                'experience_years' => $validated['experience_years'] ?? 0,
                'is_active' => true,
            ]
        );

        $service->load('serviceCategory');

        return response()->json([
            'success' => true,
            'message' => 'Service skill added successfully',
            'data' => [
                'service' => $service,
            ],
        ], 201);
    }

    /**
     * Remove a service skill from technician.
     */
    public function destroy(Request $request, string $categoryId): JsonResponse
    {
        $technician = $request->user()->technician;

        $deleted = TechnicianService::where('technician_id', $technician->id)
            ->where('service_category_id', $categoryId)
            ->delete();

        if (! $deleted) {
            return response()->json(['success' => false, 'message' => 'Skill not found'], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Service skill removed successfully',
        ]);
    }
}
