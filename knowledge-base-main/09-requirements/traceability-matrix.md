---
requirement_ids:
  - REQ-AUTH-001
  - REQ-AUTH-002
  - REQ-AUTH-003
  - REQ-AUTH-004
  - REQ-AUTH-005
  - REQ-AUTH-006
  - REQ-EMP-001
  - REQ-EMP-002
  - REQ-EMP-003
  - REQ-EMP-004
  - REQ-EMP-005
  - REQ-MEDIA-001
  - REQ-MEDIA-002
  - REQ-NOTIF-001
  - REQ-NOTIF-002
  - REQ-NOTIF-003
status: Confirmed
version: 1.0
created: 2026-05-23
updated: 2026-05-23
---

# Traceability Matrix

> Cross-reference: `REQ-ID` → `Implementation` → `Tests` → `Diagrams` → `Acceptance Criteria`
>
> **Status legend**: ✅ Implemented | ⚠️ Partial | ❌ Not implemented | 🔒 Disabled (code exists but commented out)

---

## Authentication

| REQ ID | Title | Status | Controller | App Service Method | Test File | Diagram | AC Count |
|---|---|---|---|---|---|---|---|
| REQ-AUTH-001 | Login with Employee.Code | ✅ | `AuthController.LoginAsync` | `AuthAppService.LoginAsync` | [Missing] | `auth-login.mermaid` | 4 |
| REQ-AUTH-002 | JWT Token Issuance (1h, sessionId) | ✅ | — (part of login) | `AuthAppService.CreateAccessTokenAsync` | [Missing] | `auth-login.mermaid` | 4 |
| REQ-AUTH-003 | Refresh Token Rotation (720h) | ✅ | `AuthController.RefreshLoginAsync` | `AuthAppService.RefreshLoginAsync` | [Missing] | `auth-token-refresh.mermaid` | 3 |
| REQ-AUTH-004 | Password Reset via Token URL | ✅ | `AuthController.RequestPasswordRecoveryAsync` / `ResetPasswordAsync` | `AuthAppService.RequestPasswordRecoveryAsync` / `ResetPasswordAsync` | [Missing] | `auth-password-reset.mermaid` | 5 |
| REQ-AUTH-005 | Logout Clears Redis Token | ✅ | `AuthController.LogoutAsync` | `AuthAppService.LogoutAsync` | [Missing] | `auth-logout.mermaid` | 2 |
| REQ-AUTH-006 | Multi-Tenant X-Tenant Header | ✅ | All controllers | ABP `ICurrentTenant` middleware | [Missing] | — | 3 |

---

## Employee Management

| REQ ID | Title | Status | Controller | App Service Method | Test File | Diagram | AC Count |
|---|---|---|---|---|---|---|---|
| REQ-EMP-001 | Employee CRUD | ✅ | `EmployeeController` | `EmployeeAppService.GetAsync` / `GetListAsync` / `CreateAsync` / `UpdateDetailAsync` / `DeleteAsync` | [Missing] | `sync-employee-identity.mermaid` | 7 |
| REQ-EMP-002 | Employee–IdentityUser Sync | ✅ | — (part of CRUD) | `EmployeeAppService.CreateAsync` / `UpdateDetailAsync` | [Missing] | `sync-employee-identity.mermaid` | 5 |
| REQ-EMP-003 | Bulk Import (2-step) | ✅ | `EmployeeController.ValidateImportAsync` / `ImportAsync` | `EmployeeAppService.ValidateImportAsync` / `ExecuteImportAsync` | [Missing] | `sync-employee-import.mermaid` | 8 |
| REQ-EMP-004 | Employee Search & Filter | ✅ | `EmployeeController.GetListAsync` | `EmployeeAppService.GetListAsync` | [Missing] | — | 4 |
| REQ-EMP-005 | Import Template Download | ✅ | `EmployeeController.GetImportTemplateAsync` | — | [Missing] | — | 1 |

---

## Media Files

| REQ ID | Title | Status | Controller | App Service Method | Test File | Diagram | AC Count |
|---|---|---|---|---|---|---|---|
| REQ-MEDIA-001 | Upload to Cloudinary | ✅ | `MediaFileController.UploadFileAsync` | `MediaFileAppService.UploadFileAsync` | [Missing] | — | 6 |
| REQ-MEDIA-002 | Soft-Delete Only | 🔒 Partial | `MediaFileController.DeleteFileByIdAsync` | `MediaFileAppService.DeleteFileByIdAsync` | [Missing] | — | 3 |

> ⚠️ REQ-MEDIA-002: Physical Cloudinary deletion is commented out. Soft-delete (SQL only) is active. Full requirement is only ✅ once physical deletion is enabled.

---

## Notifications

| REQ ID | Title | Status | App Service | Event Handler | Template Code | Diagram | AC Count |
|---|---|---|---|---|---|---|---|
| REQ-NOTIF-001 | Template-Based Email | ✅ | `MailTemplateAppService.SendEmailAsync` | — (called by handlers) | Any | `notification-mail-template.mermaid` | 5 |
| REQ-NOTIF-002 | Password Recovery Email | ✅ | `MailTemplateAppService.SendEmailAsync` | `RecoveryPasswordEventHandler` | `PASSWORD_RECOVERY` | `notification-event-handlers.mermaid` | 3 |
| REQ-NOTIF-003 | Password Reset Success Email | ✅ | `MailTemplateAppService.SendEmailAsync` | `PasswordResetSuccessEventHandler` | `PASSWORD_RECOVERY_SUCCESS` | `notification-event-handlers.mermaid` | 2 |

---

## Permissions & Roles (Partial — Not Fully Specified)

| REQ ID | Title | Status | Controller | App Service | Diagram | Notes |
|---|---|---|---|---|---|---|
| REQ-PERM-001 | Permission Check | 🔒 Disabled | `PermissionController` | `PermissionAppService.IsGrantedMultiplePermissionsAsync` | `grpc-cross-service.mermaid` | All `[PermissionsAuthorize]` commented out |
| REQ-ROLE-001 | Role CRUD | ✅ | `RoleController` | `RoleAppService` | — | Static roles cannot be renamed (BR-ROLE-001) |
| REQ-GRPC-001 | Cross-Service Permission gRPC | ✅ | — (gRPC) | `AdministrationServicePermissionGrpc` | `grpc-cross-service.mermaid` | Silent fail always |
| REQ-GRPC-002 | Cross-Service Email gRPC | ✅ | — (gRPC) | `AdministrationServiceMailTemplateGrpc` | `grpc-cross-service.mermaid` | Silent fail always |

---

## Business Rules Traceability

| Rule ID | Title | Enforcement Layer | Source File | Linked REQ |
|---|---|---|---|---|
| BR-AUTH-001 | Employee.Code login | Application | `AuthAppService.LoginAsync` | REQ-AUTH-001 |
| BR-AUTH-002 | JWT config (ZS issuer, HMAC-SHA256) | Infrastructure | `AuthenticationJwtBearerHandler.cs` | REQ-AUTH-002 |
| BR-AUTH-003 | Refresh token format + Redis storage | Application | `AuthAppService.CreateAccessTokenAsync` | REQ-AUTH-003 |
| BR-AUTH-004 | Token rotation (delete then issue) | Application | `AuthAppService.RefreshLoginAsync` | REQ-AUTH-003 |
| BR-AUTH-005 | Password reset token encryption | Application | `AuthAppService.RequestPasswordRecoveryAsync` | REQ-AUTH-004 |
| BR-AUTH-006 | Password reset token single-use | Application | `AuthAppService.ResetPasswordAsync` | REQ-AUTH-004 |
| BR-EMP-001 | Email/OtherEmail/Phone uniqueness | Application | `EmployeeAppService.CreateAsync` | REQ-EMP-001 |
| BR-EMP-002 | IdentityUser created before Employee | Application | `EmployeeAppService.CreateAsync` | REQ-EMP-002 |
| BR-EMP-003 | List vs detail field difference | Application | `EmployeeAppService.GetListAsync` | REQ-EMP-001 |
| BR-EMP-004 | IsActive=false → lockout | Application | `EmployeeAppService.UpdateDetailAsync` | REQ-EMP-002 |
| BR-IMPORT-001 | Max 5MB file size | Application | `EmployeeAppService.ValidateImportAsync` | REQ-EMP-003 |
| BR-IMPORT-002 | Max 100 rows | Application | `EmployeeAppService.ValidateImportAsync` | REQ-EMP-003 |
| BR-IMPORT-003 | 30min session TTL | Application | `EmployeeAppService.ValidateImportAsync` | REQ-EMP-003 |
| BR-IMPORT-004 | Student email format | Application | `EmployeeAppService.ExecuteImportAsync` | REQ-EMP-003 |
| BR-IMPORT-005 | Race condition duplicate skip | Application | `EmployeeAppService.ExecuteImportAsync` | REQ-EMP-003 |
| BR-MEDIA-001 | Max 100MB upload | Application | `MediaFileAppService.UploadFileAsync` | REQ-MEDIA-001 |
| BR-MEDIA-002 | Max 5MB avatar | Application | `MediaFileConsts.MaxAvatarSize` | REQ-MEDIA-001 |
| BR-MEDIA-003 | Cloudinary folder structure | Application | `MediaFileAppService.UploadFileAsync` | REQ-MEDIA-001 |
| BR-MEDIA-004 | Cloudinary publicId + tags | Application | `MediaFileAppService.UploadFileAsync` | REQ-MEDIA-001 |
| BR-NOTIF-001 | `##Group.Field##` placeholders | Application | `MailTemplateAppService.ReplaceMailTemplateVariable` | REQ-NOTIF-001 |
| BR-NOTIF-002 | Templates not multi-tenant | Domain | `MailTemplate.cs` (IMultiTenant commented out) | REQ-NOTIF-001 |
| BR-NOTIF-003 | Testing mode redirect | Application | `MailTemplateAppService.SendEmailAsync` | REQ-NOTIF-001 |
| BR-ROLE-001 | Static roles cannot be renamed | Application | `RoleAppService.UpdateAsync` | REQ-ROLE-001 |
| BR-GRPC-001 | gRPC silent fail | Infrastructure | `AdministrationServicePermissionGrpc.cs`, `...MailTemplateGrpc.cs` | REQ-GRPC-001, REQ-GRPC-002 |

---

## Coverage Gaps

| Gap | Impact | Resolution |
|---|---|---|
| No automated tests for any REQ | All ACs are manual-only | Create `Application.Tests` unit tests per feature |
| REQ-PERM-001 (RBAC) commented out | No runtime permission enforcement | Uncomment `[PermissionsAuthorize]` per action after verifying frontend sends tokens |
| REQ-MEDIA-002 partial (physical delete disabled) | Cloudinary storage grows indefinitely | Uncomment `DestroyAsync` in `MediaFileAppService.DeleteFileByIdAsync` |
| 2FA (SendOTPEvent) disabled | OTP screen in mobile app is non-functional | Enable in `AuthAppService.LoginAsync` and wire OTP validation |
| IP rate limiting disabled | No brute-force protection | Uncomment `BlockIpAddressAsync` in `AuthAppService.LoginAsync` |
| REQ-CUSTOMER-001 (Party/Customer domain) | Customer API only has a demo stub | Full Party implementation needed |

---

## ID Registry

Use this registry to avoid ID collisions. Reserve the next ID by incrementing the counter.

| Domain | Prefix | Last Used | Next Available |
|---|---|---|---|
| Authentication | `REQ-AUTH-` | `006` | `007` |
| Employee | `REQ-EMP-` | `005` | `006` |
| Media | `REQ-MEDIA-` | `002` | `003` |
| Notifications | `REQ-NOTIF-` | `003` | `004` |
| Permissions | `REQ-PERM-` | `001` | `002` |
| Roles | `REQ-ROLE-` | `001` | `002` |
| gRPC | `REQ-GRPC-` | `002` | `003` |
| Customer/Party | `REQ-CUST-` | `000` | `001` |
| Infrastructure | `REQ-INFRA-` | `000` | `001` |
| Business Rules (Auth) | `BR-AUTH-` | `006` | `007` |
| Business Rules (Employee) | `BR-EMP-` | `004` | `005` |
| Business Rules (Import) | `BR-IMPORT-` | `005` | `006` |
| Business Rules (Media) | `BR-MEDIA-` | `004` | `005` |
| Business Rules (Notification) | `BR-NOTIF-` | `003` | `004` |
| Business Rules (Role) | `BR-ROLE-` | `001` | `002` |
| Business Rules (gRPC) | `BR-GRPC-` | `001` | `002` |
| Use Cases | `UC-` | `000` | `001` |
| User Stories | `US-` | `000` | `001` |
| Acceptance Criteria | `AC-` | (inline in REQ files) | — |
