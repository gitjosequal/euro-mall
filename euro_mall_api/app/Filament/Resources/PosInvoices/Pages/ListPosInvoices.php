<?php

namespace App\Filament\Resources\PosInvoices\Pages;

use App\Filament\Resources\PosInvoices\PosInvoiceResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListPosInvoices extends ListRecords
{
    protected static string $resource = PosInvoiceResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
