<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LoyaltyVoucher extends Model
{
    protected $fillable = [
        'title_en', 'title_ar', 'description_en', 'description_ar',
        'is_percentage', 'value', 'expires_at', 'code', 'minimum_spend', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_percentage' => 'boolean',
            'is_active' => 'boolean',
            'value' => 'decimal:2',
            'minimum_spend' => 'decimal:2',
            'expires_at' => 'datetime',
        ];
    }
}
