# 02 - Technology Stack

> Confirmed from `pom.xml`, `application.yml`, Dockerfiles, and `docker-compose.yml`. Last updated: 2026-06-16.

## Backend Stack

| Category | Technology | Version / Notes |
|---|---|---|
| Language | Java | Target version `21` |
| Framework | Spring Boot | `3.5.4` |
| Build Tool | Maven Wrapper | `mvnw`, `mvnw.cmd` per service |
| HTTP API | Spring Web | Present in domain service POMs |
| API Gateway | Spring Cloud Gateway | Present in `gateway-service` |
| ORM | Spring Data JPA / Hibernate | Present in domain service POMs |
| Database Driver | PostgreSQL JDBC | Runtime dependency |
| Migrations | Flyway | Present in all five backend services |
| Validation | Jakarta Bean Validation | Present in all five backend services |
| API docs | springdoc-openapi | Swagger UI and `/v3/api-docs` for gateway and domain services |
| Boilerplate | Lombok | Present in domain service POMs |
| Tests | Spring Boot Test | Present in all backend service POMs |
| Containers | Docker / Docker Compose | Multi-stage service Dockerfiles |

## Service Matrix

| Service | Artifact | Port | Package | Migration Strategy |
|---|---|---:|---|---|
| Gateway Service | `gateway-service` | 8080 | `com.proptech.gateway` | none |
| User Service | `user-service` | 8081 | `com.proptech.user` | Flyway + `ddl-auto: validate` |
| Product Service | `product-service` | 8082 | `com.proptech.product` | Flyway + `ddl-auto: validate` |
| Listing Service | `listing-service` | 8083 | `com.proptech.listing` | Flyway + `ddl-auto: validate` |
| Order Service | `order-service` | 8084 | `com.proptech.order` | Flyway + `ddl-auto: validate` |
| Payment Service | `payment-service` | 8085 | `com.proptech.payment` | Flyway + `ddl-auto: validate` |

## Infrastructure Stack

| Component | Technology | Source |
|---|---|---|
| Relational database | PostgreSQL 15 | `docker-compose.yml` |
| Shared DB initialization | SQL script | `server/infrastructure/postgres/init-db.sql` |
| Service container build | Eclipse Temurin 21 JDK/JRE | `server/infrastructure/docker/Dockerfile`, `listing-service/Dockerfile` |

## Frontend Stack

| Category | Technology | Notes |
|---|---|---|
| Framework | Next.js | App Router under `client/client-web/src/app` and `client/admin-portal/src/app` |
| Language | TypeScript | Strict mode enabled |
| UI | React + Ant Design | Customer modules under `client/client-web/src/features`; admin modules under `client/admin-portal/src/features` |
| AntD SSR | `@ant-design/nextjs-registry` | `AntdRegistry` is mounted in each app root layout |
| Styling | AntD reset + global CSS | `antd/dist/reset.css` and `src/styles/globals.css` imported by root layout |

## Dependencies By Service

### Gateway

- `spring-cloud-starter-gateway-server-webflux`
- `spring-boot-starter-actuator`
- `springdoc-openapi-starter-webflux-ui`
- `spring-boot-starter-test`

### Domain Services

- `spring-boot-starter-web`
- `spring-boot-starter-data-jpa`
- `spring-boot-starter-validation`
- `springdoc-openapi-starter-webmvc-ui`
- `flyway-core`
- `flyway-database-postgresql`
- `postgresql`
- `lombok`
- `spring-boot-starter-test`

## Not Confirmed In Code Yet

The following are planned or mentioned in docs but not present in current Maven dependencies/configuration:

- Spring Security / JWT
- Spring AMQP / RabbitMQ
- Spring Cache / Redis
- Testcontainers
