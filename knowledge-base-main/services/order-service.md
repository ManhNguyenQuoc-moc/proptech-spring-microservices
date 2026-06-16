# Order Service

## Summary

`order-service` owns order records and stores references to user/product by UUID.

| Item | Value |
|---|---|
| Path | `server/services/order-service/` |
| Port | `8084` |
| Package | `com.proptech.order` |
| Schema | `order_service` |
| Table | `orders` |
| Migration | Flyway |
| Hibernate DDL | `validate` |

## Current Implementation

- Main class: `OrderServiceApplication`
- Entity: `Order`
- Repository: `OrderRepository extends JpaRepository<Order, UUID>`
- REST controllers: none confirmed

## Entity Fields

- `id`
- `userId`
- `productId`
- `totalAmount`
- `status`
- `createdAt`
- `updatedAt`
- `isDeleted`

## Swagger / OpenAPI

| URL | Purpose |
|---|---|
| `/swagger-ui.html` | Order service Swagger UI |
| `/v3/api-docs` | Order service OpenAPI JSON |

## Known Gaps

- No REST API yet.
- No DTOs or application service.
- No order state machine.
- No service-to-service validation for `userId` or `productId`.
- No tests beyond Maven compile/test lifecycle.
