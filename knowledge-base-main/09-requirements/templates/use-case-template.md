---
# Use Case Template
# Copy to 09-requirements/features/{feature-name}.md
# Use cases describe actor-goal interactions with the system.

requirement_ids:
  - REQ-XXX-001
use_case_id: UC-XXX-NNN   # UC-{DOMAIN}-{NNN}
status: Draft              # Draft | Specified | Implemented | Verified
primary_actor: ""          # Employee | HR Admin | System Admin | System (automated)
---

# UC-XXX-NNN — [Use Case Title]

> **Actor**: [Primary Actor]
> **Goal**: [One-line goal statement]
> **Status**: Draft

---

## Brief Description

[1-2 sentences describing what the actor achieves and why.]

---

## Preconditions

- The actor is authenticated (valid JWT in cookie)
- X-Tenant header is set with valid tenantId
- [Other preconditions]

---

## Postconditions (Success)

- [What is true after successful execution]
- [Side effects: DB records created/updated, emails sent, cache updated]

---

## Postconditions (Failure)

- [What is true after failure — no partial writes, no orphaned records]

---

## Main Flow

| Step | Actor | System |
|---|---|---|
| 1 | [Action] | |
| 2 | | [Response / Processing] |
| 3 | [Action] | |
| 4 | | [Validation] |
| 5 | | [Persistence / Side-effect] |
| 6 | | Returns `ApiResult<OutputDto>` |

---

## Alternative Flows

### A1 — [Condition]

At step N, if [condition]:
1. [What happens]
2. System returns [error response]

### A2 — [Condition]

---

## Exceptions

| Exception | Trigger | System Response |
|---|---|---|
| [Exception 1] | [Cause] | HTTP 400 `UserFriendlyException(L["Key"])` |
| [Exception 2] | Not found | HTTP 404 `EntityNotFoundException` |
| Authentication failure | No token / expired | HTTP 401 |

---

## Business Rules Applied

| Rule ID | Applied At |
|---|---|
| BR-XXX-001 | Step 4 |

---

## Implementation Traceability

| Artifact | Location |
|---|---|
| Controller action | `XxxController.MethodAsync()` |
| App service method | `XxxAppService.MethodAsync()` |
| HTTP route | `[HttpPost] /cmn/administration-service/api/...` |
| Sequence diagram | `diagrams/...mermaid` |
