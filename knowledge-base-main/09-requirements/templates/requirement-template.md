---
# Functional Requirement Template
# Copy this file to 09-requirements/features/{feature-name}.md
# Fill in all fields. Remove comment lines before committing.

requirement_ids:
  - REQ-XXX-001   # Unique ID: REQ-{DOMAIN}-{NNN}
                  # Domains: AUTH, EMP, MEDIA, PERM, ROLE, NOTIF, GRPC, IMPORT, MOBILE, INFRA
status: Draft     # Draft | Specified | Implemented | Verified | Deprecated
priority: Medium  # Critical | High | Medium | Low
service:          # administration-api | customer-api | web-gateway | web-app | admin-web-app | mobile-app
version: 1.0
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# REQ-XXX-NNN — [Requirement Title]

> **Status**: Draft
> **Priority**: Medium
> **Service(s)**: `[service-name]`

---

## Description

[Clear, declarative statement of what the system MUST do. Use "The system shall..." or "The [actor] shall be able to...".]

---

## Rationale

[Why this requirement exists. Business or technical motivation.]

---

## Acceptance Criteria

<!-- Reference AC-XXX IDs from acceptance-criteria files, or inline them here -->

- [ ] **AC-001**: [Observable, testable condition]
- [ ] **AC-002**: [Observable, testable condition]
- [ ] **AC-003**: [Edge case or error condition]

---

## Business Rules

<!-- Reference BR-XXX IDs that govern this requirement -->

| Rule ID | Description |
|---|---|
| BR-XXX-001 | [Rule that constrains this requirement] |

---

## Implementation Traceability

| Artifact | Location | Notes |
|---|---|---|
| Controller | `src/.../Controllers/{Feature}Controller.cs` | HTTP entry point |
| App Service | `src/.../Application/{Feature}AppService.cs` | Business logic |
| Domain Entity | `src/.../Domain/Entities/{Entity}.cs` | Data model |
| DTO (Input) | `src/.../Application.Contracts/...Dtos/Input/` | |
| DTO (Output) | `src/.../Application.Contracts/...Dtos/Output/` | |
| Migration | `src/.../EntityFrameworkCore/Migrations/...` | DB schema |

---

## Test Traceability

| Test Type | File | Test Method |
|---|---|---|
| Unit | `test/.../Application.Tests/{Feature}Tests.cs` | `Method_Should_Behavior()` |
| Integration | `test/.../...` | |
| E2E | [Not yet: no E2E suite] | |

---

## Dependencies

| Depends On | Type |
|---|---|
| REQ-XXX-YYY | [Requirement dependency] |
| [External Service] | [gRPC / SMTP / Cloudinary] |

---

## Related KB Documents

- [services/administration-api.md](../services/administration-api.md)
- [05-flows.md](../05-flows.md)
- [playbooks/add-endpoint.md](../playbooks/add-endpoint.md)

---

## Change History

| Date | Version | Change |
|---|---|---|
| YYYY-MM-DD | 1.0 | Initial specification |
