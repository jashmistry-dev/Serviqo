<?php

namespace App\Http\Requests\Technician;

use Illuminate\Foundation\Http\FormRequest;

class AddSkillRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() && $this->user()->isTechnician();
    }

    public function rules(): array
    {
        return [
            'service_category_id' => ['required', 'uuid', 'exists:service_categories,id'],
            'custom_visiting_charge' => ['nullable', 'numeric', 'min:0', 'max:10000'],
            'experience_years' => ['nullable', 'integer', 'min:0', 'max:50'],
        ];
    }
}
