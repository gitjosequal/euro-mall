# Euro Mall

Loyalty product: **Flutter app** + **Laravel API**.

## Canonical GitHub repositories

| Component | Repository |
|-----------|------------|
| **Backend (Laravel)** | **https://github.com/gitjosequal/euromall_laravel.git** |
| **Mobile (Flutter)** | **https://github.com/gitjosequal/euromall_flutter.git** |

Use those remotes when pushing each codebase. This workspace may still contain both projects side by side for local development.

| Path (this workspace) | Description |
|----------------------|-------------|
| [`euro_mall_app/`](euro_mall_app/) | Flutter mobile app → push to **euromall_flutter** |
| [`euro_mall_api/`](euro_mall_api/) | Laravel REST API (`/api/v1`) → push to **euromall_laravel** |
| [`docs/API.md`](docs/API.md) | Mobile ↔ API contract (mirror into each repo as needed) |

## API quick start

```bash
cd euro_mall_api
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan db:seed
```

Point the Flutter app at your API with `--dart-define=API_BASE_URL=http://localhost:8000/api/v1` (or your deployed URL).

## Flutter

```bash
cd euro_mall_app
flutter pub get
flutter run
```

More deployment and Git notes: [`docs/STAGING_AND_GIT.md`](docs/STAGING_AND_GIT.md).
