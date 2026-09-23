<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class ServiceCategory extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'icon_url',
        'image_url',
        'min_visiting_charge',
        'max_visiting_charge',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'min_visiting_charge' => 'decimal:2',
            'max_visiting_charge' => 'decimal:2',
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }
}