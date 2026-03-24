<?php

namespace App\Filament\Resources\LoyaltyVoucherRedemptions\Pages;

use App\Filament\Resources\LoyaltyVoucherRedemptions\LoyaltyVoucherRedemptionResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditLoyaltyVoucherRedemption extends EditRecord
{
    protected static string $resource = LoyaltyVoucherRedemptionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
