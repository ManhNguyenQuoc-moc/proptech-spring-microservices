# Project Context

This repository is **PropTech Spring Microservices**.

## Source Of Truth

- Backend source: `server/services/`
- Customer frontend source: `client/client-web/`
- Admin frontend source: `client/admin-portal/`
- Local runtime: `docker-compose.yml`
- Living documentation: `knowledge-base-main/`

## Backend

- Java 21
- Spring Boot 3.5.4
- Maven Wrapper per service
- PostgreSQL 15
- Service folders:
  - `server/services/user-service`
  - `server/services/product-service`
  - `server/services/listing-service`
  - `server/services/order-service`
  - `server/services/payment-service`

## Frontend

- Customer app: Next.js under `client/client-web/`
- Admin app: Next.js under `client/admin-portal/`
- The two frontend domains are split into separate app roots and separate `src/` trees.

## AI Guidance

Before any coding task:

1. Read `knowledge-base-main/README.md`.
2. Read `knowledge-base-main/03-conventions.md`.
3. Read the relevant service doc under `knowledge-base-main/services/`.
4. Verify facts against source code before editing.

Important:

- Do not use legacy CMN/.NET/ABP assumptions.
- Gateway, Auth, RabbitMQ, Redis, and mature frontend workflows are planned unless code proves otherwise.
- `commands/` and `skills/` folders are AI/code-assistant guidance, not application runtime code.
