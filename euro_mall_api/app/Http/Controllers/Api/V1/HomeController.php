<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\V1\Concerns\ResolvesSanctumUser;
use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use App\Models\LoyaltyVoucher;
use App\Services\MemberActivityFeedService;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    use ResolvesSanctumUser;

    public function dashboard(Request $request, MemberActivityFeedService $activity)
    {
        $locale = $request->get('locale', 'en') === 'ar' ? 'ar' : 'en';
        $user = $this->optionalSanctumUser($request);
        $settings = AppSetting::query()->first();

        $activeVouchers = LoyaltyVoucher::query()
            ->where('is_active', true)
            ->where('expires_at', '>', now())
            ->visibleToMember($user)
            ->count();

        $currencyBlock = [
            'currency_symbol' => $settings?->currency_symbol ?? 'JD',
            'currency_code' => $settings?->currency_code ?? 'JOD',
        ];

        if (! $user) {
            return response()->json([
                'data' => array_merge([
                    'guest' => true,
                    'display_name' => null,
                    'tier_name' => null,
                    'current_points' => 0,
                    'next_tier_points' => 4000,
                    'tier_progress' => 0.0,
                    'points_today' => 0,
                    'active_vouchers_count' => $activeVouchers,
                    'recent_transactions' => [],
                ], $currencyBlock),
            ]);
        }

        $recent = $activity->itemsForUser($user, $locale, 5);

        return response()->json([
            'data' => array_merge([
                'guest' => false,
                'display_name' => $user->name,
                'tier_name' => $user->tier_name,
                'current_points' => (int) $user->current_points,
                'next_tier_points' => (int) $user->next_tier_points,
                'tier_progress' => (float) $user->tier_progress,
                'points_today' => (int) $user->points_earned_today,
                'active_vouchers_count' => $activeVouchers,
                'recent_transactions' => $recent,
            ], $currencyBlock),
        ]);
    }
}
