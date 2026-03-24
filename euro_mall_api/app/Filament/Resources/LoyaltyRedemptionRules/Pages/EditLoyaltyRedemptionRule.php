<?php

namespace App\Filament\Resources\LoyaltyRedemptionRules\Pages;

use App\Filament\Resources\LoyaltyRedemptionRules\LoyaltyRedemptionRuleResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditLoyaltyRedemptionRule extends EditRecord
{
    protected static string $resource = LoyaltyRedemptionRuleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
