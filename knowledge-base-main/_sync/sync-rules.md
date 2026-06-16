# Knowledge Base Sync Rules

## Core Principle

**Code is always the source of truth.** When any conflict exists between this KB and the code, the code wins and this KB must be updated.

---

## Update Triggers

| Code Change | KB Files to Update | Anchor |
|---|---|---|
| New/modified domain entity | `services/[service].md`, `04-business-domain.md`, `diagrams/entity-relations.mermaid` | `[service]-entities` |
| New/modified controller | `services/[service].md` | `[service]-controllers` |
| New YARP route in `appsettings*.json` | `services/web-gateway.md`, `01-architecture.md` | `gateway-routes` |
| Exception filter change | `03-conventions.md` | `error-http-map` |
| `BaseResultDto` / `ApiResult` change | `03-conventions.md` | `api-response-shape` |
| New gRPC service | `06-integrations.md` | `grpc-contracts` |
| New frontend page | `services/[webapp].md` | `[webapp]-pages` |
| New mobile feature | `services/mobile-app.md` | `mobile-features` |
| New npm dependency | `02-tech-stack.md` | `tech-stack-matrix` |
| New NuGet package | `02-tech-stack.md` | `tech-stack-matrix` |

---

## How to Update

1. Locate the anchor in the target file using `<!-- KB-ANCHOR: {id} -->`.
2. Replace **only** the content between anchor tags.
3. Do NOT modify content outside anchor tags unless explicitly required.
4. Add a CHANGELOG entry in `CHANGELOG.md`.

---

## Confirmed vs Inferred

- **Confirmed fact**: directly derived from source code (entity fields, route paths, package names).
- **Inferred assumption**: derived from naming conventions, patterns, or incomplete code. Marked with `[INFERRED]`.
- Never promote an inferred assumption to a confirmed fact without verifying in code.

---

## Deprecation Policy

When a feature, entity, or endpoint is removed from code:
1. Remove it from the KB (do not leave stubs or "deprecated" markers).
2. Log the removal in `CHANGELOG.md`.
3. If removal affects a playbook step, update the playbook.
