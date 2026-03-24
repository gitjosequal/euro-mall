<?php

namespace App\Filament\Resources\LoyaltyRedemptionRules;

use App\Filament\Resources\LoyaltyRedemptionRules\Pages\CreateLoyaltyRedemptionRule;
use App\Filament\Resources\LoyaltyRedemptionRules\Pages\EditLoyaltyRedemptionRule;
use App\Filament\Resources\LoyaltyRedemptionRules\Pages\ListLoyaltyRedemptionRules;
use App\Filament\Resources\LoyaltyRedemptionRules\Schemas\LoyaltyRedemptionRuleForm;
use App\Filament\Resources\LoyaltyRedemptionRules\Tables\LoyaltyRedemptionRulesTable;
use App\Models\LoyaltyRedemptionRule;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class LoyaltyRedemptionRuleResource extends Resource
{
    protected static ?string $model = LoyaltyRedemptionRule::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    public static function form(Schema $schema): Schema
    {
        return LoyaltyRedemptionRuleForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return LoyaltyRedemptionRulesTable::configure($table);
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
            'index' => ListLoyaltyRedemptionRules::route('/'),
            'create' => CreateLoyaltyRedemptionRule::route('/create'),
            'edit' => EditLoyaltyRedemptionRule::route('/{record}/edit'),
        ];
    }
}
