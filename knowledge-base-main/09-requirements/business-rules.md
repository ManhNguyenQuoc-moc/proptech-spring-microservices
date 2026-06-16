---
rule_ids:
  - BR-AUTH-001
  - BR-AUTH-002
  - BR-AUTH-003
  - BR-AUTH-004
  - BR-AUTH-005
  - BR-AUTH-006
  - BR-EMP-001
  - BR-EMP-002
  - BR-EMP-003
  - BR-EMP-004
  - BR-IMPORT-001
  - BR-IMPORT-002
  - BR-IMPORT-003
  - BR-IMPORT-004
  - BR-IMPORT-005
  - BR-MEDIA-001
  - BR-MEDIA-002
  - BR-MEDIA-003
  - BR-MEDIA-004
  - BR-NOTIF-001
  - BR-NOTIF-002
  - BR-NOTIF-003
  - BR-ROLE-001
  - BR-GRPC-001
status: Confirmed
source: Phases 0-3 source code verification
---

# Business Rules — CMN System

> All rules confirmed from source code. Status: `Confirmed` unless marked `[INFERRED]`.
> Source: `AuthAppService.cs`, `EmployeeAppService.cs`, `MediaFileAppService.cs`, `RoleAppService.cs`, gRPC handlers, consts files.

---

## Authentication Rules

### BR-AUTH-001 — Employee.Code is Login Username

**Rule**: `LoginInputDto.UserName` receives the value of `Employee.Code` (not email, not IdentityUser.UserName).

**Source**: `AuthAppService.LoginAsync()` — `WHERE Code = @username`
**Enforcement point**: `AuthAppService.LoginAsync` — Employee lookup by Code
**Violation**: Employee not found → `UserFriendlyException` (HTTP 400)
**Linked requirements**: REQ-AUTH-001

---

### BR-AUTH-002 — JWT Configuration (Issuer, Audience, Algorithm, Clock Skew)

**Rule**: All JWTs must use HMAC-SHA256, issuer `"ZS"`, audience `"ZS"`, and strict clock skew (`TimeSpan.Zero`).

**Source**: `AuthenticationJwtBearerHandler.cs`, `appsettings.json`
**Enforcement**: JWT validation middleware rejects non-conforming tokens
**Config keys**: `AuthenticationJwtBearer:SecurityKey/Issuer/Audience`
**Linked requirements**: REQ-AUTH-002

---

### BR-AUTH-003 — Refresh Token Format and Storage

**Rule**: Refresh tokens have the format `"{UUIDv7}-{UUIDv7}"`. Stored in Redis at key `{userId}:{sessionId}` with TTL 720 hours.

**Source**: `AuthAppService.CreateAccessTokenAsync()`
**Enforcement**: Token comparison in `RefreshLoginAsync` — mismatch → 401
**Linked requirements**: REQ-AUTH-003

---

### BR-AUTH-004 — Refresh Token Rotation (Delete Before Issue)

**Rule**: On every token refresh, the old Redis key `{userId}:{sessionId}` is deleted BEFORE the new one is created. New session gets a new `sessionId`.

**Source**: `AuthAppService.RefreshLoginAsync()` — `Redis.DEL` then `Redis.SET`
**Rationale**: Prevents the old token from being usable after rotation
**Linked requirements**: REQ-AUTH-003

---

### BR-AUTH-005 — Password Reset Token Encryption

**Rule**: The password reset UUID (`rawToken`) is stored in Redis. The URL contains `IStringEncryptionService.Encrypt(rawToken)`, URL-encoded. On reset, the URL token is URL-decoded, decrypted to get `rawToken`, then used as the Redis key.

**Source**: `AuthAppService.RequestPasswordRecoveryAsync()`, `ResetPasswordAsync()`
**Enforcement**: `IStringEncryptionService.Decrypt` throws on invalid/tampered token → HTTP 400
**Linked requirements**: REQ-AUTH-004

---

### BR-AUTH-006 — Password Reset Token Single-Use

**Rule**: After a successful password reset, `IsUsed` is set to `true` in the Redis value. Subsequent attempts with the same token return "token already used" error.

**Source**: `AuthAppService.ResetPasswordAsync()` — `Assert IsUsed == false`
**Enforcement**: Check before `RemovePasswordAsync` / `AddPasswordAsync`
**Linked requirements**: REQ-AUTH-004

---

## Employee Rules

### BR-EMP-001 — Email/OtherEmail/PhoneNumber Uniqueness Per Tenant

**Rule**: At employee creation, `Email`, `OtherEmail`, and `PhoneNumber` must each be unique within the tenant. Checked against existing `Employee` records (not `IdentityUser`).

**Source**: `EmployeeAppService.CreateAsync()` — three separate `AnyAsync` checks
**Enforcement**: `UserFriendlyException` (HTTP 400) if any duplicate found
**Violation messages**: `DuplicateEmail`, `DuplicateOtherEmail`, `DuplicatePhoneNumber`
**Linked requirements**: REQ-EMP-001

---

### BR-EMP-002 — IdentityUser Created Before Employee

**Rule**: In `CreateAsync`, `IdentityUser` is created first. `Employee.UserId` is set to `IdentityUser.Id`. If IdentityUser creation fails, Employee is not created.

**Source**: `EmployeeAppService.CreateAsync()` — `UserManager.CreateAsync` before `_employeeRepository.InsertAsync`
**Linked requirements**: REQ-EMP-002

---

### BR-EMP-003 — List vs Detail Response Difference

**Rule**: In the employee list response (`GetListAsync`), `PositionName` and `OrganizationUnitName` fields are `null`. In the detail response (`GetAsync`), they are populated.

**Source**: `EmployeeOutputDto.cs` — confirmed from Phase 3 source review
**Linked requirements**: REQ-EMP-001

---

### BR-EMP-004 — IsActive=false Maps to IdentityUser Permanent Lockout

**Rule**: Setting `Employee.IsActive = false` via `UpdateDetailAsync` calls `UserManager.SetLockoutEnabledAsync(true)` and `SetLockoutEndDateAsync(DateTimeOffset.MaxValue)` on the linked `IdentityUser`. This prevents login.

**Source**: `EmployeeAppService.UpdateDetailAsync()`
**Re-activation**: `IsActive = true` calls `SetLockoutEndDateAsync(null)`
**Linked requirements**: REQ-EMP-002

---

## Import Rules

### BR-IMPORT-001 — Maximum File Size: 5MB

**Rule**: Import file must not exceed 5MB. Checked before parsing.
**Source**: `EmployeeAppService.ValidateImportAsync()`
**Violation**: HTTP 400 with file size error message
**Linked requirements**: REQ-EMP-003

---

### BR-IMPORT-002 — Maximum Row Count: 100

**Rule**: Import file must not exceed 100 data rows (excluding header). Checked after parsing.
**Source**: `EmployeeAppService.ValidateImportAsync()`
**Violation**: HTTP 400 with row count error message
**Linked requirements**: REQ-EMP-003

---

### BR-IMPORT-003 — Import Session TTL: 30 Minutes

**Rule**: The validated import session is stored in Redis at key `import_employee_{sessionId}` with a 30-minute TTL. After expiry, the execute step returns an error.
**Source**: `EmployeeAppService.ValidateImportAsync()` — Redis SET with 30min expiry
**Linked requirements**: REQ-EMP-003

---

### BR-IMPORT-004 — Student Email Format

**Rule**: Employees created via bulk import use the email format `{StudentCode}@student.edu.vn` for both `IdentityUser.Email` and `IdentityUser.UserName`.
**Source**: `EmployeeAppService.ExecuteImportAsync()`
**Linked requirements**: REQ-EMP-003

---

### BR-IMPORT-005 — Race Condition Duplicate Skip at Execute

**Rule**: At execute time, each row is re-checked for duplicates (Code, Email, PhoneNumber). If a duplicate is found (created between validate and execute steps), the row is silently skipped (not errored). The `skippedCount` increments.
**Source**: `EmployeeAppService.ExecuteImportAsync()` — re-check before each row insert
**Rationale**: Prevents errors from concurrent admin sessions importing the same data
**Linked requirements**: REQ-EMP-003

---

## Media Rules

### BR-MEDIA-001 — Max Total Upload Size: 100MB

**Rule**: Total size of all files in a single upload request must not exceed 100MB (`MediaFileConsts.MaxFileSize`).
**Source**: `MediaFileAppService.UploadFileAsync()`
**Linked requirements**: REQ-MEDIA-001

---

### BR-MEDIA-002 — Max Avatar Size: 5MB

**Rule**: Avatar files must not exceed 5MB (`MediaFileConsts.MaxAvatarSize`).
**Source**: `MediaFileConsts.cs`
**Linked requirements**: REQ-MEDIA-001

---

### BR-MEDIA-003 — Cloudinary Folder Structure

**Rule**: All files are uploaded to folder `CMN/{tenantId}/` (`ParentFolder = "CMN"`).
**Source**: `MediaFileAppService.UploadFileAsync()`, `MediaFileConsts.ParentFolder = "CMN"`
**Linked requirements**: REQ-MEDIA-001

---

### BR-MEDIA-004 — Cloudinary publicId and Tags Format

**Rule**: `publicId = "{tenantId}_{fileId}"` where `fileId` is a UUIDv7. Tags: `["tenant-{tenantId}", "file-{fileId}"]`.
**Source**: `MediaFileAppService.UploadFileAsync()`
**Linked requirements**: REQ-MEDIA-001

---

## Notification Rules

### BR-NOTIF-001 — Mail Template Placeholder Syntax

**Rule**: Template body and subject use `##Group.Field##` format (shortCode = `"##"`) for variable substitution. The data dictionary key must match exactly `"Group.Field"` (case-sensitive).
**Source**: `MailTemplateAppService.ReplaceMailTemplateVariable()`
**Linked requirements**: REQ-NOTIF-001

---

### BR-NOTIF-002 — Mail Templates are System-Wide (Not Multi-Tenant)

**Rule**: `MailTemplate` entity does NOT implement `IMultiTenant`. Templates are shared across all tenants and managed by system admins only.
**Source**: `MailTemplate.cs` — `IMultiTenant` commented out
**Linked requirements**: REQ-NOTIF-001

---

### BR-NOTIF-003 — Testing Mode Email Redirect

**Rule**: When `Settings:Abp.Mailing.IsTesting = true`, all emails are redirected to override addresses. The subject is prefixed with `"[TEST]"`.
**Source**: `MailTemplateAppService.SendEmailAsync()`
**Linked requirements**: REQ-NOTIF-001

---

## Role Rules

### BR-ROLE-001 — Static Roles Cannot Be Renamed

**Rule**: Roles with `IsStatic = true` cannot have their name changed. `UpdateAsync` throws `CannotRenameStaticRole` if name change is attempted on a static role.
**Source**: `RoleAppService.UpdateAsync()`
**Enforcement**: `UserFriendlyException(L["CannotRenameStaticRole"])` — HTTP 400
**Linked requirements**: [REQ-ROLE-001 — not yet documented in features/]

---

## gRPC Rules

### BR-GRPC-001 — gRPC Silent Fail

**Rule**: All gRPC handler methods catch ALL exceptions and return a structured error response. They never propagate exceptions to the caller.
**Source**: `AdministrationServicePermissionGrpc.cs`, `AdministrationServiceMailTemplateGrpc.cs`
**Pattern**:
```csharp
try { /* ... */ }
catch (Exception ex) { return new Response { IsSuccess = false, Error = ex.Message }; }
```
**Enforcement**: Code review — every gRPC method must have this pattern
**Linked requirements**: REQ-GRPC-001 (cross-service permission check)
