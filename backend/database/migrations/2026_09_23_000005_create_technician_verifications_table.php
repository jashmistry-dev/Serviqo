<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('technician_verifications', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('technician_id')->constrained('technicians')->cascadeOnDelete();
            $table->string('document_type', 50); // government_id, police_clearance, certification, address_proof
            $table->string('document_number', 100)->nullable();
            $table->string('file_path');
            $table->string('status', 32)->default('pending')->index(); // pending, approved, rejected
            $table->text('rejection_reason')->nullable();
            $table->foreignUuid('reviewed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamps();

            $table->index(['technician_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('technician_verifications');
    }
};