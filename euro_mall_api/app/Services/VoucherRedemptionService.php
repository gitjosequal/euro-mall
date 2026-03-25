<?php

namespace App\Services;

use App\Models\LoyaltyRedemptionRule;
use App\Models\LoyaltyVoucher;
use App\Models\LoyaltyVoucherRedemption;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class VoucherRedemptionService
{
    public function __construct(private PointsEngineService $points) {}

    /**
     * Full redemption: optional points cost, single redemption row, returns refreshed user.
     *
     * @param  array<string, mixed>  $meta  Merged into ledger meta (e.g. channel => app|pos)
     *
     * @throws \DomainException insufficient points
     * @throws \InvalidArgumentException voucher expired
     * @throws \RuntimeException already redeemed
     */
    public function redeemForUser(User $user, LoyaltyVoucher $voucher, array $meta = []): User
    {
        return DB::transaction(function () use ($user, $voucher, $meta) {
            $freshUser = User::query()->lockForUpdate()->findOrFail($user->id);

            if ($voucher->expires_at->isPast()) {
                throw new \InvalidArgumentException('Voucher expired');
            }

            if (LoyaltyVoucherRedemption::query()
                ->where('user_id', $freshUser->id)
                ->where('loyalty_voucher_id', $voucher->id)
                ->exists()) {
                throw new \RuntimeException('Already redeemed');
            }

            $rule = LoyaltyRedemptionRule::query()->where('is_active', true)->first();
            if ($rule && (int) $rule->points_required > 0) {
                $cost = (int) $rule->points_required;
                if ((int) $freshUser->current_points < $cost) {
                    throw new \DomainException('Insufficient points to redeem this voucher');
                }
                $freshUser = $this->points->redeemPoints(
                    $freshUser,
                    $cost,
                    'voucher_redemption',
                    (string) $voucher->id,
                    array_merge(['voucher_code' => $voucher->code], $meta)
                );
            }

            LoyaltyVoucherRedemption::query()->create([
                'user_id' => $freshUser->id,
                'loyalty_voucher_id' => $voucher->id,
            ]);

            return $freshUser->refresh();
        });
    }
}
