## SnatchMart – Implementation & Architecture Overview

This document captures the main pieces we have implemented so far across the **Flutter app** and the **Spring Boot backend**, including architecture, logic, and key ideas (especially around affiliate integration and refresh UX).

---

## 1. High‑level architecture

- **Frontend**: Flutter app (`ui/flutter_app/`)
  - Uses `go_router` for navigation and nested routes.
  - Feature‑based structure: `home`, `products`, `wishlist`, `budgets`, `notifications`, `profile`, `dashboard`, `help`.
  - Network: `Dio` client configured via `ApiConfig.baseUrl` (`core/network/api_config.dart`).
  - State: `flutter_riverpod` providers for auth, wishlist, etc.
  - UI: modern “new age” feel with Lottie, `flutter_animate`, and high refresh‑rate support (`flutter_displaymode`).

- **Backend**: Spring Boot 3 (`src/main/java/com/snatchmart/snatchmart`)
  - REST controllers under `/api/v1/...` (products, categories, wishlist, budgets, notifications, auth, affiliate clicks).
  - Persistence with Spring Data JPA + PostgreSQL.
  - Redis caching (disabled for `local` profile).
  - Scheduled jobs with `@EnableScheduling` and `DealScheduler`.
  - Integration layer for affiliate providers (`integration` package: Flipkart, Amazon).

The Flutter app talks only to the backend. The backend is responsible for:

- Storing **users**, **products**, **categories**, **merchants**, **wishlists**, **budgets**, **notifications**, **affiliate clicks**.
- Periodically syncing product data from affiliate providers (currently modeled for Flipkart + Amazon).

---

## 2. Flutter app – key flows & features

### 2.1 Navigation & protected routes

- Root navigation uses `StatefulShellRoute.indexedStack` with 5 bottom tabs:
  - `/` → `HomeScreen`
  - `/products`
  - `/coupons`
  - `/notifications`
  - `/profile`
- Login redirect logic (in `app_router.dart`):
  - If not logged in and visiting `/`, user is redirected to `/login` (unless they chose to skip).
  - Protected routes (e.g. `/profile`, `/notifications`) redirect to `/login` if unauthenticated.
- Nested profile routes:
  - `/profile/edit`
  - `/profile/wishlist`
  - `/profile/budgets`
  - `/profile/make-link`
  - `/profile/help` (chatbot help screen).

All transitions use a shared `_transitionPage` helper for a consistent, smooth fade+slide animation.

### 2.2 Home screen UX & refresh

- Modernized `HomeScreen`:
  - Animated header with search pill, category strip, product sections.
  - Lottie illustrations for empty states (`assets/lottie/placeholder.json`).
  - Staggered animations via `flutter_animate` for sections and list items.
- High refresh rate:
  - Uses `flutter_displaymode` to request the highest refresh mode on Android devices.
  - Called in `main.dart` on app startup and when app resumes.
  - `MainActivity.kt` is kept simple (default `FlutterActivity`), letting the Dart side manage display mode.

### 2.3 Profile & help chatbot

- `ProfileScreen`:
  - Shows user avatar, greeting, and quick actions.
  - “Manage your account” opens `/profile/edit`.
  - Settings tiles for wishlist, budgets, notifications, and theme.
  - “Help and feedback” now navigates to `/profile/help`.

- `HelpChatScreen` (`features/help/screens/help_chat_screen.dart`):
  - Local, rule‑based chatbot; no backend calls.
  - Simple chat UI with bubbles (user right, bot left).
  - Quick suggestion chips for common questions (wishlist, budgets, deals, contact support).
  - Keyword‑based replies for:
    - Wishlist, budgets, coupons, notifications.
    - Account/profile/login.
    - Deals/affiliate links.
    - Make Link / partner tools.
  - Designed to give users in‑app help without leaving the app.

---

## 3. Network configuration & device connectivity

### 3.1 Base URL logic (Flutter)

`ApiConfig.baseUrl` (`core/network/api_config.dart`):

- Reads `BASE_URL` from `--dart-define=BASE_URL=...` when provided.
- If not set:
  - Android → `http://10.0.2.2:8081` (emulator → host).
  - Others → `http://127.0.0.1:8081`.
- For **physical devices**, we use a LAN IP:
  - Example: `flutter run --dart-define=BASE_URL=http://192.168.1.2:8081`.
  - There is a small debug log warning when using `10.0.2.2` to remind this is emulator‑only.

`run_app.sh` shell script in `ui/flutter_app/` helps:

- `./run_app.sh` → emulator (10.0.2.2).
- `./run_app.sh device` → auto‑detects Mac LAN IP and uses it as `BASE_URL`.

### 3.2 Backend binding & health check

- `application-local.properties`:
  - `server.address=0.0.0.0` so the backend listens on all interfaces.
  - Postgres + JPA configuration for Neon.
- `HealthController`:
  - `GET /health` returns a simple `{ "status": "UP", "service": "snatchmart" }`.
  - Used to verify from phone browser: `http://<MAC_IP>:8081/health`.

---

## 4. Backend domain model & services

### 4.1 Core entities (simplified)

- `Product`
  - `id` (UUID), `productName`, `description`, `productUniqueId`.
  - `originalPrice`, `salePrice`.
  - `reviewScore`, `reviewCount`.
  - `affiliateUrl`, `imageUrl`.
  - `merchant` (many‑to‑one → `Merchant`).
  - `category` (many‑to‑one → `Category`).
  - `isActive`, `dealsExpiresAt`.
  - `createdAt`, `updatedAt` with `@PrePersist` / `@PreUpdate`.

- `Category`
  - `id` (UUID), `name`, `slug`, optional `parent`.
  - One‑to‑many `children` for category tree.

- `Merchant`
  - `id` (UUID), `name`, optional `logoUrl`.
  - Timestamps.

- Additional entities (already wired to UI):
  - `UserLogin` (user accounts).
  - `UserWishlist`, `UserBudget`, `Notification`, `Coupon`, `ProductPriceHistory`, etc.

### 4.2 Repositories

- `ProductRepository`:
  - `findByProductUniqueId(String productUniqueId)`.
  - `JpaSpecificationExecutor` for flexible search.

- `CategoryRepository`:
  - `findBySlug(String slug)`.

- `MerchantRepository`:
  - `findByNameIgnoreCase(String name)` to reuse or create merchants by name.

### 4.3 Product service & controller

- `ProductServiceImpl`:
  - `search(...)` with multiple filters (keyword, category, merchant, min/max price, active).
  - Uses `Specification<Product>` for dynamic query building, cached with `@Cacheable`.
  - `create` / `update` / `delete` with `ProductRequest` DTO.
  - `recordPriceHistory` to snapshot price changes into `ProductPriceHistory`.

- `ProductController`:
  - `GET /api/v1/products` → paged search.
  - `GET /api/v1/products/{id}` → details.
  - `POST /api/v1/products` → create.
  - `PUT /api/v1/products/{id}` → update.
  - `DELETE /api/v1/products/{id}` → delete.
  - `GET /api/v1/products/{id}/price-history` → price history.

These endpoints are what the Flutter app hits (for home, categories, product lists, detail screens, wishlist, etc.).

---

## 5. Affiliate integration (Flipkart & Amazon)

### 5.1 Integration abstraction

- `AffiliateDeal` (integration DTO):
  - `productUniqueId`, `productName`, `description`.
  - `originalPrice`, `salePrice`.
  - `affiliateUrl`, `imageUrl`.
  - `categorySlug`, `merchantName`.

- `AffiliateClient` interface:
  - `String provider();`
  - `List<AffiliateDeal> fetchLatestDeals();`

- Implementations:
  - `FlipkartAffiliateClient` (implemented).
  - `AmazonAffiliateClient` (stub; returns empty list for now).

### 5.2 FlipkartAffiliateClient – logic

Located at `integration/FlipkartAffiliateClient.java`.

- **Configuration**:
  - Reads config from `FlipkartAffiliateConfig` (`flipkart.affiliate.id` + `.token`).
  - Uses `RestTemplate` (bean from `AppConfig`) for HTTP calls.

- **Two modes:**

1. **Dummy mode (no config)** – current default
   - If `config.isConfigured()` is `false`:
     - Logs: “Flipkart affiliate not configured; using dummy deals for UI”.
     - Returns a fixed list of 5 `AffiliateDeal`s with:
       - Categories like `electronics` and `deals`.
       - Reasonable dummy prices and descriptions.
       - `affiliateUrl` pointing to `https://www.flipkart.com/` (placeholder).
     - These are then saved to the DB by the sync service (see below) and immediately visible to the UI.

2. **Real Flipkart API mode (when configured)** – ready for later
   - Calls official APIs (from the Flipkart docs):
     - DOTD: `GET https://affiliate-api.flipkart.net/affiliate/offers/v1/dotd/json`
     - All Offers: `GET https://affiliate-api.flipkart.net/affiliate/offers/v1/all/json`
   - Sends headers:
     - `Fk-Affiliate-Id: <affiliate tracking ID>`
     - `Fk-Affiliate-Token: <affiliate API token>`
   - Parses JSON into:
     - `FlipkartDotdResponse` (`dotdList` of `FlipkartOfferDto`)
     - `FlipkartAllOffersResponse` (`allOffersList` of `FlipkartOfferDto`)
   - Maps each offer into `AffiliateDeal`:
     - `productUniqueId` = `"fk-" + prefix + "-" + hex(hash(url))` to keep stable identity per offer URL.
     - `productName` = offer `title` (fallback `"Deal"`).
     - `description` = offer description.
     - Picks the first available image URL.
     - `categorySlug` → sanitized from Flipkart `category` (lowercase, non‑alphanumeric → `-`).
     - `merchantName` = `"Flipkart"`.
   - Logs “Fetched N deals from Flipkart (DOTD + All Offers)” or warns on failure.

### 5.3 AffiliateSyncService & scheduler

- `AffiliateSyncServiceImpl`:
  - Injects:
    - `List<AffiliateClient> affiliateClients`
    - `ProductRepository`, `CategoryRepository`, `MerchantRepository`
  - `syncDeals()`:
    - For each `AffiliateClient client`:
      - Calls `client.fetchLatestDeals()` → returns deals (dummy or real).
      - For each `AffiliateDeal deal`:
        - Looks up `Product` by `productUniqueId`.
        - If found → `updateProductPricing(existing, deal)`:
          - Updates price(s), URL, image, name, description if provided.
        - If not found → `createProductFromDeal(deal)`:
          - Finds or creates `Merchant` by `merchantName`.
          - Finds or creates `Category` by `categorySlug` (name = slug with spaces).
          - Creates `Product` with:
            - Name, description, uniqueId, prices.
            - Affiliate URL, image.
            - Associated merchant + category.
            - `isActive = true`.
      - Logs: “Synced N deals from <provider>”.
  - `cleanupExpiredDeals()`:
    - Finds products where `dealsExpiresAt < now`.
    - Sets `isActive = false` and saves.

- `DealScheduler`:
  - `@Scheduled(fixedRate = 30 * 60 * 1000)` → every 30 minutes:
    - Logs: “Starting 30‑min price sync job”.
    - Calls `affiliateSyncService.syncDeals()`.
  - `@Scheduled(cron = "0 0 */6 * * *")` → every 6 hours:
    - Logs: “Starting expired deals cleanup job”.
    - Calls `affiliateSyncService.cleanupExpiredDeals()`.

Result: **every 30 minutes** the backend:

1. Fetches affiliate deals (dummy or real).
2. Inserts or updates `Product` rows.
3. UI naturally picks these up via the existing `/api/v1/products` and `/api/v1/categories` endpoints.

---

## 6. Security & CORS (current state)

- `SecurityConfig`:
  - Stateless sessions with JWT filter wired in, but current rule is:
    - `.anyRequest().permitAll()` to simplify end‑to‑end testing.
  - `CorsConfiguration`:
    - Allows all origins, methods, and headers (no credentials).
  - Later we can tighten rules (e.g., protect `/api/v1` with JWT except `/auth`, `/health`).

---

## 7. How everything ties together (idea)

1. **Data source**:
   - Affiliate providers (currently Flipkart + Amazon stub) provide product/deal information.
   - For now, Flipkart uses **dummy data** when no credentials are configured; later we can switch to real APIs.

2. **Backend ingestion**:
   - `DealScheduler` fires every 30 minutes → `AffiliateSyncService.syncDeals()`.
   - Deals are normalized to `AffiliateDeal` and written into `Product`, `Category`, `Merchant` tables.

3. **API exposure**:
   - Frontend calls `/api/v1/products`, `/api/v1/categories`, `/api/v1/wishlist`, etc.
   - These endpoints use the same `Product` model for both seed data and affiliate‑synced data.

4. **Frontend consumption**:
   - `HomeScreen`, `ProductsScreen`, `WishlistScreen`, etc. display products and categories.
   - The UI logic does not care whether a product came from seed SQL or affiliate sync; it just works with the REST API.

5. **UX polish**:
   - High refresh rate + animations make the app feel smooth.
   - Chatbot help under Profile improves discoverability and reduces confusion.

This gives you a **clear mental model** of where we are:

- Flutter app: modern, animated, talking to a single backend base URL.
- Backend: Spring Boot, Postgres, with a 30‑minute **affiliate sync pipeline** that can run in dummy or real mode.
- Future work (optional): wire in live Flipkart credentials, build proper Amazon integration, and refine security rules once flows are stable.

