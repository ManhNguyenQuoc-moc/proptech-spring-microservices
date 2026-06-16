# Dependency Graph

**Generated**: 2026-05-23
**Source**: Solution files, csproj DependsOn, host module DependsOn attributes, import analysis

---

## Service-Level Dependencies

```
                    ┌────────────────────────────────────────────────┐
                    │              EXTERNAL SERVICES                  │
                    │  SQL Server   MongoDB   Redis   Cloudinary      │
                    │  Gmail SMTP   Firebase  Google APIs   GitHub    │
                    └──────┬──────────┬────────┬─────────────────────┘
                           │          │        │
         ┌─────────────────▼──────────▼────────▼──────────────────┐
         │           Administration API (:8088 / gRPC :50051)       │
         │  SQL(ADM) + MongoDB(MailTemplate) + Redis + Cloudinary   │
         │  + MailKit/SMTP                                          │
         └──────────────────────────────┬──────────────────────────┘
                                        │ gRPC (IsGrantedPermission
                                        │       SendEmail)
                    ┌───────────────────▼──────────────────────────┐
                    │     Customer Management API (:44360 / gRPC :50052) │
                    │     SQL(CM) + MongoDB(stub) + Redis(config)    │
                    └──────────────────────────────────────────────┘
                                        ▲
                                        │ YARP proxy
         ┌──────────────────────────────┤
         │       Web Gateway             │
         │  routes → :8088 / :44360     │
         └──────────────────────────────┘
                    ▲
                    │ HTTPS
         ┌──────────┴─────────────────┐
         │                            │
    Admin Web App               Main Web App (:4200)
    (Vite/React)                (Next.js)
                    ▲
                    │ HTTPS (direct to Gateway)
             Mobile App (Flutter / itzone)
```

---

## .NET Project Layer Dependencies

### Administration API — Project Graph

```
CMN.AdministrationService.HttpApi.Host
  ├── CMN.AdministrationService.HttpApi
  │     └── CMN.AdministrationService.Application.Contracts
  │           └── CMN.AdministrationService.Domain.Shared
  ├── CMN.AdministrationService.Application
  │     ├── CMN.AdministrationService.Application.Contracts
  │     └── CMN.AdministrationService.Domain
  │           ├── CMN.AdministrationService.Domain.Shared
  │           └── (ABP Identity, Tenant, Permission modules)
  ├── CMN.AdministrationService.EntityFrameworkCore
  │     └── CMN.AdministrationService.Domain
  ├── CMN.Shared.Hosting.Microservices  ← AppControllerBase, JWT, gRPC, Swagger
  │     └── CMN.Shared.Hosting.AspNetCore  ← CMNAbpExceptionFilter
  │           └── CMN.Shared.CrossCuttingConcerns  ← ApiResult<T>
  └── (ABP Framework modules: Identity, MultiTenancy, Serilog, Swagger, etc.)
```

### Customer API — Project Graph (same pattern)

```
CMN.CustomerManagement.HttpApi.Host
  ├── CMN.CustomerManagement.HttpApi
  │     └── CMN.CustomerManagement.Application.Contracts
  │           └── CMN.CustomerManagement.Domain.Shared
  ├── CMN.CustomerManagement.Application
  │     ├── CMN.CustomerManagement.Application.Contracts
  │     └── CMN.CustomerManagement.Domain
  ├── CMN.CustomerManagement.EntityFrameworkCore
  ├── CMN.Shared.Hosting.Microservices  ← Same shared infra
  │     └── CMN.Shared.Hosting.AspNetCore
  │           └── CMN.Shared.CrossCuttingConcerns
  └── (Administration API gRPC client — generated from proto)
```

### Web Gateway — Project Graph

```
CMN.WebGateWay
  └── CMN.Shared.ServiceDefaults  ← Aspire defaults (health, observability)
```

---

## ABP Module Dependency Tree (Administration API Host)

```
AdministrationServiceHttpApiHostModule
  ├── AdministrationServiceHttpApiModule
  ├── AbpAspNetCoreMvcModule
  ├── AbpAutofacModule
  ├── AbpAspNetCoreMultiTenancyModule
  ├── AdministrationServiceApplicationModule
  │     └── AdministrationServiceApplicationContractsModule
  │           └── AdministrationServiceDomainSharedModule
  ├── AdministrationServiceEntityFrameworkCoreModule
  │     └── AdministrationServiceDomainModule
  │           ├── AbpIdentityModule (full ABP Identity)
  │           ├── AbpTenantManagementModule
  │           ├── AbpPermissionManagementModule
  │           ├── AbpSettingManagementModule
  │           ├── AbpBackgroundJobsModule (SQL-backed)
  │           ├── AbpAuditLoggingModule
  │           ├── AbpFeatureManagementModule
  │           └── AbpBlobStoringModule
  ├── AdministrationServiceMongoDbModule
  ├── AbpSwashbuckleModule
  ├── AbpAspNetCoreSerilogModule
  ├── CMNSharedHostingMicroservicesModule
  ├── AbpEmailingModule
  └── AbpMailKitModule
```

---

## Frontend Layer Import Graph

### Administration Web App

```
pages/
  └── imports → store/ (async thunks for data) + @core/ (components, hooks) + services/ (directly for mutations)
store/
  └── imports → services/ (via thunks)
services/
  └── imports → @core/http (axios instance)
@core/http
  └── imports → (axios, qs, cookie utils, auth service for token refresh)
layouts/
  └── imports → @core/ (navigation hooks, auth state)
```

**Import direction**: `pages → store → services → @core/http`  
**Forbidden**: services must NOT import from store or pages

### Main Web App (same pattern)

```
app/ (pages)
  └── imports → stores/ + services/ + @core/
stores/
  └── imports → services/
services/
  └── imports → @core/http
```

---

## Shared Library Dependency Across Services

Both `swt-cmn-administration-api` and `swt-cmn-customer-api` include **physical copies** of the same shared libraries. There is no NuGet package feed — code is duplicated:

| Shared Project | Copy in Administration | Copy in Customer |
|---|---|---|
| `CMN.Shared.CrossCuttingConcerns` | `shared/CMN.Shared.CrossCuttingConcerns/` | `shared/CMN.Shared.CrossCuttingConcerns/` |
| `CMN.Shared.Hosting.AspNetCore` | `shared/CMN.Shared.Hosting.AspNetCore/` | `shared/CMN.Shared.Hosting.AspNetCore/` |
| `CMN.Shared.Hosting.Microservices` | `shared/CMN.Shared.Hosting.Microservices/` | `shared/CMN.Shared.Hosting.Microservices/` |

**Risk**: Changes to shared code must be manually synchronized between services.

---

## Cross-Service Contract Dependencies

| Contract | Format | Owner | Consumer |
|---|---|---|---|
| `AdministrationServicePermission.proto` | Protobuf | Administration API | Customer API |
| `AdministrationServiceMailTemplate.proto` | Protobuf | Administration API | (future consumers) |
| `shared.proto` | Protobuf | Administration API | Customer API |
| `ApiResult<T>` response envelope | C# class | Shared lib | All frontend clients |
| `X-Tenant` header | HTTP header convention | ABP MultiTenancy config | All frontends → backends |
| JWT `SecurityKey` | Shared secret | Administration API | Customer API (same key = tokens cross-validate) |

---

## Dependency Risk Analysis

| Risk | Affected Services | Severity |
|---|---|---|
| Shared SQL Server instance | Administration API + Customer API | HIGH — single point of failure in dev |
| Shared MongoDB instance | Administration API | MEDIUM |
| Shared Redis instance | Administration API | MEDIUM |
| Shared JWT secret key | Administration + Customer APIs | MEDIUM — token forged for one service works on both |
| Physical copy of shared libs | Administration + Customer APIs | MEDIUM — sync drift risk |
| Customer API → Administration API gRPC | Customer API | HIGH — Customer API breaks if Administration API is down |
| Empty `BASE_URL` in mobile `.env` | Mobile App | MEDIUM — app cannot call backend in dev without config |
| MongoDB `MongoDbConnectionStringName = ""` | Customer API | LOW — no MongoDB usage yet |

---

## Namespace Conventions (Dependency Discovery Aid)

| Layer | Administration API | Customer API |
|---|---|---|
| Controller | `CMN.AdministrationService.Controllers.{Feature}` | `CMN.CustomerManagement.Controllers` |
| App service interface | `CMN.AdministrationService.{Feature}` | `CMN.CustomerManagement.{Feature}` |
| App service impl | `CMN.AdministrationService` | `CMN.CustomerManagement` |
| Input DTOs | `CMN.AdministrationService.{Feature}.Dtos.Input` | `CMN.CustomerManagement.{Feature}.Dtos.Input` |
| Output DTOs | `CMN.AdministrationService.{Feature}.Dtos.Output` | `CMN.CustomerManagement.{Feature}.Dtos.Output` |
| Domain entity | `CMN.AdministrationService.Entities` | `CMN.CustomerManagement.Entities` |
| Domain entity (MongoDB) | `CMN.AdministrationService.Entities.Mongo` | — |
| Domain event | `CMN.AdministrationService.Events` | `CMN.CustomerManagement.Events` |
| Consts (Domain.Shared) | `CMN.AdministrationService` | `CMN.CustomerManagement` |
| EF DbContext | `CMN.AdministrationService.EntityFrameworkCore` | `CMN.CustomerManagement.EntityFrameworkCore` |
| MongoDB context | `CMN.CustomerManagement.MongoDb` (⚠️ wrong namespace — code defect) | `CMN.CustomerManagement.MongoDb` |
| gRPC server | `CMN.AdministrationService.Grpc` | — |
| gRPC client | — | Protobuf generated namespace |

> ⚠️ **Namespace defect**: `AdministrationServiceMongoDbContext` and `HealthChecksBuilderExtensions` in Administration API use the namespace `CMN.CustomerManagement.MongoDb` and `CMN.CustomerManagement.HealthChecks` respectively — this appears to be a copy-paste error from the Customer API template. Does NOT affect runtime (namespace ≠ assembly), but causes confusion.
