<?php

namespace App\Filament\Resources\MallBranches\Pages;

use App\Filament\Resources\MallBranches\MallBranchResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditMallBranch extends EditRecord
{
    protected static string $resource = MallBranchResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
