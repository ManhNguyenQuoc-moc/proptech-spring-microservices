# Playbook: Developer Onboarding

> For a new developer joining the CMN project. Complete all steps before writing production code.

---

## Prerequisites

Install before starting:

- [ ] .NET 9 SDK (`dotnet --version` → `9.x.x`)
- [ ] Node.js LTS + npm
- [ ] Flutter SDK 3.5+ (`flutter doctor` shows no critical issues)
- [ ] Git
- [ ] SQL Server (local or Docker: `docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=..." -p 1433:1433 -d mcr.microsoft.com/mssql/server:2022-latest`)
- [ ] Redis (local or Docker: `docker run -p 6379:6379 -d redis`)
- [ ] IDE: Visual Studio / Rider (backend) + VS Code (frontend) + Android Studio / Xcode (mobile)

---

## Step 1: Clone and Understand Structure

```bash
git clone <repo-url>
cd CMN
```

Read in order:
1. `CLAUDE.md` — monorepo overview and global rules
2. `swt-cmn-knowledge-base/01-architecture.md` — system architecture
3. `swt-cmn-knowledge-base/04-business-domain.md` — domain model
4. `swt-cmn-knowledge-base/03-conventions.md` — engineering invariants

---

## Step 2: Configure Secrets

Each .NET service needs `appsettings.secrets.json` (git-ignored).

**Administration API** (`swt-cmn-administration-api/CMN.AdministrationService.HttpApi.Host/appsettings.secrets.json`):
```json
{
  "ConnectionStrings": {
    "Default": "Server=localhost;Database=CmnAdministration;User Id=sa;Password=YOUR_PASSWORD;TrustServerCertificate=True"
  },
  "Redis": {
    "Configuration": "localhost:6379"
  },
  "Cloudinary": {
    "CloudName": "your-cloud-name",
    "ApiKey": "your-api-key",
    "ApiSecret": "your-api-secret"
  }
}
```

**Customer API** (`swt-cmn-customer-api/CMN.CustomerManagement.HttpApi.Host/appsettings.secrets.json`):
```json
{
  "ConnectionStrings": {
    "Default": "Server=localhost;Database=CmnCustomer;User Id=sa;Password=YOUR_PASSWORD;TrustServerCertificate=True"
  },
  "Redis": {
    "Configuration": "localhost:6379"
  }
}
```

---

## Step 3: Run Database Migrations

```bash
# Administration Service
cd swt-cmn-administration-api
dotnet run --project src/CMN.AdministrationService.DbMigrator

# Customer Service
cd ../swt-cmn-customer-api
dotnet run --project src/CMN.CustomerManagement.DbMigrator
```

---

## Step 4: Start Backend Services

Open three terminals:

**Terminal 1 — Administration API**:
```bash
cd swt-cmn-administration-api
dotnet run --project CMN.AdministrationService.HttpApi.Host
# Runs on http://localhost:8088
```

**Terminal 2 — Customer API**:
```bash
cd swt-cmn-customer-api
dotnet run --project CMN.CustomerManagement.HttpApi.Host
# Runs on http://localhost:44360
```

**Terminal 3 — Web Gateway**:
```bash
cd swt-cmn-web-gateway
dotnet run --project CMN.WebGateWay
# Swagger UI: http://localhost:{gateway-port}/cmn/swagger
```

---

## Step 5: Start Frontend Apps

**Admin Web App**:
```bash
cd swt-cmn-administration-web-app
npm install
# Create .env.localDevelopment with API base URL
npm run local
```

**Web App**:
```bash
cd swt-cmn-web-app
npm install
# Create .env.local with API base URL
npm run local
# Runs on http://localhost:4200
```

**Mobile App**:
```bash
cd swt-cmn-mobile-app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
# Create .env.dev with API base URL
flutter run
```

---

## Step 6: Verify Health

- [ ] `GET http://localhost:8088/health` → 200
- [ ] `GET http://localhost:44360/health` → 200
- [ ] Swagger UI accessible at `/cmn/swagger`
- [ ] Admin web app loads login page
- [ ] Web app loads at `localhost:4200`
- [ ] Mobile app launches on emulator/device

---

## Step 7: Read Module CLAUDE.md

Before writing any code in a module, read its CLAUDE.md:

| Module | CLAUDE.md |
|---|---|
| Administration API | `swt-cmn-administration-api/CLAUDE.md` |
| Customer API | `swt-cmn-customer-api/CLAUDE.md` |
| Admin Web App | `swt-cmn-administration-web-app/CLAUDE.md` |
| Web App | `swt-cmn-web-app/CLAUDE.md` |

---

## Step 8: Understand the Skill System

Each module has a `skills/` directory with task-specific patterns. Before implementing any feature, load the relevant skill file.

Example: to add a new API endpoint in Administration Service, read `swt-cmn-administration-api/skills/api-service-skill.md` first.
