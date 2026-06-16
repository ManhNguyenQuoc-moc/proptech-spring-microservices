# 04 - Business Domain

> Confirmed from current entity classes and migrations. Last updated: 2026-06-16.

## Domain Overview

The current codebase models a basic PropTech/e-commerce-like backend with five service-owned domains:

| Domain | Service | Maturity |
|---|---|---|
| User | `user-service` | Entity + repository + migration |
| Product | `product-service` | Entity + repository + migration |
| Listing | `listing-service` | Entity + repository + basic REST API |
| Order | `order-service` | Entity + repository + migration |
| Payment | `payment-service` | Entity + repository + migration |

The architecture documents mention real-estate listing, transactions, reporting, and richer identity concerns. The source code currently implements a smaller scaffold.

## Entities

<!-- KB-ANCHOR: domain-entities -->

### User

Service: `user-service`  
Table: `user_service.users`

| Field | Type | Notes |
|---|---|---|
| `id` | `UUID` | Primary key |
| `username` | `String` | Required, unique |
| `email` | `String` | Required, unique, email format |
| `fullName` | `String` | Optional |
| `createdAt` | `OffsetDateTime` | Set on persist |
| `updatedAt` | `OffsetDateTime` | Set on persist/update |
| `isDeleted` | `Boolean` | Soft-delete flag, default false |

### Product

Service: `product-service`  
Table: `product_service.products`

| Field | Type | Notes |
|---|---|---|
| `id` | `UUID` | Primary key |
| `name` | `String` | Required |
| `description` | `String` | Optional, max 500 |
| `price` | `BigDecimal` | Required, minimum 0 |
| `createdAt` | `OffsetDateTime` | Set on persist |
| `updatedAt` | `OffsetDateTime` | Set on persist/update |
| `isDeleted` | `Boolean` | Soft-delete flag, default false |

### Listing

Service: `listing-service`  
Table: `listing_service.listings`

| Field | Type | Notes |
|---|---|---|
| `id` | `UUID` | Primary key |
| `title` | `String` | Required, max 250 |
| `description` | `String` | Optional, max 2000 |
| `price` | `BigDecimal` | Required, minimum 0 |
| `address` | `String` | Optional, max 500 |

Known gaps:

- Does not include listing status, property type, owner, media, approval workflow, or search criteria yet.

### Order

Service: `order-service`  
Table: `order_service.orders`

| Field | Type | Notes |
|---|---|---|
| `id` | `UUID` | Primary key |
| `userId` | `UUID` | Cross-service reference to user |
| `productId` | `UUID` | Cross-service reference to product |
| `totalAmount` | `BigDecimal` | Required, minimum 0 |
| `status` | `String` | Required |
| `createdAt` | `OffsetDateTime` | Set on persist |
| `updatedAt` | `OffsetDateTime` | Set on persist/update |
| `isDeleted` | `Boolean` | Soft-delete flag, default false |

### Payment

Service: `payment-service`  
Table: `payment_service.payments`

| Field | Type | Notes |
|---|---|---|
| `id` | `UUID` | Primary key |
| `orderId` | `UUID` | Cross-service reference to order |
| `amount` | `BigDecimal` | Required, minimum 0 |
| `status` | `String` | Required |
| `paymentMethod` | `String` | Optional, max 100 |
| `createdAt` | `OffsetDateTime` | Set on persist |
| `updatedAt` | `OffsetDateTime` | Set on persist/update |
| `isDeleted` | `Boolean` | Soft-delete flag, default false |

<!-- /KB-ANCHOR: domain-entities -->

## Relationships

There are no database-level foreign keys across services in the current migrations.

Logical references:

- `Order.userId` references a user owned by `user-service`.
- `Order.productId` references a product owned by `product-service`.
- `Payment.orderId` references an order owned by `order-service`.

## Current Business Rules

Confirmed rules are mostly field-level constraints:

- User username and email must be unique and non-empty.
- Product price must be non-negative.
- Listing title is required and listing price must be non-negative.
- Order total amount must be non-negative.
- Payment amount must be non-negative.
- Order and payment status are currently free-form strings.

## Planned Domain Expansion

The planning docs imply future PropTech concepts:

- Listing approval/rejection workflow
- Property type, address value object, images, listing status
- Transaction lifecycle for rentals/purchases
- Payment processing and commission calculation
- Reporting/analytics
- Identity/authentication/authorization

These should be added as explicit requirements before implementation.
