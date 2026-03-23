<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LoyaltyVoucherRedemption extends Model
{
    protected $fillable = [
        'user_id',
        'loyalty_voucher_id',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function loyaltyVoucher(): BelongsTo
    {
        return $this->belongsTo(LoyaltyVoucher::class);
    }
}
