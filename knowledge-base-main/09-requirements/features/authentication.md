---
requirement_ids:
  - REQ-AUTH-001
  - REQ-AUTH-002
  - REQ-AUTH-003
  - REQ-AUTH-004
  - REQ-AUTH-005
  - REQ-AUTH-006
status: Implemented
service: administration-api
version: 1.0
created: 2026-05-23
updated: 2026-05-23
---

# Authentication Requirements

> **Status**: Implemented
> **Service**: `administration-api`
> **Source verification**: `AuthAppService.cs`, `AuthController.cs`, `AuthenticationJwtBearerHandler.cs`

---

## REQ-AUTH-001 — Login with Employee Code

**The system shall authenticate users using `Employee.Code` as the username (not email).**

### Rationale
Employees are identified by their organizational code (`Employee.Code`), not their personal email. This allows login to survive email address changes and supports multiple accounts with different codes sharing the same organization email.

### Acceptance Criteria

- [ ] **AC-AUTH-001-01**: Given valid `Employee.Code` + correct password + valid `X-Tenant`, when `POST /api/auth` is called, then the system returns HTTP 200 with `{ accessToken, refreshToken, userName, isFirstLogin }`.
- [ ] **AC-AUTH-001-02**: Given an email address (not a code) as `userName`, when `POST /api/auth` is called, then the system returns HTTP 400 (no Employee found by email).
- [ ] **AC-AUTH-001-03**: Given valid code but wrong password, when `POST /api/auth` is called, then the system returns HTTP 400.
- [ ] **AC-AUTH-001-04**: Given `isFirstLogin = true`, when login succeeds, then the response `isFirstLogin` field is `true`.

### Business Rules
| Rule ID | Description |
|---|---|
| BR-AUTH-001 | `LoginInputDto.UserName` receives `Employee.Code` value — not email |
| BR-EMP-001 | `Employee.Code` is unique per tenant |

### Implementation Traceability
| Artifact | Location |
|---|---|
| Controller | `AuthController.cs` → `POST /api/auth` (`[AllowAnonymous]`) |
| App Service | `AuthAppService.LoginAsync()` |
| Employee lookup | `IRepository<Employee>` — `WHERE Code = @username AND TenantId = @tenantId` |
| Password check | `IdentityUserManager.CheckPasswordSignInAsync()` |
| Sequence diagram | `diagrams/auth-login.mermaid` |

---

## REQ-AUTH-002 — JWT Token Issuance

**The system shall issue JWT access tokens using HMAC-SHA256 with a 1-hour expiry and a custom `sessionId` claim.**

### Rationale
Short-lived access tokens limit the window of exposure if a token is compromised. The `sessionId` claim enables per-session refresh token revocation without invalidating all user sessions.

### Acceptance Criteria

- [ ] **AC-AUTH-002-01**: Given successful login, when tokens are issued, then the access token is a valid JWT signed with HMAC-SHA256, issuer `"ZS"`, audience `"ZS"`.
- [ ] **AC-AUTH-002-02**: Given a decoded access token, it contains the claim `sessionId` (UUIDv7 format).
- [ ] **AC-AUTH-002-03**: Given an access token older than 1 hour, when used in any authenticated request, then the system returns HTTP 401.
- [ ] **AC-AUTH-002-04**: Given `ClockSkew = TimeSpan.Zero`, when a token expires at exactly T, any request at T+1s returns 401.

### Business Rules
| Rule ID | Description |
|---|---|
| BR-AUTH-002 | JWT algorithm: HMAC-SHA256. Issuer: "ZS". Audience: "ZS". ClockSkew: zero. |

### Implementation Traceability
| Artifact | Location |
|---|---|
| Token builder | `AuthAppService.CreateAccessTokenAsync()` |
| JWT handler | `AuthenticationJwtBearerHandler.cs` |
| Config | `appsettings.json` → `AuthenticationJwtBearer:SecurityKey/Issuer/Audience/Expiration` |

---

## REQ-AUTH-003 — Refresh Token Rotation

**The system shall issue refresh tokens that expire after 720 hours and are rotated on every refresh (old token deleted, new token issued with a new `sessionId`).**

### Rationale
Refresh token rotation prevents token replay attacks: a stolen refresh token cannot be used once the legitimate client has rotated it.

### Acceptance Criteria

- [ ] **AC-AUTH-003-01**: Given a valid refresh token, when `POST /api/auth/refresh-login` is called, then the system returns new `accessToken` and `refreshToken`, and the old refresh token is deleted from Redis.
- [ ] **AC-AUTH-003-02**: Given the old refresh token (after rotation), when `POST /api/auth/refresh-login` is called again with it, then the system returns HTTP 400/401 (token not found in Redis).
- [ ] **AC-AUTH-003-03**: Given a refresh token older than 720 hours, when used, then the system returns HTTP 401 (Redis TTL expired — key not found).

### Business Rules
| Rule ID | Description |
|---|---|
| BR-AUTH-003 | Refresh token format: `"{UUIDv7}-{UUIDv7}"`. Redis key: `{userId}:{sessionId}`, TTL 720h. |
| BR-AUTH-004 | New refresh token gets a new `sessionId` — old session key is deleted before new one is created. |

### Implementation Traceability
| Artifact | Location |
|---|---|
| App Service | `AuthAppService.RefreshLoginAsync()` |
| Redis key | `{userId}:{sessionId}` TTL 720h |
| Sequence diagram | `diagrams/auth-token-refresh.mermaid` |

---

## REQ-AUTH-004 — Password Reset via Token URL

**The system shall support password reset through a time-limited, single-use encrypted token delivered via email link.**

### Rationale
The token URL approach (vs OTP code) does not require the user to manually type a code and works across email clients without JavaScript. The UUID is encrypted in the URL to prevent enumeration of token values.

### Acceptance Criteria

- [ ] **AC-AUTH-004-01**: Given a valid email address, when `POST /api/auth/request-password-recovery` is called, then a `PASSWORD_RECOVERY` email is sent containing a `?token=` URL.
- [ ] **AC-AUTH-004-02**: Given the `?token=` value from the email, when `POST /api/auth/reset-password { Token, NewPassword }` is called within 24 hours, then the password is changed and a `PASSWORD_RECOVERY_SUCCESS` email is sent.
- [ ] **AC-AUTH-004-03**: Given the same token used a second time, when `POST /api/auth/reset-password` is called, then the system returns HTTP 400 ("token already used").
- [ ] **AC-AUTH-004-04**: Given a token older than 24 hours, when `POST /api/auth/reset-password` is called, then the system returns HTTP 400 ("token expired").
- [ ] **AC-AUTH-004-05**: Given a tampered or invalid token, when `POST /api/auth/reset-password` is called, then `IStringEncryptionService.Decrypt` throws and the system returns HTTP 400.

### Business Rules
| Rule ID | Description |
|---|---|
| BR-AUTH-005 | Token = UUID, encrypted via `IStringEncryptionService.Encrypt`. Redis key: `PasswordReset:{rawToken}`. TTL: 24h. |
| BR-AUTH-006 | `IsUsed` is set to `true` immediately after successful reset — before confirmation email. |

### Implementation Traceability
| Artifact | Location |
|---|---|
| Request endpoint | `AuthController.RequestPasswordRecoveryAsync()` → `AuthAppService.RequestPasswordRecoveryAsync()` |
| Reset endpoint | `AuthController.ResetPasswordAsync()` → `AuthAppService.ResetPasswordAsync()` |
| Frontend page | `swt-cmn-web-app/src/app/(auth)/reset-password/` — reads `?token=` from URL |
| Sequence diagram | `diagrams/auth-password-reset.mermaid` |

---

## REQ-AUTH-005 — Logout Clears Redis Token

**The system shall delete the refresh token from Redis on logout, invalidating the session.**

### Acceptance Criteria

- [ ] **AC-AUTH-005-01**: Given a logged-in user, when `POST /api/auth/logout` is called with a valid JWT, then the Redis key `{userId}:{sessionId}` is deleted.
- [ ] **AC-AUTH-005-02**: Given a logged-out session (Redis key deleted), when `POST /api/auth/refresh-login` is called with the old refresh token, then the system returns 401 (token not found).

### Implementation Traceability
| Artifact | Location |
|---|---|
| App Service | `AuthAppService.LogoutAsync()` — extracts `userId` + `sessionId` from current JWT claims |
| Sequence diagram | `diagrams/auth-logout.mermaid` |

---

## REQ-AUTH-006 — Multi-Tenant Request Identification

**Every API request shall include an `X-Tenant` header identifying the tenant, which the system uses to scope all data operations.**

### Acceptance Criteria

- [ ] **AC-AUTH-006-01**: Given a request without `X-Tenant` header, when any tenant-scoped endpoint is called, then the system operates under no tenant context (ABP null-tenant behavior).
- [ ] **AC-AUTH-006-02**: Given `X-Tenant: itzone` header, when an employee list is requested, then only employees belonging to the `itzone` tenant are returned.
- [ ] **AC-AUTH-006-03**: Given `X-Tenant` set to a non-existent tenant, when any endpoint is called, then the system returns an appropriate error.

### Implementation Traceability
| Artifact | Location |
|---|---|
| Frontend injection | `@core/http` Axios interceptor — reads `tenantId` from `localStorage` |
| Mobile injection | Dio interceptor — reads from `get_storage` |
| ABP tenant resolution | ABP `ICurrentTenant` resolved from `X-Tenant` header by ABP framework |
