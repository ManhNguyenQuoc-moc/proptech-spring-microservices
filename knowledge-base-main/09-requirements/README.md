# 09 — Requirements & Traceability

> Enterprise requirements system for CMN. All requirements have machine-readable IDs (`REQ-XXX-NNN`, `BR-XXX-NNN`) and are cross-referenced to implementation files, diagrams, and acceptance criteria.

---

## Directory Structure

```
09-requirements/
  README.md                              ← this file
  traceability-matrix.md                 ← cross-reference: REQ → implementation → tests → ACs
  business-rules.md                      ← all confirmed business rules (BR-XXX)

  features/
    authentication.md                    ← REQ-AUTH-001 to REQ-AUTH-006
    employee-management.md               ← REQ-EMP-001 to REQ-EMP-005
    media-notification.md                ← REQ-MEDIA-001/002, REQ-NOTIF-001/002/003

  templates/
    requirement-template.md              ← template for new functional requirements
    business-rule-template.md            ← template for new business rules
    use-case-template.md                 ← template for use cases (actor-goal-flow)
    user-story-template.md               ← template for Agile user stories
    acceptance-criteria-template.md      ← template for standalone AC documents

  bugs/                                  ← (create .md files here for bug reports)
  decisions/                             ← (create .md files here for ADRs)
```

---

## ID Scheme

| Type | Format | Example | Where Defined |
|---|---|---|---|
| Functional Requirement | `REQ-{DOMAIN}-{NNN}` | `REQ-AUTH-001` | `features/*.md` |
| Business Rule | `BR-{DOMAIN}-{NNN}` | `BR-EMP-001` | `business-rules.md` |
| Use Case | `UC-{DOMAIN}-{NNN}` | `UC-AUTH-001` | (use template) |
| User Story | `US-{DOMAIN}-{NNN}` | `US-EMP-001` | (use template) |
| Acceptance Criteria | `AC-{REQ}-{NNN}` | `AC-AUTH-001-01` | inline in REQ files |

**Domain codes**:
`AUTH` · `EMP` · `MEDIA` · `NOTIF` · `PERM` · `ROLE` · `GRPC` · `IMPORT` · `CUST` · `INFRA` · `MOBILE`

---

## How to Add a New Requirement

1. Check `traceability-matrix.md` → ID Registry for the next available ID
2. Copy `templates/requirement-template.md` to `features/{feature-name}.md` (or append to existing file)
3. Fill in all fields including `requirement_ids:` YAML frontmatter
4. Increment the ID counter in the ID Registry table in `traceability-matrix.md`
5. Add a row to the relevant table in `traceability-matrix.md`
6. Add CHANGELOG entry in `CHANGELOG.md`

---

## How to Add a New Business Rule

1. Check `business-rules.md` → domain section for next available ID
2. Add the rule following the template pattern in `business-rules.md`
3. Update `traceability-matrix.md` → Business Rules Traceability table
4. Link the rule to its `REQ-XXX` requirement in the linked requirements field

---

## YAML Frontmatter Format

Every requirement file must include YAML frontmatter for machine parsing:

```yaml
---
requirement_ids:
  - REQ-AUTH-001
  - REQ-AUTH-002
status: Implemented    # Draft | Specified | Implemented | Verified | Deprecated
service: administration-api
version: 1.0
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

Business rule files use `rule_ids:` instead of `requirement_ids:`.

---

## Current Coverage (as of Phase 6)

| Domain | REQs Specified | BRs Specified | Tests | Status |
|---|---|---|---|---|
| Authentication | 6 | 6 | ❌ None | ✅ All implemented |
| Employee | 5 | 4 | ❌ None | ✅ All implemented |
| Import | — (under EMP) | 5 | ❌ None | ✅ All implemented |
| Media Files | 2 | 4 | ❌ None | ⚠️ Physical delete disabled |
| Notifications | 3 | 3 | ❌ None | ✅ All implemented |
| Permissions | 1 | — | ❌ None | 🔒 RBAC commented out |
| Roles | 1 | 1 | ❌ None | ✅ Implemented |
| gRPC | 2 | 1 | ❌ None | ✅ Implemented |
| Customer/Party | 0 | 0 | — | ❌ Stub only |

**Critical gap**: Zero automated test coverage for any requirement. All AC verification is currently manual only.

---

## Related KB Documents

- [04-business-domain.md](../04-business-domain.md) — domain model
- [05-flows.md](../05-flows.md) — operational flows
- [07-security-permissions.md](../07-security-permissions.md) — auth + RBAC
- [traceability-matrix.md](traceability-matrix.md) — full cross-reference
- [../diagrams/](../diagrams/) — all Mermaid diagrams referenced from ACs
