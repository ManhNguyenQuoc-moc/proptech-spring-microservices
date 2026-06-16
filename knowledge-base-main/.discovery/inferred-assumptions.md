# Inferred Assumptions

Items here are NOT directly confirmed in code. They are inferences from patterns, naming, or partial evidence. **Verify before acting on these.**

---

## Authentication

- ~~`[INFERRED]`~~ **DISPROVED** — OpenIddict is NOT used. `AdministrationServiceHttpApiHostModule.cs` confirms all OpenIddict module registrations are commented out. The system uses a custom `AuthenticationJwtBearerHandler` (HMAC-SHA256 symmetric JWT). `OpenIddictDataSeedContributor.cs` exists but is not active. *(Verified 2026-05-23)*

- ~~`[INFERRED]`~~ **CONFIRMED** — `AuthenticationJwtBearerHandler.ConfigureAuthenticationJwtBearer()` reads `AuthenticationJwtBearer:SecurityKey/Issuer/Audience` from config. Does NOT extract tenant claims — tenant comes from `X-Tenant` header separately. *(Verified 2026-05-23)*

- ~~`[INFERRED]`~~ **CONFIRMED** — `PermissionsAuthorizeAttribute` is a `TypeFilterAttribute` wrapping `IPermissionChecker`. Returns 401 on missing claims, 403 on permission denied. Currently all usages are commented out on controller actions. *(Verified 2026-05-23)*

- ~~`[INFERRED]`~~ **CONFIRMED** — Login uses `Employee.Code` as username (NOT email). `AuthAppService.LoginAsync` queries `Employee` table by `Code`, then looks up `IdentityUser` by `Employee.UserId`. *(Verified 2026-05-23)*

- ~~`[INFERRED]`~~ **CONFIRMED** — Password reset is a token URL flow (NOT OTP). UUID token is encrypted with `IStringEncryptionService`, stored in Redis (24h TTL), and sent as a URL query param. No 6-digit OTP involved in password reset. *(Verified 2026-05-23)*

- ~~`[INFERRED]`~~ **CONFIRMED** — `SendOTPEvent` / `SendOTPEventHandler` exists for 2FA during login, but the 2FA call in `LoginAsync` is commented out. 2FA is not active. *(Verified 2026-05-23)*

- ~~`[INFERRED]`~~ **CONFIRMED** — Frontend stores `accessToken` and `refreshToken` in **cookies** (not localStorage). Tenant ID stored in **localStorage**. Confirmed from `@core/http/index.ts`. *(Verified 2026-05-23)*

## Customer Service

- ~~`[INFERRED]`~~ **CONFIRMED** — The `Party` entity is a stub — it contains only `TenantId` with no domain fields. Customer management is nascent. *(Verified 2026-05-23)*

- `[INFERRED]` Customer service calls Administration Service via gRPC for permission checking.
  - Evidence: Generated gRPC client protos exist in customer-api's Application obj directory; `CustomerManagementHttpApiHostModule.cs` reads gRPC config from `RemoteServices`.
  - Remaining gap: Exact call sites in Customer API Application layer not yet found.

## Redis

- ~~`[INFERRED]`~~ **CONFIRMED** — Redis is enabled in `appsettings.Development.json` (`Redis:IsEnabled: true`, `Redis:Configuration: "localhost:6379,defaultDatabase=0"`). *(Verified 2026-05-23)*

- ~~`[INFERRED]`~~ **CONFIRMED** — Redis cache keys in Administration Service:
  - `PasswordReset:{rawToken}` — password reset token, TTL 24h
  - `{userId}:{sessionId}` — refresh token per session, TTL 720h
  - `import_employee_{sessionId}` — import session, TTL 30 min
  - `{tenantId}:login-ip:{clientIP}` — failed login counter, TTL 30 min
  - `{tenantId}:blocked-ip:{clientIP}` — IP block flag, TTL 5 min
  *(Verified 2026-05-23)*

## Hangfire

- ~~`[INFERRED]`~~ **DISPROVED** — Hangfire is NOT registered in `CustomerManagementHttpApiHostModule.cs`. The CLAUDE.md stack description was incorrect. The Administration API uses ABP Background Jobs (`Volo.Abp.BackgroundJobs.EntityFrameworkCore`). No Hangfire dependency found in either service. *(Verified 2026-05-23)*

## Employee Import

- ~~`[INFERRED]`~~ **CONFIRMED** — Employee import is a 2-step process: Step 1 = Validate (parse, validate rows, generate error file, store session in Redis 30min); Step 2 = Execute (read session, create employees in batch). *(Verified 2026-05-23)*

- ~~`[INFERRED]`~~ **CONFIRMED** — Import constraints: max 5MB file, max 100 data rows, formats `.xlsx/.xls/.csv`. Student email generated as `{StudentCode}@student.edu.vn` during import. *(Verified 2026-05-23)*

## Mail Templates

- ~~`[INFERRED]`~~ **CONFIRMED** — Mail templates are managed in Administration Service (MongoDB) and exposed to Customer API via gRPC (`SendEmail` method). `MailTemplateAppService.SendEmailAsync()` resolves template by Code, replaces `##Group.Field##` placeholders, sends via `IEmailSender` (MailKit/SMTP). *(Verified 2026-05-23)*

- ~~`[INFERRED]`~~ **CONFIRMED** — Known template codes: `SEND_OTP` (2FA), `PASSWORD_RECOVERY` (reset link), `PASSWORD_RECOVERY_SUCCESS` (confirmation). *(Verified 2026-05-23)*

## Cloudinary

- ~~`[INFERRED]`~~ **CONFIRMED** — Cloudinary folder: `CMN/{tenantId}/`. PublicId: `{tenantId}_{fileId}`. Tags: `tenant-{tenantId},file-{fileId}`. Max batch 100MB. Soft-delete only (physical Cloudinary deletion commented out). *(Verified 2026-05-23)*

## Mobile App

- `[INFERRED]` The mobile app communicates with services through the Web Gateway (not directly to backends).
  - Evidence: `BASE_URL` in `.env` is empty string; no direct backend URL patterns found.
  - Remaining gap: `.env.dev` and `.env.production` not read — URL for non-local environments unknown.

## Frontend Auth Flow

- ~~`[INFERRED]`~~ **CONFIRMED** — The admin web app auth service calls `POST /cmn/administration-service/api/auth` for login, `POST .../auth/refresh-login` for token refresh, `POST .../auth/logout` for logout. NOT an OpenIddict endpoint. *(Verified 2026-05-23)*
