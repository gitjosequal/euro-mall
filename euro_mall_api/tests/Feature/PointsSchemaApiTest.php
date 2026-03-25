<?php

namespace Tests\Feature;

use App\Models\CmsPage;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PointsSchemaApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_points_schema_returns_ok_with_null_body_when_row_missing(): void
    {
        $this->getJson('/api/v1/points/schema?locale=en')
            ->assertOk()
            ->assertJsonPath('data.body', null);
    }

    public function test_points_schema_returns_markdown_when_seeded(): void
    {
        CmsPage::query()->create([
            'slug' => 'points_schema',
            'title_en' => 'Points',
            'title_ar' => 'نقاط',
            'body_en' => '# Hello',
            'body_ar' => '# مرحبا',
        ]);

        $this->getJson('/api/v1/points/schema?locale=en')
            ->assertOk()
            ->assertJsonPath('data.body', '# Hello');

        $this->getJson('/api/v1/points/schema?locale=ar')
            ->assertOk()
            ->assertJsonPath('data.body', '# مرحبا');
    }
}
