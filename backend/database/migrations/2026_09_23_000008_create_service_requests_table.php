<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('service_requests', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('tracking_number', 32)->unique();
            $table->foreignUuid('customer_id')->constrained('customers')->restrictOnDelete();
            $table->foreignUuid('service_category_id')->constrained('service_categories')->restrictOnDelete();
            $table->string('title');
            $table->text('description');
            $table->jsonb('images')->nullable();
            $table->date('preferred_date');
            $table->string('preferred_time_slot', 32); // morning, afternoon, evening
            $table->text('address_line');
            $table->foreignUuid('city_id')->nullable()->constrained('cities')->nullOnDelete();
            $table->string('pincode', 10)->index();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();

            // Status state machine
            $table->string('status', 32)->default('requested')->index();
            // assigned_technician_id is NULL until first acceptance locks the request atomically (BR-001, BR-003)
            $table->foreignUuid('assigned_technician_id')->nullable()->constrained('technicians')->nullOnDelete();
            $table->timestamp('accepted_at')->nullable();

            $table->timestamp('cancelled_at')->nullable();
            $table->foreignUuid('cancelled_by')->nullable()->constrained('users')->nullOnDelete();
            $table->text('cancellation_reason')->nullable();
            $table->timestamp('completed_at')->nullable();

            // Financial locks
            $table->decimal('visiting_charge_locked', 12, 2)->default(0.00); // BR-002: locked visiting charge
            $table->integer('lock_version')->default(0); // Optimistic locking support

            $table->timestamps();
            $table->softDeletes();

            $table->index(['status', 'created_at']);
            $table->index(['customer_id', 'status']);
            $table->index(['assigned_technician_id', 'status']);
            $table->index(['city_id', 'pincode']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('service_requests');
    }
};