<?php

namespace App\Filament\Resources\PosInvoices\Pages;

use App\Filament\Resources\PosInvoices\PosInvoiceResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditPosInvoice extends EditRecord
{
    protected static string $resource = PosInvoiceResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
