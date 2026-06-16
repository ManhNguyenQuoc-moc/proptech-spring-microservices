# Product Service

## Summary

`product-service` owns product records.

| Item | Value |
|---|---|
| Path | `server/services/product-service/` |
| Port | `8082` |
| Package | `com.proptech.product` |
| Schema | `product_service` |
| Table | `products` |
| Migration | Flyway |
| Hibernate DDL | `validate` |

## Current Implementation

- Main class: `ProductServiceApplication`
- Entity: `Product`
- Repository: `ProductRepository extends JpaRepository<Product, UUID>`
- REST controllers: none confirmed

## Entity Fields

- `id`
- `name`
- `description`
- `price`
- `createdAt`
- `updatedAt`
- `isDeleted`

## Swagger / OpenAPI

| URL | Purpose |
|---|---|
| `/swagger-ui.html` | Product service Swagger UI |
| `/v3/api-docs` | Product service OpenAPI JSON |

## Known Gaps

- No REST API yet.
- No DTOs or application service.
- No product inventory/category model.
- No tests beyond Maven compile/test lifecycle.
