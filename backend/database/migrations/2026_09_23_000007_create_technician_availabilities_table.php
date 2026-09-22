<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('technician_availabilities', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('technician_id')->constrained('technicians')->cascadeOnDelete();
            $table->smallInteger('day_of_week'); // 0=Sunday, 1=Monday ... 6=Saturday
            $table->time('start_time');
            $table->time('end_time');
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();

            $table->index(['technician_id', 'day_of_week']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('technician_availabilities');
    }
};