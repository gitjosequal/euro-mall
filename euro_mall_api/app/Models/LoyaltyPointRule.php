<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LoyaltyPointRule extends Model
{
    protected $fillable = [
        'name',
        'amount_per_point',
        'points_per_unit',
        'max_points_per_transaction',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'amount_per_point' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }
}
