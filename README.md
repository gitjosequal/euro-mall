# Euro Mall

Monorepo for the **Euro Mall loyalty** product.

| Path | Description |
|------|-------------|
| [`euro_mall_app/`](euro_mall_app/) | Flutter mobile app |
| [`euro_mall_api/`](euro_mall_api/) | Laravel 13 REST API (`/api/v1`) |
| [`docs/API.md`](docs/API.md) | Mobile ↔ API contract |

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
