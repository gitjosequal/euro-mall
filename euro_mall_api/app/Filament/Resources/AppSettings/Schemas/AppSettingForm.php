<?php

namespace App\Filament\Resources\AppSettings\Schemas;

use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class AppSettingForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('support_phone')
                    ->tel()
                    ->label('Support phone'),
                TextInput::make('developer_name')
                    ->label('Developer / partner name'),
                TextInput::make('developer_url')
                    ->url()
                    ->label('Developer URL'),
                TextInput::make('display_version')
                    ->label('Display version (optional)')
                    ->helperText('If set, shown in the app instead of the native build version where applicable.'),
                TextInput::make('currency_symbol')
                    ->maxLength(8)
                    ->helperText('Example: JD — prefix/symbol for amounts in the mobile app.'),
                TextInput::make('currency_code')
                    ->maxLength(8)
                    ->helperText('Example: JOD — passed to NumberFormat.'),
                Repeater::make('social_links')
                    ->label('Social links')
                    ->schema([
                        TextInput::make('label')
                            ->required(),
                        TextInput::make('url')
                            ->url()
                            ->required(),
                        TextInput::make('icon')
                            ->helperText('Optional key, e.g. instagram, facebook.'),
                    ])
                    ->columns(3)
                    ->defaultItems(0)
                    ->collapsible()
                    ->itemLabel(fn (array $state): ?string => $state['label'] ?? null),
                Repeater::make('onboarding_slides')
                    ->label('Mobile onboarding slides')
                    ->schema([
                        TextInput::make('title_en')
                            ->required(),
                        TextInput::make('title_ar')
                            ->required(),
                        Textarea::make('body_en')
                            ->required()
                            ->rows(3),
                        Textarea::make('body_ar')
                            ->required()
                            ->rows(3),
                        TextInput::make('icon')
                            ->placeholder('star_rounded')
                            ->helperText('Icons: star_rounded, qr_code_2_rounded, location_on_rounded, storefront_rounded'),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->defaultItems(0)
                    ->itemLabel(fn (array $state): ?string => $state['title_en'] ?? 'Slide'),
            ]);
    }
}
