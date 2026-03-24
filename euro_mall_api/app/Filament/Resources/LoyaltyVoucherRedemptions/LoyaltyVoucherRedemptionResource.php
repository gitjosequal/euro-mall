<?php

namespace App\Filament\Resources\LoyaltyVoucherRedemptions;

use App\Filament\Resources\LoyaltyVoucherRedemptions\Pages\CreateLoyaltyVoucherRedemption;
use App\Filament\Resources\LoyaltyVoucherRedemptions\Pages\EditLoyaltyVoucherRedemption;
use App\Filament\Resources\LoyaltyVoucherRedemptions\Pages\ListLoyaltyVoucherRedemptions;
use App\Filament\Resources\LoyaltyVoucherRedemptions\Schemas\LoyaltyVoucherRedemptionForm;
use App\Filament\Resources\LoyaltyVoucherRedemptions\Tables\LoyaltyVoucherRedemptionsTable;
use App\Models\LoyaltyVoucherRedemption;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class LoyaltyVoucherRedemptionResource extends Resource
{
    protected static ?string $model = LoyaltyVoucherRedemption::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    public static function form(Schema $schema): Schema
    {
        return LoyaltyVoucherRedemptionForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return LoyaltyVoucherRedemptionsTable::configure($table);
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
            'index' => ListLoyaltyVoucherRedemptions::route('/'),
            'create' => CreateLoyaltyVoucherRedemption::route('/create'),
            'edit' => EditLoyaltyVoucherRedemption::route('/{record}/edit'),
        ];
    }
}
