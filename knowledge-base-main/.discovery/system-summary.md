# System Summary

**Generated**: 2026-05-23
**Discovery session**: Full Phase 0 workspace scan
**Confidence**: High for confirmed items; [INFERRED] marked for unverified assumptions

---

## What This System Is

**CMN** (Central Management Node) is a multi-tenant SaaS platform built as a microservices monorepo. It provides:

1. **Administration management** — employee records, org hierarchy, roles, permissions, media files, mail templates
2. **Customer management** — customer/party data (in early development/stub state)
3. **Web portal** — admin panel (React) and customer-facing portal (Next.js)
4. **Mobile app** — employee-facing mobile app (Flutter, branded "itzone")

The system is Vietnamese-first (default locale `vi`, error messages in Vietnamese) and serves tenants identified by the `itzone` brand.

---

## System Scale & Maturity

| Dimension | Status |
|---|---|
| Administration API | Active, 4 EF Core migrations, full CRUD, bulk import, gRPC server |
| Customer API | Stub — 1 entity (Party), no migrations, no app services, gRPC client present |
| Web Gateway | Active, YARP routing for 2 services |
| Admin Web App | Active, 4 pages (org, permission, roles, users) |
| Main Web App | Active, employee + party + auth flows |
| Mobile App | Active, 5 screens (splash, login, OTP, home, selfie) |
| Code Reviewer | Internal tool, separate |

---

## Architecture Pattern

**Pattern**: Microservices monorepo with per-service DDD layering  
**Backend**: ABP Framework on .NET 9 (layered DDD)  
**Frontend**: React SPA (admin) + Next.js (web) + Flutter (mobile)  
**Gateway**: YARP reverse proxy (single entry point for HTTP)  
**Inter-service**: gRPC (Customer → Administration for permissions)  
**Auth**: Custom JWT Bearer (NOT OpenIddict — was planned, then commented out)  
**Multi-tenancy**: Header-based (`X-Tenant`) with ABP tenant resolution  
**Data**: Per-service database schemas (ADM, CM) on shared SQL Server instance + shared MongoDB + Redis  

---

## Key Architectural Decisions

### 1. Custom JWT Authentication (Not OpenIddict)

OpenIddict was planned (ABP module references and data seed contributor present) but commented out in both host modules. The system uses a custom `AuthenticationJwtBearer` implementation:

- Tokens issued by Administration API's `AuthAppService`
- Same security key shared across all backend services
- Standard JWT Bearer validation in all services
- Token expiry: 1h access / 720h (30-day) refresh

**Implication**: No OAuth2 authorization code flow, no OIDC discovery endpoint. All auth is username/password → custom JWT.

### 2. Shared SQL Server Instance

Both Administration and Customer APIs connect to the same SQL Server database (`SWTCMN`) but use different schemas (`ADM` vs `CM`). This simplifies local dev but is a coupling risk for production scale-out.

### 3. MongoDB for Email Templates Only

MongoDB is used exclusively for `MailTemplate` documents in the Administration API. Customer API has the module wired but completely unconfigured. This is likely scaffolding for future use.

### 4. Physical Library Copies

Shared infrastructure libraries (`CrossCuttingConcerns`, `Hosting.AspNetCore`, `Hosting.Microservices`) are physically duplicated in each service rather than published as NuGet packages. Changes must be manually synchronized.

### 5. ABP Framework as Foundation

ABP provides: Identity management (users, roles, claims), permission management, tenant management, background jobs, settings, audit logs, blob storage, feature management, EF Core integration. All via module composition.

---

## Request Flow (Summary)

### Authenticated HTTP Request
```
Client → YARP Gateway → Service API → Controller (AppControllerBase)
       → AppService (business logic) → Repository (IRepository<T>)
       → EF Core → SQL Server (schema: ADM or CM)
       ← ApiResult<TData> JSON response
```

### Auth Request
```
Client → /cmn/administration-service/api/auth [POST]
       → AuthController [AllowAnonymous] → AuthAppService.LoginAsync
       → ABP IdentityUser lookup + password validation
       → Generate JWT (custom, issuer "ZS")
       ← { accessToken, refreshToken, expiration }
```

### Permission-Gated Request (Customer → Administration)
```
Customer API AppService → gRPC client → AdministrationServicePermissionGrpc
       → Administration API :50051 → IsGrantedPermission(PermissionName)
       ← { IsGranted: bool }
```

### Email Sending
```
[Event or direct call] → AdministrationServiceMailTemplateGrpc.SendEmail
       → MailTemplateAppService → MongoDB (load template by code)
       → Render template with MailData
       → MailKit → Gmail SMTP → recipient
```

---

## Known Gaps (Unverified Items)

These were not confirmed during Phase 0 discovery:

| Item | Confidence | Where to verify |
|---|---|---|
| Hangfire — Customer API has it in CLAUDE.md stack but not in host module | Likely NOT present (ABP Background Jobs used instead) | Check Customer API Application module |
| OpenIddict — is the data seed contributor active? | Probably disabled (module commented out) | `OpenIddictDataSeedContributor.cs` |
| gRPC client registration in Customer API Application module | Unverified — how is gRPC channel registered? | `CustomerManagementApplicationModule.cs` |
| JWT storage in admin web app: cookie vs localStorage | Confirmed cookies for tokens; X-Tenant in localStorage | `@core/http/index.ts` — CONFIRMED |
| Mobile app `BASE_URL` in dev: empty | Confirmed empty in `.env` | `.env` — CONFIRMED |
| Customer API Redis: configured but used? | Unverified — key is in config but no cache keys found | Customer Domain/Application |
| Health check path in Customer API | `/health` [INFERRED from same pattern as Admin] | `HealthChecks/` files |
| MailTemplate entity NOT implementing IMultiTenant | Confirmed — `// IMultiTenant` is commented out | `MailTemplate.cs` entity |
| ABP `OrganizationUnit` vs custom `OrganizationUnit` | Both exist: ABP's and custom Entities.OrganizationUnit | DbContext shows both in different DbSets |
| sonar-project.properties in mobile/web-app — is SonarQube actually wired to CI? | Cannot confirm — no CI YAML found | .github/ — no workflow files found |

---

## Namespace Defect Note

Two files in the Administration API use incorrect namespaces (likely copy-paste from Customer API template):

1. `AdministrationServiceMongoDbContext.cs` → namespace `CMN.CustomerManagement.MongoDb` (should be `CMN.AdministrationService.MongoDb`)
2. `HealthChecksBuilderExtensions.cs` → namespace `CMN.CustomerManagement.HealthChecks` (should be `CMN.AdministrationService.HealthChecks`)

These do not affect runtime behavior but indicate copy-paste tech debt.

---

## Production Readiness Indicators

| Aspect | Status |
|---|---|
| Auth | Custom JWT — functional but not OAuth2/OIDC standard |
| Database | Shared SQL Server instance (single point of failure) |
| CI/CD | Not detected (no GitHub Actions workflows) |
| Docker | Dockerfiles present per service; no Compose or Kubernetes |
| Health checks | Implemented (`/health`) |
| Logging | Serilog configured |
| Monitoring | Firebase (mobile); SonarQube referenced; no APM found for backend |
| Secrets | `appsettings.secrets.json` pattern (git-ignored) — dev credentials in `appsettings.Development.json` |
| Multi-tenancy | Functional via X-Tenant header |
| Localization | Vietnamese + English supported |
| Migrations | Administration API: 4 migrations; Customer API: none |

---

## Monorepo Quick Reference

| Module | Type | Port(s) | Route | DB Schema |
|---|---|---|---|---|
| `swt-cmn-administration-api` | .NET 9 + ABP | 8088 / gRPC 50051 | `/cmn/administration-service/api` | ADM |
| `swt-cmn-customer-api` | .NET 9 + ABP | 44360 / gRPC 50052 | `/cmn/customer-management/api` | CM |
| `swt-cmn-web-gateway` | .NET 9 + YARP | varies | `/cmn/swagger` | — |
| `swt-cmn-administration-web-app` | Vite + React 19 | dev:varies | `/administration/*` | — |
| `swt-cmn-web-app` | Next.js 16 | 4200 | App Router | — |
| `swt-cmn-mobile-app` | Flutter (itzone) | N/A | go_router | local SQLite |
| `swt-cmn-code-reviewer` | .NET 9 console | N/A | Internal tool | — |
