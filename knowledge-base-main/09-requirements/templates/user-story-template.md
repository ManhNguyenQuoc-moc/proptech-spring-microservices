---
# User Story Template
# Copy to 09-requirements/features/{feature-name}.md
# User stories are short statements from an actor's perspective.

requirement_ids:
  - REQ-XXX-001
story_id: US-XXX-NNN      # US-{DOMAIN}-{NNN}
status: Draft              # Draft | Ready | In Progress | Done | Rejected
priority: Medium           # Critical | High | Medium | Low
story_points: 0            # Estimated effort
sprint: ""                 # Sprint label if tracked here
---

# US-XXX-NNN — [Story Title]

> **As a** [Actor / Role],
> **I want** [Goal / Capability],
> **so that** [Business value / Reason].

**Status**: Draft | **Priority**: Medium

---

## Context

[Optional: 1-2 sentences of background that explains why this story matters.]

---

## Acceptance Criteria

> Format: Given [precondition] / When [action] / Then [observable outcome]

- [ ] **AC-001**: Given [state], when [actor does X], then [system does Y]
- [ ] **AC-002**: Given [state], when [actor does X with invalid input], then [system returns error Z]
- [ ] **AC-003**: Given [state], when [actor does X], then [side-effect E occurs]

---

## Definition of Done

- [ ] Backend endpoint implemented and returns correct response shape
- [ ] Frontend form/page renders and calls the endpoint
- [ ] Unit tests cover happy path and primary error case
- [ ] Knowledge base updated (service doc, CHANGELOG)
- [ ] Tested in staging environment

---

## Technical Notes

[Implementation hints, patterns to follow, constraints — e.g., "Use existing `IDepartmentAppService` interface", "Follow the pattern in `EmployeeAppService.CreateAsync`"]

---

## Business Rules

| Rule ID | Description |
|---|---|
| BR-XXX-001 | |

---

## Linked Requirements

| REQ ID | Title | Relationship |
|---|---|---|
| REQ-XXX-001 | | Implements |

---

## Related Stories

| Story ID | Title | Relationship |
|---|---|---|
| US-XXX-002 | | Depends on |

---

## Implementation Traceability

| Artifact | Status | Location |
|---|---|---|
| Backend endpoint | ☐ Not started | |
| Frontend component | ☐ Not started | |
| Unit test | ☐ Not started | |
| Integration test | ☐ Not started | |
