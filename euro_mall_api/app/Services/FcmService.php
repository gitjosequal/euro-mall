<?php

namespace App\Services;

use Firebase\JWT\JWT;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmService
{
    public function sendToTokens(array $tokens, string $title, string $body, array $data = []): void
    {
        $tokens = array_values(array_unique(array_filter($tokens)));
        if ($tokens === []) {
            return;
        }

        $projectId = config('services.fcm.project_id');
        $clientEmail = config('services.fcm.client_email');
        $privateKey = $this->normalizedPrivateKey(config('services.fcm.private_key'));

        if (! $projectId || ! $clientEmail || ! $privateKey) {
            Log::info('FCM dispatch (stub: set FCM_PROJECT_ID, FCM_CLIENT_EMAIL, FCM_PRIVATE_KEY)', [
                'tokens_count' => count($tokens),
                'title' => $title,
            ]);

            return;
        }

        $access = $this->accessToken($clientEmail, $privateKey);
        if (! $access) {
            return;
        }

        $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";
        $stringData = $this->stringifyData($data);

        foreach ($tokens as $fcmToken) {
            $payload = [
                'message' => [
                    'token' => $fcmToken,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    'data' => $stringData,
                ],
            ];

            $res = Http::withToken($access)->timeout(20)->post($url, $payload);
            if (! $res->successful()) {
                Log::warning('FCM send failed', [
                    'status' => $res->status(),
                    'body' => $res->body(),
                ]);
            }
        }
    }

    /**
     * @return array<string, string>
     */
    protected function stringifyData(array $data): array
    {
        $out = [];
        foreach ($data as $k => $v) {
            $out[(string) $k] = is_string($v) ? $v : json_encode($v);
        }

        return $out;
    }

    protected function normalizedPrivateKey(?string $key): ?string
    {
        if (! $key) {
            return null;
        }

        $k = str_replace('\\n', "\n", trim($key));

        return str_contains($k, 'BEGIN') ? $k : null;
    }

    protected function accessToken(string $clientEmail, string $privateKeyPem): ?string
    {
        $cached = Cache::get('fcm_oauth_access_token');
        if (is_string($cached) && $cached !== '') {
            return $cached;
        }

        $now = time();
        try {
            $jwt = JWT::encode([
                'iss' => $clientEmail,
                'sub' => $clientEmail,
                'aud' => 'https://oauth2.googleapis.com/token',
                'iat' => $now,
                'exp' => $now + 3600,
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            ], $privateKeyPem, 'RS256');
        } catch (\Throwable $e) {
            Log::warning('FCM JWT signing failed', ['message' => $e->getMessage()]);

            return null;
        }

        $res = Http::asForm()->timeout(20)->post('https://oauth2.googleapis.com/token', [
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $jwt,
        ]);

        if (! $res->successful()) {
            Log::warning('FCM OAuth token exchange failed', ['body' => $res->body()]);

            return null;
        }

        $token = $res->json('access_token');
        if (! is_string($token) || $token === '') {
            return null;
        }

        Cache::put('fcm_oauth_access_token', $token, now()->addMinutes(50));

        return $token;
    }
}
