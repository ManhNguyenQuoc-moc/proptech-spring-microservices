# Quarterly Audit Playbook — CMN Knowledge Base

> Run this playbook once per quarter (January, April, July, October).
> Time estimate: ~3 hours total. Delegate phases to domain owners if available.
> Produces: drift report, requirements status update, tech debt review, KB snapshot, audit report.

---

<!-- BEGIN: audit-overview -->
## Audit Overview

A quarterly audit verifies that the KB accurately reflects:
1. Current codebase (drift audit)
2. Current requirements and their implementation status (requirements audit)
3. Current architecture diagrams (diagram audit)
4. Outstanding technical debt (debt audit)
5. Playbook validity (playbook audit)

At the end of the audit, create a **release snapshot** (see Phase 6) and file an **audit report** (see Phase 7).
<!-- END: audit-overview -->

---

<!-- BEGIN: audit-schedule -->
## Audit Schedule

| Quarter | Target Window | Snapshot Tag |
|---|---|---|
| Q1 | Jan 1–15 | `kb/YYYY-Q1` |
| Q2 | Apr 1–15 | `kb/YYYY-Q2` |
| Q3 | Jul 1–15 | `kb/YYYY-Q3` |
| Q4 | Oct 1–15 | `kb/YYYY-Q4` |

**Audit Owner**: KB Owner (see `governance.md` → Ownership Model)

**Participants**: Domain owners for their respective areas; all required for Phase 1 (drift).

**Past Audits**:

| Date | Auditor | Snapshot | Drift Items | TDs Resolved | Report |
|---|---|---|---|---|---|
| *(first audit TBD)* | — | — | — | — | — |
<!-- END: audit-schedule -->

---

<!-- BEGIN: pre-audit-checklist -->
## Pre-Audit Checklist

Complete before starting Phase 1:

- [ ] Confirm all Tier 1 and Tier 2 KB updates from the past quarter are merged
- [ ] Confirm `_meta/manifest.yml` updated: version and `updated` date set to today
- [ ] Pull latest code for all services (admin-api, customer-api)
- [ ] Run `validate-manifest.ps1` — resolve any errors before proceeding
- [ ] Run `validate-anchors.ps1` — resolve any errors before proceeding
- [ ] Open `CHANGELOG.md` — review entries from the past quarter for completeness
- [ ] Identify any open drift items from the previous audit report
<!-- END: pre-audit-checklist -->

---

<!-- BEGIN: phase-1-drift -->
## Phase 1 — Drift Audit (30 min)

Run all drift detection scripts and document results.

### Step 1: Full Drift Scan

```powershell
# Run from monorepo root
.\swt-cmn-knowledge-base\scripts\detect-drift.ps1 -OutputFormat JSON > audit-drift-YYYY-QN.json
.\swt-cmn-knowledge-base\scripts\detect-drift.ps1
```

### Step 2: Document Findings

For each drift item reported:

| Item ID | Type | Description | Priority | Assigned To | Fix Sprint |
|---|---|---|---|---|---|
| DRIFT-001 | NEW/STALE/CHANGED | *(description)* | High/Medium | *(owner)* | *(sprint)* |

Copy this table into the audit report (Phase 7).

### Step 3: Triage

- **[NEW]** items with severity `high` (controllers, entities, gRPC): fix before closing audit
- **[NEW]** items with severity `medium/low`: create KB maintenance ticket for next sprint
- **[STALE]** items: verify code is actually deleted (not renamed), then remove from KB
- **[CHANGED]** items: update the specific manifest field

### Step 4: Endpoint Security Spot-Check

Review the endpoint list from `scan-endpoints.ps1` for:
- [ ] Any `[AllowAnonymous]` on endpoints that should be authenticated
- [ ] Any endpoints present in code but missing `auth` field in manifest

Known issue: **TD-001** — `POST /employee` has `[AllowAnonymous]`. Verify this is still present and still tracked.

### Phase 1 Exit Criteria

- [ ] Drift scan complete and results documented
- [ ] All high-severity `[NEW]` items fixed or tickets created
- [ ] All `[STALE]` items verified and removed
- [ ] `detect-drift.ps1` exit code = 0 (or all remaining items have tickets)
<!-- END: phase-1-drift -->

---

<!-- BEGIN: phase-2-requirements -->
## Phase 2 — Requirements Audit (45 min)

Review the requirements system for accuracy and completeness.

### Step 1: REQ Status Review

Open `09-requirements/traceability-matrix.md`. For each row:

- [ ] Verify status (`✅ Implemented`, `⚠️ Partial`, `❌ Not implemented`, `🔒 Disabled`)
- [ ] Check if any `[Missing]` test files have been added since last audit
- [ ] Check if any `Partial` items have been completed

**Flag for attention**: Any REQ with status mismatch (code says implemented, KB says partial, or vice versa).

### Step 2: AC Coverage Check

For each feature in `09-requirements/features/`:
- [ ] Are all acceptance criteria still valid?
- [ ] Have any ACs been verified and should be checked (`- [x]` instead of `- [ ]`)?
- [ ] Are any ACs now invalid due to a design change?

**Current coverage gap**: Zero ACs are verified (all `- [ ]`). Target for next audit: at minimum manually verify 25% of ACs per domain.

### Step 3: Business Rules Currency

Open `09-requirements/business-rules.md`. For each rule:
- [ ] Does the source file/method still exist?
- [ ] Is the enforcement still active (not commented out)?
- [ ] Are the parameter values (consts) still current?

Pay special attention to rules referencing commented-out code (BR-AUTH-001 linked to disabled 2FA, etc.)

### Step 4: ID Registry Sanity

Open `09-requirements/traceability-matrix.md` → ID Registry.

For each domain:
- [ ] `Last Used` matches the highest actual ID in the features files
- [ ] `Next Available` = `Last Used` + 1

Update any discrepancies immediately.

### Step 5: Coverage Gaps Table

Update the Coverage Gaps table at the bottom of `traceability-matrix.md`:
- Remove any gaps that have been resolved
- Add any new gaps discovered during this audit

### Phase 2 Exit Criteria

- [ ] All REQ statuses verified accurate
- [ ] ID registry is correct
- [ ] Coverage Gaps table is current
<!-- END: phase-2-requirements -->

---

<!-- BEGIN: phase-3-diagrams -->
## Phase 3 — Diagram Currency Audit (30 min)

Verify that Mermaid diagrams still reflect real implementation behavior.

### Diagrams to Audit

| Diagram | Key Things to Check |
|---|---|
| `diagrams/architecture.mermaid` | All 7 services present; port numbers correct; integrations accurate |
| `diagrams/entity-relations.mermaid` | All entities present; key fields correct; no phantom entities |
| `diagrams/auth-login.mermaid` | Login field is Employee.Code; 2FA disabled note present |
| `diagrams/auth-token-refresh.mermaid` | 401 interceptor flow; cookie storage; Redis key format |
| `diagrams/auth-password-reset.mermaid` | UUID → Encrypt → Redis flow; IsUsed=true check |
| `diagrams/sync-employee-identity.mermaid` | IdentityUser created before Employee; lockout behavior |
| `diagrams/sync-employee-import.mermaid` | 2-step import; 5MB/100 row limits; 30min TTL |
| `diagrams/event-choreography.mermaid` | SendOTPEvent styled as disabled; 3 active handlers |
| `diagrams/grpc-cross-service.mermaid` | Silent-fail on all operations; OR semantics for CheckPermissions |
| `diagrams/notification-mail-template.mermaid` | MongoDB source; ##Group.Field## placeholder |
| `diagrams/frontend-bootstrap-web.mermaid` | Cookie storage; X-Tenant header; 401 auto-refresh |
| `diagrams/frontend-bootstrap-mobile.mermaid` | get_storage (unencrypted — TD-007); BASE_URL |
| `diagrams/state-*.mermaid` (3 files) | State transitions match real conditions |
| `diagrams/worker-abp-background-jobs.mermaid` | ABP (not Hangfire); SQL Server backed |

### Audit Method

For each diagram:
1. Read the diagram file
2. Open the corresponding source code (controller/service/entity)
3. Verify key assertions in the diagram match the code
4. Mark `[OK]` or note discrepancy

### Known Diagram Gaps

- `diagrams/data-flow.mermaid` — verify token storage still says cookies (fixed in Phase 4)
- No diagram exists for the Roles feature — consider adding if complexity warrants

### Phase 3 Exit Criteria

- [ ] All 15 diagrams reviewed
- [ ] Any inaccurate diagrams updated
- [ ] CHANGELOG entry for each updated diagram
<!-- END: phase-3-diagrams -->

---

<!-- BEGIN: phase-4-tech-debt -->
## Phase 4 — Technical Debt Audit (20 min)

Review all technical debt items in `_meta/manifest.yml` → `technical_debt`.

### For Each TD Item

Open `_meta/manifest.yml`, find `technical_debt:`. For each item:

| Check | Question |
|---|---|
| Still exists? | Does the code issue described still exist? (Read the source file) |
| Severity correct? | Has the risk changed since the TD was logged? |
| Resolution path clear? | Is the `resolution` field actionable? |

### Current TD Inventory

| ID | Title | Severity | Last Reviewed | Status |
|---|---|---|---|---|
| TD-001 | [AllowAnonymous] on POST /employee | HIGH | 2026-05-23 | Open |
| TD-002 | All [PermissionsAuthorize] commented out | HIGH | 2026-05-23 | Open |
| TD-003 | Physical Cloudinary deletion disabled | MEDIUM | 2026-05-23 | Open |
| TD-004 | 2FA SendOTPEvent disabled | MEDIUM | 2026-05-23 | Open |
| TD-005 | IP rate limiting disabled | MEDIUM | 2026-05-23 | Open |
| TD-006 | Namespace defect in MongoDbContext | LOW | 2026-05-23 | Open |
| TD-007 | Mobile token storage unencrypted | MEDIUM | 2026-05-23 | Open |
| TD-008 | Zero automated test coverage | HIGH | 2026-05-23 | Open |

### TD Actions

- **Resolved**: Remove from manifest.yml, add CHANGELOG entry noting the fix
- **New TD found**: Add entry with next available TD-NNN, with severity, location, and resolution
- **Priority changed**: Update severity field in manifest.yml

### Phase 4 Exit Criteria

- [ ] All TD items verified (code reviewed, not just KB read)
- [ ] Resolved items removed
- [ ] New items added
- [ ] `last_reviewed` date updated (add this field to TD entries going forward)
<!-- END: phase-4-tech-debt -->

---

<!-- BEGIN: phase-5-playbooks -->
## Phase 5 — Playbook Verification (30 min)

Verify that engineering playbooks still work as written.

### Audit Method

Pick **one playbook** per quarterly audit to execute end-to-end (rotate through all 9 playbooks over ~3 years). Check the rest by reading only.

**Playbooks to rotate through**:

| Audit | Execute | Read-Only Review |
|---|---|---|
| 2026-Q3 | `add-endpoint.md` | All others |
| 2026-Q4 | `add-entity.md` | All others |
| 2027-Q1 | `migration.md` | All others |
| 2027-Q2 | `add-event.md` | All others |
| *(continue rotating)* | | |

### Read-Only Review Checklist

For each playbook, verify:
- [ ] Class names and method names referenced still exist in codebase
- [ ] File paths referenced still exist
- [ ] Commands (dotnet build, npm install, etc.) still valid
- [ ] No forbidden patterns introduced since playbook was written

### Playbooks at Risk (most likely to drift)

- `playbooks/migration.md` — Current Migration Baseline table goes stale as migrations are added
- `playbooks/deployment.md` — Port numbers, infra addresses may change
- `playbooks/add-endpoint.md` — Forbidden pattern list may grow

### Phase 5 Exit Criteria

- [ ] One playbook executed end-to-end without errors
- [ ] All playbooks reviewed for stale references
- [ ] Any stale references updated
<!-- END: phase-5-playbooks -->

---

<!-- BEGIN: phase-6-snapshot -->
## Phase 6 — Release Snapshot (15 min)

Create an immutable KB snapshot for this quarter.

```powershell
# Run from monorepo root
$quarter = "2026-Q3"   # adjust per audit
$snapshot = "swt-cmn-knowledge-base\.snapshots\$quarter"

# Validate before snapshot
.\swt-cmn-knowledge-base\scripts\validate-manifest.ps1
.\swt-cmn-knowledge-base\scripts\validate-anchors.ps1

# Create snapshot
New-Item -ItemType Directory -Path $snapshot -Force

Get-ChildItem swt-cmn-knowledge-base -Recurse |
    Where-Object { $_.FullName -notmatch '\\.snapshots\\' -and -not $_.PSIsContainer } |
    ForEach-Object {
        $dest = $_.FullName.Replace(
            (Join-Path $PWD "swt-cmn-knowledge-base"),
            (Join-Path $PWD $snapshot)
        )
        New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null
        Copy-Item $_.FullName $dest
    }

Write-Host "Snapshot created: $snapshot"

# Update manifest.yml updated date
# (edit _meta/manifest.yml → updated: "YYYY-MM-DD")

# Add CHANGELOG entry
.\swt-cmn-knowledge-base\scripts\update-changelog.ps1 `
    -Type "VERIFY" `
    -Description "$quarter quarterly audit complete — snapshot created" `
    -Source "Quarterly audit"
```

### What to Verify After Snapshot

- [ ] Snapshot directory exists and contains all expected files
- [ ] `manifest.yml` in snapshot matches the current one
- [ ] Snapshot is committed to version control (if applicable)
<!-- END: phase-6-snapshot -->

---

<!-- BEGIN: audit-report-template -->
## Phase 7 — Audit Report

Create a file at `_meta/audit-reports/audit-YYYY-QN.md` using this template:

```markdown
# KB Audit Report — YYYY-QN

**Date**: YYYY-MM-DD
**Auditor**: [Name]
**Duration**: ~N hours

## Summary

| Area | Status | Drift Items | Actions Taken |
|---|---|---|---|
| Drift Audit | ✅ Clean / ⚠️ N items | N | N fixed, N ticketed |
| Requirements | ✅ Current / ⚠️ N updates | — | N statuses updated |
| Diagrams | ✅ Current / ⚠️ N updated | — | N diagrams corrected |
| Technical Debt | ✅ Current / N new / N resolved | — | Inventory updated |
| Playbooks | ✅ Verified / ⚠️ N stale refs | — | N refs updated |

## Drift Items Found

| ID | Type | Description | Resolution | Sprint |
|---|---|---|---|---|

## Requirements Changes

*(List any REQ status changes, new REQs added, ACs verified)*

## Technical Debt Changes

*(New TDs added, TDs resolved)*

## Diagrams Updated

*(List diagrams corrected and what changed)*

## Open Items (carry to next audit)

*(Unresolved drift items, known gaps)*

## Snapshot

Tag: kb/YYYY-QN
Files in snapshot: N
validation-manifest: PASS / FAIL (N errors)
validate-anchors: PASS / FAIL (N errors)
```
<!-- END: audit-report-template -->

---

<!-- BEGIN: audit-history -->
## Audit History

| Quarter | Date | Auditor | Drift Items | TDs Resolved | Report |
|---|---|---|---|---|---|
| *(pending — first audit Q3 2026)* | — | — | — | — | — |
<!-- END: audit-history -->
