<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('loyalty_voucher_assignments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('loyalty_voucher_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['loyalty_voucher_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loyalty_voucher_assignments');
    }
};
