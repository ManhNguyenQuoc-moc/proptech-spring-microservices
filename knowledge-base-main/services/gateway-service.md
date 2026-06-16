# Gateway Service

## Summary

`gateway-service` is the API edge for frontend clients. It proxies public API paths to backend services so `client-web` and `admin-portal` do not need to call each microservice port directly.

| Item | Value |
|---|---|
| Path | `server/services/gateway-service/` |
| Port | `8080` |
| Package | `com.proptech.gateway` |
| Runtime | Spring Cloud Gateway WebFlux |
| Database | None |
| Migration | None |

## Current Routes

| Public Path | Target Service |
|---|---|
| `/api/users/**` | `user-service:8081` |
| `/api/products/**` | `product-service:8082` |
| `/api/listings/**` | `listing-service:8083` |
| `/api/orders/**` | `order-service:8084` |
| `/api/payments/**` | `payment-service:8085` |

## Swagger / OpenAPI

Gateway exposes its own OpenAPI document and aggregates domain service documents in one Swagger UI:

| URL | Purpose |
|---|---|
| `/swagger-ui.html` | Aggregated Swagger UI |
| `/v3/api-docs` | Gateway OpenAPI JSON |
| `/v3/api-docs/user-service` | User service OpenAPI JSON |
| `/v3/api-docs/product-service` | Product service OpenAPI JSON |
| `/v3/api-docs/listing-service` | Listing service OpenAPI JSON |
| `/v3/api-docs/order-service` | Order service OpenAPI JSON |
| `/v3/api-docs/payment-service` | Payment service OpenAPI JSON |

Only `listing-service` has confirmed REST endpoints today. Other routes are prepared for future controllers.

## CORS

Allowed local frontend origins:

- `http://localhost:3000`
- `http://localhost:3001`

## Known Gaps

- No authentication or authorization filter yet.
- No rate limiting.
- No request tracing or correlation ID.
