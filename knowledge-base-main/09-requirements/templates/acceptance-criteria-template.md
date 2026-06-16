---
# Acceptance Criteria Template
# A standalone AC document for a feature. Can also be inlined inside requirement or user story files.
# AC IDs are referenced from REQ-XXX and US-XXX files.

ac_ids:
  - AC-XXX-001
  - AC-XXX-002
requirement_ids:
  - REQ-XXX-001   # The requirement these ACs verify
story_ids:
  - US-XXX-001    # The user story these ACs belong to
status: Draft     # Draft | Ready | Pass | Fail | Blocked
---

# AC-XXX — Acceptance Criteria: [Feature/Story Name]

> Linked requirement: `REQ-XXX-001`
> Linked story: `US-XXX-001`

---

## Criteria

### AC-XXX-001 — [Criterion Title]

**Given** [precondition — system state before the action]
**When** [the actor performs the action]
**Then** [the observable outcome]

**Test type**: Unit | Integration | Manual | E2E
**Test file**: `test/.../XxxTests.cs` → `Method_Should_Behavior()`

---

### AC-XXX-002 — [Criterion Title]

**Given** [precondition]
**When** [action]
**Then** [outcome]

**Test type**: Manual
**Test file**: N/A — manual verification steps:
1. [Step]
2. [Step]
3. Verify: [expected state]

---

### AC-XXX-003 — [Error/Edge Case Criterion]

**Given** [state that causes an error]
**When** [the actor performs the action with invalid data or missing auth]
**Then** [the system returns HTTP {code} with `{ error: { code: "LocalizationKey", message: "..." } }`]

**Test type**: Unit
**Test file**: `XxxTests.cs` → `Method_Should_Throw_When_ConditionViolated()`

---

## Verification Status

| AC ID | Type | Automated? | Status | Evidence |
|---|---|---|---|---|
| AC-XXX-001 | Functional | Yes | ☐ Pending | |
| AC-XXX-002 | Functional | No (manual) | ☐ Pending | |
| AC-XXX-003 | Error case | Yes | ☐ Pending | |

---

## Notes

[Any clarifications, known limitations, or deferred verification items.]
