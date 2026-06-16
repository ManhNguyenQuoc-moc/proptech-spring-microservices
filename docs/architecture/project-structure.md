# PropTech Platform - Project Structure & Architecture

## 1. Overview

Dự án được xây dựng theo kiến trúc:

- Microservices
- Domain Driven Design (DDD)
- Clean Architecture
- Spring Boot 3 + Java 21
- PostgreSQL
- RabbitMQ
- Redis
- React / Next.js
- Docker

Mục tiêu:

- Tách biệt nghiệp vụ theo Domain (Bounded Context)
- Dễ mở rộng và bảo trì
- Hỗ trợ triển khai độc lập từng service
- Hỗ trợ nhiều loại client (Web, Admin Portal, Mobile trong tương lai)

---

# 2. High-Level Architecture

```text
Frontend
│
├── Client Web
│
└── Admin Portal

        │
        ▼

Gateway Service

        │
        ▼

┌──────────────────────────────────────┐
│              Backend                 │
├──────────────────────────────────────┤
│ Identity Service                     │
│ Listing Service                      │
│ Transaction Service                  │
│ Payment Service                      │
│ Reporting Service                    │
└──────────────────────────────────────┘

        │
        ▼

Infrastructure

PostgreSQL
RabbitMQ
Redis
Monitoring
```

---

# 3. Repository Structure

```text
proptech-platform/
│
├── .github/
│
├── docs/
│
├── infrastructure/
│
├── services/
│
├── frontend/
│
├── docker-compose.yml
│
├── .gitignore
│
└── README.md
```

---

# 4. Documentation Structure

```text
docs/
│
├── requirements/
│   ├── functional-requirements.md
│   └── non-functional-requirements.md
│
├── use-cases/
│   ├── guest.md
│   ├── customer.md
│   ├── realtor.md
│   └── admin.md
│
├── bounded-context/
│   └── context-map.md
│
├── architecture/
│   ├── project-structure.md
│   ├── clean-architecture.md
│   ├── microservices.md
│   └── event-flow.md
│
├── erd/
│
└── api-contracts/
```

---

# 5. Backend Microservices

```text
services/
│
├── gateway-service/
│
├── identity-service/
│
├── listing-service/
│
├── transaction-service/
│
├── payment-service/
│
└── reporting-service/
```

---

# 6. Bounded Context Mapping

## Identity Context

Responsibilities:

- Authentication
- Authorization
- User Management
- Role Management
- JWT
- Refresh Token

Service:

```text
identity-service
```

---

## Listing Context

Responsibilities:

- Property Listing
- Property Search
- Listing Approval
- Listing Management

Service:

```text
listing-service
```

---

## Transaction Context

Responsibilities:

- Property Purchase
- Property Rental
- Contract Management
- Transaction Lifecycle

Service:

```text
transaction-service
```

---

## Payment Context

Responsibilities:

- Payment Processing
- Commission Calculation
- Payment History

Service:

```text
payment-service
```

---

## Reporting Context

Responsibilities:

- Dashboard
- Statistics
- Revenue Reports
- Analytics

Service:

```text
reporting-service
```

---

# 7. Why There Is No Admin Service

Admin is an Actor.

Admin is not a Domain.

Examples:

Approve Listing

```text
Listing Context
```

Lock User

```text
Identity Context
```

View Revenue

```text
Reporting Context
```

Therefore:

```text
Admin Portal
```

uses existing services instead of requiring a dedicated admin-service.

---

# 8. Frontend Structure

```text
frontend/
│
├── client-web/
│
└── admin-portal/
```

---

## Client Web

Used by:

- Guest
- Customer
- Realtor

Structure:

```text
client-web/
│
└── src/
    │
    ├── components/
    ├── features/
    ├── pages/
    ├── layouts/
    ├── hooks/
    ├── services/
    ├── store/
    └── utils/
```

---

## Admin Portal

Used by:

- Admin

Structure:

```text
admin-portal/
│
└── src/
    │
    ├── components/
    ├── features/
    ├── pages/
    ├── layouts/
    ├── hooks/
    ├── services/
    ├── store/
    └── utils/
```

---

# 9. Root Infrastructure

Purpose:

System-wide infrastructure.

Structure:

```text
infrastructure/
│
├── postgres/
├── rabbitmq/
├── redis/
├── nginx/
└── monitoring/
```

Examples:

- Docker Compose
- PostgreSQL Configuration
- RabbitMQ Configuration
- Redis Configuration
- Prometheus
- Grafana
- Nginx

Root Infrastructure belongs to the entire platform.

---

# 10. Service Infrastructure

Each service contains its own Infrastructure Layer.

Example:

```text
listing-service/
│
├── domain/
├── application/
├── infrastructure/
├── presentation/
└── config/
```

Infrastructure Layer responsibilities:

- JPA Repository Implementations
- RabbitMQ Publishers/Consumers
- Redis Adapters
- External Service Clients

Example:

```text
infrastructure/
│
├── persistence/
├── messaging/
├── cache/
└── external/
```

---

# 11. Clean Architecture Structure

```text
service/
│
├── domain/
│
├── application/
│
├── infrastructure/
│
├── presentation/
│
└── config/
```

---

## Domain Layer

Contains business rules.

```text
domain/
│
├── aggregate/
├── entity/
├── valueobject/
├── repository/
├── service/
└── event/
```

No Spring Framework dependency should exist here.

---

## Application Layer

Contains use cases.

```text
application/
│
├── usecase/
├── command/
├── query/
└── dto/
```

---

## Infrastructure Layer

Contains implementation details.

```text
infrastructure/
│
├── persistence/
├── messaging/
├── cache/
└── external/
```

---

## Presentation Layer

Contains APIs.

```text
presentation/
│
├── controller/
├── request/
├── response/
├── mapper/
└── exception/
```

---

# 12. Database Strategy

Each microservice owns its own database.

```text
identity_db

listing_db

transaction_db

payment_db

reporting_db
```

Avoid:

```text
proptech_db
```

for all services.

---

# 13. Event-Driven Communication

RabbitMQ Events:

```text
listing.created

listing.updated

listing.approved

listing.rejected

transaction.created

transaction.completed

payment.completed

payment.failed
```

Services communicate via events rather than direct database access.

---

# 14. Git Branch Strategy

Main Branch:

```text
main
```

Feature Branch Examples:

```text
feature/setup-repository

feature/identity-service

feature/listing-service

feature/transaction-service

feature/payment-service

feature/reporting-service

feature/client-web

feature/admin-portal
```

---

# 15. Development Roadmap

Phase 1

- Repository Setup
- Git Workflow
- Documentation

Phase 2

- Requirements Analysis
- Use Cases
- Bounded Context
- Event Storming
- ERD

Phase 3

- Docker Compose
- PostgreSQL
- RabbitMQ
- Redis

Phase 4

- Gateway Service
- Identity Service

Phase 5

- Listing Service
- Transaction Service

Phase 6

- Payment Service
- Reporting Service

Phase 7

- Client Web
- Admin Portal

Phase 8

- CI/CD
- Monitoring
- Deployment

```

```
