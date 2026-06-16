# 08 - Deployment & CI/CD

> Confirmed from Dockerfiles, Maven projects, and Docker Compose. Last updated: 2026-06-16.

## Local Development

### Prerequisites

- Java 21
- Maven or Maven Wrapper
- Docker Desktop
- Git

### Start Infrastructure And Services

From repository root:

```bash
docker compose up --build
```

This starts PostgreSQL, the API gateway, and all five domain backend services. Domain service containers wait for the PostgreSQL healthcheck before starting.

### Run A Single Service Locally

Start PostgreSQL first:

```bash
docker compose up postgres
```

Then run a service from its folder, for example:

```bash
cd server/services/listing-service
./mvnw spring-boot:run
```

On Windows PowerShell:

```powershell
cd server/services/listing-service
.\mvnw.cmd spring-boot:run
```

## Service Ports

| Service | Port |
|---|---:|
| `gateway-service` | 8080 |
| `user-service` | 8081 |
| `product-service` | 8082 |
| `listing-service` | 8083 |
| `order-service` | 8084 |
| `payment-service` | 8085 |
| PostgreSQL host port | 5433 |

## Swagger / OpenAPI

After starting Docker Compose, open:

```text
http://localhost:8080/swagger-ui.html
```

Individual service Swagger UIs are also available on their own ports, for example:

```text
http://localhost:8083/swagger-ui.html
```

## Build And Test

Each service is an independent Maven project.

```powershell
cd server/services/user-service
.\mvnw.cmd test
```

Known test status from local inspection:

- `user-service`: Maven test passes.
- `product-service`: Maven test passes.
- `order-service`: Maven test passes.
- `payment-service`: Maven test passes.
- `gateway-service`: Spring context smoke test should not require PostgreSQL.
- `listing-service`: Maven test fails if PostgreSQL is not running because its `@SpringBootTest` loads the full persistence context.

## Database Migrations

Flyway migrations exist for:

- `user-service`
- `product-service`
- `listing-service`
- `order-service`
- `payment-service`

## Docker Image Build

Most services, including `gateway-service`, use the shared Dockerfile:

```text
server/infrastructure/docker/Dockerfile
```

`listing-service` has its own Dockerfile:

```text
server/services/listing-service/Dockerfile
```

Both use a two-stage build:

1. Build with `eclipse-temurin:21-jdk`.
2. Run with `eclipse-temurin:21-jre`.

## CI/CD Status

No active CI/CD workflow for these Spring Boot services is confirmed in the current repository.

Recommended next steps:

- Add GitHub Actions workflow for changed services.
- Cache Maven dependencies.
- Run `mvnw test` per changed service.
- Build Docker images after tests pass.
- Add a separate integration-test profile once Testcontainers or Docker-based tests are introduced.
