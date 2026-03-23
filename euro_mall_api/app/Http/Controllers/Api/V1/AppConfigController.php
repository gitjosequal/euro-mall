<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;

class AppConfigController extends Controller
{
    public function show()
    {
        $s = AppSetting::query()->first();

        return response()->json([
            'data' => [
                'support_phone' => $s?->support_phone,
                'social_links' => $s?->social_links ?? [],
                'developer_name' => $s?->developer_name,
                'developer_url' => $s?->developer_url,
                'display_version' => $s?->display_version,
            ],
        ]);
    }
}
