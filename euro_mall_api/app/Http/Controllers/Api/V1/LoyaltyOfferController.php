<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\LoyaltyOffer;
use Illuminate\Http\Request;

class LoyaltyOfferController extends Controller
{
    public function index(Request $request)
    {
        $locale = $request->get('locale', 'en') === 'ar' ? 'ar' : 'en';
        $rows = LoyaltyOffer::query()
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        return response()->json([
            'data' => $rows->map(fn (LoyaltyOffer $o) => $this->transform($o, $locale))->values(),
        ]);
    }

    protected function transform(LoyaltyOffer $o, string $locale): array
    {
        return [
            'id' => (string) $o->id,
            'title' => $locale === 'ar' ? $o->title_ar : $o->title_en,
            'subtitle' => $locale === 'ar' ? $o->subtitle_ar : $o->subtitle_en,
            'badge' => $locale === 'ar' ? $o->badge_ar : $o->badge_en,
            'image_url' => $o->image_url,
            'expires_at' => $o->expires_at?->toIso8601String(),
        ];
    }
}
