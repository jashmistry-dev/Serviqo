<?php

namespace App\Http\Requests\Technician;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateTechnicianProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() && $this->user()->isTechnician();
    }

    public function rules(): array
    {
        $userId = $this->user()->id;

        return [
            'name' => ['sometimes', 'required', 'string', 'max:150'],
            'phone' => ['sometimes', 'required', 'string', 'regex:/^[6-9]\d{9}$/', Rule::unique('users', 'phone')->ignore($userId)],
            'bio' => ['nullable', 'string', 'max:1000'],
            'experience_years' => ['sometimes', 'required', 'integer', 'min:0', 'max:50'],
            'visiting_charge' => ['sometimes', 'required', 'numeric', 'min:0', 'max:10000'],
            'city_id' => ['nullable', 'uuid', 'exists:cities,id'],
            'address' => ['nullable', 'string', 'max:255'],
            'pincode' => ['nullable', 'string', 'regex:/^\d{6}$/'],
        ];
    }

    public function messages(): array
    {
        return [
            'phone.regex' => 'Phone must be a valid 10-digit Indian mobile number.',
            'visiting_charge.min' => 'Visiting charge cannot be negative.',
            'pincode.regex' => 'Pincode must be a 6-digit postal code.',
        ];
    }
}
