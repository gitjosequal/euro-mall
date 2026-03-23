<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Mobile OTP
    |--------------------------------------------------------------------------
    |
    | send: stores a short-lived code in cache for this phone.
    | AUTH_OTP_USE_FIXED=true → code is always AUTH_OTP_CODE (e.g. 1111) for dev.
    | AUTH_OTP_USE_FIXED=false → random 4-digit; integrate SMS in AuthOtpController::send.
    |
    | verify: checks cache first; if AUTH_OTP_FALLBACK_FIXED=true, also accepts
    | AUTH_OTP_CODE without a prior send (dev convenience only — disable in prod).
    |
    */
    'otp_code' => env('AUTH_OTP_CODE', '1111'),

    'otp_use_fixed' => filter_var(
        env('AUTH_OTP_USE_FIXED', 'true'),
        FILTER_VALIDATE_BOOLEAN,
        FILTER_NULL_ON_FAILURE
    ) ?? true,

    'otp_fallback_fixed' => filter_var(
        env('AUTH_OTP_FALLBACK_FIXED', 'true'),
        FILTER_VALIDATE_BOOLEAN,
        FILTER_NULL_ON_FAILURE
    ) ?? true,

    'otp_ttl_seconds' => (int) env('AUTH_OTP_TTL', 600),

];
