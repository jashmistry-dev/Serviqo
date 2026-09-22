<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('complaints', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('ticket_number', 32)->unique();
            $table->foreignUuid('service_request_id')->constrained('service_requests')->cascadeOnDelete();
            $table->foreignUuid('raised_by_user_id')->constrained('users')->restrictOnDelete();
            $table->foreignUuid('against_user_id')->constrained('users')->restrictOnDelete();
            $table->string('complaint_type', 32); // service_quality, billing_issue, no_show, behavior, damage, other
            $table->text('description');
            $table->jsonb('evidence_files')->nullable();
            $table->string('status', 32)->default('opened')->index(); // opened, under_investigation, resolved, escalated, dismissed
            $table->text('resolution_notes')->nullable();
            $table->foreignUuid('resolved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();

            $table->index(['service_request_id', 'status']);
            $table->index(['against_user_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('complaints');
    }
};