# Add Feature — CMN

Add a complete new feature to the CMN system following the knowledge base playbook.

## Arguments

$ARGUMENTS — describe the feature in natural language. Examples:
- "employee export CSV — administration-api"
- "REQ-EMP-006: export danh sách nhân viên ra file CSV"
- "add role permission matrix endpoint — admin-api — PERM domain"

## Execution Protocol

### Step 0 — Parse Intent

Extract from $ARGUMENTS:
- **Feature name** (what it does)
- **Service**: `administration-api` | `customer-api` (default: `administration-api`)
- **Domain**: AUTH | EMP | MEDIA | NOTIF | PERM | ROLE | GRPC | CUST | INFRA (infer from description)
- **REQ ID**: if user provides one (REQ-XXX-NNN), use it; otherwise reserve next available from ID Registry

### Step 1 — Load Minimal KB Context (token budget: read 3 files max)

Read in order, STOP expanding once context is sufficient:

1. **`swt-cmn-knowledge-base/_meta/manifest.yml`** — lines `# === BEGIN: bounded-contexts ===` to `# === END: bounded-contexts ===` only
   - Confirm the domain and service mapping
   - Find linked existing REQ IDs to avoid duplication

2. **`swt-cmn-knowledge-base/playbooks/add-feature.md`**
   - This is the authoritative step list — follow it exactly, do not improvise

3. **`swt-cmn-knowledge-base/09-requirements/traceability-matrix.md`** — ID Registry section only
   - Get the `next_available` ID for the domain
   - Do NOT read the full matrix; use `offset` to skip to the ID Registry table

**Do NOT read**: full manifest.yml, business-rules.md, other playbooks, diagrams (unless the playbook step requires one).

### Step 2 — Explore Existing Code Patterns (use code-review-graph)

Before writing any code:
```
semantic_search_nodes: "[FeatureName] OR [DomainController]"
```
Find the existing controller and app service for this domain. Read ONE existing similar feature (e.g., if adding export, find an existing GetListAsync) for pattern reference. Use `get_review_context` to fetch source — do NOT use Read on the whole file.

### Step 3 — Read Conventions (forbidden patterns only)

Read `swt-cmn-knowledge-base/03-conventions.md` — skip to `## Forbidden Patterns (Backend)` section. This is mandatory. Stop reading when you reach `## Architecture Constraints`.

### Step 4 — Execute Playbook

Follow `playbooks/add-feature.md` step by step:

**Phase 1 — Backend**
- Domain consts → Entity update (if needed) → Migration (if needed) → Permission key → InputDto + Validator → OutputDto → IAppService method → AppService impl → Localization keys → Controller action → Tests (note: test files likely missing per TD-008)

**Phase 2 — Frontend** (skip if user says backend only)
- Service method → Store thunk → Page component

**Phase 3 — KB Update** (mandatory, always)
- Update `_meta/manifest.yml` → features[] with new feature entry (use `_templates/feature.yml` as shape)
- Update `_meta/manifest.yml` → bounded_contexts[domain].features[]
- Update `09-requirements/traceability-matrix.md` → add row + increment ID Registry counter
- Create or append to `09-requirements/features/{domain-filename}.md` with full REQ doc

### Step 5 — Validate

```powershell
.\swt-cmn-knowledge-base\scripts\validate-manifest.ps1
.\swt-cmn-knowledge-base\scripts\validate-anchors.ps1
```

If errors: fix before reporting done.

### Step 6 — Changelog

```powershell
.\swt-cmn-knowledge-base\scripts\update-changelog.ps1 `
  -Type "ADD" `
  -Description "[FeatureName] added to [service]" `
  -Source "[ControllerClass.MethodAsync]"
```

## Critical CMN Rules (always apply)

- `return Success(data)` — NEVER `return Ok(data)`
- `throw new UserFriendlyException(L["Key"])` — NEVER raw strings
- `new OutputDto { Id = entity.Id, ... }` — NEVER `ObjectMapper.Map<>()`
- `IRepository<T, Guid>` — NEVER inject DbContext
- `await AsyncExecuter.ToListAsync(query)` — NEVER `.ToListAsync()` directly
- New endpoints: leave `[PermissionsAuthorize]` commented out initially (TD-002 policy)
- New entities: must implement `IMultiTenant` (unless system-wide — document explicitly)
- Schema: `ADM` for administration-api, `CM` for customer-api
