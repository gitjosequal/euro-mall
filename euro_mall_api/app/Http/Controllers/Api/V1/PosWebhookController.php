<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\LoyaltyVoucher;
use App\Models\LoyaltyVoucherRedemption;
use App\Models\PosInvoice;
use App\Models\User;
use App\Services\PointsEngineService;
use App\Services\VoucherRedemptionService;
use Illuminate\Http\Request;

class PosWebhookController extends Controller
{
    public function ingestInvoice(Request $request, PointsEngineService $engine)
    {
        $data = $request->validate([
            'branch_code' => 'required|string|max:64',
            'customer_phone' => 'required|string|min:8|max:24',
            'transaction_amount' => 'required|numeric|min:0',
            'pos_transaction_id' => 'required|string|max:128',
            'transaction_date' => 'required|date',
            'item_details' => 'sometimes|array',
        ]);

        $phone = preg_replace('/\s+/', '', trim($data['customer_phone']));
        $existing = PosInvoice::query()
            ->where('pos_transaction_id', $data['pos_transaction_id'])
            ->first();
        if ($existing) {
            return response()->json([
                'data' => [
                    'status' => 'duplicate',
                    'invoice_id' => (string) $existing->id,
                    'points_earned' => (int) $existing->points_earned,
                ],
            ]);
        }

        $user = User::query()->firstOrCreate(
            ['phone' => $phone],
            [
                'name' => 'Member',
                'email' => substr(hash('sha256', $phone), 0, 16).'@m.euromall.app',
                'password' => bcrypt(str()->random(32)),
                'gender' => 'other',
                'tier_name' => 'Silver',
                'current_points' => 0,
                'next_tier_points' => 4000,
                'tier_progress' => 0,
                'points_earned_today' => 0,
            ]
        );

        $amount = (float) $data['transaction_amount'];
        $earned = $engine->calculateEarnedPoints($amount);

        $invoice = PosInvoice::query()->create([
            'pos_transaction_id' => $data['pos_transaction_id'],
            'branch_code' => $data['branch_code'],
            'customer_phone' => $phone,
            'transaction_amount' => $amount,
            'transaction_date' => $data['transaction_date'],
            'item_details' => $data['item_details'] ?? null,
            'points_earned' => $earned,
            'user_id' => $user->id,
        ]);

        $user = $engine->applyEarnedPoints(
            $user,
            $earned,
            $amount,
            'pos_invoice',
            (string) $invoice->id,
            ['pos_transaction_id' => $invoice->pos_transaction_id, 'branch_code' => $invoice->branch_code]
        );

        return response()->json([
            'data' => [
                'status' => 'processed',
                'invoice_id' => (string) $invoice->id,
                'user_id' => (string) $user->id,
                'points_earned' => $earned,
                'points_balance' => (int) $user->current_points,
                'tier_name' => $user->tier_name,
            ],
        ], 201);
    }

    public function validateVoucher(Request $request, VoucherRedemptionService $redemptions)
    {
        $data = $request->validate([
            'voucher_code' => 'required|string|max:64',
            'customer_phone' => 'required|string|min:8|max:24',
            'consume' => 'sometimes|boolean',
        ]);

        $phone = preg_replace('/\s+/', '', trim($data['customer_phone']));
        $user = User::query()->where('phone', $phone)->first();
        if (! $user) {
            return response()->json(['message' => 'Customer not found'], 404);
        }

        $voucher = LoyaltyVoucher::query()
            ->where('is_active', true)
            ->where('code', $data['voucher_code'])
            ->first();

        if (! $voucher) {
            return response()->json(['message' => 'Voucher not found'], 404);
        }

        if (! $voucher->isVisibleTo($user)) {
            return response()->json(['message' => 'Voucher not available for this customer'], 403);
        }

        if ($voucher->expires_at->isPast()) {
            return response()->json(['message' => 'Voucher expired'], 422);
        }

        $already = LoyaltyVoucherRedemption::query()
            ->where('user_id', $user->id)
            ->where('loyalty_voucher_id', $voucher->id)
            ->exists();
        if ($already) {
            return response()->json(['message' => 'Voucher already redeemed'], 409);
        }

        $consume = (bool) ($data['consume'] ?? false);
        if ($consume) {
            try {
                $redemptions->redeemForUser($user, $voucher, ['channel' => 'pos']);
            } catch (\InvalidArgumentException) {
                return response()->json(['message' => 'Voucher expired'], 422);
            } catch (\RuntimeException) {
                return response()->json(['message' => 'Voucher already redeemed'], 409);
            } catch (\DomainException $e) {
                return response()->json(['message' => $e->getMessage()], 422);
            }
        }

        $user->refresh();

        return response()->json([
            'data' => [
                'valid' => true,
                'consumed' => $consume,
                'points_balance' => (int) $user->current_points,
                'voucher' => [
                    'id' => (string) $voucher->id,
                    'code' => $voucher->code,
                    'percentage' => (bool) $voucher->is_percentage,
                    'value' => (float) $voucher->value,
                    'minimum_spend' => $voucher->minimum_spend !== null ? (float) $voucher->minimum_spend : null,
                ],
            ],
        ]);
    }
}
