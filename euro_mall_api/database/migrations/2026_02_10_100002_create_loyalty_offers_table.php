<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('loyalty_offers')) {
            return;
        }

        Schema::create('loyalty_offers', function (Blueprint $table) {
            $table->id();
            $table->string('title_en');
            $table->string('title_ar');
            $table->string('subtitle_en');
            $table->string('subtitle_ar');
            $table->string('badge_en');
            $table->string('badge_ar');
            $table->string('image_url')->nullable();
            $table->dateTime('expires_at')->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loyalty_offers');
    }
};
