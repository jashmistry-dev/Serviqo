<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('technicians', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->text('bio')->nullable();
            $table->integer('experience_years')->default(0);
            $table->decimal('visiting_charge', 12, 2)->default(0.00); // BR-002: visiting charge tracked separately
            $table->string('verification_status', 32)->default('pending')->index(); // pending, under_review, verified, rejected, suspended
            $table->text('verification_notes')->nullable();
            $table->timestamp('verified_at')->nullable();
            $table->foreignUuid('verified_by')->nullable()->constrained('users')->nullOnDelete();
            $table->boolean('is_available')->default(false)->index();
            $table->string('subscription_tier', 32)->default('free')->index(); // free, basic, pro
            $table->timestamp('subscription_expires_at')->nullable();
            $table->decimal('rating_avg', 3, 2)->default(0.00)->index();
            $table->integer('rating_count')->default(0);
            $table->foreignUuid('city_id')->nullable()->constrained('cities')->nullOnDelete();
            $table->text('address')->nullable();
            $table->string('pincode', 10)->nullable()->index();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['verification_status', 'is_available']);
            $table->index(['city_id', 'pincode']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('technicians');
    }
};