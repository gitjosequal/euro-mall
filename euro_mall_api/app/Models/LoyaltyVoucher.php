<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

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

    /** @return BelongsToMany<User, $this> */
    public function assignedUsers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'loyalty_voucher_assignments')
            ->withTimestamps();
    }

    public function isVisibleTo(?User $user): bool
    {
        if (! $this->assignedUsers()->exists()) {
            return true;
        }

        if (! $user) {
            return false;
        }

        return $this->assignedUsers()->where('users.id', $user->id)->exists();
    }

    /**
     * Catalog vouchers (no per-user restriction) or vouchers assigned to the given user.
     */
    public function scopeVisibleToMember(Builder $query, ?User $user): Builder
    {
        return $query->where(function (Builder $q) use ($user) {
            $q->whereDoesntHave('assignedUsers');
            if ($user) {
                $q->orWhereHas('assignedUsers', fn (Builder $a) => $a->where('users.id', $user->id));
            }
        });
    }
}
