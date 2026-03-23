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

### `POST /auth/otp/send`

Body: `{ "phone": "+962790000000" }` (normalized server-side).

- Stores a short-lived OTP in **cache** (TTL `AUTH_OTP_TTL`, default 600s).
- **`AUTH_OTP_USE_FIXED=true`** (default in `.env.example`): code is always **`AUTH_OTP_CODE`** (e.g. `1111`).
- **`AUTH_OTP_USE_FIXED=false`**: random 4-digit; wire your SMS provider here and **do not** log codes in prod.
- Response includes `expires_in` (seconds). Codes are logged in `storage/logs` for local dev only — redact in production.

### `POST /auth/otp/verify`

Body: `{ "phone": "+962790000000", "code": "1111" }`.

- Must match the **cached** code from `send` (one successful verify consumes the cache entry).
- If **`AUTH_OTP_FALLBACK_FIXED=true`** (dev), **`AUTH_OTP_CODE`** is also accepted without calling `send` (disable in production).
- Creates or finds user by normalized phone; returns Sanctum token:

```json
{
  "data": {
    "token": "1|…",
    "token_type": "Bearer",
    "user": { "id": 1, "phone": "+962790000000", "name": null }
  }
}
```

### `GET /home/dashboard`

Optional `Authorization: Bearer`. Query: `locale`.

- **Guest**: welcome copy, `active_vouchers_count` from catalog.
- **Member**: personalized greeting, loyalty snapshot, `recent_transactions` from `customer_orders`.

### `GET /vouchers` · `GET /vouchers/{id}`

Query: `locale`. Public catalog; shapes match Flutter `Voucher.fromApiJson`.

Optional header: `Authorization: Bearer {token}`. When present, each item includes:

- `redeemed_at`: ISO8601 timestamp if this member already redeemed that catalog voucher, else `null`.

### `POST /vouchers/{id}/redeem` (authenticated)

Requires `Authorization: Bearer`.

- **422** if voucher expired.
- **409** if this user already redeemed this voucher (one row per user + voucher).
- **200**:

```json
{ "data": { "redeemed_at": "2026-02-11T12:00:00+00:00", "message": "ok" } }
```

### `GET /offers` · `GET /branches`

Query: `locale`. Public lists for offers and mall branches.

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

After OTP verification, the app persists the token:

```dart
await context.read<AuthTokenStore>().setToken(plainTextToken);
```

**Production:** set `AUTH_OTP_USE_FIXED=false`, `AUTH_OTP_FALLBACK_FIXED=false`, send real SMS from `otp/send`, and stop logging OTP values.

## Admin / CMS

Manage content via your admin panel (Filament, Nova, or direct DB):

- `app_settings` — config row
- `cms_pages` — legal & about copy (Markdown)
- `faqs` — questions/answers per locale columns
- `contact_messages` — inbox from the app form
- `customer_orders` — per-user order history for the loyalty app
- `loyalty_vouchers`, `loyalty_offers`, `mall_branches` — catalog for the app
- `loyalty_voucher_redemptions` — one row per member + catalog voucher redeemed
- `notification_preferences` — per user

**Source repositories**

- Laravel API: **https://github.com/gitjosequal/euromall_laravel.git**
- Flutter app: **https://github.com/gitjosequal/euromall_flutter.git**

The runnable Laravel API is the **euromall_laravel** project (migrations, controllers, seeders). Copy **`.env.example`** and set **`AUTH_OTP_CODE=1111`** (or your dev code).
