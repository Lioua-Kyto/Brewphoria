# BrewPhoria Backend — Architecture

## Overview

BrewPhoria is a **Node.js + TypeScript REST API** for a coffee e-commerce platform. It follows a clean, layered architecture where each layer has a single responsibility and dependencies flow in one direction only.

```
HTTP Request
    │
    ▼
┌─────────────────────────────────────────────────────┐
│  Middleware Layer                                   │
│  helmet · cors · morgan · rate-limiter · auth       │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│  Routing Layer  (src/routes/)                       │
│  /api/v1/{auth|products|orders|cart|...}            │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│  Controller Layer  (src/controllers/)               │
│  Input validation (Zod) · auth guards · response    │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│  Service Layer  (src/services/)                     │
│  Business logic · orchestration · error throwing    │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│  Repository Layer  (src/repositories/)              │
│  All Prisma queries · pure data access              │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│  Database  (PostgreSQL via Prisma ORM)              │
│  Prisma 7 · library engine · schema.prisma          │
└─────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
src/
├── app.ts                  # Express app setup (middleware, routes, static files)
├── index.ts                # Entry point (createServer, bootstrap)
├── server.ts               # HTTP server creation
├── cron.ts                 # Scheduled jobs (expiry checks, etc.)
│
├── config/
│   ├── database.ts         # PrismaClient singleton
│   ├── env.ts              # Zod-validated environment variables
│   ├── firebase.ts         # Firebase Admin SDK (auth + FCM)
│   ├── logger.ts           # Winston logger
│   ├── gemini.ts           # Google Gemini client
│   └── redis.ts            # ioredis client
│
├── controllers/            # HTTP layer: parse req, call service, send res
├── services/               # Business logic and orchestration
├── repositories/           # Database queries (Prisma only)
├── routes/                 # Express routers, auth guards, role guards
├── middleware/             # auth, roleGuard, asyncHandler, rateLimiter, upload
└── utils/                  # errors.ts, pagination.ts, response.ts, utils.ts
```

---

## Domain Modules

| Domain        | Controller               | Service               | Repository               | Routes                  |
| ------------- | ------------------------ | --------------------- | ------------------------ | ----------------------- |
| Auth          | `AuthController`         | `AuthService`         | `UserRepository`         | `/api/v1/auth`          |
| Users         | `UserController`         | `UserService`         | `UserRepository`         | `/api/v1/users`         |
| Products      | `ProductController`      | `ProductService`      | `ProductRepository`      | `/api/v1/products`      |
| Categories    | `CategoryController`     | `CategoryService`     | `CategoryRepository`     | `/api/v1/categories`    |
| Cart          | `CartController`         | `CartService`         | `CartRepository`         | `/api/v1/cart`          |
| Orders        | `OrderController`        | `OrderService`        | `OrderRepository`        | `/api/v1/orders`        |
| Reviews       | `ReviewController`       | `ReviewService`       | `ReviewRepository`       | `/api/v1/reviews`       |
| Loyalty       | `LoyaltyController`      | `LoyaltyService`      | `LoyaltyRepository`      | `/api/v1/loyalty`       |
| Notifications | `NotificationController` | `NotificationService` | `NotificationRepository` | `/api/v1/notifications` |
| Chat          | `ChatController`         | `ChatService`         | `ChatRepository`         | `/api/v1/chat`          |
| Admin         | `AdminController`        | `AdminService`        | —                        | `/api/v1/admin`         |

---

## Key Technical Decisions

### Authentication

- **Firebase Authentication** — clients send a Firebase ID token in `Authorization: Bearer <token>`.
- The `authenticate` middleware verifies the token via Firebase Admin SDK and attaches the user to `req.user`.
- Role-based access is enforced by the `roleGuard("ADMIN")` middleware.

### Database

- **PostgreSQL** with **Prisma ORM** (v7, `engineType = "library"`).
- All queries are in the repository layer — services never directly import `prisma`.
- The singleton pattern in `database.ts` prevents multiple connections during hot-reload in development.

### Order Checkout Flow

All of the following happen atomically inside a **single `prisma.$transaction()`**:

1. Create the Order record (`status: CONFIRMED`) with embedded `OrderItem` rows.
2. Decrement stock for every product in the order.
3. Delete all `CartItem` rows for the user's cart.
4. Update the `LoyaltyAccount` (award earned points, deduct redeemed points, recalculate tier).
5. Create `LoyaltyTransaction` records for audit trail.
6. Optionally create an in-app `Notification` if the user's loyalty tier changed.

After the transaction, a best-effort Firebase Cloud Messaging (FCM) push notification is sent.

### Image Uploads

- Incoming images go through **multer** (memory storage) → **Sharp** resizing.
- Sharp constraints: max 1200×1200 px (`fit: "inside"`, no upscaling), WebP format, quality 80.
- Files are persisted to `uploads/products/` on disk.
- Served statically via Express at `/uploads`.

### Caching / Rate Limiting

- **ioredis** is available for caching (ready to integrate).
- `express-rate-limit` is applied globally; stricter limiters on auth routes.

### AI Chat

- **Google Gemini** via the `@google/genai` package powers the coffee recommendation chat.
- Conversation sessions are stored in `ChatSession` / `ChatMessage` models.

### Background Jobs

- `node-cron` handles scheduled tasks (e.g., expiring loyalty points).

---

## Environment Variables

| Variable                | Purpose                                                |
| ----------------------- | ------------------------------------------------------ |
| `DATABASE_URL`          | PostgreSQL connection string                           |
| `DATABASE_URL_TEST`     | Test database (optional, falls back to `DATABASE_URL`) |
| `FIREBASE_PROJECT_ID`   | Firebase project                                       |
| `FIREBASE_PRIVATE_KEY`  | Firebase service account key                           |
| `FIREBASE_CLIENT_EMAIL` | Firebase service account email                         |
| `GEMINI_API_KEY`        | Google Gemini API key                                  |
| `REDIS_URL`             | Redis connection string                                |
| `JWT_SECRET`            | Internal JWT signing secret                            |
| `ALLOWED_ORIGINS`       | CORS origins (comma-separated)                         |
| `UPLOAD_DIR`            | Directory for uploaded images (default: `uploads`)     |
| `BASE_URL`              | Public base URL (default: `http://localhost:3000`)     |
| `PORT`                  | HTTP port (default: `3000`)                            |
| `NODE_ENV`              | `development` / `production` / `test`                  |

---

## Infrastructure (docker-compose)

```
brewphoria_backend (docker-compose)
├── postgres  — PostgreSQL 16 on port 5432
└── redis     — Redis 7 on port 6379
```

The application server itself is **not** run inside docker-compose in development — only the infrastructure services are. The Node.js app runs directly on the host via `npm run dev`.
