<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\NotificationPreference;
use Illuminate\Http\Request;

class NotificationPreferenceController extends Controller
{
    public function show(Request $request)
    {
        $prefs = NotificationPreference::query()->firstOrCreate(
            ['user_id' => $request->user()->id],
            [
                'push_marketing' => true,
                'push_orders' => true,
                'email_digest' => false,
            ]
        );

        return response()->json([
            'data' => [
                'push_marketing' => $prefs->push_marketing,
                'push_orders' => $prefs->push_orders,
                'email_digest' => $prefs->email_digest,
            ],
        ]);
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'push_marketing' => 'sometimes|boolean',
            'push_orders' => 'sometimes|boolean',
            'email_digest' => 'sometimes|boolean',
        ]);

        $prefs = NotificationPreference::query()->firstOrCreate(
            ['user_id' => $request->user()->id],
            [
                'push_marketing' => true,
                'push_orders' => true,
                'email_digest' => false,
            ]
        );

        $prefs->fill($validated);
        $prefs->save();

        return $this->show($request);
    }
}
