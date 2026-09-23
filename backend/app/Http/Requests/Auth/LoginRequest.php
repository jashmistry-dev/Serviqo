<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'string'],
            'password' => ['required', 'string'],
            'expected_role' => ['nullable', 'string', 'in:customer,technician,admin'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ];
    }
}