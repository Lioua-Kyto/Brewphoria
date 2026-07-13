# BrewPhoria — Required API Keys Guide

A quick-reference for every secret in `.env`. For each key: what it is, where to get it, and what to paste.

---

## 1. Firebase Admin SDK Keys

> Used for: user authentication (JWT verification), push notifications (FCM)

**How to get them:**

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create a project (or open existing) → click the ⚙️ gear → **Project Settings**
3. Click the **Service accounts** tab
4. Click **Generate new private key** → download the JSON file

**What to put in `.env`:**

```
FIREBASE_PROJECT_ID=          ← "project_id" field from the JSON
FIREBASE_CLIENT_EMAIL=        ← "client_email" field from the JSON
FIREBASE_PRIVATE_KEY=         ← "private_key" field from the JSON (see note below)
```

> **IMPORTANT — private key format:**
>
> - Open the downloaded JSON file in a text editor
> - Copy the entire value of `"private_key"` — it starts with `-----BEGIN PRIVATE KEY-----\n` and ends with `\n-----END PRIVATE KEY-----\n`
> - The `\n` are literal backslash-n characters in the JSON — keep them as-is
> - Paste the whole thing on ONE line in `.env`, wrapped in double quotes:
>
>   ```
>   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----\n"
>   ```

---

## 2. FCM (Push Notifications)

> Used for: sending push notifications to mobile devices

**No extra key needed.** The Firebase Admin SDK (`firebase-admin`) sends push notifications via the FCM v1 API automatically using your `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, and `FIREBASE_PRIVATE_KEY` service account credentials. Google has removed the legacy FCM Server Key — the v1 API is the current standard and it is handled entirely by the SDK.

You do **not** need a `FCM_SERVER_KEY`. Just make sure the three `FIREBASE_*` variables are set correctly.

---

## 3. Google Gemini API Key

> Used for: AI chat assistant feature

**How to get it:**

1. Go to [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click **Create API key** → copy it immediately

```
GEMINI_API_KEY=your_gemini_api_key_here
```

> **Billing:** Google Gemini offers a free tier for developers. Check the pricing page for more details.

---

## 4. Database URL

> Used for: PostgreSQL connection. No external sign-up needed.

If using the included Docker compose setup, this is already configured:

```
DATABASE_URL=postgresql://brewphoria:brewphoria_secret@localhost:5432/brewphoria
DATABASE_URL_TEST=postgresql://brewphoria:brewphoria_secret@localhost:5432/brewphoria_test
```

Change the password `brewphoria_secret` to something stronger for any non-local environment. The `docker-compose.yml` `POSTGRES_PASSWORD` must match.

---

## 5. Redis URL

> Used for: caching, rate limiting, session store. No external sign-up needed.

Already configured for the Docker compose setup:

```
REDIS_URL=redis://localhost:6379
```

---

## 6. Other App Variables

| Variable          | Value                                 | Notes                                                   |
| ----------------- | ------------------------------------- | ------------------------------------------------------- |
| `NODE_ENV`        | `development` / `production` / `test` | Controls logging level and DB selection                 |
| `PORT`            | `3000`                                | Port the API listens on                                 |
| `BASE_URL`        | `http://localhost:3000`               | Used to build image URLs in API responses               |
| `ALLOWED_ORIGINS` | `http://localhost:3000`               | CORS — comma-separated list of allowed frontend origins |
| `UPLOAD_DIR`      | `uploads`                             | Relative path for stored product images                 |

---

## Quick-start checklist

- [x] Firebase project created
- [x] Firebase service account JSON downloaded
- [x] `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY` copied from JSON
- [x] Google Gemini API key copied
- [ ] `.env` file created (copy `.env.example` as a starting point)
- [ ] All values pasted in — no placeholder text remaining

---

## Common Mistakes

**Firebase private key is invalid:**

- Make sure the key is on **one line** in `.env` with no real line breaks
- Make sure it's wrapped in `"double quotes"`
- The `\n` inside must be literal backslash + n, not actual newlines

**Docker env_file parse error (`unexpected character in variable name`):**

- Your `.env` file has Windows-style line endings (CRLF `\r\n`)
- Fix in VS Code: click `CRLF` in the bottom-right status bar → change to `LF` → save
- This must be done **before** running `docker-compose up`

**P1000 Prisma auth error:**

- `DATABASE_URL` password doesn't match `POSTGRES_PASSWORD` in `docker-compose.yml`
- Both must be identical (default: `brewphoria_secret`)
