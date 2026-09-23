<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterTechnicianRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['required', 'string', 'max:20', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:8'],
            'bio' => ['nullable', 'string', 'max:1000'],
            'experience_years' => ['required', 'integer', 'min:0', 'max:60'],
            'visiting_charge' => ['required', 'numeric', 'min:0', 'max:10000'],
            'city_id' => ['nullable', 'uuid', 'exists:cities,id'],
            'address' => ['nullable', 'string', 'max:500'],
            'pincode' => ['nullable', 'string', 'max:10'],
        ];
    }
}