<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LoyaltyRedemptionRule extends Model
{
    protected $fillable = [
        'name',
        'points_required',
        'value_amount',
        'is_percentage',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'value_amount' => 'decimal:2',
            'is_percentage' => 'boolean',
            'is_active' => 'boolean',
        ];
    }
}
