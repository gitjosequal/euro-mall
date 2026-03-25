<?php

namespace App\Filament\Resources\LoyaltyVouchers\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class LoyaltyVoucherForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('title_en')
                    ->required(),
                TextInput::make('title_ar')
                    ->required(),
                Textarea::make('description_en')
                    ->required()
                    ->columnSpanFull(),
                Textarea::make('description_ar')
                    ->required()
                    ->columnSpanFull(),
                Toggle::make('is_percentage')
                    ->required(),
                TextInput::make('value')
                    ->required()
                    ->numeric(),
                DateTimePicker::make('expires_at')
                    ->required(),
                TextInput::make('code')
                    ->required(),
                TextInput::make('minimum_spend')
                    ->numeric(),
                Toggle::make('is_active')
                    ->required(),
                Select::make('assignedUsers')
                    ->label('Restricted to members')
                    ->relationship('assignedUsers', 'name')
                    ->multiple()
                    ->preload()
                    ->searchable()
                    ->columnSpanFull()
                    ->helperText('Leave empty: visible to everyone. If you pick members, only they see this voucher.'),
            ]);
    }
}
