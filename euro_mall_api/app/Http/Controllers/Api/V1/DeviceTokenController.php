<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\DeviceToken;
use Illuminate\Http\Request;

class DeviceTokenController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'fcm_token' => 'required|string|max:2048',
            'platform' => 'sometimes|string|max:32',
        ]);

        DeviceToken::query()->updateOrCreate(
            ['fcm_token' => $data['fcm_token']],
            [
                'user_id' => $request->user()->id,
                'platform' => $data['platform'] ?? 'unknown',
                'last_seen_at' => now(),
            ]
        );

        return response()->json(['data' => ['message' => 'ok']]);
    }

    public function destroy(Request $request)
    {
        $data = $request->validate([
            'fcm_token' => 'required|string|max:2048',
        ]);

        DeviceToken::query()
            ->where('user_id', $request->user()->id)
            ->where('fcm_token', $data['fcm_token'])
            ->delete();

        return response()->json(['data' => ['message' => 'ok']]);
    }
}
