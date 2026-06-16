# Service Inventory

**Generated**: 2026-05-23
**Discovery method**: Full source scan (CLAUDE.md files, csproj, package.json, pubspec.yaml, appsettings, host modules, controllers)

---

## Service Registry

| # | Module Directory | Service Name | Type | Runtime | Port(s) | Status |
|---|---|---|---|---|---|---|
| 1 | `swt-cmn-administration-api/` | Administration API | Backend microservice | .NET 9 | HTTP: 8088, gRPC: 50051 | Active |
| 2 | `swt-cmn-customer-api/` | Customer Management API | Backend microservice | .NET 9 | HTTP: 44360, gRPC: 50052 | Active (stub) |
| 3 | `swt-cmn-web-gateway/` | Web Gateway | API gateway | .NET 9 | HTTP: varies | Active |
| 4 | `swt-cmn-administration-web-app/` | Administration Web App | Frontend SPA | Node.js (Vite) | Dev: varies | Active |
| 5 | `swt-cmn-web-app/` | Web App | Frontend SSR/SPA | Node.js (Next.js) | 4200 | Active |
| 6 | `swt-cmn-mobile-app/` | Mobile App (itzone) | Mobile app | Flutter | iOS + Android | Active |
| 7 | `swt-cmn-code-reviewer/` | GitHub PR Reviewer | Internal tool | .NET 9 | N/A | Internal tool |

---

## Service Details

### 1. Administration API (`swt-cmn-administration-api/`)

**Type**: ABP Framework microservice  
**Framework**: .NET 9 + ABP Framework  
**Ports**: HTTP `8088` (Http1AndHttp2), gRPC `50051` (Http2 only, TLS)  
**Route prefix**: `/cmn/administration-service/api`  
**Swagger**: `cmn/administration-service/swagger`  

**Solution structure**:
```
CMN.AdministrationService.HttpApi.Host/    ← Startup host
shared/
  CMN.Shared.CrossCuttingConcerns/         ← ApiResult<T>, base DTOs
  CMN.Shared.Hosting.AspNetCore/           ← CMNAbpExceptionFilter
  CMN.Shared.Hosting.Microservices/        ← AppControllerBase, JWT auth, gRPC client, Swagger
src/
  CMN.AdministrationService.Application/
  CMN.AdministrationService.Application.Contracts/
  CMN.AdministrationService.DbMigrator/
  CMN.AdministrationService.Domain/
  CMN.AdministrationService.Domain.Shared/
  CMN.AdministrationService.EntityFrameworkCore/  ← EF Core + MongoDB
  CMN.AdministrationService.HttpApi/
  CMN.AdministrationService.HttpApi.Client/
test/
  CMN.AdministrationService.*.Tests/        ← xUnit + Shouldly
skills/                                    ← AI skill files (code patterns)
```

**Controllers** (confirmed from source):
| Controller | Route | Methods |
|---|---|---|
| `AuthController` | `/cmn/administration-service/api/auth` | POST (login), POST refresh-login, POST request-password-recovery, POST reset-password, POST logout |
| `EmployeeController` | `/cmn/administration-service/api/employee` | GET list, POST, GET {id}, PUT {id}, GET import/template, POST import/validate, GET import/error-file/{sessionId}, POST import |
| `RoleController` | `/cmn/administration-service/api/role` | GET list, GET all, GET {id}, POST, PUT {id}, DELETE {id}, GET {id}/permissions, PUT {id}/permissions |
| `PermissionController` | `/cmn/administration-service/api/permissions` | GET |
| `MediaFileController` | `/cmn/administration-service/api/media-file` | POST upload, DELETE {id}, GET {id} |
| `IdentityUserController` | `/cmn/administration-service/api/users` | GET {id} (demo stub) |

**gRPC services** (confirmed from protos + host module):
| Service | Proto | Methods |
|---|---|---|
| `AdministrationServicePermissionGrpc` | `AdministrationServicePermission.proto` | `IsGrantedPermission`, `IsGrantedPermissions`, `TestPermission` |
| `AdministrationServiceMailTemplateGrpc` | `AdministrationServiceMailTemplate.proto` | `SendEmail` |

**Domain entities** (SQL Server, schema `ADM`):
- `Employee` — staff record with identity link, org, position, avatar, login state
- `OrganizationUnit` — hierarchical org tree (CodePath, NamePath)
- `Positions` — job positions linked to org unit
- `MediaFile` — Cloudinary file metadata

**MongoDB collections** (prefix `adm`):
- `MailTemplate` — email templates (Name, Code, Subject, Body)

**Domain events**: `SendOTPEvent`, `RecoveryPasswordEvent`, `PasswordResetSuccessEvent`  
**Cache keys**: `PasswordResetTokenCacheItem`, `PasswordResetTokenCacheKey` (Redis)  
**Data seeders**: `MailTemplateDataSeeder`, `OpenIddictDataSeedContributor`  

**Application services**:
- `AuthAppService` — login, refresh, logout, OTP, password recovery/reset
- `EmployeeAppService` + `EmployeeImportHelper` — employee CRUD + bulk import
- `RoleAppService` — ABP identity role management
- `PermissionAppService` — ABP permission queries
- `IdentityUserAppService` — identity user management (stub)
- `MediaFileAppService` — Cloudinary upload/delete/get
- `MailTemplateAppService` — MongoDB mail template CRUD

**DBContext**: `AdministrationServiceDbContext` replaces `IIdentityDbContext` + `ITenantManagementDbContext`  
(stores ABP Identity, Tenants, Background Jobs, Audit Logs, Permissions, Settings, Blob, Features + domain entities)

**EF Core migrations**: 4 migrations starting 2025-11-08, latest `20251115061328_Init_20251115`

---

### 2. Customer Management API (`swt-cmn-customer-api/`)

**Type**: ABP Framework microservice  
**Framework**: .NET 9 + ABP Framework  
**Ports**: HTTP `44360` (Http1AndHttp2), gRPC `50052` (Http2 only, TLS)  
**Route prefix**: `/cmn/customer-management/api`  
**Swagger**: `cmn/customer-management/swagger`  

**Solution structure**:
```
CMN.CustomerManagement.HttpApi.Host/   ← Startup host
shared/
  CMN.Shared.*                         ← Same shared libs as admin (copies)
src/
  CMN.CustomerManagement.Application/
  CMN.CustomerManagement.Application.Contracts/
  CMN.CustomerManagement.DbMigrator/
  CMN.CustomerManagement.Domain/
  CMN.CustomerManagement.Domain.Shared/
  CMN.CustomerManagement.EntityFrameworkCore/  ← EF Core + MongoDB stub
  CMN.CustomerManagement.HttpApi/
  CMN.CustomerManagement.HttpApi.Client/
test/
skills/
```

**Controllers** (confirmed):
| Controller | Route | Methods |
|---|---|---|
| `PartyController` | `/cmn/customer-management/api/party` | GET {id} (demo stub) |

**gRPC client** (consumes Administration API):
- `AdministrationServicePermissionGrpc` client — generated Protobuf client for permission checks

**Domain entities** (SQL Server, schema `CM`):
- `Party` — stub entity (only `TenantId` field)

**MongoDB**: Module present but not configured — `MongoDbConnectionStringName = ""` (empty). No collections defined. [STUB]

**EF Core migrations**: None found (schema not migrated yet) [STUB]

**Application services**: None beyond base module (no `PartyAppService` found)

---

### 3. Web Gateway (`swt-cmn-web-gateway/`)

**Type**: YARP reverse proxy  
**Framework**: .NET 9 + YARP  
**Solution**: `CMN.WebGateWay.slnx`  

**Structure**:
```
CMN.WebGateWay/          ← Gateway project
shared/
  CMN.Shared.ServiceDefaults/   ← Aspire service defaults
```

**YARP routes** (from `appsettings.Development.json`):
| Route ID | Path Pattern | Cluster | Destination |
|---|---|---|---|
| `cmn-administration` | `/cmn/administration-service/{**catch-all}` | `administration-service` | `http://localhost:8088` |
| `cmn-customer-management` | `/cmn/customer-management/{**catch-all}` | `customer-management` | `http://localhost:44360` |

**Swagger aggregation**: Combines OpenAPI specs from both services at `/cmn/swagger`

---

### 4. Administration Web App (`swt-cmn-administration-web-app/`)

**Type**: Admin panel SPA  
**Framework**: Vite 7 + React 19 + TypeScript 5.9  
**Base URL**: All protected routes under `/administration`  
**Base API URL**: `VITE_API_URL` env var  

**Source structure**:
```
src/
  @core/        ← Shared infrastructure (HTTP, components, hooks, utils, consts)
  assets/
  layouts/      ← App chrome (header, sidebar)
  pages/
    auth/       ← Public routes (login)
    (protected)/  ← Protected routes (requires auth)
      organization/
      permission/
      roles/
      users/
  services/
    administration-service/   ← API call layer
      auth/, employee/, masterdata/, permission/, role/
  store/
    administration-service/   ← Redux slices + thunks
    customer-management/      ← (future)
  themes/
```

**Protected pages** (confirmed):
- `/administration/organization` — Organization unit management
- `/administration/permission` — Permission management
- `/administration/roles` — Role management (with RoleCreateModal, RoleUpdateModal)
- `/administration/users` — User management

---

### 5. Main Web App (`swt-cmn-web-app/`)

**Type**: Web application (SSR + SPA)  
**Framework**: Next.js 16 + React 19  
**Port**: 4200  
**Base API URL**: env var  

**Source structure**:
```
src/
  @core/       ← Shared infrastructure
  app/
    layout.tsx
    page.tsx   ← Root
    (auth)/
      signin/
      reset-password/
    (landingpage)/
      home/
    (protected)/
      employee/       ← Employee list + detail with tabs
        [id]/         ← Employee detail (Attendance, Detail, Duty, Fix tabs)
      instructions/
      party/
  enums/
  layouts/
  services/
    administration-service/   auth/, employee/, masterdata/
    customer-management/      masterdata/, party/
  stores/
    administration-service/
    customer-management/
  themes/
```

---

### 6. Mobile App — itzone (`swt-cmn-mobile-app/`)

**Type**: Mobile application  
**Framework**: Flutter 3.5+ (Dart)  
**App name**: itzone  
**Platforms**: iOS, Android (also macos, linux, windows, web configs present)  

**lib structure**:
```
lib/
  main.dart
  common/     ← Shared utilities
  data/
    common/   ← Shared data models
    database/ ← Local SQLite (itzone.db)
    models/   ← Freezed data models
  features/
    home/
    login/
    otp/
    selfie/
    splash/
  gen/        ← Generated assets/localization
  routes/     ← go_router config (splash, login, home, selfie, otp)
  services/
  utils/
  widgets/
```

**Routes** (confirmed from `app_routes.dart`):
| Route | Screen |
|---|---|
| `/` (splash) | `Splash` |
| `/login` | `LoginPage` |
| `/home` | `HomePage` |
| `/selfie` | `SelfiePage` |
| `/otp` | `OtpScreen` |

**Local DB**: SQLite via `drift` or similar, DB name `itzone.db`  
**Default credentials** (dev): username `admin`, password `admin`  

---

### 7. GitHub PR Reviewer (`swt-cmn-code-reviewer/`)

**Type**: Internal developer tool  
**Framework**: .NET 9 console + Blazor UI  
**Purpose**: Automated code review for GitHub pull requests  
**Dockerized**: Yes (separate Dockerfile for API + UI)  
**Status**: Internal-only, not part of production system  

**Components**:
- `GitHubPRReviewer/` — .NET API console app (Controllers, Models, Services, Skills)
- `GitHubPRReviewerUI/` — Blazor web UI

---

## Key Cross-Cutting Facts

| Fact | Confirmed Source |
|---|---|
| Multi-tenancy discriminator: `X-Tenant` header | Both host modules |
| JWT custom auth (NOT OpenIddict) | `appsettings.Development.json` — `AuthenticationJwtBearer` section |
| JWT issuer/audience: "ZS" | `appsettings.Development.json` |
| Token expiry: 1h access, 720h refresh | `appsettings.Development.json` |
| Tokens stored in cookies (frontend) | `@core/http/index.ts` |
| X-Tenant from localStorage (frontend) | `@core/http/index.ts` |
| ABP Auditing disabled | Both host modules |
| Redis enabled | `appsettings.Development.json` |
| Languages: Vietnamese (default) + English | Admin host module, HTTP client |
| One seeded tenant: `itzone` | `appsettings.Development.json` |
| OTP disabled in dev (default: 123456) | `appsettings.Development.json` |
