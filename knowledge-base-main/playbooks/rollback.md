# Playbook: Rollback

> Rollback procedures for CMN services. Use this when a deployment introduces a regression, data corruption, or service failure.

---

## Decision Tree

```
Service unhealthy after deploy?
├── Is it a code bug? → Code Rollback (Step 1)
├── Is it a DB schema issue? → Migration Rollback (Step 2)
├── Is it a Redis state issue? → Redis Flush (Step 3)
├── Is it a config/secrets issue? → Config Rollback (Step 4)
└── Is it a frontend issue? → Frontend Rollback (Step 5)
```

---

## Step 1 — Code Rollback (.NET Service)

### Option A: Revert to previous Git tag/commit

```bash
# Identify the last known-good commit
git log --oneline -10

# Build from the previous commit
git checkout {commit-hash}
dotnet publish CMN.[Service].HttpApi.Host -c Release -o ./publish/[service]

# Redeploy the previous build
```

### Option B: Redeploy the previous artifact

If CI/CD produces versioned artifacts, redeploy the previous version without touching git.

---

## Step 2 — Migration Rollback (Database)

### 2.1 — List Applied Migrations

```bash
dotnet ef migrations list \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

Example output:
```
20251108... (Applied)
20251109... (Applied)
20251114... (Applied)
20251115... (Applied)        ← current, problematic
20260123_Add_Department      ← new, rolling back this
```

### 2.2 — Roll Back to Previous Migration

```bash
dotnet ef database update {PreviousMigrationName} \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

This calls the `Down()` method of the current migration (drops added tables, removes added columns).

**Verify**: connect to SQL Server and confirm the rolled-back table/column is gone.

### 2.3 — Remove Migration File (if not yet in production)

```bash
dotnet ef migrations remove \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

> Only run `migrations remove` after `database update {Previous}` has been applied. Removing before the DB rollback leaves the schema out of sync.

### 2.4 — Current Migration Baseline (safe rollback targets)

**Administration API** — safe to roll back to:
| Target | Safe? | Notes |
|---|---|---|
| `20251115...` | Yes | Last known-good state from Phase 0 discovery |
| `20251114...` | Yes | |
| `20251108...` (initial) | Caution | Drops most ADM tables |

**Customer API** — safe to roll back to:
| Target | Safe? | Notes |
|---|---|---|
| `20260103081306_Initial` | Yes | Creates only `CM.Party` — minimal schema |
| `0` (empty) | Caution | Drops all CM tables |

---

## Step 3 — Redis Flush (Cache Corruption or Stale State)

Use only if cache keys are confirmed corrupted or if a token/session bug requires clearing all active sessions.

```bash
# Connect to Redis CLI
redis-cli -h {redis-host} -p 6379

# Flush all keys in current DB (CAUTION — logs out all users)
FLUSHDB

# Or selectively delete by pattern (safer)
SCAN 0 MATCH "*:login-ip:*" COUNT 100
DEL {key1} {key2} ...

# Delete all refresh tokens (logs out all users without deleting other keys)
SCAN 0 MATCH "*:*" COUNT 1000  # review before deleting
```

**Impact of FLUSHDB**:
- Deletes all refresh tokens → all users are logged out (must re-login)
- Deletes all password reset tokens → any in-flight password resets fail
- Deletes all import sessions → any in-progress bulk imports are abandoned
- Deletes IP rate limit counters → rate limiting resets

---

## Step 4 — Config/Secrets Rollback

If the rollback is caused by a wrong config value (e.g., wrong DB connection string, wrong JWT key):

1. Restore the previous `appsettings.{Environment}.json` value
2. Restart the service — config changes take effect on restart
3. If JWT `SecurityKey` was changed: all existing tokens are invalid — all users must re-login

---

## Step 5 — Frontend Rollback

### Admin Web App / Web App

Redeploy the previous `dist/` artifact (Vite) or the previous Next.js build output from CI/CD.

```bash
# If previous build artifact is available:
cd swt-cmn-administration-web-app
# Deploy previous dist/ to static host
```

### Mobile App

Mobile app rollbacks are limited by app store policies:
- **Internal/TestFlight**: redeploy the previous build from the distribution console
- **Production (App Store / Play Store)**: submit a hotfix build; forced rollback is not possible

---

## Step 6 — Post-Rollback Verification

After rollback, verify:

```bash
# Health checks
curl http://{admin-host}:8088/health       # should return 200
curl http://{customer-host}:44360/health   # should return 200

# Smoke test: login still works
curl -X POST .../cmn/administration-service/api/auth \
  -H "X-Tenant: itzone" \
  -d '{"userName":"...","password":"..."}'

# Confirm DB is on expected migration
dotnet ef migrations list \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
# Last line should show "(Applied)" on the previous migration
```

---

## Incident Log Template

When performing a rollback, record:

```
Date: YYYY-MM-DD HH:MM
Service: [administration-api / customer-api / web-gateway / frontend]
Trigger: [what caused the rollback]
Rolled back to: [git commit hash or migration name]
DB rollback: [yes/no — which migration]
Redis flush: [yes/no]
Time to recover: [duration]
Root cause: [brief description]
Prevention: [what to change to avoid recurrence]
```
