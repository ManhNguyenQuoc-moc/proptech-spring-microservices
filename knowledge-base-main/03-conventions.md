# 03 - Engineering Conventions

> Current conventions for this Spring Boot repository. These describe the desired direction while acknowledging the scaffold state.

## Source Of Truth

- Source code under `server/services/` wins over documentation.
- Service-specific `pom.xml`, `application.yml`, entity classes, repository classes, and migrations define the current runtime behavior.
- Planning docs may describe future architecture; do not assume a dependency or feature exists until it appears in code.

## Backend Package Layout

Use the existing service package convention:

```text
com.proptech.{service}
├── {Service}Application.java
├── domain
│   └── entity
├── application
│   └── service
├── infrastructure
│   └── repository
└── presentation
    └── controller
```

For new feature work, prefer completing this structure instead of adding unrelated package styles.

## Layer Rules

| Layer | Owns | Should Avoid |
|---|---|---|
| `presentation` | REST controllers, request/response mapping | Business logic, direct database access |
| `application` | Use cases and orchestration | HTTP-specific types |
| `domain` | Business concepts, invariants, domain entities/value objects | Controller logic |
| `infrastructure` | Spring Data repositories, persistence adapters, external adapters | Business policy |

Current scaffold note: domain entities are also JPA entities today. If the project moves deeper into Clean Architecture, split pure domain models from persistence entities deliberately.

## API Rules

- Controllers should expose DTOs, not raw JPA entities, for production APIs.
- Validate input with `spring-boot-starter-validation` and `@Valid`.
- Keep controller methods thin: delegate to application services.
- Return clear HTTP status codes (`201` for create, `404` for missing resources, `400` for validation errors).
- Add a global exception handler before exposing public APIs widely.

Current exception: `listing-service` currently accepts and returns `Listing` entity directly. Treat this as prototype code.

## Persistence Rules

- Prefer Flyway migrations with `spring.jpa.hibernate.ddl-auto=validate` once a schema is intentional.
- Keep each service's tables in its own schema where possible.
- Do not add JPA relationships across service boundaries.
- Store cross-service references as IDs (`UUID`) and resolve through service APIs/events later.
- Use UTC for runtime and database connections.

## Entity Rules

- Use `UUID` primary keys.
- Use `OffsetDateTime` for auditable timestamps where needed.
- Include soft-delete (`isDeleted`) only when behavior is implemented or planned consistently.
- Keep validation annotations close to DTOs long term; entity-level validation is acceptable in the current scaffold.

## Configuration Rules

- Use environment variables for runtime host/port/schema values:
  - `DB_HOST`
  - `DB_PORT`
  - `DB_SCHEMA`
- Do not commit real secrets. Current `postgres/postgres` credentials are local development defaults only.
- Keep service ports stable unless `docker-compose.yml` and service docs are updated together.

## Testing Rules

- Unit tests should not require a running local PostgreSQL instance.
- For Spring context tests that need persistence, prefer Testcontainers or a test profile.
- Avoid `@SpringBootTest` smoke tests that fail just because Docker Compose is not running.

## Known Anti-Patterns To Avoid

| Anti-pattern | Preferred Direction |
|---|---|
| Controller returns JPA entity directly | Return response DTO |
| Controller receives JPA entity directly | Receive request DTO + validate |
| `ddl-auto:update` in stable services | Flyway + `ddl-auto:validate` |
| Cross-service foreign keys | Store UUID reference, integrate via API/event |
| Business logic in repository/controller | Put behavior in application/domain layer |
| Assuming planned infrastructure exists | Check dependencies/config/source first |
