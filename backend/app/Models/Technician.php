<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Technician extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = [
        'user_id',
        'bio',
        'experience_years',
        'visiting_charge',
        'verification_status',
        'verification_notes',
        'verified_at',
        'verified_by',
        'is_available',
        'subscription_tier',
        'subscription_expires_at',
        'rating_avg',
        'rating_count',
        'city_id',
        'address',
        'pincode',
        'latitude',
        'longitude',
    ];

    protected function casts(): array
    {
        return [
            'visiting_charge' => 'decimal:2',
            'rating_avg' => 'decimal:2',
            'rating_count' => 'integer',
            'experience_years' => 'integer',
            'is_available' => 'boolean',
            'verified_at' => 'datetime',
            'subscription_expires_at' => 'datetime',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function city(): BelongsTo
    {
        return $this->belongsTo(City::class);
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function isVerified(): bool
    {
        return $this->verification_status === 'verified';
    }
}