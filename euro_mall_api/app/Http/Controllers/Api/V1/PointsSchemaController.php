<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\CmsPage;

class PointsSchemaController extends Controller
{
    public function show()
    {
        $page = CmsPage::query()->where('slug', 'points_schema')->firstOrFail();
        $locale = request('locale', 'en') === 'ar' ? 'ar' : 'en';
        $body = $locale === 'ar' ? $page->body_ar : $page->body_en;

        return response()->json([
            'data' => [
                'body' => $body,
            ],
        ]);
    }
}
