<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')
                    ->required(),
                TextInput::make('email')
                    ->label('Email address')
                    ->email()
                    ->required(),
                DateTimePicker::make('email_verified_at'),
                TextInput::make('password')
                    ->password()
                    ->required(),
                TextInput::make('phone')
                    ->tel(),
                TextInput::make('gender'),
                DatePicker::make('dob'),
                TextInput::make('tier_name'),
                TextInput::make('current_points')
                    ->required()
                    ->numeric()
                    ->default(0),
                TextInput::make('next_tier_points')
                    ->required()
                    ->numeric()
                    ->default(4000),
                TextInput::make('tier_progress')
                    ->required()
                    ->numeric()
                    ->default(0),
                TextInput::make('points_earned_today')
                    ->required()
                    ->numeric()
                    ->default(0),
            ]);
    }
}
