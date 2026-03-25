<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\V1\Concerns\ResolvesSanctumUser;
use App\Http\Controllers\Controller;
use App\Models\LoyaltyVoucher;
use App\Models\LoyaltyVoucherRedemption;
use App\Models\User;
use App\Services\VoucherRedemptionService;
use Carbon\CarbonInterface;
use Illuminate\Http\Request;

class LoyaltyVoucherController extends Controller
{
    use ResolvesSanctumUser;

    public function index(Request $request)
    {
        $locale = $request->get('locale', 'en') === 'ar' ? 'ar' : 'en';
        $user = $this->optionalSanctumUser($request);

        $rows = LoyaltyVoucher::query()
            ->where('is_active', true)
            ->visibleToMember($user)
            ->orderBy('id')
            ->get();

        $redeemedAt = $this->redeemedAtMapForUser($user, $rows->pluck('id')->all());

        return response()->json([
            'data' => $rows->map(fn (LoyaltyVoucher $v) => $this->transform(
                $v,
                $locale,
                $redeemedAt[$v->id] ?? null
            ))->values(),
        ]);
    }

    public function show(Request $request, string $id)
    {
        $locale = $request->get('locale', 'en') === 'ar' ? 'ar' : 'en';
        $user = $this->optionalSanctumUser($request);
        $v = LoyaltyVoucher::query()->where('is_active', true)->findOrFail($id);
        if (! $v->isVisibleTo($user)) {
            abort(404);
        }

        $redeemedAt = null;
        if ($user) {
            $redeemedAt = LoyaltyVoucherRedemption::query()
                ->where('user_id', $user->id)
                ->where('loyalty_voucher_id', $v->id)
                ->value('created_at');
        }

        return response()->json([
            'data' => $this->transform($v, $locale, $redeemedAt),
        ]);
    }

    /**
     * Record a one-time redemption for the authenticated member.
     */
    public function redeem(Request $request, string $id, VoucherRedemptionService $redemptions)
    {
        $v = LoyaltyVoucher::query()->where('is_active', true)->findOrFail($id);
        $user = $request->user();

        if (! $v->isVisibleTo($user)) {
            return response()->json(['message' => 'Voucher not found'], 404);
        }

        try {
            $redemptions->redeemForUser($user, $v, ['channel' => 'app']);
        } catch (\InvalidArgumentException) {
            return response()->json(['message' => 'This voucher has expired'], 422);
        } catch (\RuntimeException) {
            return response()->json(['message' => 'You have already redeemed this voucher'], 409);
        } catch (\DomainException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'data' => [
                'redeemed_at' => now()->toIso8601String(),
                'message' => 'ok',
            ],
        ]);
    }

    /**
     * @param  array<int>  $voucherIds
     * @return array<int, CarbonInterface>
     */
    protected function redeemedAtMapForUser(?User $user, array $voucherIds): array
    {
        if (! $user || $voucherIds === []) {
            return [];
        }

        return LoyaltyVoucherRedemption::query()
            ->where('user_id', $user->id)
            ->whereIn('loyalty_voucher_id', $voucherIds)
            ->get(['loyalty_voucher_id', 'created_at'])
            ->keyBy('loyalty_voucher_id')
            ->map(fn (LoyaltyVoucherRedemption $r) => $r->created_at)
            ->all();
    }

    protected function transform(
        LoyaltyVoucher $v,
        string $locale,
        mixed $redeemedAt = null
    ): array {
        $title = $locale === 'ar' ? $v->title_ar : $v->title_en;
        $description = $locale === 'ar' ? $v->description_ar : $v->description_en;

        $redeemedIso = null;
        if ($redeemedAt !== null) {
            $redeemedIso = $redeemedAt instanceof CarbonInterface
                ? $redeemedAt->toIso8601String()
                : (string) $redeemedAt;
        }

        return [
            'id' => (string) $v->id,
            'title' => $title,
            'description' => $description,
            'percentage' => $v->is_percentage,
            'value' => (float) $v->value,
            'expires_at' => $v->expires_at->toIso8601String(),
            'code' => $v->code,
            'minimum_spend' => $v->minimum_spend !== null ? (float) $v->minimum_spend : null,
            'redeemed_at' => $redeemedIso,
        ];
    }
}
