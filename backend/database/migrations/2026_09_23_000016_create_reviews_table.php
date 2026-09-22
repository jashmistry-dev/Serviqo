<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reviews', function (Blueprint $table) {
            $table->uuid('id')->primary();
            // Exactly one valid review per service request (BR-006)
            $table->foreignUuid('service_request_id')->unique()->constrained('service_requests')->cascadeOnDelete();
            $table->foreignUuid('customer_id')->constrained('customers')->restrictOnDelete();
            $table->foreignUuid('technician_id')->constrained('technicians')->cascadeOnDelete();
            $table->smallInteger('rating'); // 1 to 5
            $table->text('review_text')->nullable();
            $table->text('technician_reply')->nullable();
            $table->timestamp('technician_replied_at')->nullable();
            $table->boolean('is_public')->default(true)->index();
            $table->timestamps();

            $table->index(['technician_id', 'rating']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};