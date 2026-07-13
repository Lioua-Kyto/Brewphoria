# BrewPhoria Backend — Getting Started

## Prerequisites

| Tool           | Minimum Version | Notes                                            |
| -------------- | --------------- | ------------------------------------------------ |
| Node.js        | 20 LTS          | Required by Dockerfile and sharp native bindings |
| npm            | 10+             | Comes with Node 20                               |
| Docker Desktop | latest          | Runs Postgres 16 + Redis 7                       |
| Git            | any             | —                                                |

You also need a **Firebase project** (for auth + push notifications) and a **Google Gemini API key** (for the coffee chat feature).

---

## 1 — Clone & Install

```bash
git clone <repo-url>
cd BrewPhoria/backend
npm install
```

---

## 2 — Configure Environment Variables

Copy the example file and fill in your secrets:

```bash
cp .env.example .env   # or edit .env directly, it already exists
```

Open `.env` and set the values marked below:

```dotenv
NODE_ENV=development
PORT=3000

# PostgreSQL (docker-compose default — change only if using a remote DB)
DATABASE_URL=postgresql://brewphoria:brewphoria_secret@localhost:5432/brewphoria
DATABASE_URL_TEST=postgresql://brewphoria:brewphoria_secret@localhost:5432/brewphoria_test

# Redis (docker-compose default)
REDIS_URL=redis://localhost:6379

# ─── Required secrets ─────────────────────────────────────────────────────────

# Firebase — create a project at https://console.firebase.google.com
# In Project Settings → Service Accounts → Generate new private key (JSON)
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\nYOUR_KEY_HERE\n-----END RSA PRIVATE KEY-----"

# Google Gemini — get a key at https://aistudio.google.com/app/apikey
GEMINI_API_KEY=your_gemini_api_key_here

# ─── Optional ─────────────────────────────────────────────────────────────────
UPLOAD_DIR=uploads
BASE_URL=http://localhost:3000
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

> **Tip:** For `FIREBASE_PRIVATE_KEY`, open the downloaded JSON file, copy the `private_key` value (the whole `-----BEGIN...-----END RSA PRIVATE KEY-----` block), and paste it with literal `\n` characters (or wrap it in double quotes).

---

## 3 — Start Infrastructure (Postgres + Redis)

```bash
# Start only the infrastructure services, not the api container
docker compose up -d postgres redis
```

Wait ~5 seconds for Postgres to initialize, then verify:

```bash
docker compose ps
# Both postgres and redis should show "healthy"
```

---

## 4 — Generate the Prisma Client

Every time `prisma/schema.prisma` changes (including the first run), regenerate the client:

```bash
npm run prisma:generate
```

---

## 5 — Run Database Migrations

```bash
npm run prisma:migrate
# Prisma will prompt: "Enter a name for the new migration:" → e.g. init
```

For **production / CI** (applies existing migrations without generating new ones):

```bash
npm run prisma:migrate:deploy
```

---

## 6 — Create the Uploads Directory

The API stores uploaded product images on disk. Create the directory once:

```bash
mkdir -p uploads/products
```

---

## 7 — Start the Development Server

```bash
npm run dev
```

The server starts on `http://localhost:3000`. You should see:

```
✅ Connected to PostgreSQL via Prisma
🚀 BrewPhoria API running on port 3000
```

Verify the health endpoint:

```bash
curl http://localhost:3000/health
# {"success":true,"data":{"status":"ok","timestamp":"..."},"message":"BrewPhoria API is running"}
```

---

## 8 — Run Tests

Tests use a separate database (`DATABASE_URL_TEST`). Make sure it exists:

```bash
# The test DB is created automatically by Prisma if it doesn't exist.
# Or create it manually:
docker exec -it brewphoria_postgres psql -U brewphoria -c "CREATE DATABASE brewphoria_test;"
```

Then run:

```bash
npm test                  # all tests, single run
npm run test:watch        # watch mode
npm run test:coverage     # with coverage report
```

> Tests run with `NODE_ENV=test` — make sure `DATABASE_URL_TEST` is set in `.env`.

---

## 9 — Explore with Prisma Studio

```bash
npm run prisma:studio
# Opens a browser UI at http://localhost:5555
```

---

## 10 — Production: Full Docker Build

To build and run everything (Postgres + Redis + API) in containers:

```bash
docker compose up -d
```

> Make sure `.env` contains valid Firebase / Google Gemini secrets before building — they are injected via `env_file` in `docker-compose.yml`.

---

## Available Scripts

| Script                          | Description                                      |
| ------------------------------- | ------------------------------------------------ |
| `npm run dev`                   | Start dev server with hot-reload (`ts-node-dev`) |
| `npm run build`                 | Compile TypeScript → `dist/`                     |
| `npm start`                     | Run compiled production build                    |
| `npm test`                      | Run all tests once                               |
| `npm run test:watch`            | Run tests in watch mode                          |
| `npm run test:coverage`         | Test coverage report                             |
| `npm run prisma:generate`       | Regenerate Prisma client from schema             |
| `npm run prisma:migrate`        | Create + apply a new migration                   |
| `npm run prisma:migrate:deploy` | Apply pending migrations (prod / CI)             |
| `npm run prisma:studio`         | Open Prisma Studio GUI                           |
| `npm run lint`                  | Run ESLint on `src/`                             |

---

## API Base URL

All routes are prefixed with `/api/v1`.

| Resource      | Base route                                               |
| ------------- | -------------------------------------------------------- |
| Auth          | `POST /api/v1/auth/register` · `POST /api/v1/auth/login` |
| Products      | `GET /api/v1/products`                                   |
| Categories    | `GET /api/v1/categories`                                 |
| Cart          | `GET /api/v1/cart`                                       |
| Orders        | `POST /api/v1/orders/checkout`                           |
| Reviews       | `GET /api/v1/reviews`                                    |
| Loyalty       | `GET /api/v1/loyalty`                                    |
| Notifications | `GET /api/v1/notifications`                              |
| Chat          | `POST /api/v1/chat`                                      |
| Admin         | `GET /api/v1/admin/dashboard`                            |
| Health        | `GET /health`                                            |

Send Firebase ID tokens as: `Authorization: Bearer <firebase_id_token>`

---

## Troubleshooting

### `PrismaClientConstructorValidationError: Using engine type "client" requires adapter or accelerateUrl`

The Prisma client needs to be regenerated after the schema was updated to use `engineType = "library"`. Run:

```bash
npm run prisma:generate
```

### `Error: The datasource.url property is required`

The `DATABASE_URL` environment variable is not set or `.env` is not being loaded. Confirm `.env` exists at `backend/.env` and `DATABASE_URL` is filled in.

### Port 5432 already in use

Another Postgres instance is running locally. Stop it or change the port mapping in `docker-compose.yml`:

```yaml
ports:
  - "5433:5432" # expose on 5433 instead
```

Then update `DATABASE_URL` in `.env` to use port `5433`.

### Sharp fails to install / load

Sharp requires native bindings matching your Node.js version. Run:

```bash
npm rebuild sharp
```

Or ensure your node version matches the Docker `node:20-alpine` image.
