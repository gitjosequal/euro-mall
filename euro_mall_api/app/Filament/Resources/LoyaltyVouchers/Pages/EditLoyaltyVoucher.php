<?php

namespace App\Filament\Resources\LoyaltyVouchers\Pages;

use App\Filament\Resources\LoyaltyVouchers\LoyaltyVoucherResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditLoyaltyVoucher extends EditRecord
{
    protected static string $resource = LoyaltyVoucherResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
