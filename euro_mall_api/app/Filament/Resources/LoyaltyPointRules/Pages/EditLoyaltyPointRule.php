<?php

namespace App\Filament\Resources\LoyaltyPointRules\Pages;

use App\Filament\Resources\LoyaltyPointRules\LoyaltyPointRuleResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditLoyaltyPointRule extends EditRecord
{
    protected static string $resource = LoyaltyPointRuleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
