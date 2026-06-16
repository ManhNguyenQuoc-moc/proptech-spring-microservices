# [Service Name] — Service Documentation

> **Stack**: [stack summary]
> **Route prefix**: [/cmn/xxx/api]
> **DB Schema**: [SCHEMA]
> **Dev Port**: [PORT]
> **Source**: [module-dir/]

---

## Overview

[1-3 sentence description of what this service owns and why it exists.]

---

## Domain Entities

<!-- KB-ANCHOR: [service-id]-entities -->

| Entity | Table (Schema.Name) | Key Fields | Notes |
|---|---|---|---|
| `EntityName` | `SCHEMA.TableName` | field1, field2 | description |

<!-- /KB-ANCHOR: [service-id]-entities -->

---

## Controllers & Routes

<!-- KB-ANCHOR: [service-id]-controllers -->

| Controller | Method | Route | Auth | Description |
|---|---|---|---|---|
| `XxxController` | GET | `/cmn/xxx/api/resource` | Bearer | description |

<!-- /KB-ANCHOR: [service-id]-controllers -->

---

## Application Services

| Service | Interface | Responsibilities |
|---|---|---|
| `XxxAppService` | `IXxxAppService` | description |

---

## DTOs

| DTO | Namespace | Direction | Validator |
|---|---|---|---|
| `XxxInputDto` | `CMN.Xxx.Dtos.Input` | Request | `XxxInputDtoValidator` (same file) |
| `XxxOutputDto` | `CMN.Xxx.Dtos.Output` | Response | — |

---

## Error Codes

| Localization Key | When |
|---|---|
| `XxxNotFound` | Entity not in DB |
| `DuplicateXxx` | Unique constraint violation |

---

## Configuration

| Key | Default | Description |
|---|---|---|
| `key` | `value` | description |

---

## Dependencies

- **Upstream**: [services this service calls]
- **Downstream**: [services that call this service]
- **External**: [Cloudinary, Firebase, etc.]
