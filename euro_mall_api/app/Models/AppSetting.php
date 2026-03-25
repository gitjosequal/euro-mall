<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AppSetting extends Model
{
    protected $fillable = [
        'support_phone',
        'developer_name',
        'developer_url',
        'display_version',
        'social_links',
        'currency_symbol',
        'currency_code',
        'onboarding_slides',
    ];

    protected function casts(): array
    {
        return [
            'social_links' => 'array',
            'onboarding_slides' => 'array',
        ];
    }
}
