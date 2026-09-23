<?php

namespace App\Http\Requests\Technician;

use Illuminate\Foundation\Http\FormRequest;

class UploadVerificationDocumentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() && $this->user()->isTechnician();
    }

    public function rules(): array
    {
        return [
            'document_type' => ['required', 'string', 'in:government_id,police_clearance,certification,address_proof'],
            'document_number' => ['nullable', 'string', 'max:100'],
            'document' => ['required', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'], // 5MB max
        ];
    }

    public function messages(): array
    {
        return [
            'document_type.in' => 'Document type must be one of: government_id, police_clearance, certification, address_proof.',
            'document.mimes' => 'Document must be a valid PDF or image file (jpg, jpeg, png).',
            'document.max' => 'Document file size must not exceed 5MB.',
        ];
    }
}
