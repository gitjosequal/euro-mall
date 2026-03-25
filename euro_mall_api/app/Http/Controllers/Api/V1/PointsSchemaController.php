<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\CmsPage;

class PointsSchemaController extends Controller
{
    /**
     * Public points-program copy from CMS. Returns 200 with null body if the row
     * is missing so the mobile app can show an empty-state instead of HTTP 404.
     */
    public function show()
    {
        $page = CmsPage::query()->where('slug', 'points_schema')->first();
        $locale = request('locale', 'en') === 'ar' ? 'ar' : 'en';

        $body = null;
        if ($page !== null) {
            $raw = $locale === 'ar' ? $page->body_ar : $page->body_en;
            $body = $raw !== null && $raw !== '' ? $raw : null;
        }

        return response()->json([
            'data' => [
                'body' => $body,
            ],
        ]);
    }
}
