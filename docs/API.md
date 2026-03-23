# Euro Mall API (mobile)

Base URL: `{origin}/api/v1` (matches `AppEnvironment.apiBaseUrl` in the Flutter app).  
The Flutter `ApiClient` adds a trailing slash and strips leading slashes on paths so Dio resolves URLs correctly (e.g. `…/api/v1/app/config`).

All JSON responses use UTF-8. Pass `locale=en` or `locale=ar` on endpoints that return localized strings.

## Public

### `GET /app/config`

App-wide metadata (editable in admin / DB).

```json
{
  "data": {
    "support_phone": "+962 6 000 0000",
    "social_links": [
      { "label": "Instagram", "url": "https://instagram.com/...", "icon": "instagram" }
    ],
    "developer_name": "Josequal",
    "developer_url": "https://www.josequal.com",
    "display_version": "1.0.0"
  }
}
```

- `display_version` is optional; if empty, the app shows `package_info` version only.
- **Do not** hardcode developer branding in the app; serve it from this endpoint.

### `GET /cms/pages/{slug}`

Query: `locale`.

Slugs used by the app: `terms`, `privacy`, `about`.

```json
{
  "data": {
    "slug": "terms",
    "title": "Terms & conditions",
    "body": "# Markdown\n\nYour CMS content…"
  }
}
```

### `GET /faqs`

Query: `locale`.

```json
{
  "data": [
    { "id": "1", "question": "…", "answer": "…" }
  ]
}
```

### `GET /points/schema`

Query: `locale`.

```json
{
  "data": {
    "body": "# Points program\n\n…"
  }
}
```

### `POST /contact`

```json
{
  "name": "Jane",
  "email": "jane@example.com",
  "phone": "+962…",
  "message": "Hello"
}
```

Response: `200` with optional JSON body.

## Authenticated (`Authorization: Bearer {token}`)

Use **Laravel Sanctum** personal access tokens (or your auth provider). The app stores the token in `SharedPreferences` key `euromall_auth_token` (via `AuthTokenStore`).

### `GET /me`

```json
{
  "data": {
    "name": "…",
    "phone": "…",
    "email": "…",
    "gender": "male|female|other",
    "dob": "1995-04-12",
    "tier_name": "Silver"
  }
}
```

### `PUT /me`

Body: `name`, `email`, `gender`, optional `dob` (`Y-m-d`).

### `GET /me/notification-preferences`

### `PUT /me/notification-preferences`

```json
{
  "push_marketing": true,
  "push_orders": true,
  "email_digest": false
}
```

### `GET /orders`

```json
{
  "data": [
    {
      "id": "1",
      "title": "Store purchase",
      "date": "2026-02-09T12:00:00Z",
      "amount": 42.5,
      "points": 43,
      "earned": true
    }
  ]
}
```

## Auth (implement on backend)

After OTP / login verification, return a Sanctum token and persist it in the app:

```dart
await context.read<AuthTokenStore>().setToken(plainTextToken);
```

Until this is wired, protected screens show “Sign in” or 401 handling.

## Admin / CMS

Manage content via your admin panel (Filament, Nova, or direct DB):

- `app_settings` — config row
- `cms_pages` — legal & about copy (Markdown)
- `faqs` — questions/answers per locale columns
- `contact_messages` — inbox from the app form
- `customer_orders` — per-user order history for the loyalty app
- `notification_preferences` — per user

The runnable Laravel API lives in **`euro_mall_api/`** in this repo (migrations, controllers, seeders).
