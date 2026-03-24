<?php

namespace App\Filament\Resources\MallBranches\Pages;

use App\Filament\Resources\MallBranches\MallBranchResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListMallBranches extends ListRecords
{
    protected static string $resource = MallBranchResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
