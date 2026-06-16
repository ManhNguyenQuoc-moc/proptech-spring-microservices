# Payment Service

## Summary

`payment-service` owns payment records and stores references to order by UUID.

| Item | Value |
|---|---|
| Path | `server/services/payment-service/` |
| Port | `8085` |
| Package | `com.proptech.payment` |
| Schema | `payment_service` |
| Table | `payments` |
| Migration | Flyway |
| Hibernate DDL | `validate` |

## Current Implementation

- Main class: `PaymentServiceApplication`
- Entity: `Payment`
- Repository: `PaymentRepository extends JpaRepository<Payment, UUID>`
- REST controllers: none confirmed

## Entity Fields

- `id`
- `orderId`
- `amount`
- `status`
- `paymentMethod`
- `createdAt`
- `updatedAt`
- `isDeleted`

## Swagger / OpenAPI

| URL | Purpose |
|---|---|
| `/swagger-ui.html` | Payment service Swagger UI |
| `/v3/api-docs` | Payment service OpenAPI JSON |

## Known Gaps

- No REST API yet.
- No DTOs or application service.
- No payment provider integration.
- No payment status enum/state machine.
- No service-to-service validation for `orderId`.
- No tests beyond Maven compile/test lifecycle.
