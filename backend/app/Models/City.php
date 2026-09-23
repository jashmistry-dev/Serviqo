<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class City extends Model
{
    use HasFactory, HasUuids;

    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = [
        'name',
        'state',
        'is_active',
        'pincodes',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'pincodes' => 'array',
        ];
    }

    public function customers(): HasMany
    {
        return $this->hasMany(Customer::class);
    }

    public function technicians(): HasMany
    {
        return $this->hasMany(Technician::class);
    }
}