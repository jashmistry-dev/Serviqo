<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Technician\UploadVerificationDocumentRequest;
use App\Models\TechnicianVerification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class TechnicianVerificationController extends Controller
{
    /**
     * List all submitted verification documents and current status.
     */
    public function index(Request $request): JsonResponse
    {
        $technician = $request->user()->technician;

        if (! $technician) {
            return response()->json(['success' => false, 'message' => 'Technician profile not found'], 404);
        }

        $verifications = $technician->verifications()
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'verification_status' => $technician->verification_status,
                'verified_at' => $technician->verified_at,
                'verification_notes' => $technician->verification_notes,
                'documents' => $verifications,
                'is_verified' => $technician->isVerified(),
                'disclaimer' => 'Verified based on submitted and reviewed information.',
            ],
        ]);
    }

    /**
     * Upload a verification document.
     */
    public function store(UploadVerificationDocumentRequest $request): JsonResponse
    {
        $technician = $request->user()->technician;
        $validated = $request->validated();

        $file = $request->file('document');
        $filename = sprintf('tech_%s_%s_%d.%s', $technician->id, $validated['document_type'], time(), $file->getClientOriginalExtension());
        $path = $file->storeAs('verifications', $filename, 'public');

        $verification = TechnicianVerification::create([
            'technician_id' => $technician->id,
            'document_type' => $validated['document_type'],
            'document_number' => $validated['document_number'] ?? null,
            'file_path' => $path,
            'status' => 'pending',
        ]);

        // If technician status is pending or rejected, move to under_review upon document upload
        if (in_array($technician->verification_status, ['pending', 'rejected'])) {
            $technician->markUnderReview();
        }

        return response()->json([
            'success' => true,
            'message' => 'Verification document uploaded successfully and submitted for administrator review.',
            'data' => [
                'verification' => $verification,
                'verification_status' => $technician->verification_status,
                'disclaimer' => 'Verified based on submitted and reviewed information.',
            ],
        ], 201);
    }
}
