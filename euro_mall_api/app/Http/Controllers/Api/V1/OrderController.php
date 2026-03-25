<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use App\Services\MemberActivityFeedService;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    /**
     * Full points & order activity (loyalty ledger + customer orders).
     */
    public function index(Request $request, MemberActivityFeedService $activity)
    {
        $locale = $request->get('locale', 'en') === 'ar' ? 'ar' : 'en';
        $user = $request->user();
        $items = $activity->itemsForUser($user, $locale);
        $settings = AppSetting::query()->first();

        return response()->json([
            'data' => $items,
            'meta' => [
                'currency_symbol' => $settings?->currency_symbol ?? 'JD',
                'currency_code' => $settings?->currency_code ?? 'JOD',
            ],
        ]);
    }
}
