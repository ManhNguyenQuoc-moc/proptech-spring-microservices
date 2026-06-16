# CLAUDE.md

This file guides Claude Code when working in this repository.

## Repository Identity

This repo is **PropTech Spring Microservices**, not the legacy CMN/.NET/ABP project.

Code wins over documentation. If documentation conflicts with source code, update documentation after verifying the source.

## Required Reading Order

Before making changes, read:

1. `knowledge-base-main/PROJECT_CONTEXT.md`
2. `knowledge-base-main/README.md`
3. `knowledge-base-main/03-conventions.md`
4. Relevant service doc under `knowledge-base-main/services/`

For customer frontend work, also read:

- `knowledge-base-main/services/client-web.md`
- relevant files under `client/skills/`

For admin frontend work, also read:

- `knowledge-base-main/services/admin-portal.md`
- relevant files under `client/skills/`

For backend work, also read:

- relevant files under `server/skills/`

## Project Layout

```text
proptech-spring-microservices/
├── knowledge-base-main/     # Living docs for AI and developers
├── server/
│   ├── commands/            # Backend AI task prompts
│   ├── skills/              # Backend AI task rules
│   └── services/            # Real Spring Boot services
├── client/
│   ├── commands/            # Frontend AI task prompts
│   ├── skills/              # Frontend AI task rules
│   ├── client-web/          # Customer-facing Next.js app
│   └── admin-portal/        # Admin/back-office Next.js app
└── docker-compose.yml
```

`commands/` and `skills/` are not runtime application code.

## Current Stack

Backend:

- Java 21
- Spring Boot 3.5.4
- Maven
- PostgreSQL
- Docker Compose

Frontend:

- Next.js App Router
- TypeScript
- React
- Two frontend apps: customer (`client-web`) and admin (`admin-portal`)

## Guardrails

- Do not assume authentication, gateway, RabbitMQ, Redis, or production frontend flows exist until source code confirms them.
- Keep backend service boundaries explicit.
- Do not add cross-service JPA relationships.
- For customer frontend work, edit `client/client-web`.
- For admin frontend work, edit `client/admin-portal`.
- Shared frontend code should be duplicated only when necessary until a shared package is intentionally introduced.
