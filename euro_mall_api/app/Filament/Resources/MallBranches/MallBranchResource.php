<?php

namespace App\Filament\Resources\MallBranches;

use App\Filament\Resources\MallBranches\Pages\CreateMallBranch;
use App\Filament\Resources\MallBranches\Pages\EditMallBranch;
use App\Filament\Resources\MallBranches\Pages\ListMallBranches;
use App\Filament\Resources\MallBranches\Schemas\MallBranchForm;
use App\Filament\Resources\MallBranches\Tables\MallBranchesTable;
use App\Models\MallBranch;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class MallBranchResource extends Resource
{
    protected static ?string $model = MallBranch::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    public static function form(Schema $schema): Schema
    {
        return MallBranchForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return MallBranchesTable::configure($table);
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
            'index' => ListMallBranches::route('/'),
            'create' => CreateMallBranch::route('/create'),
            'edit' => EditMallBranch::route('/{record}/edit'),
        ];
    }
}
