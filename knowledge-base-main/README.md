# PropTech Spring Microservices Knowledge Base

> Living knowledge base for the current PropTech Spring Boot microservices repository.

Code is the source of truth. If this knowledge base conflicts with files under `server/services/`, `client/`, `server/infrastructure/`, or `docker-compose.yml`, update the knowledge base.

---

## Current Repository State

This repository is an early-stage Spring Boot microservices scaffold with two separate Next.js frontend apps.

Confirmed today:

- Backend stack: Java 21, Spring Boot 3.5.4, Maven Wrapper, Spring Web, Spring Cloud Gateway, Spring Data JPA, PostgreSQL.
- Infrastructure: Docker Compose with PostgreSQL 15.
- Backend services: gateway, user, product, listing, order, payment.
- Customer frontend: `client/client-web`.
- Admin frontend: `client/admin-portal`.
- Authentication, authorization, RabbitMQ, Redis, observability, and Kubernetes are planned/documented ideas, not confirmed runtime code.
- Some files under `playbooks/`, `diagrams/`, and `09-requirements/` may still be legacy material and have not yet been normalized to this Spring Boot repository.

---

## Quick Navigation

| I want to... | Go to |
|---|---|
| Understand system architecture | [01-architecture.md](01-architecture.md) |
| See the tech stack | [02-tech-stack.md](02-tech-stack.md) |
| Follow engineering conventions | [03-conventions.md](03-conventions.md) |
| Understand the domain model | [04-business-domain.md](04-business-domain.md) |
| Trace current/planned flows | [05-flows.md](05-flows.md) |
| See integrations | [06-integrations.md](06-integrations.md) |
| Understand security status | [07-security-permissions.md](07-security-permissions.md) |
| Run/deploy locally | [08-deployment-cicd.md](08-deployment-cicd.md) |
| Understand the customer frontend | [services/client-web.md](services/client-web.md) |
| Understand the admin frontend | [services/admin-portal.md](services/admin-portal.md) |
| Understand the API gateway | [services/gateway-service.md](services/gateway-service.md) |

---

## Service Documentation

| Service | Port | Status | Doc |
|---|---:|---|---|
| Gateway Service | 8080 | Spring Cloud Gateway route proxy | [services/gateway-service.md](services/gateway-service.md) |
| User Service | 8081 | Entity + repository + Flyway migration | [services/user-service.md](services/user-service.md) |
| Product Service | 8082 | Entity + repository + Flyway migration | [services/product-service.md](services/product-service.md) |
| Listing Service | 8083 | Basic REST API + Flyway migration | [services/listing-service.md](services/listing-service.md) |
| Order Service | 8084 | Entity + repository + Flyway migration | [services/order-service.md](services/order-service.md) |
| Payment Service | 8085 | Entity + repository + Flyway migration | [services/payment-service.md](services/payment-service.md) |
| Client Web | 3000 | Customer-facing Next.js app | [services/client-web.md](services/client-web.md) |
| Admin Portal | 3001 | Admin/back-office Next.js app | [services/admin-portal.md](services/admin-portal.md) |

---

## Monorepo Quick Reference

| Path | Purpose |
|---|---|
| `docker-compose.yml` | Starts PostgreSQL, gateway, and backend services |
| `server/infrastructure/postgres/init-db.sql` | Creates service-owned PostgreSQL schemas |
| `server/infrastructure/docker/Dockerfile` | Shared multi-stage Dockerfile for most services |
| `server/services/*/pom.xml` | Per-service Maven project configuration |
| `server/services/*/src/main/resources/application.yml` | Per-service runtime configuration |
| `client/client-web/` | Customer-facing Next.js app |
| `client/admin-portal/` | Admin/back-office Next.js app |
| `client/commands/` | Frontend AI task prompts, not runtime app code |
| `client/skills/` | Frontend AI task rules, not runtime app code |
| `server/commands/` | Backend AI task prompts, not runtime app code |
| `server/skills/` | Backend AI task rules, not runtime app code |
| `docs/architecture/` | Project planning docs for Spring Boot microservices |

---

## AI Agent Guidance

1. Treat `server/services/`, `client/client-web/`, `client/admin-portal/`, and `docker-compose.yml` as source of truth.
2. Read the relevant `services/*.md` before changing a service/app.
3. Prefer small changes that match the current codebase maturity.
4. Gateway exists as a route proxy only; do not assume Auth/RabbitMQ/Redis exist until code is added.
5. Legacy docs outside this core KB may still mention unrelated stacks; verify against source before using them.
