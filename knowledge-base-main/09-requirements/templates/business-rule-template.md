---
# Business Rule Template
# Copy to 09-requirements/features/{feature-name}.md or 09-requirements/business-rules.md
# Business rules are constraints the system enforces on data or processes.

rule_ids:
  - BR-XXX-001    # Unique ID: BR-{DOMAIN}-{NNN}
                  # Domains: AUTH, EMP, MEDIA, PERM, ROLE, NOTIF, GRPC, IMPORT
status: Confirmed # Inferred | Confirmed | Deprecated
source: ""        # File where rule is implemented (e.g. AuthAppService.cs:142)
---

# BR-XXX-NNN — [Business Rule Title]

> **Status**: Confirmed
> **Source**: `[path/to/implementing/file.cs]:[line]`

---

## Rule Statement

[Declarative statement of the constraint. Use "The system MUST..." or "A [entity] MUST NOT..."]

---

## Rationale

[Why this rule exists — business reason, compliance, or domain constraint.]

---

## Trigger

[When does this rule apply? What action or state change triggers enforcement?]

---

## Enforcement Point

| Layer | File | How Enforced |
|---|---|---|
| Application | `XxxAppService.cs` | `throw new UserFriendlyException(L["..."])` |
| Validation | `XxxInputDtoValidator.cs` | FluentValidation rule |
| Database | `OnModelCreating` | Unique index / NOT NULL constraint |

---

## Violation Behavior

| Scenario | Response |
|---|---|
| [Violation scenario 1] | HTTP 400 + `{ error: { code: "...", message: "..." } }` |
| [Violation scenario 2] | Validation error before reaching app service |

---

## Linked Requirements

| REQ ID | Title |
|---|---|
| REQ-XXX-001 | [Requirement this rule governs] |

---

## Test Coverage

| Test | File | Method |
|---|---|---|
| Should enforce rule | `...Tests.cs` | `Method_Should_Throw_When_RuleViolated()` |
