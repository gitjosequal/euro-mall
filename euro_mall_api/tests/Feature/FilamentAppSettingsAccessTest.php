<?php

namespace Tests\Feature;

use App\Models\AppSetting;
use App\Models\User;
use Database\Seeders\RbacSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FilamentAppSettingsAccessTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_open_app_configuration_edit_screen(): void
    {
        $this->seed(RbacSeeder::class);

        $setting = AppSetting::query()->create([
            'support_phone' => '+962',
            'currency_code' => 'JOD',
            'currency_symbol' => 'JD',
            'social_links' => [],
            'onboarding_slides' => [],
        ]);

        $admin = User::query()->where('email', 'admin@euromall.test')->first();
        $this->assertNotNull($admin);

        $this->actingAs($admin)
            ->get('/admin/app-settings/'.$setting->id.'/edit')
            ->assertOk();
    }
}
