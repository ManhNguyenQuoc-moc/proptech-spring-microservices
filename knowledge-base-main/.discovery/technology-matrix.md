# Technology Matrix

**Generated**: 2026-05-23
**Source**: package.json, pubspec.yaml, csproj files, appsettings, host modules

---

## Backend Services (.NET)

### Administration API + Customer API (shared stack)

| Category | Technology | Version | Notes |
|---|---|---|---|
| Runtime | .NET | 9 | Target framework: net9.0 |
| Framework | ABP Framework (Volo.Abp) | (latest ABP 9.x) | Full ABP module system |
| ORM | Entity Framework Core | 9.x | SQL Server provider |
| NoSQL | MongoDB Driver | via Volo.Abp.MongoDB | ABP MongoDb integration |
| Cache | Redis (StackExchange.Redis) | via Volo.Abp.Caching.StackExchangeRedis | Password reset tokens |
| DI | Autofac | via Volo.Abp.Autofac | DI container |
| API docs | Swashbuckle / ABP Swashbuckle | — | Swagger/OpenAPI |
| gRPC | Grpc.AspNetCore | — | Both server + client |
| Auth | Custom JWT Bearer | — | NOT OpenIddict; custom `AuthenticationJwtBearer` section |
| Identity | ABP Identity | — | Users, Roles, Claims, Sessions |
| Multi-tenancy | ABP AspNetCore MultiTenancy | — | X-Tenant header resolution |
| Validation | FluentValidation | — | All input DTOs validated |
| Email | MailKit + Volo.Abp.MailKit | — | Administration API only |
| Email | Gmail SMTP | host: smtp.gmail.com, port: 587 | Dev email |
| Logging | Serilog + AbpAspNetCoreSerilog | — | Structured logging |
| Background Jobs | Volo.Abp.BackgroundJobs.EntityFrameworkCore | — | ABP jobs in SQL Server (NOT Hangfire) |
| Permission Mgmt | Volo.Abp.PermissionManagement | — | Permission store in SQL Server |
| Feature Mgmt | Volo.Abp.FeatureManagement | — | Feature flags |
| Settings | Volo.Abp.SettingManagement | — | Dynamic settings |
| Blob Storage | Volo.Abp.BlobStoring.Database | — | Blob data in SQL Server |
| Audit | ABP Auditing | — | Disabled (`IsEnabled = false`) |
| Media | Cloudinary .NET SDK | via CloudinaryDotNet | Administration API file upload |
| Reverse Proxy (GW) | YARP (Yet Another Reverse Proxy) | — | Web Gateway only |
| Health Checks | HealthChecks.UI.Client | — | `/health` endpoint |
| Testing | xUnit + Shouldly | — | Unit + integration tests |
| Build | MSBuild / dotnet CLI | — | Standard .NET build |
| Containerization | Docker | — | Dockerfile + Dockerfile.local per service |

### Administration API — Additional ABP Modules

| Module | Purpose |
|---|---|
| `AbpAspNetCoreMvcModule` | MVC controllers |
| `AbpAspNetCoreMultiTenancyModule` | Multi-tenant header |
| `AbpAspNetCoreSerilogModule` | Serilog enrichers |
| `AbpSwashbuckleModule` | ABP Swagger integration |
| `AbpAutofacModule` | Autofac DI |
| `AbpEmailingModule` | Email abstractions |
| `AbpMailKitModule` | MailKit SMTP |
| `AdministrationServiceMongoDbModule` | MongoDB integration |
| `CMNSharedHostingMicroservicesModule` | Shared JWT + gRPC + Swagger config |

---

## Database Layer

| Database | Version | Connection | Purpose |
|---|---|---|---|
| SQL Server | (dev: 2019+) | `100.69.37.126:1433` DB=`SWTCMN` | Primary relational store (both services) |
| MongoDB | (dev: 4.4+) | `100.69.37.126:27017/swt_cmn` | MailTemplate collection (Administration) |
| Redis | (dev: 6.x+) | `localhost:6379` defaultDB=0 | Password reset token cache |

---

## Administration Web App (`swt-cmn-administration-web-app/`)

| Category | Technology | Version | Notes |
|---|---|---|---|
| Build tool | Vite | 7.3.1 | Lightning-fast HMR |
| UI framework | React | 19.2.0 | With concurrent features |
| Language | TypeScript | 5.9.3 | Strict mode |
| UI library | Ant Design | 6.3.0 | Primary component system |
| UI locale | viVN | — | Vietnamese locale for AntD |
| State management | Redux Toolkit | 2.11.2 | Async thunks + slices |
| HTTP client | Axios | latest | Configured in `@core/http` |
| Form serialization | qs | latest | Params serialization |
| Routing | React Router (Vite) | — | SPA routing |
| Styling | CSS Modules / clsx | — | Utility class composition |
| Linting | ESLint | — | `npm run lint` |
| Preview | Vite preview | — | `npm run preview` |
| Containerization | Docker | — | `Dockerfile` |

**Key custom abstractions**:
- `SWT*` components — all AntD primitives wrapped before use in pages
- `useSWT*` hooks — custom hooks convention
- `http` — singleton Axios instance with auth + tenant interceptors
- `useSWTMutation` — mutation helper for create/update/delete

---

## Main Web App (`swt-cmn-web-app/`)

| Category | Technology | Version | Notes |
|---|---|---|---|
| Framework | Next.js | 16.1.1 | App Router (RSC + SSR) |
| UI framework | React | 19.2.3 | |
| Language | TypeScript | latest | |
| UI library | Ant Design | 6.2.0 | |
| State management | Redux Toolkit | 2.5.0 | |
| CSS | Tailwind CSS | 4.x | |
| HTTP client | Axios | — | Same pattern as admin web app |
| Routing | Next.js App Router | — | File-system based |
| Env management | Next.js native | — | `.env.local`, `.env.development`, `.env.internalDevelopment` |
| Containerization | Docker | — | `Dockerfile` |
| Code quality | SonarQube | — | `sonar-project.properties` |
| Package manager | yarn | — | `yarn.lock` present |

---

## Mobile App (`swt-cmn-mobile-app/` — itzone)

| Category | Technology | Version | Notes |
|---|---|---|---|
| Framework | Flutter | ^3.5.3 | Dart SDK |
| State management | Riverpod (hooks_riverpod) | 2.6.1 | Reactive state |
| Routing | go_router | 16.3.0 | Declarative routing |
| HTTP client | Retrofit (dio_based) | 4.5.0 | Code-generated API client |
| Models | Freezed | 3.1.0 | Immutable data classes |
| Localization | easy_localization | — | i18n support |
| Firebase | firebase_core, firebase_analytics, firebase_crashlytics, firebase_messaging, firebase_performance | — | Analytics, crash reporting, push notifs |
| Maps | google_maps_flutter | — | Google Maps integration |
| Auth | google_sign_in | — | Google OAuth |
| Local DB | drift or sqflite | — | SQLite, DB: `itzone.db` |
| Env | flutter_dotenv | — | `.env`, `.env.dev`, `.env.production` |
| Assets | flutter_gen | — | Generated asset references |
| Code quality | SonarQube | — | `sonar-project.properties` |
| Platforms | Android, iOS | — | Also macos/linux/windows/web project files |

---

## Internal Tool (`swt-cmn-code-reviewer/`)

| Category | Technology | Version | Notes |
|---|---|---|---|
| Runtime | .NET | 9 | |
| API | ASP.NET Core (console) | — | `GitHubPRReviewer/` |
| UI | Blazor | — | `GitHubPRReviewerUI/` |
| AI integration | (Claude/OpenAI via API) | — | [INFERRED] Skills directory present |
| Containerization | Docker | — | Two Dockerfiles |

---

## DevOps & Infrastructure

| Category | Technology | Notes |
|---|---|---|
| Containerization | Docker | Per-service Dockerfiles (no docker-compose found) |
| Code quality | SonarQube | `sonar-project.properties` in web-app and mobile-app |
| CI/CD | None confirmed | `.github/` directory present but only java-upgrade hook scripts found — no GitHub Actions workflows |
| Reverse proxy | YARP | Web Gateway |
| Nginx | Optional | `NginxSettings:IsEnabled` config in both APIs; `Dockerfile.local` + `web.config` for IIS/nginx |
| Service defaults | Aspire (CMN.Shared.ServiceDefaults) | Web Gateway only — basic health/observability defaults |
| Process manager | (none confirmed) | No PM2, Supervisor, or k8s found |

---

## Shared Libraries (per service)

Each backend service duplicates a `shared/` directory with the same projects:

| Project | Namespace | Purpose |
|---|---|---|
| `CMN.Shared.CrossCuttingConcerns` | `CMN.Shared.CrossCuttingConcerns` | `ApiResult<T>`, `BaseResultDto`, shared DTOs |
| `CMN.Shared.Hosting.AspNetCore` | `CMN.Shared.Hosting.AspNetCore` | `CMNAbpExceptionFilter` (exception→HTTP mapping) |
| `CMN.Shared.Hosting.Microservices` | `CMN.Shared.Hosting.Microservices` | `AppControllerBase`, JWT auth extension, Swagger config, gRPC client |

> **Note**: These shared libraries exist as physical copies within each service module (not NuGet packages or git submodules). They are maintained in sync manually.

The Web Gateway has its own: `CMN.Shared.ServiceDefaults` (Aspire service defaults).
