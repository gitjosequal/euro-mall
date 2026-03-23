<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class NotificationPreference extends Model
{
    protected $fillable = [
        'user_id',
        'push_marketing',
        'push_orders',
        'email_digest',
    ];

    protected function casts(): array
    {
        return [
            'push_marketing' => 'boolean',
            'push_orders' => 'boolean',
            'email_digest' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
