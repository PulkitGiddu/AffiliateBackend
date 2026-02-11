# SnatchMart – Flow Diagram: UI → Backend → Neon DB

This document describes how the user interacts with the Flutter UI, how the Spring Boot backend is invoked, and how Neon (PostgreSQL) is used with the relevant tables.

---

## 1. High-Level Architecture

```mermaid
flowchart LR
    subgraph User
        U[User]
    end
    subgraph "Flutter App (UI)"
        UI[Screens]
        API[Dio ApiClient]
        UI --> API
    end
    subgraph "Spring Boot Backend"
        REST[REST Controllers]
        SVC[Services]
        REPO[JPA Repositories]
        REST --> SVC
        SVC --> REPO
    end
    subgraph "Neon DB (PostgreSQL)"
        DB[(Tables)]
    end
    U --> UI
    API -->|"HTTP/REST\n(JWT)"| REST
    REPO -->|"JDBC/SQL"| DB
```

- **User** uses the Flutter app (login, home, products, wishlist, coupons, etc.).
- **Flutter** uses **Dio** with base URL (e.g. `http://127.0.0.1:8081`), **JWT** in headers, and calls **REST** endpoints.
- **Spring Boot** exposes **REST** → **Services** → **JPA Repositories** → **Neon DB**.

---

## 2. Request Flow (Single Action)

```mermaid
sequenceDiagram
    participant User
    participant Flutter as Flutter UI
    participant Dio as Dio / ApiClient
    participant Backend as Spring Boot
    participant Service as Service Layer
    participant Repo as JPA Repository
    participant Neon as Neon DB

    User->>Flutter: Tap / Navigate
    Flutter->>Dio: e.g. GET /api/v1/products
    Dio->>Backend: HTTP + JWT (if auth)
    Backend->>Service: Controller calls Service
    Service->>Repo: e.g. productRepository.findAll()
    Repo->>Neon: SQL (SELECT/INSERT/UPDATE/DELETE)
    Neon-->>Repo: Rows
    Repo-->>Service: Entities
    Service-->>Backend: DTOs
    Backend-->>Dio: JSON response
    Dio-->>Flutter: Decoded data
    Flutter-->>User: Update UI
```

---

## 3. Feature Flows and Tables Used

### 3.1 Authentication (Register / Login)

```mermaid
flowchart LR
    subgraph UI
        A1[Register/Login Screen]
    end
    subgraph Backend
        B1["AuthController\n/api/v1/auth"]
        B2[AuthService]
        B3[UserRepository]
    end
    subgraph DB
        T1[(user_login)]
    end
    A1 -->|POST /register, POST /login| B1
    B1 --> B2
    B2 --> B3
    B3 --> T1
```

| Action        | API                    | Backend → DB        | Table(s)   |
|---------------|------------------------|---------------------|------------|
| Register      | `POST /api/v1/auth/register` | AuthService → UserRepository | **user_login** (INSERT) |
| Login         | `POST /api/v1/auth/login`   | AuthService → UserRepository | **user_login** (SELECT by email) |

---

### 3.2 Home: Categories and Top Deals (Products)

```mermaid
flowchart LR
    subgraph UI
        H1[Home Screen]
    end
    subgraph Backend
        C1["CategoryController\n/api/v1/categories"]
        C2["ProductController\n/api/v1/products"]
        S1[CategoryService]
        S2[ProductService]
        R1[CategoryRepository]
        R2[ProductRepository]
        R3[MerchantRepository]
    end
    subgraph DB
        T1[(categories)]
        T2[(products)]
        T3[(merchants)]
    end
    H1 -->|GET /categories| C1
    H1 -->|GET /products?...| C2
    C1 --> S1 --> R1 --> T1
    C2 --> S2 --> R2 --> T2
    S2 -.->|FK| R3 --> T3
```

| Action           | API                         | Tables used                               |
|------------------|-----------------------------|-------------------------------------------|
| Load categories  | `GET /api/v1/categories`    | **categories**                            |
| Load products    | `GET /api/v1/products`      | **products**, **merchants**, **categories** (via FKs) |

---

### 3.3 Product Detail and Price History

```mermaid
flowchart LR
    subgraph UI
        P1[Product Detail Screen]
    end
    subgraph Backend
        PC["ProductController"]
        PS[ProductService]
        PR[ProductRepository]
        PHR[ProductPriceHistoryRepository]
    end
    subgraph DB
        T1[(products)]
        T2[(product_price_history)]
        T3[(merchants)]
        T4[(categories)]
    end
    P1 -->|GET /products/:id| PC
    P1 -->|GET /products/:id/price-history| PC
    PC --> PS --> PR --> T1
    PS --> PHR --> T2
    PR -.-> T3
    PR -.-> T4
```

| Action            | API                                  | Tables used                                      |
|------------------|--------------------------------------|--------------------------------------------------|
| Product by ID     | `GET /api/v1/products/{id}`          | **products**, **merchants**, **categories**      |
| Price history     | `GET /api/v1/products/{id}/price-history` | **product_price_history**, **products**     |

---

### 3.4 Wishlist

```mermaid
flowchart LR
    subgraph UI
        W1[Wishlist Screen]
    end
    subgraph Backend
        WC["WishlistController\n/api/v1/wishlist"]
        WS[WishlistService]
        WR[UserWishlistRepository]
    end
    subgraph DB
        T1[(user_wishlist)]
        T2[(products)]
    end
    W1 -->|GET?userId=| WC
    W1 -->|POST add, DELETE remove| WC
    WC --> WS --> WR --> T1
    WR -.->|product_id FK| T2
```

| Action      | API                          | Tables used                |
|-------------|------------------------------|----------------------------|
| Get list    | `GET /api/v1/wishlist?userId=`  | **user_wishlist**, **products** |
| Add         | `POST /api/v1/wishlist`       | **user_wishlist** (INSERT) |
| Remove      | `DELETE /api/v1/wishlist?userId=&productId=` | **user_wishlist** (DELETE) |

---

### 3.5 Budgets

```mermaid
flowchart LR
    subgraph UI
        B1[Budgets Screen]
    end
    subgraph Backend
        BC["BudgetController\n/api/v1/budgets"]
        BS[BudgetService]
        BR[UserBudgetRepository]
        UR[UserRepository]
    end
    subgraph DB
        T1[(user_budgets)]
        T2[(user_login)]
    end
    B1 -->|GET?userId=, POST, PUT, DELETE| BC
    BC --> BS --> BR --> T1
    BS --> UR --> T2
```

| Action   | API                                | Tables used                    |
|----------|------------------------------------|--------------------------------|
| List     | `GET /api/v1/budgets?userId=`      | **user_budgets**, **user_login** |
| Create   | `POST /api/v1/budgets`             | **user_budgets**, **user_login** |
| Update   | `PUT /api/v1/budgets/{id}`         | **user_budgets**               |
| Delete   | `DELETE /api/v1/budgets/{id}`       | **user_budgets**               |

---

### 3.6 Coupons

```mermaid
flowchart LR
    subgraph UI
        C1[Coupons Screen]
    end
    subgraph Backend
        CC["CouponController\n/api/v1/coupons"]
        CS[CouponService]
        CR[CouponRepository]
        MR[MerchantRepository]
    end
    subgraph DB
        T1[(coupons)]
        T2[(merchants)]
    end
    C1 -->|GET, GET/:id, POST, PUT, DELETE| CC
    CC --> CS --> CR --> T1
    CS --> MR --> T2
```

| Action | API                           | Tables used        |
|--------|-------------------------------|--------------------|
| List   | `GET /api/v1/coupons`         | **coupons**, **merchants** |
| By ID  | `GET /api/v1/coupons/{id}`    | **coupons**        |
| Create/Update/Delete | POST/PUT/DELETE | **coupons**, **merchants** |

---

### 3.7 Notifications

```mermaid
flowchart LR
    subgraph UI
        N1[Notifications Screen]
    end
    subgraph Backend
        NC["NotificationController\n/api/v1/notifications"]
        NS[NotificationService]
        NR[NotificationRepository]
    end
    subgraph DB
        T1[(notifications)]
        T2[(user_login)]
    end
    N1 -->|GET?userId=, PUT/:id/read| NC
    NC --> NS --> NR --> T1
    NR -.->|user_id FK| T2
```

| Action   | API                                    | Tables used          |
|----------|----------------------------------------|----------------------|
| List     | `GET /api/v1/notifications?userId=`    | **notifications**, **user_login** |
| Mark read| `PUT /api/v1/notifications/{id}/read`  | **notifications** (UPDATE) |

---

### 3.8 Affiliate Click (Track Outbound Clicks)

```mermaid
flowchart LR
    subgraph UI
        A1[Product / Deal link]
    end
    subgraph Backend
        AC["AffiliateClickController\n/api/v1/affiliate-clicks"]
        AS[AffiliateClickService]
        ACR[AffiliateClickRepository]
        UR[UserRepository]
        PR[ProductRepository]
    end
    subgraph DB
        T1[(affiliate_clicks)]
        T2[(user_login)]
        T3[(products)]
    end
    A1 -->|POST track click| AC
    AC --> AS --> ACR --> T1
    AS --> UR --> T2
    AS --> PR --> T3
```

| Action | API                              | Tables used                                   |
|--------|----------------------------------|-----------------------------------------------|
| Track  | `POST /api/v1/affiliate-clicks`  | **affiliate_clicks**, **user_login**, **products** |

---

### 3.9 User Management (Profile / Referrals)

| Action        | API (e.g. UserSignUpController)     | Tables used     |
|---------------|-------------------------------------|-----------------|
| Create user   | `POST /api/v1/users`                | **user_login**  |
| Update user   | `PUT /api/v1/{id}`                  | **user_login**  |
| Get user      | `GET /api/v1/{id}`                  | **user_login**  |
| Get by referral code | `GET /api/v1/referral/{code}` | **user_login**  |
| Referrals by user   | `GET /api/v1/{id}/referrals`  | **user_login** (self-references) |
| Login         | `POST /api/v1/login`                | **user_login**  |

---

## 4. Database Tables and Relationships

```mermaid
erDiagram
    user_login ||--o{ user_login : "referred_by_id"
    user_login ||--o{ user_wishlist : "user_id"
    user_login ||--o{ user_budgets : "user_id"
    user_login ||--o{ notifications : "user_id"
    user_login ||--o{ affiliate_clicks : "user_id"

    merchants ||--o{ products : "merchant_id"
    merchants ||--o{ coupons : "merchant_id"
    merchants ||--o{ affiliate_clicks : "merchant_id"

    categories ||--o{ categories : "parent_id"
    categories ||--o{ products : "category_id"

    products ||--o{ product_sales_events : "product_id"
    products ||--o{ user_wishlist : "product_id"
    products ||--o{ product_price_history : "product_id"
    products ||--o{ affiliate_clicks : "product_id"

    sales_events ||--o{ product_sales_events : "sales_event_id"

    user_login {
        uuid id PK
        email_id
        username
        password_hash
        referral_code
        referred_by_id FK
    }

    merchants {
        uuid id PK
        name
        logo_url
    }

    categories {
        uuid id PK
        name
        slug
        parent_id FK
    }

    products {
        uuid id PK
        product_name
        sale_price
        merchant_id FK
        category_id FK
        affiliate_url
    }

    user_wishlist {
        user_id PK,FK
        product_id PK,FK
    }

    user_budgets {
        uuid id PK
        user_id FK
        product_name
        target_price
    }

    coupons {
        uuid id PK
        code
        discount_type
        merchant_id FK
    }

    notifications {
        uuid id PK
        user_id FK
        message
        is_read
    }

    affiliate_clicks {
        uuid id PK
        user_id FK
        product_id FK
        merchant_id FK
    }

    product_price_history {
        uuid id PK
        product_id FK
        price
        recorded_at
    }

    sales_events { uuid id PK }
    product_sales_events { product_id FK, sales_event_id FK }
```

---

## 5. Summary: UI → Backend → Neon

| Layer        | Role |
|-------------|------|
| **User**    | Uses Flutter app (login, browse, wishlist, budgets, coupons, notifications). |
| **Flutter** | Screens + Dio `ApiClient` (base URL, JWT). Calls REST endpoints. |
| **Backend** | Spring Boot: Controllers → Services → JPA Repositories. Returns JSON. |
| **Neon DB** | PostgreSQL. Tables: `user_login`, `merchants`, `categories`, `products`, `sales_events`, `product_sales_events`, `coupons`, `affiliate_clicks`, `user_wishlist`, `user_budgets`, `product_price_history`, `notifications`. |

Connection to Neon is configured via Spring DataSource (e.g. `spring.datasource.url` with Neon connection string). JPA/Hibernate map entities to these tables; Repositories generate SQL; Neon executes it and returns results.
