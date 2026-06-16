# GEMINI.md

This file guides Gemini when working in this repository.

## Repository Identity

This repo is **PropTech Spring Microservices**.

Do not use legacy CMN/.NET/ABP assumptions. The current source is Java/Spring Boot backend plus separate Next.js frontend apps.

## Read First

1. `knowledge-base-main/PROJECT_CONTEXT.md`
2. `knowledge-base-main/README.md`
3. `knowledge-base-main/03-conventions.md`
4. Relevant service documentation under `knowledge-base-main/services/`

For customer frontend tasks, read `knowledge-base-main/services/client-web.md`.

For admin frontend tasks, read `knowledge-base-main/services/admin-portal.md`.

## Source Of Truth

- Backend code: `server/services/`
- Customer frontend code: `client/client-web/`
- Admin frontend code: `client/admin-portal/`
- Local runtime: `docker-compose.yml`
- Documentation: `knowledge-base-main/`

## Frontend Apps

Frontend is split into two Next.js apps:

- `client/client-web`: public/customer-facing pages and features
- `client/admin-portal`: administrative pages and features

Each app owns its own `src/` tree.

## Reminder

`commands/` and `skills/` folders are AI assistant guidance, not application runtime code.
