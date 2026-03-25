<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mall_branches', function (Blueprint $table) {
            $table->string('pos_branch_code', 64)->nullable()->after('phone');
        });
    }

    public function down(): void
    {
        Schema::table('mall_branches', function (Blueprint $table) {
            $table->dropColumn('pos_branch_code');
        });
    }
};
