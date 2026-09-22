<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('request_technician_assignments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('service_request_id')->constrained('service_requests')->cascadeOnDelete();
            $table->foreignUuid('technician_id')->constrained('technicians')->cascadeOnDelete();
            // Status: pending, viewed, accepted, rejected, expired, lost_race
            $table->string('status', 32)->default('pending')->index();
            $table->decimal('visiting_charge_offered', 12, 2)->default(0.00);
            $table->timestamp('responded_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamps();

            $table->unique(['service_request_id', 'technician_id']);
            $table->index(['technician_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('request_technician_assignments');
    }
};