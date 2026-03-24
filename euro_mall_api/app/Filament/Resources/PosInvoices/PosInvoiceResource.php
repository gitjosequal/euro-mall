<?php

namespace App\Filament\Resources\PosInvoices;

use App\Filament\Resources\PosInvoices\Pages\CreatePosInvoice;
use App\Filament\Resources\PosInvoices\Pages\EditPosInvoice;
use App\Filament\Resources\PosInvoices\Pages\ListPosInvoices;
use App\Filament\Resources\PosInvoices\Schemas\PosInvoiceForm;
use App\Filament\Resources\PosInvoices\Tables\PosInvoicesTable;
use App\Models\PosInvoice;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class PosInvoiceResource extends Resource
{
    protected static ?string $model = PosInvoice::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    public static function form(Schema $schema): Schema
    {
        return PosInvoiceForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return PosInvoicesTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListPosInvoices::route('/'),
            'create' => CreatePosInvoice::route('/create'),
            'edit' => EditPosInvoice::route('/{record}/edit'),
        ];
    }
}
