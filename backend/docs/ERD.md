# BrewPhoria — Entity Relationship Diagram

## Mermaid ERD

```mermaid
erDiagram
    User {
        string id PK
        string firebaseUid UK
        string email UK
        string displayName
        string avatarUrl
        Role   role
        string fcmToken
        DateTime createdAt
        DateTime updatedAt
    }

    Address {
        string   id PK
        string   userId FK
        string   label
        string   fullName
        string   phone
        string   street
        string   city
        string   state
        string   postalCode
        string   country
        boolean  isDefault
        DateTime createdAt
    }

    Category {
        string   id PK
        string   name UK
        string   slug UK
        string   imageUrl
        boolean  isActive
        DateTime createdAt
        DateTime updatedAt
    }

    Product {
        string   id PK
        string   name
        string   slug UK
        string   description
        Decimal  price
        string   categoryId FK
        string[] images
        int      stock
        boolean  isActive
        boolean  isFeatured
        Decimal  avgRating
        int      reviewCount
        DateTime createdAt
        DateTime updatedAt
    }

    Cart {
        string   id PK
        string   userId FK UK
        DateTime updatedAt
    }

    CartItem {
        string   id PK
        string   cartId FK
        string   productId FK
        int      quantity
        DateTime addedAt
    }

    Order {
        string      id PK
        string      userId FK
        string      addressId FK
        Decimal     subtotal
        Decimal     deliveryFee
        Decimal     discount
        Decimal     loyaltyDiscount
        Decimal     total
        int         pointsEarned
        int         pointsRedeemed
        OrderStatus status
        string      paymentMethod
        string      notes
        DateTime    createdAt
        DateTime    updatedAt
    }

    OrderItem {
        string  id PK
        string  orderId FK
        string  productId FK
        string  productName
        string  productImage
        Decimal unitPrice
        int     quantity
        Decimal subtotal
    }

    Review {
        string   id PK
        string   userId FK
        string   productId FK
        string   orderItemId FK UK
        int      rating
        string   comment
        string[] images
        boolean  isVisible
        DateTime createdAt
        DateTime updatedAt
    }

    LoyaltyAccount {
        string      id PK
        string      userId FK UK
        int         currentPoints
        int         lifetimePoints
        LoyaltyTier tier
        DateTime    updatedAt
    }

    LoyaltyTransaction {
        string                 id PK
        string                 accountId FK
        string                 orderId FK
        LoyaltyTransactionType type
        int                    points
        string                 description
        DateTime               expiresAt
        DateTime               createdAt
    }

    Notification {
        string           id PK
        string           userId FK
        NotificationType type
        string           title
        string           body
        Json             data
        boolean          isRead
        DateTime         createdAt
    }

    ChatSession {
        string   id PK
        string   userId
        DateTime createdAt
        DateTime updatedAt
    }

    ChatMessage {
        string   id PK
        string   sessionId FK
        string   role
        string   content
        DateTime createdAt
    }

    User         ||--o{ Address          : "has"
    User         ||--o| Cart             : "owns"
    User         ||--o{ Order            : "places"
    User         ||--o{ Review           : "writes"
    User         ||--o| LoyaltyAccount   : "has"
    User         ||--o{ Notification     : "receives"

    Address      ||--o{ Order            : "used in"

    Category     ||--o{ Product          : "contains"

    Product      ||--o{ CartItem         : "added to"
    Product      ||--o{ OrderItem        : "purchased as"
    Product      ||--o{ Review           : "reviewed in"

    Cart         ||--o{ CartItem         : "contains"

    Order        ||--o{ OrderItem        : "contains"
    Order        ||--o{ LoyaltyTransaction : "triggers"

    OrderItem    ||--o| Review           : "reviewed via"

    LoyaltyAccount ||--o{ LoyaltyTransaction : "records"

    ChatSession  ||--o{ ChatMessage      : "contains"
```

---

## Enum Reference

### `Role`

| Value   | Description            |
| ------- | ---------------------- |
| `USER`  | Standard customer      |
| `ADMIN` | Platform administrator |

### `OrderStatus`

| Value              | Description                             |
| ------------------ | --------------------------------------- |
| `PENDING`          | Created, awaiting confirmation          |
| `CONFIRMED`        | Confirmed (set immediately on checkout) |
| `PREPARING`        | Being prepared                          |
| `OUT_FOR_DELIVERY` | With the delivery driver                |
| `DELIVERED`        | Successfully delivered                  |
| `CANCELLED`        | Cancelled                               |
| `REFUNDED`         | Refunded                                |

### `LoyaltyTier`

| Value      | Points Multiplier |
| ---------- | ----------------- |
| `BRONZE`   | 1×                |
| `SILVER`   | 1.25×             |
| `GOLD`     | 1.5×              |
| `PLATINUM` | 2×                |

### `LoyaltyTransactionType`

| Value      | Description                    |
| ---------- | ------------------------------ |
| `EARNED`   | Points earned from an order    |
| `REDEEMED` | Points spent at checkout       |
| `EXPIRED`  | Expired points removed by cron |
| `BONUS`    | Manual bonus grant             |

### `NotificationType`

| Value                  | Trigger                      |
| ---------------------- | ---------------------------- |
| `ORDER_STATUS_CHANGED` | Order status update          |
| `NEW_SALE`             | Promotional sale             |
| `NEW_ORDER`            | Admin: new order placed      |
| `NEW_REVIEW`           | Admin: new review            |
| `LOYALTY_TIER_UP`      | User reached a higher tier   |
| `POINTS_EXPIRING`      | Cron: points about to expire |

---

## Key Constraints

| Constraint                    | Description                                                            |
| ----------------------------- | ---------------------------------------------------------------------- |
| `CartItem(cartId, productId)` | A product appears at most once per cart                                |
| `Review(userId, orderItemId)` | One review per order line item per user                                |
| `LoyaltyAccount(userId)`      | One loyalty account per user                                           |
| `Cart(userId)`                | One cart per user                                                      |
| `Order → Address`             | Snapshot via `addressId`; address is never deleted while it has orders |
