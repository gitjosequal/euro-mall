# Staging API & Git

## Repositories (canonical)

| Project | GitHub |
|---------|--------|
| **Laravel API** | **https://github.com/gitjosequal/euromall_laravel.git** |
| **Flutter app** | **https://github.com/gitjosequal/euromall_flutter.git** |

Clone each repo separately (recommended for CI/CD and access control):

```bash
# Backend
git clone https://github.com/gitjosequal/euromall_laravel.git
cd euromall_laravel

# Mobile
git clone https://github.com/gitjosequal/euromall_flutter.git
cd euromall_flutter
```

If `git push` fails with **SSH host key verification**, use HTTPS remotes:

```bash
# In Laravel repo
git remote set-url origin https://github.com/gitjosequal/euromall_laravel.git

# In Flutter repo
git remote set-url origin https://github.com/gitjosequal/euromall_flutter.git
```

**Combined workspace:** If you keep both folders in one directory (e.g. `euro_mall/`), set `origin` only inside each project folder to the matching URL above—do not use a single monorepo remote unless you maintain one.

## Language (first launch)

- On first install, the app uses the **device language**: Arabic → UI in Arabic, otherwise English.
- The user can switch **English / Arabic** under **Settings → Preferences**; saved in `shared_preferences`.

## Flutter → API URL

- **File:** `lib/core/config/app_environment.dart` (in **euromall_flutter**)
- **Default:** `https://euromall.josequal.net/api/v1`

```bash
cd euromall_flutter
flutter run --dart-define=API_BASE_URL=https://euromall.josequal.net/api/v1
```

See `.vscode/launch.json` for `toolArgs` with the same define.

## Laravel API (local)

```bash
cd euromall_laravel
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan db:seed
php artisan serve
```

Point the app at `http://127.0.0.1:8000/api/v1` when testing locally.

Full contract: **`docs/API.md`** (keep a copy in the Laravel repo alongside the API, or link from the Flutter repo README).

## Deploy backend to staging

On the server: pull **euromall_laravel**, set `.env`, run `composer install --no-dev`, `php artisan migrate --force`, cache config.

Recommended production services (Hetzner target):

- Nginx with SSL (Let's Encrypt), PHP-FPM 8.3+, MySQL 8+, Redis.
- Queue worker: `php artisan queue:work --tries=3 --timeout=90`.
- Scheduler (cron): `* * * * * php /var/www/euromall_laravel/artisan schedule:run >> /dev/null 2>&1`.
- Cache warmup: `php artisan config:cache && php artisan route:cache && php artisan view:cache`.
- Passport keys present and secure (`storage/oauth-*.key`).
- OTP dev mode only on staging (`AUTH_OTP_CODE=1111`, fixed enabled); disable fixed OTP on production cutover.
