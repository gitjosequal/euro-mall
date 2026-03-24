<?php

namespace App\Filament\Resources\LoyaltyPointRules\Pages;

use App\Filament\Resources\LoyaltyPointRules\LoyaltyPointRuleResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListLoyaltyPointRules extends ListRecords
{
    protected static string $resource = LoyaltyPointRuleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
