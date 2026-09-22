<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('transaction_reference', 40)->unique();
            $table->foreignUuid('service_request_id')->nullable()->constrained('service_requests')->cascadeOnDelete();
            $table->foreignUuid('payer_user_id')->constrained('users')->restrictOnDelete();
            $table->foreignUuid('payee_user_id')->constrained('users')->restrictOnDelete();
            $table->string('payment_type', 32)->index(); // visiting_charge, service_full, service_balance, additional_charge, subscription
            $table->string('payment_method', 16)->default('upi')->index(); // upi, cash (Phase 1)
            $table->decimal('amount', 12, 2);
            $table->string('status', 32)->default('pending')->index(); // pending, paid, failed, refunded, disputed
            $table->timestamp('paid_at')->nullable();
            $table->string('upi_transaction_id', 100)->nullable();
            $table->foreignUuid('cash_collected_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('cash_confirmed_at')->nullable();
            $table->jsonb('gateway_response')->nullable();
            $table->timestamps();

            $table->index(['service_request_id', 'payment_type', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};