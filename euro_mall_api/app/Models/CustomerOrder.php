<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CustomerOrder extends Model
{
    protected $table = 'customer_orders';

    protected $fillable = [
        'user_id',
        'title',
        'ordered_at',
        'amount',
        'points',
        'earned',
    ];

    protected function casts(): array
    {
        return [
            'ordered_at' => 'datetime',
            'amount' => 'decimal:2',
            'earned' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
