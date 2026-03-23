<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\CmsPage;

class CmsPageController extends Controller
{
    public function show(string $slug)
    {
        $page = CmsPage::query()->where('slug', $slug)->firstOrFail();
        $locale = request('locale', 'en') === 'ar' ? 'ar' : 'en';

        return response()->json([
            'data' => [
                'slug' => $page->slug,
                'title' => $locale === 'ar' ? $page->title_ar : $page->title_en,
                'body' => $locale === 'ar' ? $page->body_ar : $page->body_en,
            ],
        ]);
    }
}
