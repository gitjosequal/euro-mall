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
