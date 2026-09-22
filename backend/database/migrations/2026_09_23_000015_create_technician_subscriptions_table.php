<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('technician_subscriptions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('technician_id')->constrained('technicians')->cascadeOnDelete();
            $table->string('plan_name', 32); // free_starter, pro_monthly, pro_annual
            $table->string('status', 32)->default('active')->index(); // active, expired, cancelled, grace_period
            $table->decimal('amount_paid', 12, 2)->default(0.00);
            $table->foreignUuid('payment_id')->nullable()->constrained('payments')->nullOnDelete();
            $table->timestamp('starts_at');
            $table->timestamp('expires_at');
            $table->timestamps();

            $table->index(['technician_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('technician_subscriptions');
    }
};