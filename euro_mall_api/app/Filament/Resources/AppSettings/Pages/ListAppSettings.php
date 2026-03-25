<?php

namespace App\Filament\Resources\AppSettings\Pages;

use App\Filament\Resources\AppSettings\AppSettingResource;
use App\Models\AppSetting;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListAppSettings extends ListRecords
{
    protected static string $resource = AppSettingResource::class;

    public function mount(): void
    {
        if (AppSetting::query()->count() === 0) {
            AppSetting::query()->create([
                'support_phone' => null,
                'developer_name' => null,
                'developer_url' => null,
                'display_version' => null,
                'social_links' => [],
                'currency_symbol' => 'JD',
                'currency_code' => 'JOD',
                'onboarding_slides' => [],
            ]);
        }

        parent::mount();
    }

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make()
                ->visible(fn (): bool => AppSettingResource::canCreate()),
        ];
    }
}
