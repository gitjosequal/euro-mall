<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class MeController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'data' => [
                'name' => $user->name,
                'phone' => $user->phone ?? '',
                'email' => $user->email,
                'gender' => $user->gender ?? 'other',
                'dob' => $user->dob?->format('Y-m-d'),
                'tier_name' => $user->tier_name,
                'current_points' => (int) ($user->current_points ?? 0),
                'next_tier_points' => (int) ($user->next_tier_points ?? 4000),
                'tier_progress' => (float) ($user->tier_progress ?? 0),
                'points_earned_today' => (int) ($user->points_earned_today ?? 0),
            ],
        ]);
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|max:255',
            'gender' => 'sometimes|in:male,female,other',
            'dob' => 'sometimes|nullable|date',
        ]);

        $request->user()->fill($validated);
        $request->user()->save();

        return $this->show($request);
    }
}
