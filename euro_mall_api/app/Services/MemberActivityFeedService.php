<?php

namespace App\Services;

use App\Models\CustomerOrder;
use App\Models\LoyaltyLedger;
use App\Models\User;

class MemberActivityFeedService
{
    /**
     * Unified timeline: loyalty ledger + mall orders, newest first.
     *
     * @return list<array<string, mixed>>
     */
    public function itemsForUser(User $user, string $locale, ?int $limit = null): array
    {
        $ar = $locale === 'ar';

        $rows = collect();

        foreach (LoyaltyLedger::query()->where('user_id', $user->id)->orderByDesc('created_at')->cursor() as $row) {
            $rows->push([
                '_t' => $row->created_at->getTimestamp(),
                'payload' => $this->fromLedger($row, $ar),
            ]);
        }

        foreach (CustomerOrder::query()->where('user_id', $user->id)->orderByDesc('ordered_at')->cursor() as $order) {
            $rows->push([
                '_t' => $order->ordered_at->getTimestamp(),
                'payload' => $this->fromOrder($order),
            ]);
        }

        $sorted = $rows->sortByDesc('_t')->values();
        if ($limit !== null) {
            $sorted = $sorted->take($limit);
        }

        return $sorted->pluck('payload')->values()->all();
    }

    /**
     * @return array<string, mixed>
     */
    protected function fromLedger(LoyaltyLedger $row, bool $ar): array
    {
        $earn = $row->transaction_type === 'earn';

        return [
            'id' => 'ledger_'.$row->id,
            'title' => $this->ledgerTitle($row, $ar),
            'date' => $row->created_at->toIso8601String(),
            'amount' => (float) $row->amount,
            'points' => abs((int) $row->points_delta),
            'earned' => $earn,
            'source' => 'loyalty_ledger',
        ];
    }

    /**
     * @return array<string, mixed>
     */
    protected function fromOrder(CustomerOrder $order): array
    {
        return [
            'id' => 'order_'.$order->id,
            'title' => $order->title,
            'date' => $order->ordered_at->toIso8601String(),
            'amount' => (float) $order->amount,
            'points' => abs((int) $order->points),
            'earned' => (bool) $order->earned,
            'source' => 'order',
        ];
    }

    protected function ledgerTitle(LoyaltyLedger $row, bool $ar): string
    {
        $src = $row->source_type;
        $txn = $row->transaction_type;

        if ($txn === 'earn' && $src === 'pos_invoice') {
            return $ar ? 'نقاط من الشراء' : 'Points from purchase';
        }

        if ($txn === 'redeem' && $src === 'voucher_redemption') {
            return $ar ? 'استبدال قسيمة' : 'Voucher redemption';
        }

        if ($txn === 'earn') {
            return $ar ? 'إضافة نقاط' : 'Points earned';
        }

        return $ar ? 'استبدال نقاط' : 'Points redeemed';
    }
}
