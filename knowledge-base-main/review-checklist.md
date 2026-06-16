# KB Review Checklist — CMN Knowledge Base

> Use this checklist when reviewing a PR that contains KB changes, or when performing self-review on AI-generated KB output.
>
> **How to use**: Find the checklist(s) that match the type of change. An unchecked item is a PR blocker.

---

<!-- BEGIN: checklist-index -->
## Checklist Index

| Checklist | Use When |
|---|---|
| **A — Code Change + KB Update** | A PR includes both source code changes and KB updates |
| **B — KB-Only Change** | A PR updates only KB content, no source code change |
| **C — New Feature** | A new feature is being added (entity + endpoints + requirements) |
| **D — AI-Generated KB Output** | An AI agent produced the KB update — extra scrutiny required |
| **E — Quarterly Audit Review** | Reviewing the output of a quarterly audit before snapshot |
| **Quick Reference** | Single-page summary of all must-check items |
<!-- END: checklist-index -->

---

<!-- BEGIN: checklist-a -->
## Checklist A — Code Change + KB Update

*Use when a PR contains both source code changes AND KB updates.*

### A1 — Completeness (Tier 1 gates)

- [ ] If a new controller method was added → `_meta/manifest.yml` features[] updated
- [ ] If a controller method was deleted → removed from manifest.yml (not left as stale)
- [ ] If a new entity was added → `diagrams/entity-relations.mermaid` updated
- [ ] If a `.proto` method was added → manifest.yml `integrations[grpc-channel].operations` updated
- [ ] If an event is newly published → manifest.yml `features[].events_published` updated
- [ ] If technical debt was resolved → manifest.yml `technical_debt` item removed
- [ ] If new technical debt was introduced → manifest.yml `technical_debt` item added with TD-NNN ID

### A2 — Accuracy

- [ ] Endpoint HTTP method in manifest matches `[HttpGet/Post/Put/Delete/Patch]` attribute in code
- [ ] Controller class name and method name in manifest match the actual code identifiers
- [ ] `auth` field in endpoint entry matches the actual attribute (`[AllowAnonymous]` = `anonymous`, `[Authorize]` = `bearer`)
- [ ] Status fields are correct (`implemented`, `partial`, `disabled`) — not aspirational

### A3 — Forbidden Patterns Not Introduced

- [ ] No `ObjectMapper.Map<>()` added (AutoMapper is forbidden — use `new OutputDto { ... }`)
- [ ] No `DbContext` injected into app service (use `IRepository<T, Guid>`)
- [ ] No raw string exceptions (use `throw new UserFriendlyException(L["Key"])`)
- [ ] No `return Ok(...)` or `return Json(...)` (use `return Success(...)`)
- [ ] No new `[AllowAnonymous]` on endpoints that should be protected
- [ ] If gRPC handler added: `try/catch` silent-fail pattern present (BR-GRPC-001)

### A4 — Validation Scripts

- [ ] `validate-manifest.ps1` passes (exit code 0)
- [ ] `validate-anchors.ps1` passes (exit code 0)
- [ ] `detect-drift.ps1` reports 0 remaining drift items (or all remaining items have tickets)

### A5 — CHANGELOG

- [ ] CHANGELOG entry present for the KB change
- [ ] Entry uses correct type (`ADD`, `UPDATE`, `FIX`, `REMOVE`, `VERIFY`)
- [ ] Entry lists specific files changed
<!-- END: checklist-a -->

---

<!-- BEGIN: checklist-b -->
## Checklist B — KB-Only Change

*Use when a PR updates only KB content without any source code change.*

### B1 — Accuracy

- [ ] Every factual claim added or modified is verifiable from current source code
- [ ] No `[INFERRED]` annotation was silently upgraded to a confirmed fact without a source reference
- [ ] No requirement status was changed to `Verified` without AC evidence
- [ ] No requirement status was changed to `Deprecated` without explicit stakeholder sign-off
- [ ] No business rule was removed without verifying the code constraint was actually removed

### B2 — Consistency

- [ ] IDs follow the correct format: `REQ-DOMAIN-NNN`, `BR-DOMAIN-NNN`, `TD-NNN`
- [ ] New IDs reserved using the ID Registry in `09-requirements/traceability-matrix.md`
- [ ] ID counters in traceability-matrix.md and manifest.yml are consistent
- [ ] Anchor markers added: `validate-anchors.ps1` passes (exit code 0)
- [ ] Manifest valid: `validate-manifest.ps1` passes (exit code 0)

### B3 — No Silent Deletions

- [ ] Nothing was removed that was confirmed from source code (only stale/wrong content was removed)
- [ ] If content was removed: reviewer has verified the removal is correct (read the source code)

### B4 — CHANGELOG

- [ ] CHANGELOG entry present
<!-- END: checklist-b -->

---

<!-- BEGIN: checklist-c -->
## Checklist C — New Feature Added

*Use when a complete new feature is being added (entity + endpoints + frontend + requirements). Combines A + B with additional completeness checks.*

### C1 — Requirements Coverage

- [ ] REQ-DOMAIN-NNN reserved in `09-requirements/traceability-matrix.md` ID Registry
- [ ] Full requirement doc added to `09-requirements/features/*.md` using `templates/requirement-template.md`
- [ ] Acceptance criteria written (at minimum 2 ACs per REQ)
- [ ] Business rules identified and added to `09-requirements/business-rules.md`
- [ ] Traceability matrix row added with: status, controller, app service method, diagram reference

### C2 — Manifest Coverage

- [ ] Feature entry added to `_meta/manifest.yml` features[] (using `_templates/feature.yml`)
- [ ] Feature added to `bounded_contexts[id].features` list
- [ ] Endpoints include `auth` field for each endpoint
- [ ] Status is `implemented` (not `planned` if code is shipping)

### C3 — Diagram Coverage

- [ ] At minimum one diagram exists for the new feature (sequence or flowchart)
- [ ] Diagram added to `diagrams/` directory
- [ ] Diagram referenced in manifest.yml `features[].diagram`
- [ ] Diagram referenced in traceability-matrix.md row

### C4 — Playbook Applicability

- [ ] If this feature introduces a new architectural pattern: relevant playbook is updated
- [ ] If this feature adds a new business rule that is a general constraint: add to `03-conventions.md`

### C5 — Validation + CHANGELOG

- [ ] All Checklist A validation steps pass
- [ ] CHANGELOG entry present
<!-- END: checklist-c -->

---

<!-- BEGIN: checklist-d -->
## Checklist D — AI-Generated KB Output

*Use when reviewing KB content produced by an AI agent (Claude Code or similar). Apply IN ADDITION to Checklist A or B.*

### D1 — Confidence Level Verification

- [ ] Any `[INFERRED]` items are appropriate — AI cannot verify from code what it hasn't read
- [ ] Any `[UNVERIFIED — check source]` items have been verified by the human reviewer before merging
- [ ] No items have been silently promoted from `[INFERRED]` to confirmed without evidence

### D2 — Hallucination Check (Critical)

For any class name, method name, or file path referenced by the AI:
- [ ] The class/method EXISTS in the codebase (search with Grep or code-review-graph)
- [ ] The method signature matches (parameter types, return types)
- [ ] The file path exists on disk
- [ ] Any Redis key formats, consts values, or TTLs match actual code — not approximated

### D3 — Restricted Action Verification

Verify the AI did NOT autonomously perform any of these (governance.md restricted actions):
- [ ] AI did NOT remove a confirmed business rule
- [ ] AI did NOT change a REQ status to `Deprecated` or `Verified`
- [ ] AI did NOT remove a service from manifest.yml
- [ ] AI did NOT modify governance.md, this file, or audit-playbook.md content
- [ ] AI did NOT resolve a technical debt item without code evidence

### D4 — Completeness vs. Scope Creep

- [ ] AI updated only what was in scope (did not add unrequested KB entries)
- [ ] AI did not omit any Tier 1 mandatory updates for code changes in the same PR
- [ ] AI-generated CHANGELOG entry accurately describes what changed

### D5 — AI Audit Trail

- [ ] AI session produced a CHANGELOG entry
- [ ] AI session noted any remaining drift items it found but did NOT fix
- [ ] Confidence level of changes is documented or can be inferred from context
<!-- END: checklist-d -->

---

<!-- BEGIN: checklist-e -->
## Checklist E — Quarterly Audit Review

*Use when reviewing the output of a quarterly audit (audit-playbook.md Phase 1–7) before creating the snapshot.*

### E1 — Drift Audit Complete

- [ ] `detect-drift.ps1` exit code = 0 (or all remaining items have tickets with sprint assigned)
- [ ] All `[STALE]` items verified against code (not just removed blindly)
- [ ] All `[NEW]` items with severity `high` are fixed, not just ticketed

### E2 — Requirements System Current

- [ ] ID Registry in traceability-matrix.md is accurate (`last_used` matches highest actual ID)
- [ ] No REQ has incorrect status (spot-check 3–5 REQs against actual code)
- [ ] Coverage Gaps table is current

### E3 — Diagrams Verified

- [ ] All 15 diagrams reviewed (Phase 3 checklist in audit-playbook.md)
- [ ] Any disabled features still marked as disabled in diagrams (e.g., SendOTPEvent red)

### E4 — Technical Debt Inventory Current

- [ ] All 8 TD items verified against source code
- [ ] Any resolved TDs removed
- [ ] Any new TDs documented

### E5 — Snapshot Ready

- [ ] `validate-manifest.ps1` PASS
- [ ] `validate-anchors.ps1` PASS
- [ ] Snapshot created and committed
- [ ] Audit report filed in `_meta/audit-reports/`
- [ ] Audit History table in `audit-playbook.md` updated
<!-- END: checklist-e -->

---

<!-- BEGIN: quick-reference -->
## Quick Reference — Must-Check Items

The 10 items that catch the most drift and errors:

| # | Check | Where |
|---|---|---|
| 1 | New endpoints in manifest.yml with correct HTTP method and auth | `_meta/manifest.yml` features[] |
| 2 | Deleted endpoints removed from manifest (no stale entries) | `_meta/manifest.yml` features[] |
| 3 | No `ObjectMapper.Map<>()` — inline `new OutputDto { ... }` only | Code review |
| 4 | gRPC handlers have `try/catch` silent-fail | Code review (BR-GRPC-001) |
| 5 | REQ IDs follow `REQ-DOMAIN-NNN` format | `09-requirements/` |
| 6 | ID Registry counters are correct | `traceability-matrix.md` |
| 7 | `validate-manifest.ps1` exits 0 | Run script |
| 8 | `validate-anchors.ps1` exits 0 | Run script |
| 9 | CHANGELOG entry present | `CHANGELOG.md` |
| 10 | AI-generated content: class/method names exist in code | Grep / code search |
<!-- END: quick-reference -->

---

<!-- BEGIN: reviewer-notes -->
## Reviewer Notes

### If You Find a Forbidden Pattern

1. Block the PR
2. Link to `03-conventions.md` Forbidden Patterns section
3. Note the specific pattern: `return Ok(data)` → should be `return Success(data)`
4. Do not merge until fixed

### If You Find a Stale KB Entry

1. Don't just remove it — verify in code first
2. If code confirms it's gone: remove from KB and CHANGELOG it
3. If code shows it was renamed: update KB to new name

### If You Find Missing Technical Debt

1. Add to `_meta/manifest.yml` technical_debt with next available TD-NNN
2. Note severity (high/medium/low) and resolution path
3. Create a ticket if severity is high or medium
<!-- END: reviewer-notes -->
