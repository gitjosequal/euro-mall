<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class AuthOtpController extends Controller
{
    /**
     * Request OTP: stores code in cache (TTL from config). Integrate SMS in production.
     */
    public function send(Request $request)
    {
        $request->validate([
            'phone' => 'required|string|min:8|max:24',
        ]);

        $phone = $this->normalizePhone($request->phone);
        $useFixed = (bool) config('euromall.otp_use_fixed');
        $code = $useFixed
            ? (string) config('euromall.otp_code')
            : str_pad((string) random_int(0, 9999), 4, '0', STR_PAD_LEFT);

        $ttl = (int) config('euromall.otp_ttl_seconds', 600);
        Cache::put($this->otpCacheKey($phone), $code, $ttl);

        Log::info('Euro Mall OTP', [
            'phone' => $phone,
            'expires_in_seconds' => $ttl,
            // Remove or redact in production if using real SMS
            'code' => $code,
        ]);

        return response()->json([
            'data' => [
                'message' => 'ok',
                'expires_in' => $ttl,
            ],
        ]);
    }

    /**
     * Verify OTP and issue Sanctum token.
     */
    public function verify(Request $request)
    {
        $request->validate([
            'phone' => 'required|string|min:8|max:24',
            'code' => 'required|string|max:16',
        ]);

        $phone = $this->normalizePhone($request->phone);
        $input = (string) $request->code;
        $key = $this->otpCacheKey($phone);
        $cached = Cache::get($key);

        $valid = false;
        if ($cached !== null && hash_equals((string) $cached, $input)) {
            Cache::forget($key);
            $valid = true;
        } elseif (config('euromall.otp_fallback_fixed') && $input === (string) config('euromall.otp_code')) {
            $valid = true;
        }

        if (! $valid) {
            return response()->json([
                'message' => 'Invalid verification code',
            ], 422);
        }

        $email = substr(hash('sha256', $phone), 0, 16).'@m.euromall.app';

        $user = User::query()->firstOrCreate(
            ['phone' => $phone],
            [
                'name' => 'Member',
                'email' => $email,
                'password' => Hash::make(Str::random(40)),
                'gender' => 'other',
                'tier_name' => 'Silver',
                'current_points' => 0,
                'next_tier_points' => 4000,
                'tier_progress' => 0,
                'points_earned_today' => 0,
            ]
        );

        $user->tokens()->where('name', 'mobile-app')->delete();
        $token = $user->createToken('mobile-app')->plainTextToken;

        return response()->json([
            'data' => [
                'token' => $token,
                'token_type' => 'Bearer',
            ],
        ]);
    }

    protected function otpCacheKey(string $normalizedPhone): string
    {
        return 'euromall:otp:'.hash('sha256', $normalizedPhone);
    }

    protected function normalizePhone(string $raw): string
    {
        return preg_replace('/\s+/', '', trim($raw));
    }
}
