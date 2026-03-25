<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Throwable;

class AppConfigController extends Controller
{
    public function show(): JsonResponse
    {
        if (! Schema::hasTable('app_settings')) {
            return response()->json(['data' => $this->defaultPayload()]);
        }

        try {
            $row = DB::table('app_settings')->first();
        } catch (Throwable $e) {
            Log::warning('app.config.query_failed', ['exception' => $e->getMessage()]);

            return response()->json(['data' => $this->defaultPayload()]);
        }

        if ($row === null) {
            return response()->json(['data' => $this->defaultPayload()]);
        }

        return response()->json([
            'data' => [
                'support_phone' => $row->support_phone ?? null,
                'social_links' => $this->decodeJsonArray($row->social_links ?? null),
                'developer_name' => $row->developer_name ?? null,
                'developer_url' => $row->developer_url ?? null,
                'display_version' => $row->display_version ?? null,
                'currency_symbol' => $row->currency_symbol ?? 'JD',
                'currency_code' => $row->currency_code ?? 'JOD',
                'onboarding_slides' => $this->decodeJsonArray($row->onboarding_slides ?? null),
            ],
        ]);
    }

    /**
     * @return array<string, mixed>
     */
    private function defaultPayload(): array
    {
        return [
            'support_phone' => null,
            'social_links' => [],
            'developer_name' => null,
            'developer_url' => null,
            'display_version' => null,
            'currency_symbol' => 'JD',
            'currency_code' => 'JOD',
            'onboarding_slides' => [],
        ];
    }

    /**
     * @return array<int|string, mixed>
     */
    private function decodeJsonArray(mixed $value): array
    {
        if ($value === null || $value === '') {
            return [];
        }

        if (is_array($value)) {
            return $value;
        }

        if (! is_string($value)) {
            return [];
        }

        $decoded = json_decode($value, true);
        if (json_last_error() !== JSON_ERROR_NONE || ! is_array($decoded)) {
            return [];
        }

        return $decoded;
    }
}
