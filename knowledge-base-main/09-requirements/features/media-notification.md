---
requirement_ids:
  - REQ-MEDIA-001
  - REQ-MEDIA-002
  - REQ-NOTIF-001
  - REQ-NOTIF-002
  - REQ-NOTIF-003
status: Implemented
service: administration-api
version: 1.0
created: 2026-05-23
updated: 2026-05-23
---

# Media File & Notification Requirements

> **Status**: Implemented
> **Service**: `administration-api`
> **Source verification**: `MediaFileAppService.cs`, `MediaFileController.cs`, `MailTemplateAppService.cs`, `MailTemplateConsts.cs`, event handlers

---

## REQ-MEDIA-001 — Media File Upload to Cloudinary

**The system shall upload media files to Cloudinary with a structured folder, publicId, and tag naming convention.**

### Acceptance Criteria

- [ ] **AC-MEDIA-001-01**: Given a valid file ≤ 100MB, when `POST /api/media-file` is called, then the file is uploaded to Cloudinary folder `CMN/{tenantId}/` with `publicId = {tenantId}_{fileId}`.
- [ ] **AC-MEDIA-001-02**: Given multiple files in one request, when any single upload fails, then ALL uploads in the batch are rolled back (Cloudinary delete called for already-uploaded files).
- [ ] **AC-MEDIA-001-03**: Given a successful upload, then a `MediaFile` entity is persisted in SQL Server with `SecureUrl`, `PublicId`, `AssetId`, `Format`, `Size`, `ResourceType`.
- [ ] **AC-MEDIA-001-04**: Given a file > 100MB total batch size, then the system returns HTTP 400 before uploading.
- [ ] **AC-MEDIA-001-05**: Given an image upload, the `ResourceType = "image"`, `AllowedExtensions = [".jpg", ".jpeg", ".png"]` are enforced.
- [ ] **AC-MEDIA-001-06**: Given a successful upload, the Cloudinary tags are `["tenant-{tenantId}", "file-{fileId}"]`.

### Business Rules
| Rule ID | Description |
|---|---|
| BR-MEDIA-001 | Max total upload size: 100MB (`MediaFileConsts.MaxFileSize`) |
| BR-MEDIA-002 | Max avatar size: 5MB (`MediaFileConsts.MaxAvatarSize`) |
| BR-MEDIA-003 | Cloudinary folder: `CMN/{tenantId}/` (parent folder = `"CMN"`) |
| BR-MEDIA-004 | publicId format: `{tenantId}_{fileId}` where fileId is UUIDv7 |

### Implementation Traceability
| Artifact | Location |
|---|---|
| Controller | `MediaFileController.cs` → `POST /api/media-file` |
| App Service | `MediaFileAppService.UploadFileAsync()` |
| Consts | `MediaFileConsts.cs` — `ParentFolder = "CMN"`, `MaxFileSize`, `MaxAvatarSize`, `AllowedImageExtensions` |
| Rollback | `MediaFileAppService.UploadFileAsync()` — catch block deletes all uploaded items |

---

## REQ-MEDIA-002 — Soft-Delete Only (No Physical Cloudinary Deletion)

**The system shall support media file deletion as a soft-delete only. Physical deletion from Cloudinary is disabled.**

### Rationale
Physical Cloudinary deletion is irreversible and could break any existing URLs that reference the file. Soft-delete allows recovery and audit trail while preventing active use.

### Acceptance Criteria

- [ ] **AC-MEDIA-002-01**: Given a valid media file ID, when `DELETE /api/media-file/{id}` is called, then `MediaFile.IsDeleted = true` in SQL Server.
- [ ] **AC-MEDIA-002-02**: Given the deletion, the Cloudinary asset is NOT removed (the Cloudinary `DestroyAsync` call is commented out in the implementation).
- [ ] **AC-MEDIA-002-03**: Given a soft-deleted file ID, when the file is referenced in any response, the record still exists in the database with `IsDeleted = true`.

### Known Constraint
The Cloudinary `DestroyAsync` call is currently commented out in `MediaFileAppService.DeleteFileByIdAsync`. This is tracked as technical debt.

### Implementation Traceability
| Artifact | Location |
|---|---|
| App Service | `MediaFileAppService.DeleteFileByIdAsync()` — `DestroyAsync` call commented out |

---

## REQ-NOTIF-001 — Template-Based Email Notification

**The system shall send emails using named templates stored in MongoDB, with `##Group.Field##` placeholder substitution.**

### Rationale
Template-based email decouples email content from code. Templates are managed via the admin UI without code deployments. The `##Group.Field##` syntax is the confirmed placeholder format.

### Acceptance Criteria

- [ ] **AC-NOTIF-001-01**: Given a template code and data dictionary, when `SendEmailAsync` is called, then the template is fetched from MongoDB collection `adm_MailTemplate`.
- [ ] **AC-NOTIF-001-02**: Given a template with `##User.Name##` in the body, when sent with `{ "User.Name": "Nguyen Van A" }`, then the email body contains "Nguyen Van A".
- [ ] **AC-NOTIF-001-03**: Given `Settings:Abp.Mailing.IsTesting = true`, when any email is sent, then the recipient is overridden to the testing address and the subject is prefixed with `"[TEST]"`.
- [ ] **AC-NOTIF-001-04**: Given a template code that does not exist in MongoDB, when `SendEmailAsync` is called, then an exception is thrown.
- [ ] **AC-NOTIF-001-05**: Given a gRPC call from Customer API to `SendEmail`, when called, then the response is `{ IsSuccess: true }` on success or `{ IsSuccess: false, Error: "..." }` on failure (never throws).

### Business Rules
| Rule ID | Description |
|---|---|
| BR-NOTIF-001 | Placeholder format: `##Group.Field##` (shortCode = `"##"` by default) |
| BR-NOTIF-002 | Templates stored in MongoDB `swt_cmn.adm_MailTemplate` — NOT in SQL Server |
| BR-NOTIF-003 | `MailTemplate` is NOT multi-tenant — templates are system-wide |

### Implementation Traceability
| Artifact | Location |
|---|---|
| App Service | `MailTemplateAppService.SendEmailAsync()` |
| MongoDB collection | `adm_MailTemplate` in `swt_cmn` DB |
| gRPC server | `AdministrationServiceMailTemplateGrpc.SendAsync()` |
| Sequence diagram | `diagrams/notification-mail-template.mermaid` |

---

## REQ-NOTIF-002 — Password Recovery Email

**The system shall send a `PASSWORD_RECOVERY` email containing the reset link when password recovery is requested.**

### Acceptance Criteria

- [ ] **AC-NOTIF-002-01**: Given `RequestPasswordRecoveryAsync` succeeds, then a `PASSWORD_RECOVERY` template email is sent to the user's email with `##PasswordReset.ResetLink##` populated.
- [ ] **AC-NOTIF-002-02**: Given the email, the `##User.Name##`, `##User.UserName##`, and `##User.TenantName##` placeholders are correctly substituted.
- [ ] **AC-NOTIF-002-03**: The `##PasswordReset.ExpireHours##` placeholder is set to `24`.

### Known Template Codes
| Code | Template Constant | Purpose |
|---|---|---|
| `SEND_OTP` | `MailTemplateConsts.SEND_OTP_CODE` | 2FA OTP (currently disabled) |
| `PASSWORD_RECOVERY` | `MailTemplateConsts.PASSWORD_RECOVERY` | Reset link email |
| `PASSWORD_RECOVERY_SUCCESS` | `MailTemplateConsts.PASSWORD_RECOVERY_SUCCESS` | Confirmation email |

### Implementation Traceability
| Artifact | Location |
|---|---|
| Publisher | `AuthAppService.RequestPasswordRecoveryAsync()` → publishes `RecoveryPasswordEvent` |
| Handler | `RecoveryPasswordEventHandler.HandleEventAsync()` |
| Event diagram | `diagrams/event-choreography.mermaid` |

---

## REQ-NOTIF-003 — Password Reset Success Email

**The system shall send a `PASSWORD_RECOVERY_SUCCESS` confirmation email after a successful password reset.**

### Acceptance Criteria

- [ ] **AC-NOTIF-003-01**: Given `ResetPasswordAsync` succeeds, then a `PASSWORD_RECOVERY_SUCCESS` template email is sent.
- [ ] **AC-NOTIF-003-02**: Given the email, the `##PasswordReset.Time##` and `##PasswordReset.Date##` placeholders show the reset time.

### Implementation Traceability
| Artifact | Location |
|---|---|
| Publisher | `AuthAppService.ResetPasswordAsync()` → publishes `PasswordResetSuccessEvent` |
| Handler | `PasswordResetSuccessEventHandler.HandleEventAsync()` |
