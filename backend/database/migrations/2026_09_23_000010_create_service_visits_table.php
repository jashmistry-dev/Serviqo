<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('service_visits', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('service_request_id')->constrained('service_requests')->cascadeOnDelete();
            $table->foreignUuid('technician_id')->constrained('technicians')->restrictOnDelete();
            // Status: scheduled, on_the_way, arrived, inspection_in_progress, completed, cancelled
            $table->string('visit_status', 32)->default('scheduled')->index();
            $table->timestamp('scheduled_at');
            $table->timestamp('arrived_at')->nullable();
            $table->timestamp('completed_at')->nullable();

            // Visiting charge (payable even if quotation rejected, BR-002)
            $table->decimal('visiting_charge', 12, 2)->default(0.00);
            $table->boolean('visiting_charge_paid')->default(false)->index();
            $table->text('inspection_notes')->nullable();
            $table->jsonb('inspection_images')->nullable();
            $table->timestamps();

            $table->index(['service_request_id', 'visit_status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('service_visits');
    }
};