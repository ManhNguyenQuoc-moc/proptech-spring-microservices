# User Service

## Summary

`user-service` owns basic user records.

| Item | Value |
|---|---|
| Path | `server/services/user-service/` |
| Port | `8081` |
| Package | `com.proptech.user` |
| Schema | `user_service` |
| Table | `users` |
| Migration | Flyway |
| Hibernate DDL | `validate` |

## Current Implementation

- Main class: `UserServiceApplication`
- Entity: `User`
- Repository: `UserRepository extends JpaRepository<User, UUID>`
- REST controllers: none confirmed

## Entity Fields

- `id`
- `username`
- `email`
- `fullName`
- `createdAt`
- `updatedAt`
- `isDeleted`

## Swagger / OpenAPI

| URL | Purpose |
|---|---|
| `/swagger-ui.html` | User service Swagger UI |
| `/v3/api-docs` | User service OpenAPI JSON |

## Known Gaps

- No REST API yet.
- No password/authentication model.
- No DTOs or application service.
- No tests beyond Maven compile/test lifecycle.
