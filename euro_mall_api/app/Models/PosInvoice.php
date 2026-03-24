<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PosInvoice extends Model
{
    protected $fillable = [
        'pos_transaction_id',
        'branch_code',
        'customer_phone',
        'transaction_amount',
        'transaction_date',
        'item_details',
        'points_earned',
        'user_id',
    ];

    protected function casts(): array
    {
        return [
            'transaction_amount' => 'decimal:2',
            'transaction_date' => 'datetime',
            'item_details' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
