<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('loyalty_voucher_redemptions')) {
            return;
        }

        Schema::create('loyalty_voucher_redemptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('loyalty_voucher_id')->constrained('loyalty_vouchers')->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['user_id', 'loyalty_voucher_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loyalty_voucher_redemptions');
    }
};
