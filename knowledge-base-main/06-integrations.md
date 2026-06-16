# 06 - Integrations

> Confirmed integrations only. Last updated: 2026-06-16.

## Confirmed Integrations

### PostgreSQL

All backend services connect to PostgreSQL.

| Setting | Value |
|---|---|
| Docker image | `postgres:15` |
| Container name | `proptech-postgres` |
| Container port | `5432` |
| Host port | `5433` |
| Database | `listing_db` |
| Username | `postgres` |
| Password | `postgres` |

Service JDBC URL pattern:

```yaml
jdbc:postgresql://${DB_HOST:127.0.0.1}:${DB_PORT:5433}/listing_db?gssencmode=disable
```

Schema ownership:

| Service | Schema |
|---|---|
| `user-service` | `user_service` |
| `product-service` | `product_service` |
| `listing-service` | `listing_service` |
| `order-service` | `order_service` |
| `payment-service` | `payment_service` |

### Docker Network

Docker Compose places all services on `microservice-net`. Service containers use `DB_HOST=postgres` and `DB_PORT=5432` to reach the database container.

### API Gateway

`gateway-service` exposes a single local API entry point on port `8080`.

| Public Path | Target |
|---|---|
| `/api/users/**` | `user-service:8081` |
| `/api/products/**` | `product-service:8082` |
| `/api/listings/**` | `listing-service:8083` |
| `/api/orders/**` | `order-service:8084` |
| `/api/payments/**` | `payment-service:8085` |

Gateway Swagger UI aggregates service OpenAPI documents:

| URL | Purpose |
|---|---|
| `http://localhost:8080/swagger-ui.html` | Aggregated Swagger UI |
| `http://localhost:8080/v3/api-docs` | Gateway OpenAPI JSON |
| `http://localhost:8080/v3/api-docs/listing-service` | Listing service OpenAPI JSON through gateway |

## Internal Service Communication

No direct service-to-service HTTP, gRPC, or messaging integration is confirmed in source code. Gateway routing is implemented only at the API edge.

Current cross-service relationships are stored as IDs in database fields:

- `orders.user_id`
- `orders.product_id`
- `payments.order_id`

## Planned Integrations Not Yet Implemented

| Integration | Status |
|---|---|
| RabbitMQ | Planned in docs, no dependency/config confirmed |
| Redis | Planned in docs, no dependency/config confirmed |
| External payment provider | Not implemented |
| Media storage | Not implemented |
| Email/SMS | Not implemented |

Do not write code that assumes these integrations exist without first adding the dependency, configuration, and service documentation.
