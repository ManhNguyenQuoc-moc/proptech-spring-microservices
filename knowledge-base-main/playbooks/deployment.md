# Playbook: Deployment

> This playbook covers deploying CMN services.
> Confirmed infrastructure: SQL Server + Redis + MongoDB at `100.69.37.126`.
> Environments: `Development`, `InternalDevelopment`, `LocalDevelopment`, `Production`.

---

## Service Port Map

| Service | HTTP Port | gRPC Port |
|---|---|---|
| Administration API | `:8088` | `:50051` (TLS HTTP/2) |
| Customer API | `:44360` | `:50052` |
| Web Gateway | (configured per env) | — |

---

## Infrastructure Dependencies

| Dependency | Address | Used By |
|---|---|---|
| SQL Server | `100.69.37.126:1433` DB `SWTCMN` | Administration API (ADM schema), Customer API (CM schema) |
| Redis | configured per env | Administration API (tokens, sessions), Customer API |
| MongoDB | `100.69.37.126:27017` DB `swt_cmn` | Administration API (MailTemplate collection) |
| Cloudinary | (CDN, config via API keys) | Administration API (media files) |
| SMTP | configured via `Abp.Mailing.Smtp.*` | Administration API (outbound email) |
| Firebase | (Google config files) | Mobile App |

---

## Step 1 — Pre-Deployment Checklist

- [ ] All tests pass: `dotnet test` for each .NET service
- [ ] No pending EF migrations left unapplied
- [ ] `appsettings.{Environment}.json` has correct values for target environment
- [ ] Secrets are NOT committed to git (check `appsettings.secrets.json` is in `.gitignore`)
- [ ] gRPC TLS certificates are provisioned for `:50051`

---

## Step 2 — Build .NET Services

```bash
# Administration API
cd swt-cmn-administration-api
dotnet publish CMN.AdministrationService.HttpApi.Host \
  -c Release \
  -o ./publish/administration-api

# Customer API
cd ../swt-cmn-customer-api
dotnet publish CMN.CustomerManagement.HttpApi.Host \
  -c Release \
  -o ./publish/customer-api

# Web Gateway
cd ../swt-cmn-web-gateway
dotnet publish CMN.WebGateWay \
  -c Release \
  -o ./publish/web-gateway
```

---

## Step 3 — Run Database Migrations

**Before starting the services**, apply pending migrations:

```bash
# Administration API
cd swt-cmn-administration-api
dotnet run --project src/CMN.AdministrationService.DbMigrator \
  --environment Production

# Customer API
cd ../swt-cmn-customer-api
dotnet run --project src/CMN.CustomerManagement.DbMigrator \
  --environment Production
```

The DbMigrator also runs ABP data seeding (tenant `itzone`, permissions, identity settings).

---

## Step 4 — Start Backend Services

**Startup order** (gRPC server must start before gRPC client):

1. **Administration API** first (gRPC server on `:50051`)
2. **Customer API** second (gRPC client — connects to Admin API)
3. **Web Gateway** last

```bash
# 1. Administration API
cd swt-cmn-administration-api/publish/administration-api
dotnet CMN.AdministrationService.HttpApi.Host.dll \
  --environment Production \
  --urls "http://0.0.0.0:8088;https://0.0.0.0:50051"

# 2. Customer API
cd swt-cmn-customer-api/publish/customer-api
dotnet CMN.CustomerManagement.HttpApi.Host.dll \
  --environment Production \
  --urls "http://0.0.0.0:44360;https://0.0.0.0:50052"

# 3. Web Gateway
cd swt-cmn-web-gateway/publish/web-gateway
dotnet CMN.WebGateWay.dll \
  --environment Production
```

---

## Step 5 — Build + Deploy Frontend Apps

### Admin Web App (Vite)

```bash
cd swt-cmn-administration-web-app
npm install
npm run build          # tsc -b && vite build
# Output: dist/
# Serve dist/ from a static host or CDN
```

### Web App (Next.js)

```bash
cd swt-cmn-web-app
npm install
npm run build          # next build --webpack
npm run start          # starts production server
```

### Mobile App (Flutter)

```bash
cd swt-cmn-mobile-app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Android
flutter build apk --release
# Output: build/app/outputs/apk/release/app-release.apk

# iOS
flutter build ios --release
# Requires Xcode + provisioning profile
```

Confirm `.env.production` has correct `BASE_URL` and `GOOGLE_API_KEY` before building.

---

## Step 6 — Smoke Tests

After deployment, verify:

```bash
# Health checks
curl http://{admin-host}:8088/health
curl http://{customer-host}:44360/health

# Swagger UI accessible
curl http://{gateway-host}/cmn/swagger

# Login (confirms DB + Redis + JWT working)
curl -X POST http://{gateway-host}/cmn/administration-service/api/auth \
  -H "Content-Type: application/json" \
  -H "X-Tenant: itzone" \
  -d '{"userName":"admin","password":"Admin1234!"}'
# Expect: 200 with accessToken, refreshToken
```

---

## Environment Configuration Reference

| Key | Where | Purpose |
|---|---|---|
| `ConnectionStrings:Default` | appsettings / secrets | SQL Server |
| `Redis:Configuration` | appsettings / secrets | Redis host |
| `MongoDB:ConnectionString` | appsettings / secrets | MongoDB |
| `AuthenticationJwtBearer:SecurityKey` | appsettings / env var | JWT signing key (same value in Admin+Customer API) |
| `AuthenticationJwtBearer:Issuer` | appsettings | `"ZS"` |
| `AuthenticationJwtBearer:Audience` | appsettings | `"ZS"` |
| `App:CorsOrigins` | appsettings | Allowed CORS origins |
| `App:ResetPasswordUrl` | appsettings | Base URL for password reset link |
| `Cloudinary:CloudName` | secrets | Cloudinary account |
| `Settings:Abp.Mailing.Smtp.*` | appsettings / secrets | SMTP server config |
| `VITE_API_URL` | frontend .env | Admin web app API base URL |
| `NEXT_PUBLIC_API_URL` | frontend .env | Web app API base URL |
| `BASE_URL` | mobile .env.production | Mobile app API base URL |

---

## Docker (Web Gateway — Dockerfile present)

```bash
cd swt-cmn-web-gateway/CMN.WebGateWay
docker build -t cmn-web-gateway .
docker run -p 80:8080 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  cmn-web-gateway
```

Dockerfiles for Administration API and Customer API may need to be created if not present.
