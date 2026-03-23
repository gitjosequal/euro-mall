<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LoyaltyOffer extends Model
{
    protected $fillable = [
        'title_en', 'title_ar', 'subtitle_en', 'subtitle_ar',
        'badge_en', 'badge_ar', 'image_url', 'expires_at', 'sort_order', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'expires_at' => 'datetime',
        ];
    }
}
