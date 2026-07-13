# BrewPhoria API Documentation

> **Base URL**: `http://localhost:3000/api/v1`  
> **Docker Base URL**: `http://localhost:3000/api/v1`  
> **Content-Type**: `application/json` for all requests (except file uploads which use `multipart/form-data`)
>
> See also: [`ARCHITECTURE.md`](ARCHITECTURE.md) (system design, diagrams, case studies).
> 🔓 = public · 🔐 = auth required · 👑 = admin only.

---

## Authentication

All protected endpoints require a **Firebase ID token** in the `Authorization` header:

```
Authorization: Bearer <firebase_id_token>
```

Firebase ID tokens expire after **1 hour**. Obtain a fresh token by calling `currentUser.getIdToken()` on the Flutter Firebase Auth SDK.

**Legend used in this document**:

- 🔓 Public — no token required
- 🔐 Auth required — any authenticated user
- 👑 Admin only — `role === "ADMIN"`

---

## Standard Response Envelope

Every response (success or error) follows this shape:

```json
// Success
{
  "success": true,
  "data": { ... },
  "message": "Human readable message",
  "meta": { "page": 1, "limit": 20, "total": 60, "totalPages": 3 }
}

// Error
{
  "success": false,
  "error": {
    "code": "MACHINE_READABLE_CODE",
    "message": "Human readable message",
    "fields": { "email": ["Invalid email"] }
  }
}
```

`meta` is only present on paginated list endpoints.  
`fields` is only present on `VALIDATION_ERROR` responses.

---

## Pagination

All list endpoints accept optional query parameters:

| Param   | Default | Max   | Description           |
| ------- | ------- | ----- | --------------------- |
| `page`  | `1`     | —     | Page number (1-based) |
| `limit` | `20`    | `100` | Items per page        |

---

## Error Codes

| Code                   | HTTP Status | Meaning                                      |
| ---------------------- | ----------- | -------------------------------------------- |
| `UNAUTHORIZED`         | 401         | Missing / invalid / expired token            |
| `FORBIDDEN`            | 403         | Insufficient role                            |
| `VALIDATION_ERROR`     | 400         | Invalid request body or query                |
| `BAD_REQUEST`          | 400         | General bad request                          |
| `<RESOURCE>_NOT_FOUND` | 404         | e.g., `PRODUCT_NOT_FOUND`, `ORDER_NOT_FOUND` |
| `CONFLICT`             | 409         | Duplicate resource                           |
| `RATE_LIMIT_EXCEEDED`  | 429         | Too many requests                            |
| `INTERNAL_ERROR`       | 500         | Unexpected server error                      |

---

## Health Check

### `GET /health` 🔓

Returns API status.

**Response `200`**

```json
{
  "success": true,
  "data": { "status": "ok", "timestamp": "2026-02-24T12:00:00.000Z" },
  "message": "BrewPhoria API is running"
}
```

---

## Auth

### `POST /auth/login` 🔓

Authenticates a Firebase user. Creates a `User` row in Postgres on first login (upsert). Must be called before any other endpoint.

**Rate limit**: 10 requests / 15 min per IP.

**Request body**

```json
{
  "idToken": "eyJhbGciOi..."
}
```

**Response `200`**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "cuid",
      "firebaseUid": "abc123",
      "email": "user@example.com",
      "displayName": "Alice",
      "avatarUrl": null,
      "role": "USER",
      "createdAt": "2026-01-01T00:00:00.000Z"
    },
    "loyaltySummary": {
      "currentPoints": 340,
      "lifetimePoints": 600,
      "tier": "SILVER"
    }
  },
  "message": "Login successful"
}
```

---

### `POST /auth/logout` 🔐

Clears the user's FCM token (stops push notifications).

**Request body**: none

**Response `200`**

```json
{ "success": true, "data": null, "message": "Logged out successfully" }
```

---

### `PATCH /auth/fcm-token` 🔐

Registers or updates the device's Firebase Cloud Messaging token for push notifications. Call this after login and whenever the FCM token refreshes.

**Request body**

```json
{ "fcmToken": "fGm_token_string..." }
```

**Response `200`**

```json
{ "success": true, "data": null, "message": "FCM token updated" }
```

---

## Users

All `/users` routes require authentication.

### `GET /users/me` 🔐

Returns the current user's full profile.

**Response `200`**

```json
{
  "success": true,
  "data": {
    "id": "cuid",
    "email": "alice@example.com",
    "displayName": "Alice Johnson",
    "avatarUrl": null,
    "role": "USER",
    "createdAt": "2026-01-01T00:00:00.000Z"
  },
  "message": "Profile retrieved"
}
```

---

### `PATCH /users/me` 🔐

Updates display name and/or avatar URL. When `displayName` changes, the server re-derives
`firstName`/`lastName` (used for greetings) from it.

**Request body** (all fields optional)

```json
{
  "displayName": "Alice J.",
  "avatarUrl": "https://example.com/avatar.jpg"
}
```

**Response `200`** — updated user object (includes `firstName`, `lastName`).

---

### `GET /users/me/addresses` 🔐

Returns all saved delivery addresses for the current user.

**Response `200`**

```json
{
  "success": true,
  "data": [
    {
      "id": "cuid",
      "label": "Home",
      "fullName": "Alice Johnson",
      "phone": "555-1234",
      "street": "123 Maple St",
      "city": "Portland",
      "state": "OR",
      "postalCode": "97201",
      "country": "US",
      "isDefault": true
    }
  ],
  "message": "Addresses retrieved"
}
```

---

### `POST /users/me/addresses` 🔐

Adds a new delivery address.

**Request body**

```json
{
  "label": "Work",
  "fullName": "Alice Johnson",
  "phone": "555-5678",
  "street": "1 Business Ave Suite 200",
  "city": "Seattle",
  "state": "WA",
  "postalCode": "98101",
  "country": "US",
  "isDefault": false
}
```

**Response `201`** — new address object.

---

### `PATCH /users/me/addresses/:id` 🔐

Updates an existing address (all fields optional).

**Response `200`** — updated address object.

---

### `DELETE /users/me/addresses/:id` 🔐

Deletes an address.

**Response `200`**

```json
{ "success": true, "data": null, "message": "Address deleted" }
```

---

### `GET /users/me/wishlist` 🔐

Returns the current user's saved products (favourites), newest first.

**Response `200`** — array of product objects.

---

### `POST /users/me/wishlist` 🔐

Adds a product to the wishlist (idempotent — unique on `(userId, productId)`).

**Request body**

```json
{ "productId": "cuid" }
```

**Response `201`** — the created wishlist entry.

---

### `DELETE /users/me/wishlist/:productId` 🔐

Removes a product from the wishlist.

**Response `200`**

```json
{ "success": true, "data": null, "message": "Removed from wishlist" }
```

---

## Categories

### `GET /categories` 🔓

Returns all active categories.

**Response `200`**

```json
{
  "success": true,
  "data": [
    {
      "id": "cuid",
      "name": "Espresso & Hot Drinks",
      "slug": "espresso-hot-drinks",
      "imageUrl": "https://images.unsplash.com/...",
      "isActive": true
    }
  ],
  "message": "Categories retrieved"
}
```

---

## Products

### `GET /products` 🔓

Returns paginated product list (active only).

**Query parameters**

| Param        | Type                 | Description                          |
| ------------ | -------------------- | ------------------------------------ |
| `page`       | number               | Page number                          |
| `limit`      | number               | Items per page                       |
| `category`   | string               | Filter by category ID                |
| `minPrice`   | number               | Minimum price filter                 |
| `maxPrice`   | number               | Maximum price filter                 |
| `isFeatured` | `"true"` / `"false"` | Filter featured products             |
| `search`     | string               | Full-text search on name/description |
| `sort`       | `newest` \| `price_asc` \| `price_desc` \| `rating` | Ordering (default `newest`) |

**Response `200`**

```json
{
  "success": true,
  "data": [
    {
      "id": "cuid",
      "name": "Classic Espresso",
      "slug": "classic-espresso",
      "description": "A concentrated shot...",
      "price": "3.50",
      "images": ["https://..."],
      "stock": 100,
      "isFeatured": true,
      "avgRating": "4.50",
      "reviewCount": 12,
      "category": {
        "id": "cuid",
        "name": "Espresso & Hot Drinks",
        "slug": "espresso-hot-drinks"
      }
    }
  ],
  "message": "Products retrieved",
  "meta": { "page": 1, "limit": 20, "total": 60, "totalPages": 3 }
}
```

---

### `GET /products/:slug` 🔓

Returns a single product by slug, including its `type` (`DRINK` | `BEANS` | `MERCH`),
customization option groups, and optional detail metadata (`roastLevel`, `calories`,
`caffeineMg`, `prepMinutes`, `tastingNotes`).

**`modifierGroups` is gated by the product's `type`, not just its category** — a `MERCH`
product always gets `[]`, even if other products in the same category have groups (see
[ARCHITECTURE.md §9.6](ARCHITECTURE.md#96-category-isnt-the-same-axis-as-customizability)).
`DRINK` gets Size/Milk/Sweetness/Add-ons; `BEANS` gets a Grind group; `MERCH` gets none.
Detail metadata follows suit: `roastLevel`/`tastingNotes` show for `DRINK` and `BEANS`,
`calories`/`caffeineMg`/`prepMinutes` are `DRINK`-only, and `MERCH` gets neither.

**Response `200`** (extra fields over the list item)

```json
{
  "success": true,
  "data": {
    "id": "cuid",
    "name": "Caramel Macchiato",
    "slug": "caramel-macchiato",
    "price": "5.40",
    "type": "DRINK",
    "roastLevel": "Medium",
    "tastingNotes": ["caramel", "vanilla"],
    "modifierGroups": [
      {
        "id": "cuid",
        "name": "Size",
        "selectionType": "SINGLE",
        "isRequired": true,
        "sortOrder": 0,
        "options": [
          { "id": "cuid", "label": "Small", "priceDelta": 0, "isDefault": true },
          { "id": "cuid", "label": "Large", "priceDelta": 0.8, "isDefault": false }
        ]
      }
    ]
  },
  "message": "Product retrieved"
}
```

> `priceDelta` is exposed as a **number** in this DTO (Prisma `Decimal` otherwise serialises
> to a string — see [ARCHITECTURE.md §9.2](ARCHITECTURE.md#92-money-integrity-across-the-wire)).

**Error `404`** — `PRODUCT_NOT_FOUND`

---

### `GET /products/:id/reviews` 🔓

Returns paginated visible reviews for a product.

**Query parameters**: `page`, `limit`

**Response `200`**

```json
{
  "success": true,
  "data": [
    {
      "id": "cuid",
      "rating": 5,
      "comment": "Absolutely love this!",
      "images": [],
      "createdAt": "2026-01-15T10:00:00.000Z",
      "user": { "displayName": "Alice Johnson", "avatarUrl": null }
    }
  ],
  "message": "Reviews retrieved",
  "meta": { ... }
}
```

---

### `GET /products/:id/reviews/summary` 🔓

Exact rating aggregates across **all** visible reviews (not just the loaded page) — a read
model for the reviews summary card.

**Response `200`**

```json
{
  "success": true,
  "data": {
    "average": 4.6,
    "count": 128,
    "distribution": { "1": 2, "2": 4, "3": 8, "4": 22, "5": 92 }
  },
  "message": "Review summary retrieved"
}
```

---

## Cart

All `/cart` routes require authentication.

### `GET /cart` 🔐

Returns the current user's cart with all items.

**Response `200`**

```json
{
  "success": true,
  "data": {
    "id": "cuid",
    "items": [
      {
        "id": "cuid",
        "quantity": 2,
        "unitPrice": "6.20",
        "modifiers": [
          { "groupId": "cuid", "groupName": "Size", "optionId": "cuid", "label": "Large", "priceDelta": 0.8 }
        ],
        "product": {
          "id": "cuid",
          "name": "Caramel Macchiato",
          "slug": "caramel-macchiato",
          "price": "5.40",
          "images": ["https://..."],
          "stock": 100
        }
      }
    ]
  },
  "message": "Cart retrieved"
}
```

> Cart lines are keyed by their own **`id`**. The same product with a different modifier
> selection is a separate line; the server merges lines with an identical product **and**
> option set and (re)computes `unitPrice = base + Σ priceDelta`.

---

### `POST /cart/items` 🔐

Adds a product to the cart. Lines are merged by product **+** the exact set of `modifiers`.

**Request body**

```json
{
  "productId": "cuid",
  "quantity": 2,
  "modifiers": ["optionId1", "optionId2"]
}
```

`modifiers` is an array of selected `ModifierOption` ids (omit or `[]` for none). The server
validates them against the product's category groups and prices the line.

**Response `201`** — updated cart object.

---

### `PATCH /cart/items/:itemId` 🔐

Updates the quantity of a cart line **by cart-item id**. Use quantity ≥ 1 (to remove use DELETE).

**Request body**

```json
{ "quantity": 3 }
```

**Response `200`** — updated cart object.

---

### `DELETE /cart/items/:itemId` 🔐

Removes a specific cart line **by cart-item id**.

**Response `200`** — updated cart object.

---

### `DELETE /cart` 🔐

Clears the entire cart.

**Response `200`**

```json
{ "success": true, "data": null, "message": "Cart cleared" }
```

---

## Orders

All `/orders` routes require authentication.

### `POST /orders/checkout` 🔐

Places an order from the current cart. Validates stock, applies loyalty discount, awards points, clears cart.

**Request body**

```json
{
  "addressId": "cuid",
  "pointsToRedeem": 100,
  "tip": 2.0,
  "paymentMethod": "COD",
  "notes": "Leave at door"
}
```

| Field            | Required             | Notes                                          |
| ---------------- | -------------------- | ---------------------------------------------- |
| `addressId`      | Yes                  | Must belong to the authenticated user          |
| `pointsToRedeem` | No (default 0)       | 100 points = $1 discount; re-validated server-side |
| `tip`            | No (default 0)       | Gratuity added to the total                    |
| `paymentMethod`  | No (default `"COD"`) | `"COD"`                                        |
| `notes`          | No                   | Max 500 characters                             |

The order is created `CONFIRMED`; `subtotal`, `loyaltyDiscount`, `total`, and `pointsEarned`
are recomputed from server state inside a single transaction (the client's numbers are
validated inputs, not trusted values).

**Response `201`**

```json
{
  "success": true,
  "data": {
    "id": "cuid",
    "status": "CONFIRMED",
    "subtotal": "12.75",
    "deliveryFee": "3.99",
    "tip": "2.00",
    "discount": "0.00",
    "loyaltyDiscount": "1.00",
    "total": "17.74",
    "pointsEarned": 15,
    "pointsRedeemed": 100,
    "paymentMethod": "COD",
    "estimatedReadyAt": "2026-02-24T12:12:00.000Z",
    "items": [
      {
        "id": "cuid",
        "productName": "Caramel Macchiato",
        "productImage": "https://...",
        "unitPrice": "6.20",
        "quantity": 2,
        "subtotal": "12.40",
        "modifiers": [ { "groupName": "Size", "label": "Large", "priceDelta": 0.8 } ]
      }
    ],
    "address": { ... },
    "createdAt": "2026-02-24T12:00:00.000Z"
  },
  "message": "Order placed successfully"
}
```

---

### `GET /orders` 🔐

Returns paginated order history for the current user (newest first).

**Query parameters**: `page`, `limit`

**Response `200`** — paginated array of order objects.

---

### `GET /orders/:id` 🔐

Returns a single order by ID. Only the owner can access it.

**Response `200`** — full order object with items and address.

**Error `404`** — `ORDER_NOT_FOUND`

---

## Reviews

All `/reviews` routes require authentication.

### `POST /reviews` 🔐

Creates a review for a delivered order item. A user can only review each `orderItem` once.

**Request body**

```json
{
  "orderItemId": "cuid",
  "rating": 5,
  "comment": "Absolutely love this coffee!",
  "images": ["https://example.com/photo.jpg"]
}
```

| Field         | Required | Notes                                              |
| ------------- | -------- | -------------------------------------------------- |
| `orderItemId` | Yes      | Must belong to a DELIVERED order owned by the user |
| `rating`      | Yes      | Integer 1–5                                        |
| `comment`     | Yes      | 10–1000 characters                                 |
| `images`      | No       | Up to 3 URLs                                       |

**Response `201`** — new review object.

**Error `409`** — `CONFLICT` if this order item was already reviewed.

---

### `PATCH /reviews/:id` 🔐

Updates own review (all fields optional).

**Request body**

```json
{
  "rating": 4,
  "comment": "Still great but slightly overpowering.",
  "images": []
}
```

**Response `200`** — updated review object.

---

### `DELETE /reviews/:id` 🔐

Deletes own review.

**Response `200`**

```json
{ "success": true, "data": null, "message": "Review deleted" }
```

---

## Loyalty

All `/loyalty` routes require authentication.

### `GET /loyalty` 🔐

Returns the user's loyalty account.

**Response `200`**

```json
{
  "success": true,
  "data": {
    "id": "cuid",
    "currentPoints": 850,
    "lifetimePoints": 1200,
    "tier": "GOLD"
  },
  "message": "Loyalty account retrieved"
}
```

---

### `GET /loyalty/history` 🔐

Returns paginated loyalty transaction history.

**Query parameters**: `page`, `limit`

**Response `200`**

```json
{
  "success": true,
  "data": [
    {
      "id": "cuid",
      "type": "EARNED",
      "points": 15,
      "description": "Points earned on order #ABC123",
      "createdAt": "2026-02-20T10:00:00.000Z"
    }
  ],
  "message": "Transaction history retrieved",
  "meta": { ... }
}
```

---

### `POST /loyalty/redeem` 🔐

Validates a points redemption before checkout. Use this to show the user how much discount they'll receive.

**Request body**

```json
{ "pointsToRedeem": 200 }
```

**Response `200`**

```json
{
  "success": true,
  "data": {
    "pointsToRedeem": 200,
    "discountAmount": 2.0,
    "remainingPoints": 650
  },
  "message": "Redemption validated"
}
```

---

## Notifications

All `/notifications` routes require authentication.

### `GET /notifications` 🔐

Returns paginated notifications for the current user (newest first).

**Query parameters**: `page`, `limit`

**Response `200`**

```json
{
  "success": true,
  "data": [
    {
      "id": "cuid",
      "type": "ORDER_STATUS_CHANGED",
      "title": "Order Delivered!",
      "body": "Your order #ABC123 is now DELIVERED.",
      "data": { "orderId": "cuid" },
      "isRead": false,
      "createdAt": "2026-02-24T12:00:00.000Z"
    }
  ],
  "message": "Notifications retrieved",
  "meta": { ... }
}
```

---

### `PATCH /notifications/:id/read` 🔐

Marks a single notification as read.

**Response `200`** — updated notification object.

---

### `PATCH /notifications/read-all` 🔐

Marks all of the user's notifications as read.

**Response `200`**

```json
{ "success": true, "data": null, "message": "All notifications marked as read" }
```

---

## Chat (AI Barista)

All `/chat` routes require authentication.

**Rate limit**: 10 requests / 15 min per IP.

### `POST /chat/message` 🔐

Sends a message to the BrewPhoria AI barista (powered by Google Gemini). Pass `sessionId` to continue an existing conversation.

**Request body**

```json
{
  "message": "What's a good coffee for someone who finds espresso too bitter?",
  "sessionId": "cuid"
}
```

| Field       | Required | Notes                       |
| ----------- | -------- | --------------------------- |
| `message`   | Yes      | 1–1000 characters           |
| `sessionId` | No       | Omit to start a new session |

**Response `200`**

```json
{
  "success": true,
  "data": {
    "sessionId": "cuid",
    "reply": "Great question! If you find espresso too bitter, I'd recommend trying a Flat White or a Vanilla Latte..."
  },
  "message": "Message sent"
}
```

---

## Places (address autocomplete proxy)

Server-side proxy over the Google **Places API (New)** — the API key lives only in
`GOOGLE_MAPS_API_KEY` on the server, never in the client. Returns `503`
`PLACES_UNAVAILABLE` when the key is unset.

### `GET /places/autocomplete?input=<query>` 🔐

Returns up to 5 address suggestions (empty for inputs shorter than 3 chars).

**Response `200`**

```json
{
  "success": true,
  "data": [
    {
      "placeId": "ChIJ...",
      "description": "123 Maple St, Portland, OR, USA",
      "mainText": "123 Maple St",
      "secondaryText": "Portland, OR, USA"
    }
  ],
  "message": "Suggestions retrieved"
}
```

### `GET /places/details/:placeId` 🔐

Resolves a `placeId` into structured address fields.

**Response `200`**

```json
{
  "success": true,
  "data": {
    "formattedAddress": "123 Maple St, Portland, OR 97201, USA",
    "street": "123 Maple St",
    "city": "Portland",
    "state": "OR",
    "postalCode": "97201",
    "country": "US"
  },
  "message": "Address retrieved"
}
```

---

## Admin

All `/admin` routes require authentication **and** `role === "ADMIN"`.

### `GET /admin/dashboard` 👑

Returns aggregated stats (cached 60 seconds in Redis).

**Response `200`**

```json
{
  "success": true,
  "data": {
    "todayRevenue": 1250.75,
    "totalOrders": 348,
    "activeUsers": 120,
    "topProducts": [
      { "productName": "Classic Espresso", "totalQuantity": 84 }
    ],
    "recentOrders": [ ... ]
  },
  "message": "Dashboard stats retrieved"
}
```

---

### `GET /admin/notifications` 👑

Returns paginated notifications for the admin's account. Same shape as `GET /notifications`.

---

### Products (Admin)

#### `GET /admin/products` 👑

Returns paginated product list including inactive products. Supports same query params as `GET /products`.

---

#### `POST /admin/products` 👑

Creates a new product. Uses `multipart/form-data` to support image uploads.

**Form fields**

| Field         | Type          | Required | Notes                                       |
| ------------- | ------------- | -------- | ------------------------------------------- |
| `name`        | string        | Yes      | Max 200 chars                               |
| `description` | string        | Yes      |                                             |
| `price`       | number        | Yes      | Positive decimal                            |
| `categoryId`  | string (cuid) | Yes      |                                             |
| `stock`       | number        | Yes      | Non-negative integer                        |
| `isFeatured`  | boolean       | No       |                                             |
| `isActive`    | boolean       | No       |                                             |
| `images`      | file(s)       | No       | Up to 5 files, JPEG/PNG/WebP, max 5 MB each |

**Response `201`** — new product object.

---

#### `PATCH /admin/products/:id` 👑

Updates a product (all fields optional). Same form fields as create.

**Response `200`** — updated product object.

---

#### `DELETE /admin/products/:id` 👑

Soft-deletes a product (sets `isActive = false`).

**Response `200`**

```json
{ "success": true, "data": null, "message": "Product deleted" }
```

---

### Categories (Admin)

#### `GET /admin/categories` 👑

Returns all categories including inactive ones.

---

#### `POST /admin/categories` 👑

Creates a new category.

**Request body**

```json
{
  "name": "New Category",
  "slug": "new-category",
  "imageUrl": "https://example.com/image.jpg",
  "isActive": true
}
```

**Response `201`** — new category object.

---

#### `PATCH /admin/categories/:id` 👑

Updates a category (all fields optional).

**Response `200`** — updated category object.

---

#### `DELETE /admin/categories/:id` 👑

Deletes a category. Fails if products are linked.

**Response `200`**

```json
{ "success": true, "data": null, "message": "Category deleted" }
```

---

### Orders (Admin)

#### `GET /admin/orders` 👑

Returns paginated orders across all users with filtering.

**Query parameters**

| Param      | Type            | Description                           |
| ---------- | --------------- | ------------------------------------- |
| `page`     | number          |                                       |
| `limit`    | number          |                                       |
| `status`   | string          | Filter by `OrderStatus` enum value    |
| `dateFrom` | ISO date string | Orders created on or after this date  |
| `dateTo`   | ISO date string | Orders created on or before this date |

**Response `200`** — paginated array of order objects.

---

#### `PATCH /admin/orders/:id/status` 👑

Updates an order's status. Triggers an `ORDER_STATUS_CHANGED` notification to the customer.

**Request body**

```json
{ "status": "PREPARING" }
```

Valid values: `PENDING`, `CONFIRMED`, `PREPARING`, `OUT_FOR_DELIVERY`, `DELIVERED`, `CANCELLED`, `REFUNDED`

**Response `200`** — updated order object.

---

### Reviews (Admin)

#### `GET /admin/reviews` 👑

Returns paginated reviews with optional filtering.

**Query parameters**

| Param       | Type   | Description            |
| ----------- | ------ | ---------------------- |
| `page`      | number |                        |
| `limit`     | number |                        |
| `productId` | string | Filter by product      |
| `rating`    | number | Filter by rating (1–5) |

---

#### `PATCH /admin/reviews/:id/visibility` 👑

Shows or hides a review (moderation).

**Request body**

```json
{ "isVisible": false }
```

**Response `200`** — updated review object.

---

## Flutter Integration Notes

### Setting up the HTTP client

```dart
// Recommended: use dio with an interceptor that attaches the Firebase token

final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api/v1'));

dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      // Token expired — refresh and retry once
      if (error.response?.statusCode == 401) {
        final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
        if (token != null) {
          error.requestOptions.headers['Authorization'] = 'Bearer $token';
          final response = await dio.fetch(error.requestOptions);
          return handler.resolve(response);
        }
      }
      handler.next(error);
    },
  ),
);
```

### Typical user flow

1. Firebase sign-in → get `idToken`
2. `POST /auth/login` with `idToken` → receive user + loyalty summary
3. `PATCH /auth/fcm-token` with FCM token (for push notifications)
4. Browse `GET /categories` and `GET /products`
5. Add to cart via `POST /cart/items`
6. Get delivery addresses via `GET /users/me/addresses`
7. Optionally validate points: `POST /loyalty/redeem`
8. Place order: `POST /orders/checkout`
9. Track order: `GET /orders/:id`
10. Leave review: `POST /reviews` (after order is DELIVERED)
11. Poll notifications: `GET /notifications`
