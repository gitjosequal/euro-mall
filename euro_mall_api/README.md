# Euro Mall API

Laravel 13 REST API for the Euro Mall loyalty mobile app.

- **Base URL:** `/api/v1` (e.g. `https://your-domain.com/api/v1`)
- **Auth:** Laravel Sanctum (`Authorization: Bearer {token}`)
- **Contract:** see [`../docs/API.md`](../docs/API.md)

## Local setup

```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan db:seed
php artisan serve
```

After seeding, the console prints a **demo Sanctum token** for `member@euromall.test` (password: `password`).

## Production

- Set `APP_URL`, database credentials, and `APP_DEBUG=false` in `.env`.
- Run `php artisan migrate --force` on deploy.
- Optionally run `db:seed` only on first deploy (or manage CMS data via admin tools).
