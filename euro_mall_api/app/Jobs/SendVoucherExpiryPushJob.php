<?php

namespace App\Jobs;

use App\Models\DeviceToken;
use App\Models\LoyaltyVoucher;
use App\Services\FcmService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class SendVoucherExpiryPushJob implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct(public int $daysAhead = 3)
    {
    }

    /**
     * Execute the job.
     */
    public function handle(FcmService $fcm): void
    {
        $hasExpiring = LoyaltyVoucher::query()
            ->where('is_active', true)
            ->whereBetween('expires_at', [now(), now()->addDays($this->daysAhead)])
            ->exists();

        if (! $hasExpiring) {
            return;
        }

        $tokens = DeviceToken::query()->pluck('fcm_token')->all();
        $fcm->sendToTokens(
            $tokens,
            'Vouchers expiring soon',
            'You have vouchers that will expire soon.',
            ['type' => 'voucher_expiry', 'days_ahead' => (string) $this->daysAhead]
        );
    }
}
