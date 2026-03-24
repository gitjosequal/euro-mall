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
        Schema::create('loyalty_redemption_rules', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->unsignedInteger('points_required');
            $table->decimal('value_amount', 10, 2);
            $table->boolean('is_percentage')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('loyalty_redemption_rules');
    }
};
