# Sync Source — CMN

Detect drift between the CMN source code and knowledge base, then apply updates.

## Arguments

$ARGUMENTS — optional scope. Examples:
- (empty) — full drift detection across all domains
- "endpoints" — sync only HTTP endpoints
- "entities" — sync only domain entities
- "grpc" — sync only gRPC methods
- "events" — sync only domain events
- "after-feature EmployeeController.ExportAsync" — sync after a specific code addition

## Execution Protocol

### Step 1 — Run Drift Detection

**Full sync** (no arguments or scope is "all"):
```powershell
.\swt-cmn-knowledge-base\scripts\detect-drift.ps1 -OutputFormat JSON
```

Save the output mentally. Do NOT read the whole manifest.yml yet — let the drift report tell you what to read.

**Scoped sync** (e.g., "endpoints" only):
```powershell
.\swt-cmn-knowledge-base\scripts\scan-endpoints.ps1
# or: scan-entities.ps1 | scan-grpc.ps1 | scan-events.ps1
```

### Step 2 — Triage Drift Items

Classify each drift item by priority before acting:

| Item Type | Priority | Action |
|---|---|---|
| `[NEW]` controller method — severity high | Fix now | Add to manifest.yml features[] |
| `[NEW]` entity — severity high | Fix now | Update entity-relations.mermaid |
| `[NEW]` gRPC rpc method | Fix now | Add to manifest.yml integrations[grpc-channel] |
| `[NEW]` domain event | Fix now | Add to manifest.yml features[].events_published |
| `[STALE]` controller method | Verify then fix | Read the controller file — confirm method is deleted |
| `[STALE]` entity | Verify then fix | Grep for class — confirm class is gone |
| Any item severity `low` | Defer | Note in summary, create ticket |

If 0 drift items: report "KB is in sync with source code." and stop.

### Step 3 — Fix [NEW] Items

For each [NEW] endpoint (controller method):

1. Read the actual controller file (only the method found by the scanner):
   ```
   Read [controller file] offset:[method line] limit:[~30 lines]
   ```
2. Extract: HTTP method, route, `[AllowAnonymous]`/`[Authorize]`, response type
3. Determine: which bounded context owns this endpoint
4. Read `swt-cmn-knowledge-base/_meta/manifest.yml` — only the `# === BEGIN: features ===` section
5. Add feature entry using `_templates/feature.yml` shape
6. Add to corresponding `bounded_contexts[id].features[]`
7. Add row to `09-requirements/traceability-matrix.md`

For each [NEW] entity:

1. Read the entity class file (targeted)
2. Extract: entity name, key fields, base class, IMultiTenant
3. Add entity block to `diagrams/entity-relations.mermaid`
4. Note in `04-business-domain.md` if it represents a new domain concept

For each [NEW] gRPC rpc method:

1. Read the .proto file method signature
2. Add operation to `_meta/manifest.yml` → `integrations[grpc-channel].operations`
3. Update `diagrams/grpc-cross-service.mermaid`

For each [NEW] domain event:

1. Identify: which feature publishes it, which handler consumes it
2. Add to `_meta/manifest.yml` → relevant feature's `events_published[]`
3. Update `diagrams/event-choreography.mermaid`

### Step 4 — Fix [STALE] Items

For each [STALE] item:

1. Verify the code is actually gone — do NOT blindly delete KB entries:
   ```
   Grep pattern:"[ClassName]|[MethodName]" in [service directory]
   ```
2. If confirmed gone: remove from manifest.yml
3. If renamed: update to new name (treat as [CHANGED])
4. If moved to different service: update service reference

### Step 5 — Validate

```powershell
.\swt-cmn-knowledge-base\scripts\validate-manifest.ps1
.\swt-cmn-knowledge-base\scripts\validate-anchors.ps1
```

Fix any validation errors before continuing.

### Step 6 — Re-run Drift Check

```powershell
.\swt-cmn-knowledge-base\scripts\detect-drift.ps1
```

Target: exit code 0 (zero drift) or all remaining items explained and ticketed.

### Step 7 — Changelog + Report

```powershell
.\swt-cmn-knowledge-base\scripts\update-changelog.ps1 `
  -Type "UPDATE" `
  -Description "KB sync — [N] new items added, [N] stale items removed" `
  -Source "detect-drift.ps1 scan"
```

Report to user:
- Total drift items found
- Items fixed now
- Items deferred (with reason)
- Validation result

## When to Run sync-source

- After merging any feature PR (Tier 1 SLA)
- Before starting a quarterly audit (`audit-playbook.md`)
- After onboarding a new team member who may have added unreported code
- Whenever `detect-drift.ps1` is suspected to show drift

## ID Registry Updates

After adding any new REQ entry to `09-requirements/traceability-matrix.md`:
- Increment `last_used` for the domain
- Set `next_available = last_used + 1`
- Do the same in `_meta/manifest.yml` → `requirements.domains[].last_used`
