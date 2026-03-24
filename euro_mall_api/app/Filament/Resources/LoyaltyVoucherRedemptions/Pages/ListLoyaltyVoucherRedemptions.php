<?php

namespace App\Filament\Resources\LoyaltyVoucherRedemptions\Pages;

use App\Filament\Resources\LoyaltyVoucherRedemptions\LoyaltyVoucherRedemptionResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListLoyaltyVoucherRedemptions extends ListRecords
{
    protected static string $resource = LoyaltyVoucherRedemptionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
