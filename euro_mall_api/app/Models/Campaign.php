<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Campaign extends Model
{
    protected $fillable = [
        'title_en',
        'title_ar',
        'body_en',
        'body_ar',
        'send_at',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'send_at' => 'datetime',
            'is_active' => 'boolean',
        ];
    }
}
