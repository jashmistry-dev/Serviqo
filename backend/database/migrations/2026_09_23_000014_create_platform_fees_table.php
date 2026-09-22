<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('platform_fees', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('service_request_id')->constrained('service_requests')->cascadeOnDelete();
            $table->foreignUuid('technician_id')->constrained('technicians')->restrictOnDelete();
            $table->foreignUuid('payment_id')->nullable()->constrained('payments')->nullOnDelete();
            $table->decimal('base_amount', 12, 2);
            $table->decimal('fee_percentage', 5, 2)->default(10.00);
            $table->decimal('fee_amount', 12, 2);
            $table->decimal('gst_amount', 12, 2)->default(0.00);
            $table->decimal('total_platform_fee', 12, 2);
            $table->string('status', 32)->default('pending')->index(); // pending, deducted, waived, settled
            $table->timestamp('settled_at')->nullable();
            $table->timestamps();

            $table->unique('service_request_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('platform_fees');
    }
};