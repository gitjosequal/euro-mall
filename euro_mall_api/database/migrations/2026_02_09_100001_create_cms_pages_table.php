<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('cms_pages')) {
            Schema::table('cms_pages', function (Blueprint $table) {
                if (! Schema::hasColumn('cms_pages', 'title_en')) {
                    $table->string('title_en')->default('')->after('slug');
                }
                if (! Schema::hasColumn('cms_pages', 'title_ar')) {
                    $table->string('title_ar')->default('')->after('title_en');
                }
            });

            return;
        }

        Schema::create('cms_pages', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();
            $table->string('title_en');
            $table->string('title_ar');
            $table->longText('body_en');
            $table->longText('body_ar');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cms_pages');
    }
};
