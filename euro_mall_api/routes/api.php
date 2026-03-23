<?php

use App\Http\Controllers\Api\V1\AppConfigController;
use App\Http\Controllers\Api\V1\CmsPageController;
use App\Http\Controllers\Api\V1\ContactController;
use App\Http\Controllers\Api\V1\FaqController;
use App\Http\Controllers\Api\V1\MeController;
use App\Http\Controllers\Api\V1\NotificationPreferenceController;
use App\Http\Controllers\Api\V1\OrderController;
use App\Http\Controllers\Api\V1\PointsSchemaController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
| Euro Mall mobile API — base path: /api/v1/...
| Flutter: AppEnvironment.apiBaseUrl = https://your-host/api/v1
*/

Route::prefix('v1')->group(function () {
    Route::get('app/config', [AppConfigController::class, 'show']);
    Route::get('cms/pages/{slug}', [CmsPageController::class, 'show']);
    Route::get('faqs', [FaqController::class, 'index']);
    Route::post('contact', [ContactController::class, 'store']);
    Route::get('points/schema', [PointsSchemaController::class, 'show']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('me', [MeController::class, 'show']);
        Route::put('me', [MeController::class, 'update']);
        Route::get('me/notification-preferences', [NotificationPreferenceController::class, 'show']);
        Route::put('me/notification-preferences', [NotificationPreferenceController::class, 'update']);
        Route::get('orders', [OrderController::class, 'index']);
    });
});

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
