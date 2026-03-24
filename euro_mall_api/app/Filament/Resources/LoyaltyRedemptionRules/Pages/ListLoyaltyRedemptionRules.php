<?php

namespace App\Filament\Resources\LoyaltyRedemptionRules\Pages;

use App\Filament\Resources\LoyaltyRedemptionRules\LoyaltyRedemptionRuleResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListLoyaltyRedemptionRules extends ListRecords
{
    protected static string $resource = LoyaltyRedemptionRuleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
