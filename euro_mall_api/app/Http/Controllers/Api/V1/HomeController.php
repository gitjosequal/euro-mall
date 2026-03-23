<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\V1\Concerns\ResolvesSanctumUser;
use App\Http\Controllers\Controller;
use App\Models\CustomerOrder;
use App\Models\LoyaltyVoucher;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    use ResolvesSanctumUser;

    public function dashboard(Request $request)
    {
        $user = $this->optionalSanctumUser($request);

        $activeVouchers = LoyaltyVoucher::query()
            ->where('is_active', true)
            ->where('expires_at', '>', now())
            ->count();

        if (! $user) {
            return response()->json([
                'data' => [
                    'guest' => true,
                    'display_name' => null,
                    'tier_name' => null,
                    'current_points' => 0,
                    'next_tier_points' => 4000,
                    'tier_progress' => 0.0,
                    'points_today' => 0,
                    'active_vouchers_count' => $activeVouchers,
                    'recent_transactions' => [],
                ],
            ]);
        }

        $recent = CustomerOrder::query()
            ->where('user_id', $user->id)
            ->orderByDesc('ordered_at')
            ->limit(5)
            ->get()
            ->map(fn (CustomerOrder $o) => [
                'id' => (string) $o->id,
                'title' => $o->title,
                'date' => $o->ordered_at->toIso8601String(),
                'amount' => (float) $o->amount,
                'points' => (int) $o->points,
                'earned' => (bool) $o->earned,
            ]);

        return response()->json([
            'data' => [
                'guest' => false,
                'display_name' => $user->name,
                'tier_name' => $user->tier_name,
                'current_points' => (int) $user->current_points,
                'next_tier_points' => (int) $user->next_tier_points,
                'tier_progress' => (float) $user->tier_progress,
                'points_today' => (int) $user->points_earned_today,
                'active_vouchers_count' => $activeVouchers,
                'recent_transactions' => $recent,
            ],
        ]);
    }
}
