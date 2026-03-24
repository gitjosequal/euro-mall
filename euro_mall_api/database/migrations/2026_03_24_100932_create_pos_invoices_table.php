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
        Schema::create('pos_invoices', function (Blueprint $table) {
            $table->id();
            $table->string('pos_transaction_id')->unique();
            $table->string('branch_code');
            $table->string('customer_phone');
            $table->decimal('transaction_amount', 12, 2);
            $table->dateTime('transaction_date');
            $table->json('item_details')->nullable();
            $table->unsignedInteger('points_earned')->default(0);
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pos_invoices');
    }
};
