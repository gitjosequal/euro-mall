# Euro Mall — operations checklist

Monorepo: `euro_mall_api` (Laravel), `euro_mall_app` (Flutter).

## API (production)

1. **Environment**  
   Set `APP_URL`, `APP_KEY`, database, `SANCTUM_STATEFUL_DOMAINS` if needed, mail/SMS for OTP, `FCM_PROJECT_ID`, `FCM_CLIENT_EMAIL`, `FCM_PRIVATE_KEY` (PEM with `\n` for newlines).

2. **Install & migrate**  
   `composer install --no-dev --optimize-autoloader`  
   `php artisan migrate --force`  
   `php artisan passport:keys` (if not deployed with keys)  
   `php artisan db:seed --class=RbacSeeder` (or full `EuroMallSeeder` for demo data).

3. **Queues & scheduler**  
   Run a worker: `php artisan queue:work --sleep=3 --tries=3` (supervisor/systemd recommended).  
   Cron: `* * * * * cd /path/to/api && php artisan schedule:run >> /dev/null 2>&1`  
   Jobs cover campaign pushes, voucher reminders, and daily points reset.

4. **Admin**  
   Filament: `/admin`. Configure **App configuration** (currency, onboarding slides, support phone, social links) under **Configuration**.

5. **Backups**  
   Database dumps on a schedule; store `storage/` and Passport keys (`oauth-*.key`) securely; test restore periodically.

6. **Observability**  
   Ship logs to your platform (e.g. CloudWatch, Datadog); alert on HTTP 5xx rate and failed queue jobs (`failed_jobs`).

7. **Security**  
   TLS termination at the edge; rate limits on `auth/otp/*`; rotate secrets after incidents; never commit `.env`.

## Mobile app (release)

1. Point **`AppEnvironment.apiBaseUrl`** (or your flavor) to production `https://host/api/v1/`.  
2. Add production **Firebase** configs (Android `google-services.json`, iOS `GoogleService-Info.plist`).  
3. Build: `flutter build apk` / `flutter build ipa` with correct signing.

## Flutter tests

**Widget smoke (VM, good for CI):** pumps `SplashPage` with localization (no full `EuroMallApp` / Firebase / FCM).

```bash
cd euro_mall_app && flutter pub get && flutter test test/euro_mall_boot_test.dart
```

**Integration smoke (device / simulator):** requires iOS **14+** in `ios/Podfile` (already set). Then:

```bash
cd euro_mall_app && flutter test integration_test/euro_mall_smoke_test.dart
```

Use a booted simulator or `-d chrome` if your Flutter setup supports it.

## Health

- API: Laravel route `GET /up` (if enabled in your install).  
- Verify OTP, dashboard `home/dashboard`, and POS test token against staging before promoting.
