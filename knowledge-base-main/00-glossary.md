# 00 - Glossary

> Terms used by the current PropTech Spring Boot repository.

## Product Terms

| Term | Meaning |
|---|---|
| PropTech | Property technology platform represented by this repository. |
| User | Basic user record owned by `user-service`. |
| Product | Product record owned by `product-service`; currently generic and not yet specialized to real estate. |
| Listing | Property listing record owned by `listing-service`. |
| Order | Order record owned by `order-service`; references user/product by UUID. |
| Payment | Payment record owned by `payment-service`; references order by UUID. |

## Service Terms

| Term | Meaning |
|---|---|
| Service | Independently buildable Spring Boot Maven project under `server/services/`. |
| Bounded Context | A service-owned business area. Current contexts are user, product, listing, order, and payment. |
| Schema Ownership | Each service should own its PostgreSQL schema/tables and avoid direct access to another service's tables. |
| Cross-Service Reference | UUID field pointing to data owned by another service, for example `Order.userId`. |

## Technical Terms

| Term | Meaning |
|---|---|
| Spring Boot | Java application framework used by every backend service. |
| Spring Web | Spring module used for REST controllers. |
| Spring Data JPA | Repository abstraction used for PostgreSQL persistence. |
| Hibernate | JPA implementation used by Spring Data JPA. |
| Flyway | Database migration tool used by user/product/order/payment services. |
| Maven Wrapper | Per-service `mvnw` / `mvnw.cmd` scripts used to build without requiring a global Maven install. |
| Docker Compose | Local runtime topology for PostgreSQL and backend services. |
| PostgreSQL | Relational database used by all backend services. |
| DTO | Data Transfer Object; preferred API request/response shape for production controllers. |
| JPA Entity | Java class mapped to a database table via `@Entity`. |

## Current Status Terms

| Term | Meaning |
|---|---|
| Scaffold | Compiles and has basic structure, but lacks complete API/application/domain behavior. |
| Prototype API | Endpoint exists but may expose entities directly and lack validation/security. |
| Planned | Mentioned in docs/roadmap but not confirmed in source code. |
| Legacy KB | Documentation inherited from an unrelated or older system; verify before using. |

## Naming Conventions

| Concept | Convention | Example |
|---|---|---|
| Service directory | `{domain}-service` | `listing-service` |
| Java base package | `com.proptech.{domain}` | `com.proptech.listing` |
| Main class | `{Domain}ServiceApplication` | `ListingServiceApplication` |
| Entity | Singular PascalCase | `Listing` |
| Repository | `{Entity}Repository` | `ListingRepository` |
| Controller | `{Entity}Controller` | `ListingController` |
| Flyway migration | `V{n}__description.sql` | `V1__create_users_table.sql` |
