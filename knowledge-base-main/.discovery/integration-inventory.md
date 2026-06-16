# Integration Inventory

**Generated**: 2026-05-23
**Source**: Host module registrations, appsettings.Development.json, package.json, pubspec.yaml, proto files

---

## Integration Summary

| Integration | Direction | Protocol | Confirmed | Service(s) |
|---|---|---|---|---|
| SQL Server | Outbound | TCP/TDS | ✅ | Administration API, Customer API |
| MongoDB | Outbound | TCP | ✅ | Administration API (active), Customer API (stub) |
| Redis | Outbound | TCP | ✅ | Administration API |
| Cloudinary | Outbound | HTTPS REST | ✅ | Administration API |
| Gmail SMTP | Outbound | SMTP TLS | ✅ | Administration API |
| Customer API gRPC | Inbound (from Customer) | gRPC/HTTP2 TLS | ✅ | Administration API (server) |
| Administration API gRPC | Outbound | gRPC/HTTP2 TLS | ✅ | Customer API (client) |
| Firebase (FCM) | Outbound | HTTPS | ✅ | Mobile App |
| Firebase Crashlytics | Outbound | HTTPS | ✅ | Mobile App |
| Firebase Analytics | Outbound | HTTPS | ✅ | Mobile App |
| Firebase Performance | Outbound | HTTPS | ✅ | Mobile App |
| Google Sign-In | Outbound | OAuth2/HTTPS | ✅ | Mobile App |
| Google Maps | Outbound | HTTPS | ✅ | Mobile App |
| GitHub API | Outbound | REST/HTTPS | ✅ | Code Reviewer (internal tool) |
| OpenIddict | — | — | ❌ REMOVED | Code commented out |

---

## Detailed Integration Specs

### 1. SQL Server

**Type**: Primary relational database  
**Provider**: Microsoft SQL Server  
**Host (dev)**: `100.69.37.126:1433`  
**Database**: `SWTCMN`  
**Auth**: SQL login (`sa` / `MyPassword123.` in dev)  
**Connection options**: `TrustServerCertificate=True; MultipleActiveResultSets=true`  
**Config key**: `ConnectionStrings:Default`  

| Service | Schema | Entities |
|---|---|---|
| Administration API | `ADM` | Employee, OrganizationUnit, Positions, MediaFile + ABP Identity, Tenants, Permissions, Settings, Background Jobs, Audit Logs, Blob, Features |
| Customer API | `CM` | Party (stub — no migrations yet) |

**EF Core migrations**:
- Administration API: 4 migrations (2025-11-08 to 2025-11-15)
- Customer API: no migrations found [STUB]

---

### 2. MongoDB

**Type**: Document store  
**Host (dev)**: `100.69.37.126:27017`  
**Database**: `swt_cmn`  
**Auth source**: `swt_cmn`  
**Config key**: `ConnectionStrings:MongoDb`  
**ABP module**: `Volo.Abp.MongoDB`  

| Service | Collection Prefix | Collections |
|---|---|---|
| Administration API | `adm` | `MailTemplate` (Name, Code, Subject, Body, Description) |
| Customer API | `""` (empty) | None — stub module, not configured |

**Custom repo**: `IMailTemplateRepository` / `MailTemplateRepository` (MongoDB implementation)

---

### 3. Redis

**Type**: Distributed cache  
**Host (dev)**: `localhost:6379`  
**Default database**: 0  
**Config key**: `Redis:Configuration`  
**Enabled flag**: `Redis:IsEnabled: true`  
**ABP module**: `Volo.Abp.Caching.StackExchangeRedis`  

**Used for**: Password reset token cache  
**Cache key type**: `PasswordResetTokenCacheKey`  
**Cache item**: `PasswordResetTokenCacheItem` — `{ UserId, Email, Token, ExpirationTime, IsUsed }`  
**OTP config**: `OTP:Expiration: 300` seconds (5 minutes)

---

### 4. Cloudinary

**Type**: Cloud media storage  
**Protocol**: HTTPS REST API  
**SDK**: `CloudinaryDotNet`  
**Config keys**: `CloudinarySettings:CloudName`, `ApiKey`, `ApiSecret`  

**Used by**: Administration API (`MediaFileAppService`)  
**Operations**: Upload file, Delete file by PublicId  
**Stored metadata** (in SQL Server ADM schema):
- `SecureUrl`, `PublicId`, `AssetId`, `Format`, `Size`

**API surface**:
- `POST /cmn/administration-service/api/media-file/upload` — upload one or more files
- `DELETE /cmn/administration-service/api/media-file/{id}` — delete file
- `GET /cmn/administration-service/api/media-file/{id}` — get file metadata

---

### 5. Gmail SMTP

**Type**: Email delivery  
**Protocol**: SMTP + TLS  
**SDK**: `MailKit` + `Volo.Abp.MailKit`  
**Host**: `smtp.gmail.com:587`  
**TLS mode**: `SecureSocketOptions.Auto`  

**Config** (via ABP Settings stored in DB):
- `Abp.Mailing.Smtp.Host` = smtp.gmail.com
- `Abp.Mailing.Smtp.Port` = 587
- `Abp.Mailing.Smtp.EnableSsl` = true
- `Abp.Mailing.Smtp.UserName` / `Password` — credentials in secrets
- `Abp.Mailing.DefaultFromAddress` = swtcmn.noreply@gmail.com
- `Abp.Mailing.DefaultFromDisplayName` = [Dev] - SWTCMN

**Dev testing mode**:
- `Abp.Mailing.IsTesting: true`
- All emails redirected to: `tadat290903@gmail.com`

**Email template system**: Templates stored in MongoDB `MailTemplate` collection; rendered server-side with dynamic `MailData` (key-value map) via gRPC `SendEmail` RPC.

---

### 6. gRPC — Administration API (Server)

**Protocol**: gRPC over HTTP/2 + TLS  
**Bind address**: `https://*:50051`  
**Reflection**: enabled (`MapGrpcReflectionService`)  
**Namespace**: `AdministrationService.Protos`  

**Proto files**:
- `AdministrationServicePermission.proto`
- `AdministrationServiceMailTemplate.proto`
- `shared.proto` (common BaseResponse)

**Service: `AdministrationServicePermission`**
```protobuf
rpc IsGrantedPermission(IsGrantedPermissionRequest) returns (IsGrantedPermissionResponse)
  // Single permission check
  // Request: { PermissionName: string }
  // Response: { IsGranted: bool }

rpc IsGrantedPermissions(IsGrantedPermissionsRequest) returns (IsGrantedPermissionsResponse)
  // Bulk permission check
  // Request: { PermissionNames: repeated string }
  // Response: { IsGranted: bool }

rpc TestPermission(TestPermissionRequest) returns (TestPermissionResponse)
  // Test endpoint
  // Request: { PermissionName: string }
  // Response: { IsGranted: bool }
```

**Service: `AdministrationServiceMailTemplate`**
```protobuf
rpc SendEmail(SendEmailRequest) returns (SendEmailResponse)
  // Request: { ToMail, CcMail, BccMail: repeated string, EmailInfo: { MailData: map<string,string>, MailTemplateCode: string } }
  // Response: { IsSuccess: bool, Error: string, Data: optional bool }
```

---

### 7. gRPC — Administration API (Client in Customer API)

**Protocol**: gRPC over HTTP/2 + TLS  
**Target**: `https://localhost:50051` (Administration API gRPC)  
**Config key**: `RemoteServices:AdministrationService:BaseUrl`  
**Generated client**: `AdministrationServicePermissionGrpc` (in `Application/` layer)  
**Proto source**: `shared/CMN.Shared.Hosting.Microservices/GrpcClient/Protos/`

**Purpose**: Customer API calls Administration API to check user permissions before executing business logic.

---

### 8. Firebase (Mobile App)

**SDK**: FlutterFire  
**Config**: Platform-specific `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)  

| Firebase Service | Package | Usage |
|---|---|---|
| Analytics | `firebase_analytics` | User behavior tracking |
| Crashlytics | `firebase_crashlytics` | Crash reporting |
| FCM (messaging) | `firebase_messaging` | Push notifications |
| Performance | `firebase_performance` | App performance monitoring |

---

### 9. Google Sign-In (Mobile App)

**Package**: `google_sign_in`  
**Config key**: `.env GOOGLE_API_KEY`  
**Protocol**: OAuth2 / OpenID Connect  
**Usage**: Social login in mobile app  

---

### 10. Google Maps (Mobile App)

**Package**: `google_maps_flutter`  
**Config key**: `.env GOOGLE_API_KEY`  
**Usage**: Map display in mobile app (feature not fully confirmed) [INFERRED from dependency]

---

### 11. GitHub API (Internal Code Reviewer)

**Type**: Internal developer tool integration  
**Protocol**: HTTPS REST  
**Service**: `swt-cmn-code-reviewer`  
**Purpose**: Automated code review of GitHub pull requests using AI  
**Status**: Internal only, not part of production runtime  

---

## Removed / Disabled Integrations

| Integration | Status | Evidence |
|---|---|---|
| OpenIddict (OAuth2 server) | Code commented out | `//typeof(AbpAccountWebOpenIddictModule)` in both host modules |
| OpenIddict validation | Code commented out | `//app.UseAbpOpenIddictValidation()` in both host modules |
| OpenIddict data seed | Present but disabled | `OpenIddictDataSeedContributor.cs` exists in Administration Domain |
| ABP Studio Client | Code commented out | `//typeof(AbpStudioClientAspNetCoreModule)` |
| ABP Conventional Controllers | Code commented out | `//ConfigureConventionalControllers()` |
| HealthChecks UI | Code commented out | Dashboard code commented out in HealthChecksBuilderExtensions |
| ABP Bundles | Code commented out | `//ConfigureBundles()` |

---

## Integration Configuration Reference

| Secret / Config Key | Location | Notes |
|---|---|---|
| `CloudinarySettings:CloudName/ApiKey/ApiSecret` | `appsettings.secrets.json` | Never in version control |
| `Abp.Mailing.Smtp.UserName/Password` | ABP Settings DB or `appsettings.secrets.json` | |
| `AuthenticationJwtBearer:SecurityKey` | `appsettings.Development.json` | Shared across services |
| `ConnectionStrings:Default` | `appsettings.Development.json` | SQL Server |
| `ConnectionStrings:MongoDb` | `appsettings.Development.json` | MongoDB |
| `Redis:Configuration` | `appsettings.Development.json` | Redis |
| `GOOGLE_API_KEY` | Mobile `.env` | Google Maps + Sign-In |
| `BASE_URL` | Mobile `.env` | API base URL (empty in dev!) |
| `VITE_API_URL` | Admin web app `.env.*` | Gateway base URL |
