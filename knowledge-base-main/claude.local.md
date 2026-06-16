# CLAUDE.LOCAL.MD — CMN KB Routing Engine

> AI entry point. Routes context loading. Minimizes token usage. Do NOT scan the full repo.

---

## STEP 0 — READ MANIFEST FIRST (always, every task)

```
_meta/manifest.yml
```

This is the machine-readable system snapshot. It contains:
- All services, ports, routes, DB schemas
- All features with endpoint paths and app services
- All bounded contexts and their status
- All integrations (SQL Server, Redis, MongoDB, Cloudinary, gRPC)
- All technical debt items (TD-001 … TD-008)
- Critical constraints and forbidden patterns (`ai_agent_guidance` section)
- All requirement IDs and business rule IDs with next-available counters

**Do not proceed until manifest.yml is loaded.** Everything else is secondary context.

---

## STEP 1 — MANDATORY ENTRYPOINT (new task orientation only)

Read in order, stop as soon as you have enough context:

| # | File | Load When |
|---|---|---|
| 1 | `_meta/manifest.yml` | **Always** (system snapshot) |
| 2 | `03-conventions.md` | Any implementation task |
| 3 | `services/{service}.md` | Working inside a specific service |
| 4 | `01-architecture.md` | Cross-service, auth, or gateway task |
| 5 | `00-glossary.md` | Unfamiliar domain term |

Do **not** pre-load `04-business-domain.md`, `05-flows.md`, `06-integrations.md`, or `07-security-permissions.md` unless the task explicitly needs them (routing table below).

---

## STEP 2 — TASK ROUTING

| Task | Files to load (after manifest) |
|---|---|
| Add backend CRUD feature | `03-conventions.md` → `services/{service}.md` → `playbooks/add-feature.md` |
| Add single endpoint | `services/{service}.md` → `playbooks/add-endpoint.md` |
| Add domain entity | `04-business-domain.md` → `playbooks/add-entity.md` → `playbooks/migration.md` |
| Add frontend page | `services/{webapp}.md` → `playbooks/add-frontend-page.md` |
| Add gRPC method | `06-integrations.md` → `playbooks/add-grpc-method.md` |
| Add background job | `services/{service}.md` → `playbooks/add-worker.md` |
| Add domain event | `06-integrations.md` → `playbooks/add-event.md` |
| Debug auth / 401 | `01-architecture.md` §Auth → `05-flows.md` → `07-security-permissions.md` |
| Debug 403 / permission | `07-security-permissions.md` → `services/{service}.md` |
| Fix response shape | `03-conventions.md` anchor `api-response-shape` |
| Fix exception handling | `03-conventions.md` anchor `error-http-map` |
| Fix layer violation | `03-conventions.md` anchor `layer-rules` |
| Deploy / local setup | `08-deployment-cicd.md` |
| Run migration | `playbooks/migration.md` |
| Rollback | `playbooks/rollback.md` |
| Update KB after code change | `_sync/sync-rules.md` → `_meta/anchors.md` |
| Onboarding | `playbooks/onboarding.md` → `02-tech-stack.md` |

---

## STEP 3 — SERVICE OWNERSHIP

Resolve owner before loading any service doc:

| Domain / Keyword | Service doc |
|---|---|
| Auth, JWT, Login, OTP, Password | `services/administration-api.md` |
| Employee, Role, Permission, Media, MailTemplate | `services/administration-api.md` |
| Customer, Party | `services/customer-api.md` |
| Gateway, YARP, Proxy, Swagger | `services/web-gateway.md` |
| Admin UI, Staff UI (Vite + React) | `services/administration-web-app.md` |
| Main Web App (Next.js) | `services/web-app.md` |
| Mobile, Flutter, itzone | `services/mobile-app.md` |

---

## CONTEXT RULES

```
NEVER load all service docs at once
NEVER load diagrams unless updating them
NEVER load .discovery/ unless verifying a specific [INFERRED] fact
PREFER anchor-targeted reads over full file reads
PREFER code-review-graph MCP tools over Grep/Glob/Read
```

Token budget:

| Read scope | Cost | Use when |
|---|---|---|
| manifest.yml only | ~3 000 tok | Initial orientation |
| manifest + one service doc | ~5 000 tok | Standard feature task |
| manifest + conventions + service doc | ~7 000 tok | First task in a service |
| Full repo scan | 50 000+ tok | **Never** |

---

## KNOWLEDGE AUTHORITY ORDER

```
Source code → .discovery/confirmed-facts.md → services/*.md
    → 01-architecture.md / 03-conventions.md → playbooks → diagrams
    → [INFERRED] items (verify before acting)
```

Code always wins. Update KB to match code, never the reverse.

---

## KB UPDATE PROCEDURE

After any code change that impacts the KB:

```
1. Read _sync/sync-rules.md  →  identify impacted anchors
2. Read _meta/anchors.md     →  find anchor ID and target file
3. .\scripts\update-anchor.ps1 -File "..." -Anchor "..." -Content "..."
4. Add CHANGELOG.md entry
5. .\scripts\validate-kb.ps1
```

Anchor update rule: **replace only content between anchor tags — never edit outside them.**

---

## FAST PATHS

### Add CRUD feature (backend)
```
manifest.yml → 03-conventions.md → services/{service}.md → playbooks/add-feature.md
```

### Debug login
```
manifest.yml → 01-architecture.md §Auth → 05-flows.md
Key facts in manifest: bounded_contexts.authentication.key_facts
```

### Add gRPC method
```
manifest.yml → 06-integrations.md [anchor: grpc-contracts] → playbooks/add-grpc-method.md
Constraint: silent-fail mandatory (catch ALL, return {IsSuccess:false, Error:msg})
```

### Fix permission / 403
```
manifest.yml (TD-002: all [PermissionsAuthorize] commented out) → 07-security-permissions.md
```

### Update KB
```
_sync/sync-rules.md → _meta/anchors.md → update-anchor.ps1 → CHANGELOG.md → validate-kb.ps1
```

---

*~150 lines. Routing layer only — data lives in manifest.yml and service docs.*
*Last updated: 2026-05-24. KB commit: e1be63676087.*
