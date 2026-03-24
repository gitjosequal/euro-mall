<?php

namespace App\Services;

use App\Models\LoyaltyLedger;
use App\Models\LoyaltyPointRule;
use App\Models\LoyaltyTier;
use App\Models\User;
use Carbon\CarbonInterface;
use Illuminate\Support\Facades\DB;

class PointsEngineService
{
    public function calculateEarnedPoints(float $amount): int
    {
        $rule = LoyaltyPointRule::query()->where('is_active', true)->orderBy('id')->first();
        if (! $rule) {
            return 0;
        }

        if ((float) $rule->amount_per_point <= 0.0 || (int) $rule->points_per_unit <= 0) {
            return 0;
        }

        $units = (int) floor($amount / (float) $rule->amount_per_point);
        $earned = $units * (int) $rule->points_per_unit;
        if ($rule->max_points_per_transaction !== null) {
            $earned = min($earned, (int) $rule->max_points_per_transaction);
        }

        return max(0, $earned);
    }

    public function applyEarnedPoints(
        User $user,
        int $points,
        float $amount,
        string $sourceType,
        string $sourceId,
        array $meta = []
    ): User {
        return DB::transaction(function () use ($user, $points, $amount, $sourceType, $sourceId, $meta) {
            $fresh = User::query()->lockForUpdate()->findOrFail($user->id);

            $newBalance = max(0, (int) $fresh->current_points + $points);
            $fresh->current_points = $newBalance;
            $fresh->points_earned_today = max(0, (int) $fresh->points_earned_today + $points);
            $this->applyTier($fresh);
            $fresh->save();

            LoyaltyLedger::query()->create([
                'user_id' => $fresh->id,
                'source_type' => $sourceType,
                'source_id' => $sourceId,
                'transaction_type' => 'earn',
                'amount' => $amount,
                'points_delta' => $points,
                'balance_after' => $newBalance,
                'meta' => $meta,
            ]);

            return $fresh->refresh();
        });
    }

    public function redeemPoints(
        User $user,
        int $points,
        string $sourceType,
        string $sourceId,
        array $meta = []
    ): User {
        return DB::transaction(function () use ($user, $points, $sourceType, $sourceId, $meta) {
            $fresh = User::query()->lockForUpdate()->findOrFail($user->id);

            if ((int) $fresh->current_points < $points) {
                throw new \DomainException('Insufficient points');
            }

            $newBalance = max(0, (int) $fresh->current_points - $points);
            $fresh->current_points = $newBalance;
            $this->applyTier($fresh);
            $fresh->save();

            LoyaltyLedger::query()->create([
                'user_id' => $fresh->id,
                'source_type' => $sourceType,
                'source_id' => $sourceId,
                'transaction_type' => 'redeem',
                'amount' => 0,
                'points_delta' => -$points,
                'balance_after' => $newBalance,
                'meta' => $meta,
            ]);

            return $fresh->refresh();
        });
    }

    public function applyTier(User $user): void
    {
        $tier = LoyaltyTier::query()
            ->where('is_active', true)
            ->where('min_points', '<=', (int) $user->current_points)
            ->where(function ($q) use ($user) {
                $q->whereNull('max_points')
                    ->orWhere('max_points', '>=', (int) $user->current_points);
            })
            ->orderByDesc('min_points')
            ->first();

        if (! $tier) {
            return;
        }

        $user->tier_name = $tier->name;
        $next = LoyaltyTier::query()
            ->where('is_active', true)
            ->where('min_points', '>', (int) $user->current_points)
            ->orderBy('min_points')
            ->first();

        $user->next_tier_points = $next ? (int) $next->min_points : (int) $user->current_points;
        $min = (int) $tier->min_points;
        $target = $next ? (int) $next->min_points : max($min, (int) $user->current_points);
        $den = max(1, $target - $min);
        $num = max(0, (int) $user->current_points - $min);
        $user->tier_progress = min(1, $num / $den);
    }
}

