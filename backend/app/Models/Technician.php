<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
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

    public function verifications(): HasMany
    {
        return $this->hasMany(TechnicianVerification::class);
    }

    public function services(): HasMany
    {
        return $this->hasMany(TechnicianService::class);
    }

    public function serviceCategories(): BelongsToMany
    {
        return $this->belongsToMany(
            ServiceCategory::class,
            'technician_services',
            'technician_id',
            'service_category_id'
        )->withPivot(['custom_visiting_charge', 'experience_years', 'is_active'])->withTimestamps();
    }

    public function isVerified(): bool
    {
        return $this->verification_status === 'verified';
    }

    public function markUnderReview(): void
    {
        $this->update(['verification_status' => 'under_review']);
    }

    public function markVerified(string $adminId): void
    {
        $this->update([
            'verification_status' => 'verified',
            'verified_at' => now(),
            'verified_by' => $adminId,
            'verification_notes' => null,
        ]);
    }

    public function markRejected(string $adminId, string $reason): void
    {
        $this->update([
            'verification_status' => 'rejected',
            'verified_at' => null,
            'verified_by' => $adminId,
            'verification_notes' => $reason,
        ]);
    }

    public function markSuspended(string $adminId, string $reason): void
    {
        $this->update([
            'verification_status' => 'suspended',
            'is_available' => false,
            'verified_by' => $adminId,
            'verification_notes' => $reason,
        ]);
    }
}