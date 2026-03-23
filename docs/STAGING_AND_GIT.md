# Staging API & Git / backend push

## Language (first launch)

- On first install, the app uses the **device language**: Arabic → UI in Arabic, any other system language → English.
- The user can switch **English / Arabic** under **Profile → Preferences**; the choice is saved locally (`shared_preferences`).
- There is **no** separate “choose language” screen in the onboarding flow.

## Flutter app → staging URL

The app reads the API base URL from a **compile-time** define (no secrets in repo):

- **File:** `euro_mall_app/lib/core/config/app_environment.dart`
- **Default staging:** `https://euromall.josequal.net/api/v1`

### Set staging when building / running

```bash
cd euro_mall_app
flutter run --dart-define=API_BASE_URL=https://euromall.josequal.net/api/v1
```

Release / CI:

```bash
flutter build apk --dart-define=API_BASE_URL=https://euromall.josequal.net/api/v1
flutter build ios --dart-define=API_BASE_URL=https://euromall.josequal.net/api/v1
```

In **debug**, the base URL is printed once on startup: `[Euro Mall] API base: ...`

### VS Code

Add to `.vscode/launch.json` under your configuration:

```json
"toolArgs": [
  "--dart-define=API_BASE_URL=https://euromall.josequal.net/api/v1"
]
```

---

## Why we did not push backend from here

1. **No Git repository** is initialized under `/Users/naserodeh/Desktop/euro_mall` (neither root nor `euro_mall_app`).  
   `git push` requires `git init`, a **remote** (`origin`), and credentials.

2. **No Laravel (or other) backend** exists in this workspace—only the Flutter app (`euro_mall_app/`).

To push the **mobile** project:

```bash
cd euro_mall_app
git init
git add .
git commit -m "Euro Mall loyalty app"
git remote add origin <YOUR_GIT_URL>
git branch -M main
git push -u origin main
```

For the **backend**, open your Laravel (or API) repo separately, commit there, and deploy to staging as you usually do (e.g. pull on server, `composer install`, migrate, env).

---

## Optional: API contract for backend team

Align staging responses with the screens in the app (auth, `/me`, wallet, vouchers, offers, branches).  
If you want a single OpenAPI file in-repo later, we can add `docs/openapi.yaml` in a follow-up.
