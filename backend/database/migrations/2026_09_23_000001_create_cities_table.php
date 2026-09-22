<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cities', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name', 100);
            $table->string('state', 100);
            $table->boolean('is_active')->default(true)->index();
            $table->jsonb('pincodes')->nullable();
            $table->timestamps();

            $table->unique(['name', 'state']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cities');
    }
};