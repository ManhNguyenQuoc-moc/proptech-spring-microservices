# 07 - Security & Permissions

> Current source-code status. Last updated: 2026-06-16.

## Authentication Status

No authentication implementation is confirmed in the current Spring Boot services.

Confirmed absent from service POMs:

- `spring-boot-starter-security`
- OAuth2 resource server dependencies
- JWT libraries/configuration

## Authorization Status

No role-based access control, permission system, or endpoint authorization rules are currently implemented.

Current REST behavior:

- `listing-service` exposes `GET /api/listings` publicly.
- `listing-service` exposes `POST /api/listings` publicly.
- Other services do not expose REST controllers yet.

## Data Security

Current safeguards:

- PostgreSQL schemas separate most service-owned tables.
- Basic validation annotations exist in user/product/order/payment entities.
- Local Docker credentials are development defaults only.

Current gaps:

- No password hashing/account model beyond the basic `User` entity.
- No login endpoint.
- No JWT issuing or validation.
- No endpoint authorization.
- No centralized exception handling.
- No CORS policy confirmed.
- No rate limiting.
- No secrets management beyond local development config.

## Required Direction Before Public Exposure

Before exposing APIs beyond local development, add:

- Spring Security baseline.
- Authentication strategy, likely JWT bearer.
- Password storage rules if `user-service` owns credentials.
- Role/permission model if admin/user separation is required.
- Global exception handler that does not leak internals.
- CORS configuration.
- Environment-based secret management.

## Security Anti-Patterns To Avoid

| Anti-pattern | Risk |
|---|---|
| Adding public write endpoints without authentication | Unauthorized data mutation |
| Storing plaintext passwords | Credential compromise |
| Returning raw exception details in production | Information disclosure |
| Hardcoding production credentials | Secret leakage |
| Treating local Docker credentials as real secrets | Unsafe deployment |
