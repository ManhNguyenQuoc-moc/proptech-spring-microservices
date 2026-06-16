# Governance — CMN Knowledge Base

> This document defines the rules, ownership model, SLAs, and policies that keep the CMN Knowledge Base accurate and trustworthy across multiple teams, releases, and AI-assisted workflows.

---

<!-- BEGIN: overview -->
## Overview

The CMN Knowledge Base is a **shared engineering artifact**, not a project readme. It is relied upon by:
- Human developers onboarding to the system
- AI agents executing tasks against the codebase
- Automated drift detection (Phase 8 scripts)
- Security reviews, audits, and compliance checks

When the KB is wrong, AI agents produce wrong code. When the KB is stale, onboarding takes longer and bugs multiply. **Governance exists to prevent both.**

### Principles

| Principle | Rule |
|---|---|
| Code is source of truth | KB reflects code. When they diverge, update KB — never invent. |
| Explicit ownership | Every domain has a named owner. Ownerless areas decay. |
| Mandatory over optional | "Should update" becomes "will not update." Only mandatory gates work. |
| AI-assisted, human-accountable | AI agents accelerate KB maintenance but humans sign off on all substantive changes. |
| Quarterly heartbeat | At minimum, one full audit per quarter to prevent silent drift. |
<!-- END: overview -->

---

<!-- BEGIN: ownership-model -->
## Ownership Model

### KB Owner (Primary)

The **KB Owner** is accountable for the KB as a whole. Responsibilities:
- Approves structural changes (new sections, deprecated sections, format changes)
- Runs or delegates quarterly audits
- Resolves ownership disputes
- Reviews and merges governance.md changes
- Ensures AI-agent governance policies are followed

**Current KB Owner**: CMN Development Team (`tadat290903@gmail.com`)

### Domain Owners (Delegated)

Each bounded context has a delegated owner responsible for keeping that domain's KB content current.

| Domain | KB Sections | Owner | Escalation |
|---|---|---|---|
| Authentication | `06-authentication.md`, `diagrams/auth-*.mermaid`, `09-requirements/features/authentication.md` | CMN Team | KB Owner |
| Employee Management | `04-business-domain.md` (employee section), `diagrams/sync-employee-*.mermaid`, `09-requirements/features/employee-management.md` | CMN Team | KB Owner |
| Media / Notifications | `diagrams/notification-*.mermaid`, `09-requirements/features/media-notification.md` | CMN Team | KB Owner |
| Infrastructure / Integrations | `_meta/manifest.yml` (integrations), `playbooks/deployment.md`, `playbooks/rollback.md` | CMN Team | KB Owner |
| Requirements System | `09-requirements/` | CMN Team | KB Owner |
| Automation System | `AUTOMATION.md`, `scripts/`, `_meta/` | CMN Team | KB Owner |

**When a new team joins CMN**: Assign domain ownership before that team's first sprint. An unowned domain is a governance gap.

### Ownership Change Protocol

1. New owner proposed in `governance.md` PR
2. Outgoing owner approves (or KB Owner approves if outgoing is unavailable)
3. 30-day overlap period: both owners are notified of changes
4. After 30 days: new owner is sole owner
<!-- END: ownership-model -->

---

<!-- BEGIN: update-sla -->
## Update SLA — When to Update the KB

### Tier 1 — MANDATORY (block merge)

These KB updates are required **before merging the code change**. A PR without them is incomplete.

| Code Change | Required KB Update |
|---|---|
| New HTTP endpoint added | `_meta/manifest.yml` features[] + `09-requirements/traceability-matrix.md` |
| Endpoint deleted or renamed | `_meta/manifest.yml` features[] (remove/update) + traceability matrix |
| New domain entity | `diagrams/entity-relations.mermaid` + `04-business-domain.md` |
| New business rule enforced in code | `09-requirements/business-rules.md` + `_meta/manifest.yml` |
| New gRPC method in .proto | `_meta/manifest.yml` integrations[grpc-channel].operations + `diagrams/grpc-cross-service.mermaid` |
| New domain event published | `_meta/manifest.yml` features[].events_published + `diagrams/event-choreography.mermaid` |
| Technical debt resolved | `_meta/manifest.yml` technical_debt (remove item) |
| New technical debt identified | `_meta/manifest.yml` technical_debt (add TD-NNN item) |

### Tier 2 — TIMELY (within same sprint)

| Code Change | Required KB Update |
|---|---|
| New EF Core migration | `playbooks/migration.md` → Current Migration Baseline table |
| New Redis key pattern | `_meta/manifest.yml` integrations[redis].key_patterns |
| Config key added to appsettings.json | `playbooks/deployment.md` environment config section |
| Feature disabled (commented out) | `_meta/manifest.yml` disabled_features + CHANGELOG |
| Feature re-enabled | Remove from disabled_features + update status + CHANGELOG |

### Tier 3 — OPPORTUNISTIC (next available slot)

| Code Change | Required KB Update |
|---|---|
| Frontend route changed | `diagrams/frontend-bootstrap-web.mermaid` |
| New npm/NuGet package added | `02-architecture.md` tech stack section |
| Code comments explain non-obvious behavior | Consider adding to relevant `business-rules.md` entry |
| New team member onboarded | No KB update needed unless workflow gaps discovered |

### SLA Enforcement

- Tier 1: automated check via `scan-endpoints.ps1` / `scan-entities.ps1` as pre-merge gate (see `AUTOMATION.md` CI integration)
- Tier 2: tracked in sprint board under "KB Maintenance" story
- Tier 3: backlog item, addressed in quarterly audit if not done
<!-- END: update-sla -->

---

<!-- BEGIN: approval-workflow -->
## Approval Workflow

### KB Change Types and Required Approvals

| Change Type | Requires Approval From | Review Checklist |
|---|---|---|
| Additive (new feature/REQ/BR documented) | Domain owner | `review-checklist.md` Checklist A |
| Corrective (fixing stale/wrong content) | Domain owner | `review-checklist.md` Checklist B |
| Structural (new section, format change) | KB Owner | `review-checklist.md` Checklist B |
| Removal (deleting confirmed fact) | KB Owner + Domain owner | `review-checklist.md` Checklist B + explicit sign-off |
| Governance change (this file) | KB Owner | Peer review |
| AI-agent generated KB output | Domain owner | `review-checklist.md` Checklist D |

### Approval Workflow Steps

```
1. Author runs detect-drift.ps1 — confirms what changed
2. Author makes KB updates
3. Author runs validate-manifest.ps1 + validate-anchors.ps1
4. Author runs update-changelog.ps1
5. Author creates PR with KB changes
6. Reviewer applies review-checklist.md (appropriate checklist)
7. Reviewer approves or requests changes
8. Author merges
```

### Emergency KB Updates

For production incidents requiring immediate KB correction:
1. Update KB in hotfix branch
2. Self-review against Checklist B (abbreviated)
3. Post-merge, notify domain owner within 24 hours
4. Formal review within 48 hours
<!-- END: approval-workflow -->

---

<!-- BEGIN: versioning -->
## Versioning & Release Snapshots

### KB Version Scheme

The KB does not have its own independent version. Instead:
- **Major releases** of CMN services are accompanied by a KB snapshot
- **Quarterly audits** produce a dated snapshot
- **Breaking architecture changes** require a KB version bump in `_meta/manifest.yml`

### Creating a Release Snapshot

A snapshot is a tagged, immutable copy of the KB at a point in time.

```powershell
# 1. Ensure KB is up to date and validated
.\swt-cmn-knowledge-base\scripts\detect-drift.ps1
.\swt-cmn-knowledge-base\scripts\validate-manifest.ps1
.\swt-cmn-knowledge-base\scripts\validate-anchors.ps1

# 2. Create snapshot directory (naming: YYYY-QN or release tag)
$snapshot = "swt-cmn-knowledge-base\.snapshots\2026-Q2"
New-Item -ItemType Directory -Path $snapshot -Force

# 3. Copy KB files to snapshot (exclude _snapshots itself)
Copy-Item swt-cmn-knowledge-base\* $snapshot -Recurse -Exclude ".snapshots"

# 4. Tag in git (if repo available)
git tag "kb/2026-Q2" -m "KB snapshot — 2026 Q2 audit"
```

### Snapshot Index

| Snapshot | Date | Trigger | Notes |
|---|---|---|---|
| *(none yet)* | — | — | First snapshot due at Q3 2026 audit |

### What a Snapshot Includes

- All `.md` files
- `_meta/manifest.yml` + `manifest.schema.json`
- `_meta/knowledge-impact-map.yml`
- `diagrams/` (all `.mermaid` files)
- `09-requirements/` (all requirements and templates)
- CHANGELOG.md up to that date

**Snapshots do NOT include**: `scripts/` (tooling evolves), `_templates/` (templates evolve), `.discovery/` (raw working notes).
<!-- END: versioning -->

---

<!-- BEGIN: multi-team-governance -->
## Multi-Team Governance

### When a Second Team Joins CMN

When a new team takes ownership of a service or bounded context:

1. **Assign domain ownership** in this file (`ownership-model` section above)
2. **Create team onboarding checklist** based on `onboarding-workflow` section below
3. **Grant KB write access** (if access-controlled)
4. **Run joint audit** in the first sprint to establish baseline
5. **Brief new team** on: SLA tiers, approval workflow, AI governance policy

### Cross-Team Change Protocol

When a change affects multiple team boundaries (e.g., a new gRPC method that both Administration API team and Customer API team must act on):

1. The **initiating team** creates the primary KB update (manifest.yml, diagrams)
2. The **consuming team** reviews and confirms their side (client configuration, consuming service docs)
3. Both domain owners approve
4. KB Owner is notified (not required to approve, but must be informed)

### Conflict Resolution

If two teams disagree on what a KB entry should say:
1. Both parties read the source code together (code is arbiter)
2. If ambiguous from code: escalate to KB Owner
3. KB Owner decision is final and documented in `_meta/decisions/` (create `decisions/` directory if needed)

### Ownership Gaps

If content has no assigned owner (e.g., a new service is added without governance update):
- The KB Owner is the fallback owner until explicit ownership is assigned
- The KB Owner should raise this at the next quarterly audit
<!-- END: multi-team-governance -->

---

<!-- BEGIN: ai-agent-governance -->
## AI-Agent Governance

CMN uses AI agents (Claude Code and similar) to assist with KB maintenance. This section defines what AI agents may do autonomously and what requires human sign-off.

### Permitted Without Human Review

AI agents MAY perform these actions without a separate human approval step, provided they follow all listed constraints:

| Permitted Action | Constraints |
|---|---|
| Read any KB file | No constraints |
| Run validation scripts (`validate-manifest.ps1`, `validate-anchors.ps1`) | No constraints |
| Run drift detection scripts (`detect-drift.ps1`) | No constraints |
| Add NEW entries to manifest.yml (new feature, new endpoint, new event) | Must run validate-manifest.ps1 after; must add CHANGELOG entry |
| Add NEW requirements to `09-requirements/features/` | Must follow `requirement-template.md` format; must update traceability-matrix.md |
| Add NEW business rules to `business-rules.md` | Must include source file reference; must mark status as Confirmed or Inferred |
| Fix typos, broken links, formatting | Must not change meaning of any documented fact |
| Add anchor markers to existing sections | Must run validate-anchors.ps1 after |
| Generate CHANGELOG entry via `update-changelog.ps1` | No constraints |

### Requires Human Review Before Merge

AI agents MUST NOT autonomously merge these changes. They may propose them (draft PR), but a human must approve:

| Restricted Action | Reason |
|---|---|
| Removing any documented business rule | Risk of deleting a real constraint — verify in code first |
| Changing a requirement status to `Deprecated` | Stakeholder impact — must be intentional |
| Changing a requirement status to `Verified` | Requires actual AC verification, not inference |
| Removing a service from manifest.yml | Could erase knowledge of a service that was only renamed |
| Modifying governance.md (this file) | Governance changes require human oversight |
| Changing technical debt severity from medium/high to low | Risk of understating known security or correctness issues |
| Resolving a technical debt item (removing from TD list) | Must verify the fix exists in production code |
| Marking `[INFERRED]` items as Confirmed | Requires code verification, not just plausibility |

### AI Agent Session Start Protocol

Every AI agent session working on the KB MUST begin with:

```
1. Read CLAUDE.md in the target module directory
2. Read _meta/manifest.yml (or the relevant section)
3. Read 03-conventions.md → Forbidden Patterns
4. Check memory for prior session context
5. Run detect-drift.ps1 if making substantive KB changes
```

### Confidence Levels for AI-Generated Content

AI agents must annotate KB content they generate with uncertain confidence:

| Confidence | Annotation | Meaning |
|---|---|---|
| High | *(no annotation)* | Verified from source code in this session |
| Medium | `[INFERRED]` | Derived from behavior, docs, or conventions — not directly verified |
| Low | `[UNVERIFIED — check source]` | Plausible but not confirmed; must be verified before marking Implemented |

**Rule**: Never remove an `[INFERRED]` or `[UNVERIFIED]` annotation without first reading the corresponding source file.

### AI Agent Audit Trail

Every KB update session by an AI agent must produce:
1. A CHANGELOG entry (via `update-changelog.ps1`)
2. A summary of: files changed, validation results, confidence level of changes
3. Any drift items found but NOT fixed (so the next human reviewer knows the gaps)
<!-- END: ai-agent-governance -->

---

<!-- BEGIN: onboarding-workflow -->
## Onboarding Workflow

### For New Human Developers

**Day 1 — System context**
1. Read [README.md](README.md) — entry point and navigation
2. Read [01-overview.md](01-overview.md) (if present) — what CMN is and does
3. Read [02-architecture.md](02-architecture.md) — service map and tech stack
4. Read [_meta/manifest.yml](_meta/manifest.yml) — machine-readable overview of all services and features

**Day 2 — Rules and constraints**
5. Read [03-conventions.md](03-conventions.md) — MANDATORY. Especially: Forbidden Patterns (backend + frontend), Architecture Constraints, Known Technical Debt
6. Read [06-authentication.md](06-authentication.md) — auth is non-standard (custom JWT, Employee.Code login)

**Day 3 — Your service**
7. Read `CLAUDE.md` in the module directory you'll work in
8. Read the relevant playbook from `playbooks/` for your first task

**Week 1 — Verification**
9. Run `detect-drift.ps1` to understand current KB state vs. codebase
10. Note any `[INFERRED]` items in the area you're working on and verify them

**Week 2+ — Domain depth**
11. Read `09-requirements/features/` for features in your domain
12. Read `diagrams/` for the relevant operational flows

### For New AI Agent Sessions

Every new AI agent session should:

1. Read `CLAUDE.md` in the target module
2. Scan `_meta/manifest.yml` — find the bounded context and feature for the task
3. Read `03-conventions.md` — specifically Forbidden Patterns
4. Read `09-requirements/traceability-matrix.md` — find relevant REQ IDs
5. Run `detect-drift.ps1` if making structural changes

### For New Services / Teams Being Onboarded to CMN

1. Read this governance.md
2. KB Owner walks team through: ownership model, update SLA tiers, approval workflow
3. Team reviews `_meta/manifest.yml` — finds their service entry (or creates it using `_templates/service.yml`)
4. Team confirms domain ownership assignment in this file
5. Team runs `detect-drift.ps1` on their service directory for baseline drift assessment
<!-- END: onboarding-workflow -->

---

<!-- BEGIN: quarterly-audit -->
## Quarterly Audit

The full audit procedure is in [audit-playbook.md](audit-playbook.md).

**Audit schedule**: Q1 (January), Q2 (April), Q3 (July), Q4 (October) — run in the first two weeks of the quarter.

### Audit Summary (quick reference)

| Audit Phase | Time Estimate | Script / Tool |
|---|---|---|
| Drift audit | 30 min | `detect-drift.ps1` |
| Requirements audit | 45 min | Manual + traceability-matrix.md |
| Diagram currency check | 30 min | Manual review |
| Technical debt review | 20 min | manifest.yml technical_debt |
| Playbook verification | 30 min | Manual |
| Snapshot creation | 15 min | See versioning section |
| Report writing | 20 min | audit-playbook.md template |

**Total estimated time**: ~3 hours per quarter

### Audit Owner

The KB Owner is responsible for scheduling and running the audit (or delegating to a domain owner).
<!-- END: quarterly-audit -->

---

<!-- BEGIN: escalation-paths -->
## Escalation Paths

| Situation | First Contact | Escalation |
|---|---|---|
| KB content is wrong (factual error) | Domain owner | KB Owner |
| Drift detected but no one updating KB | Domain owner | KB Owner (after 1 sprint) |
| AI agent made a restricted change without approval | KB Owner | Revert immediately, retrain guidance |
| Governance policy is blocking legitimate work | KB Owner | Open governance RFC |
| Two teams disagree on a fact | KB Owner (decision maker) | Source code review |
| Security-sensitive fact incorrectly documented | KB Owner | Security review immediately |
<!-- END: escalation-paths -->

---

<!-- BEGIN: changelog-policy -->
## CHANGELOG Policy

Every KB update requires a CHANGELOG entry with:
- Date (ISO 8601: `YYYY-MM-DD`)
- Type: `ADD` | `UPDATE` | `FIX` | `REMOVE` | `VERIFY` | `INIT`
- Short description (what changed, not why — the PR has the why)
- Source: code file, PR number, or "quarterly audit YYYY-QN"
- Files changed (table format)

Use `scripts/update-changelog.ps1` to generate entries consistently.

### CHANGELOG Retention Policy

- Keep all entries indefinitely (CHANGELOG is permanent history)
- Entries are never deleted, only appended to
- If an entry was wrong, add a corrective entry — do not edit the original

### Version Tags in CHANGELOG

Major KB milestones should be tagged in git (if repo available) as `kb/YYYY-QN` or `kb/v{major}.{minor}`.
<!-- END: changelog-policy -->
