<?php

namespace App\Filament\Resources\LoyaltyVouchers;

use App\Filament\Resources\LoyaltyVouchers\Pages\CreateLoyaltyVoucher;
use App\Filament\Resources\LoyaltyVouchers\Pages\EditLoyaltyVoucher;
use App\Filament\Resources\LoyaltyVouchers\Pages\ListLoyaltyVouchers;
use App\Filament\Resources\LoyaltyVouchers\Schemas\LoyaltyVoucherForm;
use App\Filament\Resources\LoyaltyVouchers\Tables\LoyaltyVouchersTable;
use App\Models\LoyaltyVoucher;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class LoyaltyVoucherResource extends Resource
{
    protected static ?string $model = LoyaltyVoucher::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    public static function form(Schema $schema): Schema
    {
        return LoyaltyVoucherForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return LoyaltyVouchersTable::configure($table);
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
            'index' => ListLoyaltyVouchers::route('/'),
            'create' => CreateLoyaltyVoucher::route('/create'),
            'edit' => EditLoyaltyVoucher::route('/{record}/edit'),
        ];
    }
}
