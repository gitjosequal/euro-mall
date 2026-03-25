<?php

namespace App\Filament\Resources\MallBranches\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class MallBranchForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name_en')
                    ->required(),
                TextInput::make('name_ar')
                    ->required(),
                TextInput::make('address_en')
                    ->required(),
                TextInput::make('address_ar')
                    ->required(),
                TextInput::make('phone')
                    ->tel()
                    ->required(),
                TextInput::make('pos_branch_code')
                    ->label('POS branch code')
                    ->maxLength(64)
                    ->helperText('Sent with POS invoices as branch_code; must match what the till sends.'),
                TextInput::make('hours_en')
                    ->required(),
                TextInput::make('hours_ar')
                    ->required(),
                TextInput::make('latitude')
                    ->required()
                    ->numeric(),
                TextInput::make('longitude')
                    ->required()
                    ->numeric(),
                Toggle::make('open_now')
                    ->required(),
                TextInput::make('sort_order')
                    ->required()
                    ->numeric()
                    ->default(0),
                Toggle::make('is_active')
                    ->required(),
            ]);
    }
}
