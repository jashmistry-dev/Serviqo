<?php

namespace App\Http\Requests\Customer;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateCustomerProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() && $this->user()->isCustomer();
    }

    public function rules(): array
    {
        $userId = $this->user()->id;

        return [
            'name' => ['sometimes', 'required', 'string', 'max:150'],
            'phone' => ['sometimes', 'required', 'string', 'regex:/^[6-9]\d{9}$/', Rule::unique('users', 'phone')->ignore($userId)],
            'alternate_phone' => ['nullable', 'string', 'regex:/^[6-9]\d{9}$/'],
            'address_line1' => ['nullable', 'string', 'max:255'],
            'address_line2' => ['nullable', 'string', 'max:255'],
            'city_id' => ['nullable', 'uuid', 'exists:cities,id'],
            'pincode' => ['nullable', 'string', 'regex:/^\d{6}$/'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
        ];
    }

    public function messages(): array
    {
        return [
            'phone.regex' => 'Phone must be a valid 10-digit Indian mobile number.',
            'alternate_phone.regex' => 'Alternate phone must be a valid 10-digit Indian mobile number.',
            'city_id.exists' => 'Selected city does not exist in operating areas.',
            'pincode.regex' => 'Pincode must be a 6-digit postal code.',
        ];
    }
}
