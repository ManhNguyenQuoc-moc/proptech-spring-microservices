---
requirement_ids:
  - REQ-EMP-001
  - REQ-EMP-002
  - REQ-EMP-003
  - REQ-EMP-004
  - REQ-EMP-005
status: Implemented
service: administration-api
version: 1.0
created: 2026-05-23
updated: 2026-05-23
---

# Employee Management Requirements

> **Status**: Implemented
> **Service**: `administration-api`
> **Source verification**: `EmployeeAppService.cs`, `EmployeeController.cs`, `CreateEmployeeInputDto.cs`, `EmployeeOutputDto.cs`

---

## REQ-EMP-001 — Employee CRUD

**The system shall provide Create, Read (single + list), Update, and Delete operations for Employee records.**

### Acceptance Criteria

- [ ] **AC-EMP-001-01**: Given valid `CreateEmployeeInputDto`, when `POST /api/employee` is called, then a new Employee and linked IdentityUser are created and `EmployeeOutputDto` is returned with HTTP 201.
- [ ] **AC-EMP-001-02**: Given an existing employee ID, when `GET /api/employee/{id}` is called, then `EmployeeOutputDto` is returned with all fields including `PositionName` and `OrganizationUnitName`.
- [ ] **AC-EMP-001-03**: Given filter params, when `GET /api/employee` is called, then a paginated list is returned. `PositionName` and `OrganizationUnitName` are `null` in list items.
- [ ] **AC-EMP-001-04**: Given `GetListEmployeeInputDto` with `keyword`, when `GET /api/employee` is called, then only employees whose `Name` or `Code` contains the keyword are returned.
- [ ] **AC-EMP-001-05**: Given an `isActive` filter, when `GET /api/employee` is called, then only employees matching the active status are returned.
- [ ] **AC-EMP-001-06**: Given a valid `UpdateEmployeeInputDto`, when `PUT /api/employee/{id}/detail` is called, then only the provided fields are updated (partial update).
- [ ] **AC-EMP-001-07**: Given an employee ID, when `DELETE /api/employee/{id}` is called, then the employee is soft-deleted (`IsDeleted = true`).

### Business Rules
| Rule ID | Description |
|---|---|
| BR-EMP-001 | Email, OtherEmail, PhoneNumber must be unique per tenant at create time |
| BR-EMP-003 | `PositionName` and `OrganizationUnitName` are null in list responses, populated in detail responses |

### Implementation Traceability
| Artifact | Location |
|---|---|
| Controller | `EmployeeController.cs` |
| App Service | `EmployeeAppService.cs` — `GetListAsync`, `GetAsync`, `CreateAsync`, `UpdateDetailAsync`, `DeleteAsync` |
| Input DTO | `CreateEmployeeInputDto.cs` — validator in same file |
| Output DTO | `EmployeeOutputDto.cs` |
| Paged output | `PagedResultEmployeeOutputDto.cs` — includes `ExtendData.totalActiveEmployees` + `totalDeactiveEmployees` |
| Sequence diagram | `diagrams/sync-employee-identity.mermaid` |

---

## REQ-EMP-002 — Employee–IdentityUser Synchronization

**The system shall maintain synchronization between `Employee` and `IdentityUser` records. Changes to employee identity fields (Name, Email, PhoneNumber, IsActive) shall be reflected in the linked `IdentityUser`.**

### Rationale
`Employee` is the domain entity; `IdentityUser` is the ABP identity record used for authentication. They must stay in sync so login behavior reflects employee state.

### Acceptance Criteria

- [ ] **AC-EMP-002-01**: Given `CreateAsync`, when an Employee is created, then an `IdentityUser` is created first (with `UserName = email`), and the `Employee.UserId` is set to `IdentityUser.Id`.
- [ ] **AC-EMP-002-02**: Given `UpdateDetailAsync` with a new `Email`, when called, then `IdentityUser.Email` and `IdentityUser.UserName` are updated to the new email.
- [ ] **AC-EMP-002-03**: Given `UpdateDetailAsync` with `IsActive = false`, when called, then `IdentityUser.LockoutEnabled = true` and `LockoutEnd = DateTimeOffset.MaxValue` (user cannot log in).
- [ ] **AC-EMP-002-04**: Given `UpdateDetailAsync` with `IsActive = true` (re-activation), when called, then `IdentityUser.LockoutEnd = null` (user can log in again).
- [ ] **AC-EMP-002-05**: Given `UpdateDetailAsync` with no identity-linked fields changed, when called, then `IdentityUser` is NOT loaded or updated (no unnecessary DB round-trip).

### Business Rules
| Rule ID | Description |
|---|---|
| BR-EMP-002 | IdentityUser is created before Employee in CreateAsync — if IdentityUser creation fails, Employee is not created |
| BR-EMP-004 | IsActive=false maps to IdentityUser permanent lockout (`DateTimeOffset.MaxValue`) |

### Implementation Traceability
| Artifact | Location |
|---|---|
| App Service | `EmployeeAppService.CreateAsync()`, `UpdateDetailAsync()` |
| IdentityUser sync | `UserManager.SetLockoutEnabledAsync`, `SetLockoutEndDateAsync` |
| State diagram | `diagrams/state-employee-lifecycle.mermaid` |

---

## REQ-EMP-003 — Bulk Employee Import

**The system shall support 2-step bulk employee import: a validation step that produces a session, and an execution step that creates employees from the validated session.**

### Rationale
Separating validation from execution allows HR admins to review and correct errors before committing bulk records. The session-based approach prevents double-import.

### Acceptance Criteria

- [ ] **AC-EMP-003-01**: Given a CSV/XLSX file ≤ 5MB with ≤ 100 rows, when `POST /api/employee/validate-import` is called, then a `sessionId` is returned with row counts (`totalRows`, `validRowCount`, `errorRowCount`).
- [ ] **AC-EMP-003-02**: Given a file > 5MB, when validate-import is called, then the system returns HTTP 400 (file size exceeded).
- [ ] **AC-EMP-003-03**: Given a file with > 100 rows, when validate-import is called, then the system returns HTTP 400 (row limit exceeded).
- [ ] **AC-EMP-003-04**: Given rows with data errors (duplicate codes, invalid format), when validate-import is called, then `hasDataError = true`, `hasErrorFile = true`, and an error file is available at `GET /api/employee/error-file/{sessionId}`.
- [ ] **AC-EMP-003-05**: Given `canImport = true` and a valid `sessionId`, when `POST /api/employee/import { sessionId }` is called within 30 minutes, then valid rows are imported and `importedCount` is returned.
- [ ] **AC-EMP-003-06**: Given a `sessionId` older than 30 minutes (Redis TTL expired), when `POST /api/employee/import` is called, then the system returns HTTP 400 (session not found).
- [ ] **AC-EMP-003-07**: Given a duplicate employee created between validate and execute steps (race condition), when execute is called, then the duplicate row is skipped (no exception), and `skippedCount` increments.
- [ ] **AC-EMP-003-08**: Given a valid import row, when executed, then the IdentityUser email is set to `{StudentCode}@student.edu.vn` and `Employee.IsFirstLogin = true`.

### Business Rules
| Rule ID | Description |
|---|---|
| BR-IMPORT-001 | Max file size: 5MB |
| BR-IMPORT-002 | Max row count: 100 |
| BR-IMPORT-003 | Session TTL: 30 minutes in Redis. Key: `import_employee_{sessionId}` |
| BR-IMPORT-004 | Student email format: `{StudentCode}@student.edu.vn` |
| BR-IMPORT-005 | Race-condition re-check at execute step — duplicate rows are skipped, not errored |

### Implementation Traceability
| Artifact | Location |
|---|---|
| Validate endpoint | `EmployeeController.ValidateImportAsync()` → `EmployeeAppService.ValidateImportAsync()` |
| Execute endpoint | `EmployeeController.ImportAsync()` → `EmployeeAppService.ExecuteImportAsync()` |
| Error file endpoint | `EmployeeController.GetImportErrorFileAsync()` |
| Redis session key | `import_employee_{sessionId}` TTL 30min |
| Sequence diagram | `diagrams/sync-employee-import.mermaid` |
| State diagram | `diagrams/state-import-session.mermaid` |

---

## REQ-EMP-004 — Employee Search and Filtering

**The system shall support keyword search (Name and Code) and active-status filtering on the employee list endpoint.**

### Acceptance Criteria

- [ ] **AC-EMP-004-01**: Given `keyword = "nguyen"`, when `GET /api/employee?keyword=nguyen` is called, then only employees with Name or Code containing "nguyen" (case-insensitive) are returned.
- [ ] **AC-EMP-004-02**: Given `isActive = true`, when `GET /api/employee?isActive=true` is called, then only active employees are returned.
- [ ] **AC-EMP-004-03**: Given no filters, when `GET /api/employee` is called, then all employees (active and inactive) are returned, paginated.
- [ ] **AC-EMP-004-04**: Given any `GET /api/employee` response, the `data.extendData` object contains `totalActiveEmployees` and `totalDeactiveEmployees` counts for the current tenant.

### Implementation Traceability
| Artifact | Location |
|---|---|
| App Service | `EmployeeAppService.GetListAsync()` — `WhereIf` keyword filter + optional `IsActive` filter |
| Output | `PagedResultEmployeeOutputDto.ExtendData` — `totalActiveEmployees`, `totalDeactiveEmployees` |

---

## REQ-EMP-005 — Employee Import Template Download

**The system shall provide a downloadable template file for bulk employee import.**

### Acceptance Criteria

- [ ] **AC-EMP-005-01**: Given an authenticated request, when `GET /api/employee/import-template` is called, then a CSV/XLSX template file is returned with the correct column headers.

### Implementation Traceability
| Artifact | Location |
|---|---|
| Controller | `EmployeeController.GetImportTemplateAsync()` |
