<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\MallBranch;
use Illuminate\Http\Request;

class MallBranchController extends Controller
{
    public function index(Request $request)
    {
        $locale = $request->get('locale', 'en') === 'ar' ? 'ar' : 'en';
        $rows = MallBranch::query()
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        return response()->json([
            'data' => $rows->map(fn (MallBranch $b) => $this->transform($b, $locale))->values(),
        ]);
    }

    protected function transform(MallBranch $b, string $locale): array
    {
        return [
            'id' => (string) $b->id,
            'name' => $locale === 'ar' ? $b->name_ar : $b->name_en,
            'address' => $locale === 'ar' ? $b->address_ar : $b->address_en,
            'phone' => $b->phone,
            'pos_branch_code' => $b->pos_branch_code,
            'hours' => $locale === 'ar' ? $b->hours_ar : $b->hours_en,
            'latitude' => (float) $b->latitude,
            'longitude' => (float) $b->longitude,
            'open_now' => (bool) $b->open_now,
        ];
    }
}
