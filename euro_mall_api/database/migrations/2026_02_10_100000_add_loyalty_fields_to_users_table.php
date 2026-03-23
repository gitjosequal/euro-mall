<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'current_points')) {
                $table->unsignedInteger('current_points')->default(0)->after('tier_name');
            }
            if (! Schema::hasColumn('users', 'next_tier_points')) {
                $table->unsignedInteger('next_tier_points')->default(4000)->after('current_points');
            }
            if (! Schema::hasColumn('users', 'tier_progress')) {
                $table->decimal('tier_progress', 5, 2)->default(0)->after('next_tier_points');
            }
            if (! Schema::hasColumn('users', 'points_earned_today')) {
                $table->unsignedInteger('points_earned_today')->default(0)->after('tier_progress');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            foreach (['current_points', 'next_tier_points', 'tier_progress', 'points_earned_today'] as $col) {
                if (Schema::hasColumn('users', $col)) {
                    $table->dropColumn($col);
                }
            }
        });
    }
};
