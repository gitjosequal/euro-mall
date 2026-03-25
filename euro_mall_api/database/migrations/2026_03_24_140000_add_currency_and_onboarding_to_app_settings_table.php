<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('app_settings', function (Blueprint $table) {
            if (! Schema::hasColumn('app_settings', 'currency_symbol')) {
                $table->string('currency_symbol', 8)->nullable()->after('social_links');
            }
            if (! Schema::hasColumn('app_settings', 'currency_code')) {
                $table->string('currency_code', 8)->nullable()->after('currency_symbol');
            }
            if (! Schema::hasColumn('app_settings', 'onboarding_slides')) {
                $table->json('onboarding_slides')->nullable()->after('currency_code');
            }
        });
    }

    public function down(): void
    {
        Schema::table('app_settings', function (Blueprint $table) {
            foreach (['currency_symbol', 'currency_code', 'onboarding_slides'] as $col) {
                if (Schema::hasColumn('app_settings', $col)) {
                    $table->dropColumn($col);
                }
            }
        });
    }
};
