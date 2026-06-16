# AUTOMATION — Self-Updating Knowledge Base

> **The code is always the source of truth.** This KB is a mirror of the codebase. When they diverge, update the KB — never invent facts.
>
> The system is AI-assisted and drift-aware: scripts detect what changed, map it to affected docs, and surface a prioritized update checklist. A human or AI agent applies the updates.

---

<!-- BEGIN: automation-overview -->
## How It Works

```
Code changes
      │
      ▼
detect-drift.ps1          ← orchestrates all scanners, produces drift report
      │
      ├── scan-endpoints.ps1     controllers   → manifest.yml features[]
      ├── scan-entities.ps1      Domain/Entities → entity-relations.mermaid
      ├── scan-grpc.ps1          .proto files  → manifest.yml integrations[grpc-channel]
      └── scan-events.ps1        ILocalEventBus → manifest.yml features[].events_published
                │
                ▼
           Drift Report
                │
                ▼
      Human or AI agent applies KB updates
                │
                ▼
      validate-manifest.ps1     ID format + cross-reference checks
      validate-anchors.ps1      BEGIN/END anchor pairing
                │
                ▼
      update-changelog.ps1      generates CHANGELOG entry
```

The `_meta/knowledge-impact-map.yml` maps every source file glob to the KB docs affected when that pattern changes.
<!-- END: automation-overview -->

---

<!-- BEGIN: trigger-table -->
## When to Run What

| Code Change | Script | KB Files Affected |
|---|---|---|
| Controller added / route changed | `scan-endpoints.ps1` | `_meta/manifest.yml`, `09-requirements/traceability-matrix.md` |
| Entity added / field changed | `scan-entities.ps1` | `04-business-domain.md`, `diagrams/entity-relations.mermaid` |
| `.proto` file changed | `scan-grpc.ps1` | `_meta/manifest.yml`, `diagrams/grpc-cross-service.mermaid` |
| Event class / handler added | `scan-events.ps1` | `_meta/manifest.yml`, `diagrams/event-choreography.mermaid` |
| `appsettings.json` changed | Manual review | `playbooks/deployment.md`, `playbooks/rollback.md` |
| New EF Core migration | Manual review | `playbooks/migration.md`, `04-business-domain.md` |
| Redis key pattern changed | Manual review | `_meta/manifest.yml#integrations[redis].key_patterns` |
| Frontend route changed | Manual review | `diagrams/frontend-bootstrap-web.mermaid` |
| Any code change | `detect-drift.ps1` | Full cross-domain report |

**Rule**: Run `detect-drift.ps1` before committing any KB update. Run again after to confirm zero remaining drift.
<!-- END: trigger-table -->

---

<!-- BEGIN: running-scripts -->
## Running the Scripts

All scripts run from the **monorepo root** (`d:\SWT_ITZ\Project\CMN\`):

```powershell
# Full drift detection (start here)
.\swt-cmn-knowledge-base\scripts\detect-drift.ps1

# Full drift detection — JSON output (for AI agent consumption)
.\swt-cmn-knowledge-base\scripts\detect-drift.ps1 -OutputFormat JSON

# Individual scanners
.\swt-cmn-knowledge-base\scripts\scan-endpoints.ps1
.\swt-cmn-knowledge-base\scripts\scan-entities.ps1
.\swt-cmn-knowledge-base\scripts\scan-grpc.ps1
.\swt-cmn-knowledge-base\scripts\scan-events.ps1

# Validation (run after KB updates)
.\swt-cmn-knowledge-base\scripts\validate-manifest.ps1
.\swt-cmn-knowledge-base\scripts\validate-anchors.ps1

# Add CHANGELOG entry
.\swt-cmn-knowledge-base\scripts\update-changelog.ps1 `
    -Type "UPDATE" `
    -Description "Synced manifest.yml after EmployeeController.ExportAsync added"
```
<!-- END: running-scripts -->

---

<!-- BEGIN: interpreting-reports -->
## Interpreting Drift Reports

| Symbol | Meaning | Action |
|---|---|---|
| `[NEW]` | In source code, NOT in KB | Add to KB |
| `[STALE]` | In KB, NOT in source code | Remove from KB |
| `[CHANGED]` | Exists in both but signature/path differs | Update KB field |
| `[OK]` | Source and KB match | No action needed |

### Example Report

```
=== DRIFT REPORT 2026-05-24 ===

ENDPOINTS (2 drift items)
  [NEW]   EmployeeController.ExportAsync → GET /api/employee/export
          → Add to manifest.yml features[], 09-requirements/features/employee-management.md
  [STALE] EmployeeController.BulkDeleteAsync → DELETE /api/employee/bulk
          → Remove from manifest.yml (method deleted from codebase)

ENTITIES (0 drift items)  ✓ All 8 entities matched

GRPC (1 drift item)
  [NEW]   rpc GetTenantConfig in administration_service.proto
          → Add to manifest.yml integrations[grpc-channel].operations

EVENTS (0 drift items)    ✓ All 3 events matched

--- SUMMARY ---
Total drift items: 3 (2 NEW, 1 STALE)
Exit code: 1
```
<!-- END: interpreting-reports -->

---

<!-- BEGIN: update-checklists -->
## KB Update Checklists

### Adding a New Endpoint

- [ ] Add feature entry to `_meta/manifest.yml` → features (use `_templates/feature.yml`)
- [ ] Add to `bounded_contexts[id].features` in manifest.yml
- [ ] Add row to `09-requirements/traceability-matrix.md`
- [ ] Reserve next REQ ID in traceability-matrix.md → ID Registry
- [ ] Add requirement doc to `09-requirements/features/*.md`
- [ ] Run `validate-manifest.ps1` → `validate-anchors.ps1`
- [ ] Run `update-changelog.ps1`

### Adding a New Entity

- [ ] Add entity block to `diagrams/entity-relations.mermaid`
- [ ] Update `04-business-domain.md` → Domain Entities section
- [ ] If new business rules: add to `09-requirements/business-rules.md`
- [ ] Update `playbooks/migration.md` → Current Migration Baseline
- [ ] Run `update-changelog.ps1`

### Adding a gRPC Method

- [ ] Add to `_meta/manifest.yml` → integrations[grpc-channel].operations
- [ ] Update `diagrams/grpc-cross-service.mermaid`
- [ ] Confirm `BR-GRPC-001` (silent-fail) is documented
- [ ] Add REQ-GRPC-NNN if new functional requirement
- [ ] Run `update-changelog.ps1`

### Adding a Domain Event + Handler

- [ ] Add to `_meta/manifest.yml` → features[].events_published
- [ ] Update `diagrams/event-choreography.mermaid`
- [ ] If mail-related: update `diagrams/notification-event-handlers.mermaid`
- [ ] Add template code to `MailTemplateConsts` and document in `09-requirements/features/media-notification.md`
- [ ] Run `update-changelog.ps1`
<!-- END: update-checklists -->

---

<!-- BEGIN: anchor-system -->
## Anchor System

Anchored sections can be targeted for surgical updates without editing surrounding content.

### Markdown / HTML files

```html
<!-- BEGIN: section-id -->
...updatable content...
<!-- END: section-id -->
```

### YAML files

```yaml
# === BEGIN: section-id ===
# ...updatable content...
# === END: section-id ===
```

**Rules**:
- Every `BEGIN` must have a matching `END` with the same `section-id`
- IDs are kebab-case: `auth-endpoints`, `grpc-operations`
- `validate-anchors.ps1` reports any unpaired anchors

### Legacy anchor format (Phase 0 — still honored)

```html
<!-- KB-ANCHOR: anchor-id -->
...content...
<!-- /KB-ANCHOR: anchor-id -->
```

Both formats are supported. Prefer the `BEGIN/END` format for new sections.
<!-- END: anchor-system -->

---

<!-- BEGIN: inferred-assumptions -->
## Promoting Inferred Assumptions

When you verify an `[INFERRED]` item against source code:

1. Remove the `[INFERRED]` marker from the KB file.
2. Move the item from `.discovery/inferred-assumptions.md` → `.discovery/confirmed-facts.md` with a source file reference.
3. Add CHANGELOG entry.

Run `.\swt-cmn-knowledge-base\scripts\detect-drift.ps1` to check if the confirmed fact is reflected in the manifest.
<!-- END: inferred-assumptions -->

---

<!-- BEGIN: ci-integration -->
## CI/CD Integration

```yaml
# Add to CI pipeline (GitHub Actions / Azure Pipelines / etc.)
- name: KB Drift Check
  shell: pwsh
  run: |
    $result = .\swt-cmn-knowledge-base\scripts\detect-drift.ps1 -OutputFormat JSON
    $drift = $result | ConvertFrom-Json
    if ($drift.TotalDriftItems -gt 0) {
      Write-Warning "KB drift detected: $($drift.TotalDriftItems) items"
      # Uncomment next line to hard-fail CI on drift:
      # exit 1
    }
```

**Recommended gate**: Warn on drift, do not hard-fail until drift is systematically maintained to zero.
<!-- END: ci-integration -->

---

<!-- BEGIN: ai-agent-instructions -->
## AI Agent Instructions

When an AI agent updates the KB:

1. Always read the current file before editing.
2. Only modify content within anchor tags unless explicitly asked to change surrounding text.
3. Never remove confirmed facts without verifying the code deletion via file read or Grep.
4. Do not leave `[INFERRED]` markers in confirmed-fact sections.
5. Run `validate-manifest.ps1` and `validate-anchors.ps1` after edits.
6. Always add a CHANGELOG entry via `update-changelog.ps1`.
7. After editing, report: which files changed, which anchors updated, and whether drift is now zero.
<!-- END: ai-agent-instructions -->
