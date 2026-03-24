<?php

namespace App\Filament\Resources\LoyaltyVoucherRedemptions\Schemas;

use Filament\Forms\Components\Select;
use Filament\Schemas\Schema;

class LoyaltyVoucherRedemptionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('user_id')
                    ->relationship('user', 'name')
                    ->required(),
                Select::make('loyalty_voucher_id')
                    ->relationship('loyaltyVoucher', 'id')
                    ->required(),
            ]);
    }
}
