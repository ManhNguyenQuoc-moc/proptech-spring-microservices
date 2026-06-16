# Runtime Topology

**Generated**: 2026-05-23
**Discovery method**: appsettings.Development.json, host modules, proto files, HTTP client source

---

## Port Map

| Service | Protocol | Port | Binding |
|---|---|---|---|
| Administration API | HTTP (Http1+Http2) | 8088 | `http://*:8088` |
| Administration API | gRPC (Http2, TLS) | 50051 | `https://*:50051` |
| Customer API | HTTP (Http1+Http2) | 44360 | `http://*:44360` |
| Customer API | gRPC (Http2, TLS) | 50052 | `https://*:50052` |
| Web Gateway | HTTP | varies | YARP config |
| Web App | HTTP | 4200 | Next.js dev server |
| SQL Server | TCP | 1433 | `100.69.37.126:1433` |
| MongoDB | TCP | 27017 | `100.69.37.126:27017` |
| Redis | TCP | 6379 | `localhost:6379` |

---

## Communication Topology

```
┌─────────────────────────────────────────────────────────────┐
│                      CLIENTS                                │
│  Admin Web App    Web App (4200)    Mobile App (itzone)     │
│  (Vite/React)     (Next.js)         (Flutter)               │
└──────────┬───────────────┬──────────────────┬──────────────┘
           │  HTTPS        │  HTTPS           │  HTTPS
           ▼               ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                   Web Gateway (YARP)                        │
│  /cmn/administration-service/** → localhost:8088            │
│  /cmn/customer-management/**   → localhost:44360            │
│  /cmn/swagger                  → Aggregated Swagger UI      │
└──────────┬──────────────────────────────┬───────────────────┘
           │ HTTP                          │ HTTP
           ▼                              ▼
┌──────────────────────┐    ┌──────────────────────────┐
│  Administration API  │    │  Customer Management API  │
│  :8088               │◄───│  :44360                   │
│  gRPC: :50051        │    │  gRPC: :50052             │
└──────┬───────────────┘    └──────────┬────────────────┘
       │                               │
       │   gRPC (Permission check)     │
       │   Customer → Administration   │
       │   :50051                      │
       └───────────────────────────────┘
```

### Inter-Service Communication

| From | To | Protocol | Address | Purpose |
|---|---|---|---|---|
| Customer API | Administration API | gRPC | `https://localhost:50051` | Permission checks (`IsGrantedPermission`, `IsGrantedPermissions`) |
| Customer API | Administration API | gRPC | `https://localhost:50051` | (Potential) Mail template / email via `SendEmail` RPC |
| Administration API | Customer API | — | `https://localhost:50052` (config) | Not yet implemented (config present, no client code found) |

---

## Data Store Connections

### SQL Server

| Connection Name | Database | Users |
|---|---|---|
| `Default` | `SWTCMN` | Both Administration API and Customer API |
| Host | `100.69.37.126:1433` | Shared dev server |

**Administration API schema**: `ADM`  
**Customer API schema**: `CM`  
Both services connect to the same SQL Server instance/database but use separate schemas.

### MongoDB

| Connection Name | Database | Users |
|---|---|---|
| `MongoDb` (admin) | `swt_cmn` | Administration API |
| `MongoDb` (customer) | `swt_cmn` | Customer API [STUB — not configured] |
| Host | `100.69.37.126:27017` | Shared dev server |

**Administration API** uses MongoDB for: `MailTemplate` collection (prefix: `adm`)  
**Customer API** has MongoDB module but `MongoDbConnectionStringName = ""` — no collections defined. [STUB]

### Redis

| Config Key | Value | Users |
|---|---|---|
| `Redis:IsEnabled` | `true` | Administration API (confirmed) |
| `Redis:Configuration` | `localhost:6379,defaultDatabase=0` | Administration API |

**Used for**: Password reset token cache (`PasswordResetTokenCacheItem`)  
Customer API also has Redis config in CLAUDE.md stack list but not confirmed in code.

---

## External Service Topology

```
Administration API ──► Cloudinary API      (media upload/delete)
Administration API ──► Gmail SMTP :587     (email via MailKit)
Administration API ──► Redis :6379         (password reset tokens)

Mobile App (itzone) ──► Firebase           (FCM push notifications, Crashlytics, Analytics)
Mobile App (itzone) ──► Google Maps API    (map features)
Mobile App (itzone) ──► Google Sign-In API (OAuth social login)
Mobile App (itzone) ──► Backend API        (via BASE_URL env var, currently empty in dev)
```

---

## Environment Configuration Chain

### Administration API
```
appsettings.json (minimal/empty)
  ↓ overrides
appsettings.Development.json (local dev with real connection strings)
  ↓ overrides
appsettings.InternalDevelopment.json (internal dev environment)
  ↓ overrides
appsettings.secrets.json (git-ignored, local credentials)
```

### Customer API
Same pattern: `appsettings.json` → `appsettings.Development.json` → `appsettings.InternalDevelopment.json`

### Frontend Apps
```
.env.local          (local dev — highest priority)
.env.development    (development environment)
.env.internalDevelopment  (internal dev)
```
Loaded via `env-cmd` package (admin web app) or Next.js native env loading (web app).

### Mobile App
```
.env          (production)
.env.dev      (development)
```
Loaded via `flutter_dotenv`.

---

## Startup Order (Local Development)

1. Start SQL Server and MongoDB (external, `100.69.37.126`)
2. Start Redis (`localhost:6379`)
3. Start Administration API (`dotnet run`, port 8088)
4. Start Customer API (`dotnet run`, port 44360)
5. Start Web Gateway (`dotnet run`)
6. Start Admin Web App (`npm run dev` or `npm run local`)
7. Start Web App (`npm run local`, port 4200)
8. Run Mobile App (`flutter run`)

Health check endpoint (both APIs): `GET /health`

---

## Multi-Tenancy Flow

```
Frontend (login)
  └── Select tenant → store tenantId in localStorage[X-Tenant]

Every API Request
  └── @core/http interceptor reads localStorage[X-Tenant]
  └── Sets X-Tenant: <tenantId> header

API Gateway (YARP)
  └── Passes X-Tenant header through unchanged

Backend Services
  └── AbpAspNetCoreMultiTenancyOptions.TenantKey = "X-Tenant"
  └── ABP resolves tenant context from header value
```

Seeded dev tenant: `itzone` (ID: `019b8846-891c-7642-8381-1722468b8462`)

---

## Authentication Flow

```
Client POST /cmn/administration-service/api/auth
  ↓
AuthController.LoginAsync
  ↓
AuthAppService.LoginAsync
  ↓
ABP IdentityUser lookup → validate password
  ↓
Generate custom JWT (issuer: "ZS", audience: "ZS")
  ↓
Return: { accessToken, refreshToken, expiration }
  ↓
Frontend: stores in cookies (ACCESS_TOKEN_KEY, REFRESH_TOKEN_KEY)

On 401:
  Frontend interceptor → calls /auth refresh-login → new tokens → retry original request
```

JWT config:
- Access token expiry: 1 hour
- Refresh token expiry: 720 hours (30 days)
- Security key: shared across Administration and Customer APIs

---

## gRPC Protocol Details

**Administration API** — acts as **gRPC server**:
- Endpoint: `https://*:50051` (Http2 + TLS)
- Services: `AdministrationServicePermissionGrpc`, `AdministrationServiceMailTemplateGrpc`
- Reflection: enabled (for grpcurl/Postman discovery)

**Customer API** — acts as **gRPC client**:
- Connects to: `https://localhost:50051`
- Generated client: `AdministrationServicePermissionGrpc` (from shared proto)
- Proto files in: `shared/CMN.Shared.Hosting.Microservices/GrpcClient/Protos/`

**Shared proto `shared.proto`**: defines `BaseResponse { IsSuccess, Error }` common message.
