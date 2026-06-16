# PropTech Spring Microservices

Monorepo for a PropTech platform built with Spring Boot microservices and separate Next.js frontend apps.

## Repository Layout

```text
proptech-spring-microservices/
├── knowledge-base-main/     # Living documentation for AI and developers
├── server/
│   ├── commands/            # Backend AI task prompts, not runtime app code
│   ├── skills/              # Backend AI task rules, not runtime app code
│   └── services/            # Spring Boot services
├── client/
│   ├── commands/            # Frontend AI task prompts, not runtime app code
│   ├── skills/              # Frontend AI task rules, not runtime app code
│   ├── client-web/          # Customer-facing Next.js app
│   └── admin-portal/        # Admin/back-office Next.js app
└── docker-compose.yml
```

## Backend

Spring Boot services live under `server/services/`:

- `user-service`
- `product-service`
- `listing-service`
- `order-service`
- `payment-service`

## Frontend

Frontend apps use Next.js App Router:

- `client/client-web`: customer-facing pages and features
- `client/admin-portal`: admin/back-office pages and features

## Knowledge Base

Start with:

- `knowledge-base-main/PROJECT_CONTEXT.md`
- `knowledge-base-main/README.md`
- `knowledge-base-main/03-conventions.md`
