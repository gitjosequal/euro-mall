<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\CustomerOrder;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $orders = CustomerOrder::query()
            ->where('user_id', $request->user()->id)
            ->orderByDesc('ordered_at')
            ->get();

        return response()->json([
            'data' => $orders->map(function (CustomerOrder $o) {
                return [
                    'id' => (string) $o->id,
                    'title' => $o->title,
                    'date' => $o->ordered_at->toIso8601String(),
                    'amount' => (float) $o->amount,
                    'points' => (int) $o->points,
                    'earned' => (bool) $o->earned,
                ];
            })->values(),
        ]);
    }
}
