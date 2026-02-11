# SnatchMart Affiliate Deals Backend

Production-ready Spring Boot 3 backend for a Flutter deals app. Supports JWT auth, affiliate clicks, wishlist, budget tracking, price history, notifications, caching, and schedulers.

## Folder Structure
```
src/main/java/com/snatchmart/snatchmart
├── configuration
├── controller
├── DTO
├── entity
├── exception
├── integration
├── repository
├── scheduler
├── security
└── service
```

## Local Setup
```
export NEON_JDBC_URL=jdbc:postgresql://<host>/<db>?sslmode=require
export NEON_DB_USER=<user>
export NEON_DB_PASSWORD=<password>
export JWT_SECRET=<strong-secret>
```

```
./mvnw spring-boot:run
```

Swagger:
`http://localhost:8081/swagger-ui/index.html`

## API Response Format (Flutter)
All endpoints wrap responses in:
```
{
  "success": true,
  "message": "Products fetched",
  "data": { ... },
  "timestamp": "2026-02-07T10:30:00Z"
}
```

Pagination responses use:
```
{
  "items": [],
  "page": 0,
  "size": 20,
  "totalElements": 200,
  "totalPages": 10,
  "hasNext": true
}
```

## Key Endpoints
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `GET /api/v1/products`
- `GET /api/v1/categories`
- `GET /api/v1/coupons`
- `POST /api/v1/affiliate-clicks`
- `GET /api/v1/wishlist`
- `GET /api/v1/budgets`
- `GET /api/v1/notifications`

## Docker
```
docker build -t snatchmart .
docker run -p 8081:8081 snatchmart
```

## Flutter UI
Flutter scaffold is available under `ui/flutter_app`.
