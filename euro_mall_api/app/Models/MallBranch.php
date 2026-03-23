<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MallBranch extends Model
{
    protected $fillable = [
        'name_en', 'name_ar', 'address_en', 'address_ar', 'phone',
        'hours_en', 'hours_ar', 'latitude', 'longitude', 'open_now', 'sort_order', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'open_now' => 'boolean',
            'is_active' => 'boolean',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
        ];
    }
}
