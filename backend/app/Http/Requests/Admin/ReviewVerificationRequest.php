<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class ReviewVerificationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() && $this->user()->isAdmin();
    }

    public function rules(): array
    {
        return [
            'action' => ['required', 'string', 'in:approve,reject,suspend'],
            'reason' => ['required_if:action,reject,suspend', 'nullable', 'string', 'max:1000'],
        ];
    }

    public function messages(): array
    {
        return [
            'action.in' => 'Review action must be one of: approve, reject, suspend.',
            'reason.required_if' => 'A reason is required when rejecting or suspending a technician.',
        ];
    }
}
