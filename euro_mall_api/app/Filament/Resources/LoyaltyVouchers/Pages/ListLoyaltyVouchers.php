<?php

namespace App\Filament\Resources\LoyaltyVouchers\Pages;

use App\Filament\Resources\LoyaltyVouchers\LoyaltyVoucherResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListLoyaltyVouchers extends ListRecords
{
    protected static string $resource = LoyaltyVoucherResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
