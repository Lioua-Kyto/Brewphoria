<div align="center">

# ☕ BrewPhoria

**A production-grade coffee-ordering platform — Flutter mobile client + TypeScript/Express REST API.**

Guest & authenticated ordering · drink customization · loyalty programme · live order ETA ·
post-purchase reviews · a tool-augmented AI barista · and an admin surface.

![Flutter](https://img.shields.io/badge/Flutter-3.38-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3-0175C2?logo=dart&logoColor=white)
![Node](https://img.shields.io/badge/Node-20-339933?logo=nodedotjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?logo=typescript&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Prisma-4169E1?logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-cache-DC382D?logo=redis&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)

</div>

---

## Overview

BrewPhoria is a full-stack e-commerce application built around a strict separation of
concerns: a **feature-first Flutter client** optimised for perceived performance, and a
**layered Express API** that is the single source of financial truth. Every price, discount,
loyalty delta, and stock decrement is (re)computed server-side inside a transaction — the
client never dictates a total.

> **New here?** Start with **[ARCHITECTURE.md](ARCHITECTURE.md)** — system diagrams, data
> flows, and the engineering case studies behind the non-obvious decisions.

## Highlights

- **Offline-first cart with conflict-free merge** — guests build a local cart that is
  reconciled into their account on sign-in, surviving provider disposal and cold starts.
- **Atomic checkout** — order creation, stock decrement, cart clear, and loyalty movement
  run in one Prisma transaction; best-effort push notifications run *after* commit.
- **Server-authoritative pricing & modifiers** — drink customization (size/milk/sweetness/
  add-ons) is priced on the server; cart lines key on their own id so the same product with
  different options is a distinct line.
- **Loyalty programme** — tiered earn multipliers, `100 pts = $1` redemption unified between
  cart preview and checkout, append-only ledger.
- **Exact review summary read model** — O(1) denormalised ratings for lists, a dedicated
  aggregate endpoint for the precise 1–5★ histogram.
- **Tool-augmented AI barista** — Gemini references real catalogue items via resolved
  `[[product:<slug>]]` tags, rendered as inline product cards.
- **Redis caching** with per-query keys and pattern invalidation on writes.
- **Design system as native widgets** — signature cup-fill, floating product cutouts, glass
  surfaces, Hero-arc product entrance, and a kinetic splash — all reduced-motion aware and
  on a strict frame budget.

## Tech stack

| | Mobile | Backend |
| --- | --- | --- |
| Language | Dart 3 (Flutter 3.38) | TypeScript 5 (Node 20) |
| Structure | Feature-first + Riverpod (code-gen) | routes → controllers → services → repositories |
| Data | Freezed models, Hive cache | Prisma 7 + PostgreSQL |
| Networking | Dio (+ interceptors, error mapper) | Express 4, Zod validation |
| Auth | Firebase Auth SDK | Firebase Admin (ID-token verify) |
| Realtime | FCM | FCM, `node-cron` |
| AI | — | Google Gemini `2.5-flash` |
| Cache/Media | image decode-sizing | Redis · Multer + Sharp → WebP |
| Delivery | — | Docker Compose · Nginx · Cloudflare |

## Repository layout

```
BrewPhoria/
├── mobile/            Flutter client (feature-first: shop, cart, checkout, orders,
│                      loyalty, profile, auth, reviews, chatbot, wishlist, onboarding)
├── backend/           Express + Prisma API (layered) + seed + tests
├── ARCHITECTURE.md    System design, diagrams, data flows, case studies
└── API.md             Full REST endpoint reference
```

## Quick start

### Backend

```bash
cd backend
cp .env.example .env          # fill DATABASE_URL, REDIS_URL, Firebase, GEMINI_API_KEY…
npm install
npm run prisma:migrate        # apply migrations
npm run seed                  # categories, products, modifiers, demo users/orders
npm run dev                   # http://localhost:3000/api/v1  (health: /health)
```

Or the whole stack (API + Postgres + Redis):

```bash
cd backend && docker compose up --build
```

### Mobile

```bash
cd mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # codegen (Freezed/Riverpod)
flutter run
```

Configure the API base URL and Firebase (`flutterfire configure`) per your environment.

## Documentation

| Doc | What's inside |
| --- | --- |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Context & container diagrams, ERD, sequence diagrams for every core flow, and engineering case studies |
| [API.md](API.md) | Every endpoint with request/response envelopes, auth level, and error codes |

## Testing

```bash
cd backend && npm test          # Jest + Supertest (services mocked; routes end-to-end)
cd mobile  && flutter analyze    # zero-warning gate
```

## License & author

Built by **Lioua Zeddam** — [github.com/Lioua-Kyto](https://github.com/Lioua-Kyto) ·
[deviumx.com](https://deviumx.com). Available for portfolio review.
