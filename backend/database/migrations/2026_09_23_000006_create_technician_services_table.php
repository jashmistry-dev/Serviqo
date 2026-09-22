<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('technician_services', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('technician_id')->constrained('technicians')->cascadeOnDelete();
            $table->foreignUuid('service_category_id')->constrained('service_categories')->cascadeOnDelete();
            $table->decimal('custom_visiting_charge', 12, 2)->nullable();
            $table->integer('experience_years')->default(0);
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();

            $table->unique(['technician_id', 'service_category_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('technician_services');
    }
};