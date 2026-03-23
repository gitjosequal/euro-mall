# Euro Mall — Flutter app

Mobile client for the Euro Mall loyalty program.

- **Repository:** **https://github.com/gitjosequal/euromall_flutter.git**
- **Backend API:** **https://github.com/gitjosequal/euromall_laravel.git**

## Setup

```bash
flutter pub get
flutter run
```

Point at your API (see `lib/core/config/app_environment.dart`):

```bash
flutter run --dart-define=API_BASE_URL=https://your-api-host/api/v1
```

## API contract

See the Laravel product docs: **`docs/API.md`** (maintained next to the API or in your combined workspace).

## Tooling

- App icon: `dart run flutter_launcher_icons`
- Splash: `dart run flutter_native_splash:create`
