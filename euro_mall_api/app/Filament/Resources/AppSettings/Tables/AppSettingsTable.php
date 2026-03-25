<?php

namespace App\Filament\Resources\AppSettings\Tables;

use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class AppSettingsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('support_phone')
                    ->label('Support'),
                TextColumn::make('currency_symbol')
                    ->label('Currency'),
                TextColumn::make('currency_code'),
                TextColumn::make('developer_name')
                    ->toggleable(),
                TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([]);
    }
}
