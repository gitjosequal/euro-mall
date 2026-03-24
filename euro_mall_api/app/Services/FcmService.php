<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;

class FcmService
{
    public function sendToTokens(array $tokens, string $title, string $body, array $data = []): void
    {
        $tokens = array_values(array_filter($tokens));
        if ($tokens === []) {
            return;
        }

        // Stage 1: keep integration-safe logging and contract.
        // Stage 2: wire Firebase HTTP v1 sender with service account.
        Log::info('FCM dispatch (stub)', [
            'tokens_count' => count($tokens),
            'title' => $title,
            'body' => $body,
            'data' => $data,
        ]);
    }
}

