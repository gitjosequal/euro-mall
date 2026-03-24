<?php

namespace App\Jobs;

use App\Models\Campaign;
use App\Models\DeviceToken;
use App\Services\FcmService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class SendCampaignPushJob implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct(public int $campaignId)
    {
    }

    /**
     * Execute the job.
     */
    public function handle(FcmService $fcm): void
    {
        $campaign = Campaign::query()->find($this->campaignId);
        if (! $campaign || ! $campaign->is_active) {
            return;
        }

        $tokens = DeviceToken::query()->pluck('fcm_token')->all();
        $fcm->sendToTokens(
            $tokens,
            $campaign->title_en,
            $campaign->body_en,
            ['campaign_id' => (string) $campaign->id, 'type' => 'campaign']
        );
    }
}
