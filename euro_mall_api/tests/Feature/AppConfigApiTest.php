<?php

namespace Tests\Feature;

use App\Models\AppSetting;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class AppConfigApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_app_config_returns_defaults_when_no_row(): void
    {
        $this->getJson('/api/v1/app/config')
            ->assertOk()
            ->assertJsonPath('data.currency_code', 'JOD')
            ->assertJsonPath('data.currency_symbol', 'JD')
            ->assertJsonPath('data.social_links', [])
            ->assertJsonPath('data.onboarding_slides', []);
    }

    public function test_app_config_returns_stored_values(): void
    {
        AppSetting::query()->create([
            'support_phone' => '+962 1',
            'developer_name' => 'Dev',
            'developer_url' => 'https://example.test',
            'display_version' => '1.0',
            'currency_symbol' => '$',
            'currency_code' => 'USD',
            'social_links' => [['label' => 'X', 'url' => 'https://x.test', 'icon' => 'x']],
            'onboarding_slides' => [['title_en' => 'Hi', 'title_ar' => 'هلا', 'body_en' => 'a', 'body_ar' => 'ب', 'icon' => 'star']],
        ]);

        $this->getJson('/api/v1/app/config')
            ->assertOk()
            ->assertJsonPath('data.support_phone', '+962 1')
            ->assertJsonPath('data.currency_code', 'USD')
            ->assertJsonPath('data.social_links.0.label', 'X')
            ->assertJsonPath('data.onboarding_slides.0.title_en', 'Hi');
    }

    public function test_app_config_tolerates_invalid_json_columns(): void
    {
        DB::table('app_settings')->insert([
            'support_phone' => '+1',
            'developer_name' => null,
            'developer_url' => null,
            'display_version' => null,
            'social_links' => 'not-valid-json{',
            'currency_symbol' => '€',
            'currency_code' => 'EUR',
            'onboarding_slides' => 'also-bad',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->getJson('/api/v1/app/config')
            ->assertOk()
            ->assertJsonPath('data.support_phone', '+1')
            ->assertJsonPath('data.currency_code', 'EUR')
            ->assertJsonPath('data.social_links', [])
            ->assertJsonPath('data.onboarding_slides', []);
    }
}
