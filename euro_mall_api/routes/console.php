<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;
use App\Jobs\SendVoucherExpiryPushJob;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Schedule::job(new SendVoucherExpiryPushJob(3))->dailyAt('09:00');

Schedule::call(function () {
    \App\Models\User::query()
        ->where('points_earned_today', '>', 0)
        ->update(['points_earned_today' => 0]);
})->dailyAt('00:00');
