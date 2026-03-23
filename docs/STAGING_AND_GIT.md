# Staging API & Git

## Repository

Monorepo on GitHub: **https://github.com/gitjosequal/euro-mall**

- `euro_mall_app/` — Flutter app  
- `euro_mall_api/` — Laravel 13 API (`/api/v1`)

Clone:

```bash
git clone https://github.com/gitjosequal/euro-mall.git
cd euro-mall
```

If `git push` fails with **SSH host key verification**, use HTTPS remote:

```bash
git remote set-url origin https://github.com/gitjosequal/euro-mall.git
```

## Language (first launch)

- On first install, the app uses the **device language**: Arabic → UI in Arabic, otherwise English.
- The user can switch **English / Arabic** under **Settings → Preferences**; saved in `shared_preferences`.

## Flutter → API URL

- **File:** `euro_mall_app/lib/core/config/app_environment.dart`
- **Default:** `https://euromall.josequal.net/api/v1`

```bash
cd euro_mall_app
flutter run --dart-define=API_BASE_URL=https://euromall.josequal.net/api/v1
```

See `.vscode/launch.json` for `toolArgs` with the same define.

## Laravel API (local)

```bash
cd euro_mall_api
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan db:seed
php artisan serve
```

Point the app at `http://127.0.0.1:8000/api/v1` when testing locally.

Full contract: **`docs/API.md`**.

## Deploy backend to staging

On the server: pull repo (or only `euro_mall_api/`), set `.env`, run `composer install --no-dev`, `php artisan migrate --force`, cache config.
