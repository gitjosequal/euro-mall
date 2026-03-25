<?php

namespace App\Http\Controllers\Api\V1\Concerns;

use App\Models\User;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;

trait ResolvesSanctumUser
{
    protected function optionalSanctumUser(Request $request): ?User
    {
        $authUser = $request->user();
        if ($authUser instanceof User) {
            return $authUser;
        }

        $token = $request->bearerToken();
        if (! $token) {
            return null;
        }

        $accessToken = PersonalAccessToken::findToken($token);

        if (! $accessToken || ! ($accessToken->tokenable instanceof User)) {
            return null;
        }

        return $accessToken->tokenable;
    }
}
