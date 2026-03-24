<?php

namespace App\Filament\Resources\CustomerOrders;

use App\Filament\Resources\CustomerOrders\Pages\CreateCustomerOrder;
use App\Filament\Resources\CustomerOrders\Pages\EditCustomerOrder;
use App\Filament\Resources\CustomerOrders\Pages\ListCustomerOrders;
use App\Filament\Resources\CustomerOrders\Schemas\CustomerOrderForm;
use App\Filament\Resources\CustomerOrders\Tables\CustomerOrdersTable;
use App\Models\CustomerOrder;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class CustomerOrderResource extends Resource
{
    protected static ?string $model = CustomerOrder::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    public static function form(Schema $schema): Schema
    {
        return CustomerOrderForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return CustomerOrdersTable::configure($table);
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
            'index' => ListCustomerOrders::route('/'),
            'create' => CreateCustomerOrder::route('/create'),
            'edit' => EditCustomerOrder::route('/{record}/edit'),
        ];
    }
}
