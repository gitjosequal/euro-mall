<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('loyalty_point_rules', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->decimal('amount_per_point', 10, 2)->default(1);
            $table->unsignedInteger('points_per_unit')->default(1);
            $table->unsignedInteger('max_points_per_transaction')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('loyalty_point_rules');
    }
};
