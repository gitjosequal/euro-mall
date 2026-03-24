<?php

namespace App\Filament\Resources\LoyaltyPointRules;

use App\Filament\Resources\LoyaltyPointRules\Pages\CreateLoyaltyPointRule;
use App\Filament\Resources\LoyaltyPointRules\Pages\EditLoyaltyPointRule;
use App\Filament\Resources\LoyaltyPointRules\Pages\ListLoyaltyPointRules;
use App\Filament\Resources\LoyaltyPointRules\Schemas\LoyaltyPointRuleForm;
use App\Filament\Resources\LoyaltyPointRules\Tables\LoyaltyPointRulesTable;
use App\Models\LoyaltyPointRule;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class LoyaltyPointRuleResource extends Resource
{
    protected static ?string $model = LoyaltyPointRule::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    public static function form(Schema $schema): Schema
    {
        return LoyaltyPointRuleForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return LoyaltyPointRulesTable::configure($table);
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
            'index' => ListLoyaltyPointRules::route('/'),
            'create' => CreateLoyaltyPointRule::route('/create'),
            'edit' => EditLoyaltyPointRule::route('/{record}/edit'),
        ];
    }
}
