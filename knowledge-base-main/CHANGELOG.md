# CHANGELOG â€” CMN Knowledge Base

All notable changes to the Knowledge Base are recorded here.

Format:
```
## YYYY-MM-DD â€” [Type] Description
Source: [code file, PR, or discovery session]
Updated: [list of KB files changed]
```

Types: `INIT` | `ADD` | `UPDATE` | `REMOVE` | `FIX` | `VERIFY`

---

## 2026-06-05 — UPDATE KB sync — 12 new items added (org-unit.crud, identity-user.stub, customer.party-stub, media.get, GetDetailAsync rename, ExecuteImportAsync/GetImportErrorFileAsync, gRPC operation renames), 1 entity removed (IdentityUser), all scanners fixed

**Source**: detect-drift.ps1 scan

---


## 2026-05-23 â€” ADD Phase 9 Governance & Enterprise Scaling

**Source**: All confirmed implementation facts from Phases 0â€“8
**Updated**: `governance.md`, `audit-playbook.md`, `review-checklist.md` â€” enterprise governance layer

### Files Created

| File | Content |
|---|---|
| `governance.md` | Enterprise KB governance: ownership model (KB Owner + domain owners), 3-tier update SLA (mandatory/timely/opportunistic), approval workflow, versioning & snapshots, multi-team governance (cross-team change protocol, conflict resolution), AI-agent governance (permitted vs. restricted actions, confidence levels, session start protocol), onboarding workflow (human + AI), quarterly audit schedule, escalation paths, CHANGELOG policy. |
| `audit-playbook.md` | 7-phase quarterly audit procedure: (1) drift audit via detect-drift.ps1, (2) requirements audit (REQ status + AC + ID registry), (3) diagram currency audit (15 diagrams checklist), (4) technical debt audit (full TD-001..TD-008 review), (5) playbook verification (rotating execute schedule), (6) release snapshot creation with PowerShell commands, (7) audit report template. Audit schedule table and history log. |
| `review-checklist.md` | 5 context-specific review checklists: (A) code change + KB update, (B) KB-only change, (C) new feature (REQ coverage + diagrams), (D) AI-generated KB output (hallucination check, restricted actions, confidence levels), (E) quarterly audit review. Plus quick reference table of 10 must-check items. |

### Governance Highlights

- **3 SLA tiers**: Tier 1 = mandatory (block merge), Tier 2 = same sprint, Tier 3 = opportunistic
- **AI governance**: 9 permitted autonomous actions, 9 restricted actions requiring human sign-off
- **Audit schedule**: Q1/Q2/Q3/Q4 â€” first 2 weeks of January/April/July/October
- **Snapshot naming**: `kb/YYYY-QN` git tags + `_snapshots/YYYY-QN/` directories
- **Onboarding**: 5-stage workflow for humans (Day 1 â†’ Week 2), 5-step protocol for AI agents
- **Conflict resolution**: Source code is arbiter â†’ KB Owner decides â†’ documented in `_meta/decisions/`

---

## 2026-05-23 â€” ADD Phase 8 Self-Updating Knowledge System

**Source**: All confirmed implementation facts from Phases 0â€“7
**Updated**: `AUTOMATION.md`, `_meta/knowledge-impact-map.yml`, `scripts/` â€” full drift detection and validation system

### Files Created / Updated

| File | Content |
|---|---|
| `AUTOMATION.md` | Full rewrite with Phase 8 content: drift detection architecture, trigger table, update checklists per change type, anchor system reference, CI/CD integration. |
| `_meta/knowledge-impact-map.yml` | 19 source file glob patterns â†’ KB impact mappings. Covers controllers, entities, gRPC, events, consts, appsettings, migrations, frontend, mobile. Each entry has: docs, scripts, why, severity, anchors. |
| `scripts/detect-drift.ps1` | Orchestrator: runs all 4 scanners, aggregates results, Console + JSON output, exit code 0 (clean) or 1 (drift). |
| `scripts/scan-endpoints.ps1` | HTTP endpoint scanner: finds [HttpGet/Post/Put/Delete/Patch] in *Controller.cs, compares against manifest.yml features[].endpoints[].controller. |
| `scripts/scan-entities.ps1` | Entity scanner: finds FullAuditedEntity<Guid> subclasses, compares against entity-relations.mermaid entity blocks. |
| `scripts/scan-grpc.ps1` | gRPC scanner: finds `rpc MethodName` in *.proto files, compares against manifest.yml integrations[grpc-channel].operations. |
| `scripts/scan-events.ps1` | Event scanner: finds ILocalEventBus.PublishAsync<T> calls + ILocalEventHandler<T> impls, compares against manifest features[].events_published. Also warns on published events with no handler. |
| `scripts/validate-manifest.ps1` | Manifest validator: REQ/BR/TD ID format checks, service ID uniqueness, feature bounded_context cross-references, requirement file path existence, ID registry next_available > last_used. |
| `scripts/validate-anchors.ps1` | Anchor validator: stack-based BEGIN/END matching for HTML comment anchors, YAML comment anchors, and legacy KB-ANCHOR format. Reports unmatched anchors with file:line location. |
| `scripts/update-changelog.ps1` | Changelog helper: takes Type/Description/Source/Files params, generates formatted entry, inserts at top of entries section in CHANGELOG.md. DryRun mode available. |

### Drift Detection Coverage

| Domain | Scanner | Source Pattern |
|---|---|---|
| HTTP Endpoints | `scan-endpoints.ps1` | `*Controller.cs` â†’ `[Http*]` attributes |
| Domain Entities | `scan-entities.ps1` | `Domain/**/*.cs` â†’ `FullAuditedEntity<Guid>` subclasses |
| gRPC Methods | `scan-grpc.ps1` | `*.proto` â†’ `rpc MethodName` declarations |
| Domain Events | `scan-events.ps1` | `*AppService.cs` â†’ `PublishAsync<T>`, `*EventHandler.cs` â†’ `ILocalEventHandler<T>` |

### Known Gaps (not yet covered)

- Frontend route changes (no scan-routes.ps1)
- Mobile screen/route changes (no Flutter AST scanner)
- appsettings.json key additions (manual only)
- New NuGet packages (manual only)

---

## 2026-05-23 â€” ADD Phase 7 AI Automation Foundation

**Source**: All confirmed implementation facts from Phases 0â€“6
**Updated**: `_meta/` and `_templates/` directories â€” machine-readable AI automation layer

### Files Created

| File | Content |
|---|---|
| `_meta/manifest.yml` | Master machine-readable system manifest: 7 services, 8 bounded contexts, 15 features, 7 integrations, 9 REQ domains, 7 BR domains, 8 technical debt items, AI agent guidance. Anchor convention: `# === BEGIN/END: section-id ===` |
| `_meta/manifest.schema.json` | JSON Schema Draft-07 validating manifest.yml structure. Defines id patterns, enum constraints, required fields for all sections including services, bounded_contexts, features, integrations, requirements, ownership, technical_debt. |
| `_templates/service.yml` | Annotated YAML template for adding a new service entry to manifest.yml. Covers all fields: type, stack, ports, db_schema, grpc config, hard/soft dependencies, service dependencies, bounded_contexts, status. |
| `_templates/feature.yml` | Annotated YAML template for adding a new feature entry. Covers endpoints (method/path/controller/auth), app_service, grpc_handler, events_published, requirements, business_rules, diagram, disabled sub-features. |
| `_templates/flow.yml` | Annotated YAML template for operational flow documentation. Covers trigger, services_involved, step-by-step definition, error paths, diagram, disabled steps. Types: sequence, event-chain, background-job, import-pipeline, grpc-call. |
| `_templates/requirement.yml` | Machine-readable YAML form of a requirement for manifest index. Covers status lifecycle, priority, system-shall description, implementation traceability, AC count, test coverage. |
| `_templates/integration.yml` | Annotated YAML template for adding infrastructure/external system integrations. Covers connection info, config keys, key patterns (Redis), collections (MongoDB), operations (gRPC), architecture constraints. |
| `_templates/business-rule.yml` | Machine-readable YAML form of a business rule. Covers enforcement layer/file/method, violation behavior (exception type + HTTP status + L[] key), linked requirements, parameters. |

### Anchor Marker Convention

- YAML files: `# === BEGIN: section-id ===` / `# === END: section-id ===`
- Markdown/HTML files: `<!-- BEGIN: section-id -->` / `<!-- END: section-id -->`
- All templates and manifest.yml use anchor markers for AI-agent section navigation

### Machine-Readable Manifest Sections

`system` Â· `services` Â· `bounded-contexts` Â· `features` Â· `integrations` Â· `requirements` Â· `ownership` Â· `technical-debt` Â· `ai-agent-guidance`

---

## 2026-05-23 â€” ADD Phase 6 Requirements & Traceability

**Source**: All confirmed implementation facts from Phases 0â€“5
**Updated**: `09-requirements/` â€” full requirements system created from scratch

### Files Created

| File | Content |
|---|---|
| `09-requirements/README.md` | Updated: structure, ID scheme, how-to instructions, coverage table |
| `09-requirements/traceability-matrix.md` | Cross-reference: 32 REQ/BR IDs â†’ implementation files â†’ diagrams â†’ AC counts. Includes coverage gaps table and ID registry. |
| `09-requirements/business-rules.md` | 24 confirmed business rules across AUTH (6), EMP (4), IMPORT (5), MEDIA (4), NOTIF (3), ROLE (1), GRPC (1) â€” each with source file, enforcement layer, violation behavior |
| `09-requirements/features/authentication.md` | REQ-AUTH-001 to REQ-AUTH-006 â€” 6 requirements, 21 acceptance criteria, full implementation traceability |
| `09-requirements/features/employee-management.md` | REQ-EMP-001 to REQ-EMP-005 â€” 5 requirements, 25 acceptance criteria, import 2-step flow fully traced |
| `09-requirements/features/media-notification.md` | REQ-MEDIA-001/002, REQ-NOTIF-001/002/003 â€” 5 requirements, 19 acceptance criteria |
| `09-requirements/templates/requirement-template.md` | Template with YAML frontmatter, AC, business rules, implementation + test traceability sections |
| `09-requirements/templates/business-rule-template.md` | Template with rule statement, trigger, enforcement layers, violation behavior |
| `09-requirements/templates/use-case-template.md` | Actor-goal-flow template with main flow table, alternative flows, exception table |
| `09-requirements/templates/user-story-template.md` | Given/When/Then AC format, Definition of Done checklist, implementation traceability |
| `09-requirements/templates/acceptance-criteria-template.md` | Standalone AC document with per-criterion Given/When/Then, test type, verification status table |

### ID Registry Established

First-use IDs: `REQ-AUTH-001..006`, `REQ-EMP-001..005`, `REQ-MEDIA-001..002`, `REQ-NOTIF-001..003`, `REQ-PERM-001`, `REQ-ROLE-001`, `REQ-GRPC-001..002`

### Coverage Gaps Documented in Traceability Matrix

- Zero automated test coverage for any requirement
- REQ-PERM-001 (RBAC): all `[PermissionsAuthorize]` commented out â€” runtime enforcement disabled
- REQ-MEDIA-002 (physical delete): `DestroyAsync` commented out
- 2FA + IP rate limiting: code exists but disabled
- Customer/Party domain: stub only, no requirements specified

---

## 2026-05-23 â€” ADD Phase 5 Playbooks & Execution Conventions

**Source**: All confirmed implementation facts from Phases 0â€“4
**Updated**: `playbooks/` â€” 9 new files created, 1 existing file corrected; `03-conventions.md` â€” major additions

### New Playbook Files

| File | Purpose |
|---|---|
| `playbooks/add-feature.md` | Full end-to-end feature playbook: entity â†’ migration â†’ app service â†’ controller â†’ frontend. Includes pre-flight checklist, verification checklist, KB update steps. |
| `playbooks/add-endpoint.md` | Single endpoint: InputDto + Validator + OutputDto + interface + app service + controller + test. Corrected from prior draft (no AutoMapper, correct ValidationConsts usage). |
| `playbooks/add-entity.md` | Domain entity: schema/prefix table, `FullAuditedEntity<Guid>` + `IMultiTenant`, DbContext registration, migration, optional custom repository. IMultiTenant exception documented. |
| `playbooks/add-grpc-method.md` | gRPC: proto update â†’ codegen â†’ server handler (silent fail, DisableAuditing, UoW for mutations) â†’ client method â†’ channel config â†’ integration test. |
| `playbooks/add-worker.md` | ABP Background Job: args class, `AsyncBackgroundJob<TArgs>` + `ITransientDependency`, enqueue via `IBackgroundJobManager`, SQL Server storage. Marks no custom handlers in current codebase. |
| `playbooks/add-event.md` | Local domain event: event class â†’ `ILocalEventBus.PublishAsync` â†’ `ILocalEventHandler<T>` + `ITransientDependency`. Includes mail template code convention and test pattern. |
| `playbooks/migration.md` | EF Core migration lifecycle: create â†’ review checklist â†’ apply (DbMigrator vs ef CLI) â†’ rollback. Includes current migration baseline per service and connection string reference. |
| `playbooks/deployment.md` | Full deployment: build â†’ migrate â†’ startup order (Admin API first for gRPC) â†’ frontend builds â†’ smoke tests. Port map, infra dependency table, environment config reference. |
| `playbooks/rollback.md` | Rollback decision tree: code â†’ migration â†’ Redis flush â†’ config â†’ frontend. Migration rollback commands, safe rollback targets, post-rollback verification, incident log template. |

### Existing Playbooks Corrected

- **`playbooks/add-new-endpoint.md`**: Fixed `ObjectMapper.Map<Widget, WidgetOutputDto>(widget)` â†’ `new WidgetOutputDto { Id = widget.Id, Name = widget.Name }`. AutoMapper is not registered in CMN â€” this was a confirmed bug in the prior Phase 0 playbook.

### 03-conventions.md Additions

- **Forbidden Patterns (Backend)**: 15 explicit forbidden patterns with "Why" and "Correct alternative"
- **Forbidden Patterns (Frontend Extended)**: 11 additional patterns beyond the existing no-go table
- **Architecture Constraints**: 8 load-bearing decisions documented with change-impact notes
  - Custom JWT (not OpenIddict) â€” SecurityKey change logs out all users
  - Single DB, two schemas â€” no cross-schema queries in app code
  - gRPC silent-fail contract â€” cannot add propagation without client updates
  - Hangfire/OpenIddict disabled â€” do not activate without migration plan
  - MailTemplate not multi-tenant â€” never filter by TenantId
  - Frontend layer import direction enforced
  - All permissions currently commented out â€” partial enable creates inconsistent security
  - Employee.Code is login username â€” full-stack change required to alter
- **Known Technical Debt**: 7 confirmed issues with location, impact, and fix description

---

## 2026-05-23 â€” ADD Phase 4 Flows & Diagrams

**Source**: All confirmed implementation facts from Phases 0â€“3
**Updated**: `diagrams/` â€” 12 new files created, 3 existing files corrected

### New Diagram Files

| File | Type | Covers |
|---|---|---|
| `diagrams/auth-login.mermaid` | sequence | Full login flow: Employee.Code lookup â†’ JWT with sessionId â†’ Redis refresh token â†’ cookie storage. Marks disabled 2FA and IP rate limiting. |
| `diagrams/auth-token-refresh.mermaid` | sequence | 401 interceptor â†’ refresh-login â†’ extract expired claims â†’ Redis rotate (DEL old, SET new) â†’ retry |
| `diagrams/auth-password-reset.mermaid` | sequence | Two-phase: UUID token â†’ encrypt â†’ Redis 24h â†’ email link; then decrypt â†’ Redis validate â†’ password change â†’ confirmation email |
| `diagrams/auth-logout.mermaid` | sequence | JWT claim extraction â†’ Redis DEL {userId}:{sessionId} â†’ cookie clear |
| `diagrams/notification-mail-template.mermaid` | sequence | Two send paths: direct (event handler) and via gRPC (Customer API â†’ Admin API). MongoDB lookup, placeholder replacement, MailKit SMTP. |
| `diagrams/notification-event-handlers.mermaid` | flowchart | All 3 local events + handlers + template codes + variable lists. SendOTPEvent publish marked DISABLED. |
| `diagrams/sync-employee-identity.mermaid` | sequence | Create: uniqueness checks â†’ IdentityUser first â†’ Employee. Update: partial sync of Name/Email/Phone/IsActive â†’ lockout management. |
| `diagrams/sync-employee-import.mermaid` | sequence | 2-step: validate (5MB/100-row limits, error file, Redis 30min session) â†’ execute (bulk pre-load, race-condition re-check, student email format). Error file download included. |
| `diagrams/event-choreography.mermaid` | flowchart | Complete domain event choreography: publishers â†’ event bus â†’ handlers â†’ MailTemplateAppService â†’ SMTP |
| `diagrams/frontend-bootstrap-web.mermaid` | sequence | Axios init, request interceptor (cookie tokens + localStorage tenantId), response interceptor (401 refresh, error routing) |
| `diagrams/frontend-bootstrap-mobile.mermaid` | flowchart | Firebase init, dotenv load, Dio setup with Performance + auth interceptors, Riverpod ProviderScope, go_router auth guard |
| `diagrams/state-employee-lifecycle.mermaid` | stateDiagram | FirstLogin â†’ Active â†’ Deactivated (lockout) â†” Active |
| `diagrams/state-password-reset-token.mermaid` | stateDiagram | Pending â†’ Used | Expired; both terminal states throw on reuse |
| `diagrams/state-import-session.mermaid` | stateDiagram | Validating â†’ Valid | Invalid | PartiallyValid â†’ Imported | Expired |
| `diagrams/worker-abp-background-jobs.mermaid` | flowchart | ABP Background Jobs: SQL Server store, poll/fetch/execute/retry. Notes no custom handlers found. |
| `diagrams/grpc-cross-service.mermaid` | sequence | Permission check (single + batch with OR semantics), mail template send, TestPermission stub. All paths show silent-fail behavior. |

### Existing Diagrams Corrected

- **`diagrams/architecture.mermaid`**: Added MongoDB node (Administration API â†’ `swt_cmn.adm_MailTemplate`); added SQL Server DB name (`SWTCMN`); corrected Redis label to list actual cache usage; corrected gRPC label to show `:50051 TLS`
- **`diagrams/entity-relations.mermaid`**: Completed `MailTemplate` entity fields (Name, Code, Description, Subject, Body)
- **`diagrams/data-flow.mermaid`**: Fixed auth route (`/api/auth` not `/api/auth/login`); corrected token storage (cookies not localStorage); added Redis refresh token step; corrected login field to Employee.Code

---

## 2026-05-23 â€” UPDATE Phase 3 Service Deep Dive

**Source**: All controller files, DTO files, EmployeeConsts, ValidationConsts, EmployeeOutputDto, CreateEmployeeInputDto, LoginOutputDto, ImportEmployeeValidationResultDto, PartyController, CustomerManagementPermissions, admin web app store/pages glob, RoleController, MediaFileController, PermissionController
**Updated**: `services/administration-api.md`, `services/customer-api.md`, `services/web-gateway.md`, `services/administration-web-app.md`, `services/web-app.md`, `services/mobile-app.md`

### Changes

**services/administration-api.md** â€” Complete rewrite with full implementation detail:
- Added Mermaid layer architecture diagram and request lifecycle sequence diagram
- Complete route table: all HTTP methods, routes, auth level, binding type, input/output DTOs for all 5 controllers
- Complete DTO reference with field-level validation rules (regex, max lengths, required checks)
- `EmployeeOutputDto` fields documented (list vs detail differences â€” PositionName/OrgName null in list)
- `PagedResultEmployeeOutputDto.ExtendData` documented (`totalActiveEmployees`, `totalDeactiveEmployees`)
- Import DTOs fully documented (`ImportEmployeeValidationResultDto` fields)
- All entity â†’ DB table mappings confirmed (including ABP internal tables)
- All gRPC server methods documented with proto excerpt and error behavior (silent fail)
- All 3 domain events documented with trigger and handler action
- Complete Redis cache key inventory with TTLs
- Background jobs: confirmed ABP Background Jobs only (no Hangfire)
- Permission model table with all confirmed permission keys
- Integration dependency Mermaid diagram
- Known constraints: AllowAnonymous on POST /employee, all permissions commented out, no physical Cloudinary deletion, IP rate limiting disabled

**services/customer-api.md** â€” Complete rewrite:
- Added Mermaid layer architecture and request lifecycle diagrams
- PartyController: documented as demo stub with `[AllowAnonymous]` and hardcoded response
- `CustomerManagementPermissions`: documented as empty placeholder (no permissions defined)
- gRPC client: documented available methods (IsGrantedPermission, SendEmail)
- Single migration: `20260103081306_Initial` creates only `CM.Party`
- Background jobs: corrected (not Hangfire; ABP Background Jobs; no custom handlers)
- Cache: confirmed Redis configured but no usage found
- Known constraints table: stub Party, demo controller, empty permissions, no gRPC server

**services/web-gateway.md** â€” Updated:
- Added Mermaid routing diagram
- Added request lifecycle sequence diagram
- Added ownership boundaries section

**services/administration-web-app.md** â€” Major update:
- Added Mermaid layer architecture diagram
- Added Employee List request lifecycle sequence diagram
- Updated pages table: noted `users` and `organization` not found in page glob scan
- Noted employee store slice exists but no employee page directory found (may be in web-app)
- Documented Redux thunk pattern with concrete example code
- HTTP client config table with all confirmed settings
- Complete `@core/component` and `@core/hooks` inventory
- Added known constraints table

**services/web-app.md** â€” Major update:
- Added Mermaid layer architecture diagram and request lifecycle sequence diagram
- Documented `(auth)/reset-password` reads `?token=` from URL (encrypted UUID from admin API)
- Email template authoring role documented
- Complete app directory structure
- Known constraints table

**services/mobile-app.md** â€” Major update:
- Added Mermaid architecture diagram and request lifecycle sequence diagram
- Documented OTP screen exists but 2FA not active on backend
- `BASE_URL=""` constraint documented
- `get_storage` is not encrypted â€” token security note
- Ownership boundaries section added
- `lib/gen/` and asset generation documented

---

## 2026-05-23 â€” UPDATE Phase 2 Business & Domain Knowledge

**Source**: AuthAppService.cs, EmployeeAppService.cs, MediaFileAppService.cs, PermissionAppService.cs, RoleAppService.cs, MailTemplateAppService.cs, SendOTPEventHandler.cs, RecoveryPasswordEventHandler.cs, PasswordResetSuccessEventHandler.cs, AdministrationServicePermissionGrpc.cs, AdministrationServiceMailTemplateGrpc.cs, MailTemplateConsts.cs, MediaFileConsts.cs, AuthConsts.cs, auth.service.ts
**Updated**: `04-business-domain.md`, `05-flows.md`, `06-integrations.md`, `07-security-permissions.md`, `.discovery/inferred-assumptions.md`

### Changes

**04-business-domain.md** â€” Full rewrite with implementation-confirmed content:
- Corrected `Employee.Code` is the login username (NOT email)
- Documented `MailTemplate` entity fields + placeholder syntax (`##Group.Field##`)
- Confirmed known template codes: `SEND_OTP`, `PASSWORD_RECOVERY`, `PASSWORD_RECOVERY_SUCCESS`
- Added all confirmed employee business rules (duplicate checks, IdentityUser sync, partial update logic)
- Documented full 2-step employee import lifecycle with confirmed constraints (5MB, 100 rows, 30min TTL)
- Added state machines for login, password reset token, and import session
- Added domain event details: `SendOTPEvent` is implemented but 2FA is commented out in `LoginAsync`

**05-flows.md** â€” Major rewrite of core flows:
- Flow 1 (Login): Corrected to `Employee.Code` login; added session ID claim; added token caching in Redis; added IP rate limiting detail; added cookie storage confirmation
- Flow 2 (Token Refresh): New flow â€” session-based refresh token rotation
- Flow 3 (Logout): New flow â€” Redis refresh token deletion
- Flow 4 (Password Reset): Complete replacement â€” was incorrect OTP flow, now correct token URL flow: UUID token â†’ encrypt â†’ Redis 24h â†’ reset URL email â†’ decrypt â†’ validate â†’ reset â†’ confirmation email
- Flow 5 (Employee CRUD): Updated with confirmed business rules
- Flow 6 (Media Upload): Added Cloudinary folder/publicId/tags structure; max size; rollback behavior
- Flow 7 (Bulk Import): New 2-step flow (Validate then Execute) with all confirmed details
- Flow 8 (Permission gRPC): Updated with actual method signatures and silent-fail behavior
- Flow 9 (Mail Template gRPC): New flow with full send path
- Flows 10â€“11: Refined with confirmed details

**06-integrations.md** â€” Corrections and additions:
- REMOVED: OpenIddict section (disabled â€” not an integration)
- REMOVED: Hangfire section (not used)
- UPDATED: gRPC â€” added method signatures, error behavior (silent fail)
- ADDED: SMTP/MailKit section with full config keys, testing mode, placeholder format
- UPDATED: Cloudinary â€” added folder structure, publicId format, size limits, delete behavior
- UPDATED: Redis â€” full cache key inventory with TTLs
- UPDATED: Integration dependency map â€” removed OpenIddict/Hangfire, added SMTP, MongoDB

**07-security-permissions.md** â€” Updates and confirmations:
- UPDATED: Password reset description â€” token URL flow (not OTP)
- ADDED: JWT claims detail (sessionId custom claim)
- ADDED: IP rate limiting section
- CONFIRMED: Frontend JWT in cookies (not inferred)
- ADDED: Refresh token rotation detail
- ADDED: Role management properties table (IsStatic/IsDefault/IsPublic behaviors)
- CONFIRMED: `IsGrantedMultiplePermissionsAsync` uses OR semantics

**`.discovery/inferred-assumptions.md`** â€” Promoted 9 inferred items to CONFIRMED/DISPROVED:
- Login uses Employee.Code âœ“
- Password reset is token URL (not OTP) âœ“
- SendOTPEvent for 2FA (commented out) âœ“
- Frontend tokens in cookies âœ“
- Employee import is 2-step with Redis session âœ“
- Import constraints confirmed âœ“
- Mail template gRPC + placeholder format âœ“
- Cloudinary structure âœ“
- Frontend auth endpoint confirmed (not OpenIddict) âœ“

---

## 2026-05-23 â€” UPDATE Phase 1 Core Architecture Files

**Source**: AuthenticationJwtBearerHandler.cs, AdministrationServicePermissions.cs, host modules, all controller files, PermissionsAuthorizeAttribute.cs
**Updated**: `00-glossary.md`, `01-architecture.md`, `02-tech-stack.md`, `03-conventions.md`

### Changes

**00-glossary.md**:
- Fixed "Identity User" â€” removed incorrect OpenIddict reference
- Fixed "OpenIddict" â€” now correctly marked as planned but disabled
- Fixed "Hangfire" â€” removed (not used); replaced with "ABP Background Jobs"
- Added terms: OTP, PasswordResetToken, itzone, TokenAuthOption, PermissionsAuthorizeAttribute, ACCESS_TOKEN_KEY/REFRESH_TOKEN_KEY, ABP Background Jobs, MailKit, MongoDB, Redis, SWTCMN, swt_cmn, Custom JWT Bearer
- Added permission name conventions table with confirmed names from `AdministrationServicePermissions.cs`

**01-architecture.md**:
- Fixed Service Boundaries â€” removed OpenIddict and Hangfire
- Fixed Authentication section â€” replaced OpenIddict block with full custom JWT Bearer spec (algorithm, config keys, validation params, token storage, refresh flow)
- Added Confirmed API Route Table for Administration API (all controllers, all routes, auth level)
- Added Data Store Architecture section (SQL Server schemas, MongoDB collections, Redis cache keys)
- Added Mermaid architecture diagram

**02-tech-stack.md**:
- Administration API: fixed Auth row (OpenIddict â†’ Custom JWT Bearer); added MongoDB, Redis, MailKit, Background Jobs rows
- Customer API: fixed Background Jobs row (Hangfire â†’ ABP Background Jobs); added MongoDB stub note; clarified gRPC client details

**03-conventions.md**:
- Added JWT Token Issuance Pattern section with config keys
- Added Permission Authorization Pattern section (PermissionsAuthorize usage, return codes)
- Added Entity Multi-Tenancy Exception (MailTemplate)
- Added CORS Configuration Pattern

---

## 2026-05-23 â€” ADD Phase 0 Discovery Documents

**Source**: Full workspace scan â€” Phase 0 discovery pass
**Session**: Deep discovery reading host modules, controllers, entities, appsettings, proto files, frontend source

### Files Created

- `.discovery/service-inventory.md` â€” Complete service registry with ports, controllers, entities, gRPC services, solution structure per service
- `.discovery/runtime-topology.md` â€” Port map, communication topology diagram, data store connections, multi-tenancy flow, auth flow, gRPC protocol details
- `.discovery/technology-matrix.md` â€” Full tech stack per service with confirmed versions from package.json / pubspec.yaml / csproj
- `.discovery/integration-inventory.md` â€” All external integrations with config keys, protocols, usage details
- `.discovery/dependency-graph.md` â€” Service-level deps, .NET project layer graph, ABP module tree, frontend layer import graph, cross-service contracts, namespace defect note
- `.discovery/system-summary.md` â€” Executive summary, key architectural decisions, request flow, known gaps, production readiness

### New Confirmed Facts (Phase 0)

- Administration API gRPC server: port 50051 (TLS Http2); services: Permission + MailTemplate
- Customer API gRPC client: connects to Administration API :50051 for permission checks
- JWT authentication: custom (NOT OpenIddict) â€” issuer "ZS", audience "ZS", 1h access / 720h refresh
- MongoDB: Administration API stores MailTemplate collection (prefix `adm`); Customer API has MongoDB stub (not configured)
- Redis: enabled in both APIs, used by Administration API for password reset token cache
- Kestrel config: Administration API :8088 (HTTP), :50051 (gRPC); Customer API :44360 (HTTP), :50052 (gRPC)
- MailTemplate entity does NOT implement IMultiTenant (IMultiTenant commented out)
- Seeded tenant: `itzone` (ID: `019b8846-891c-7642-8381-1722468b8462`)
- OTP system: disabled in dev, expiry 300s, length 6 digits, default 123456
- Frontend tokens: stored in cookies (not localStorage); X-Tenant from localStorage
- Admin Web App pages: organization, permission, roles, users
- Web App routes: auth (signin, reset-password), landingpage (home), protected (employee, party, instructions)
- Mobile app routes: splash, login, home, selfie, otp; local SQLite DB (itzone.db)
- EF Core migrations: Administration API has 4 (2025-11-08 to 2025-11-15); Customer API has none
- Namespace defect: AdministrationServiceMongoDbContext and HealthChecksBuilderExtensions use CMN.CustomerManagement.* namespace (copy-paste error)
- ABP Background Jobs used (not Hangfire) â€” stored in SQL Server via EF Core
- OpenIddict: planned but commented out in both host modules

### Known Gaps Resolved

- âœ… JWT Bearer claim extraction: confirmed custom JWT with SecurityKey "0ac89987..." in appsettings
- âœ… MailTemplate entity fields: confirmed Name, Code, Description, Subject, Body
- âœ… Frontend JWT storage: confirmed cookies (ACCESS_TOKEN_KEY, REFRESH_TOKEN_KEY)
- âœ… gRPC channel registration in Customer API: confirmed via RemoteServices config

---

## 2026-05-23 â€” INIT Initial Knowledge Base Generation

**Source**: Automated discovery from source code (Claude Code AI agent)
**Session**: Full monorepo exploration â€” Phases 1-7

### Discovery

Read and analyzed:
- All module CLAUDE.md files (6 modules)
- `appsettings.Development.json` (web-gateway) â€” confirmed YARP routes + ports
- All domain entity files (Employee, OrganizationUnit, Positions, MediaFile, Party)
- All controller file listings (Administration + Customer services)
- All application service file listings (Administration service)
- `AppControllerBase.cs`, `CMNAbpExceptionFilter.cs`, `BaseResultDto.cs` (shared infrastructure)
- `package.json` (admin-web-app, web-app)
- `pubspec.yaml` (mobile-app)
- Frontend directory structures (pages, services, store)

### Files Created

**Scaffold**:
- `_meta/kb-schema.yaml`
- `_meta/anchors.md`
- `_meta/sync-config.yaml`
- `_templates/service-doc-template.md`
- `_templates/entity-template.md`
- `_templates/api-endpoint-template.md`
- `_sync/sync-rules.md`
- `.discovery/confirmed-facts.md`
- `.discovery/inferred-assumptions.md`
- `.discovery/discovery-log.md`

**Core Docs**:
- `00-glossary.md`
- `01-architecture.md`
- `02-tech-stack.md`
- `03-conventions.md`
- `04-business-domain.md`
- `05-flows.md`
- `06-integrations.md`
- `07-security-permissions.md`
- `08-deployment-cicd.md`
- `09-requirements/README.md`

**Service Docs**:
- `services/administration-api.md`
- `services/customer-api.md`
- `services/web-gateway.md`
- `services/administration-web-app.md`
- `services/web-app.md`
- `services/mobile-app.md`

**Diagrams**:
- `diagrams/architecture.mermaid`
- `diagrams/entity-relations.mermaid`
- `diagrams/data-flow.mermaid`
- `diagrams/layer-dependencies.mermaid`

**Playbooks**:
- `playbooks/onboarding.md`
- `playbooks/add-new-endpoint.md`
- `playbooks/add-new-entity.md`
- `playbooks/add-frontend-page.md`

**Scripts**:
- `scripts/validate-kb.ps1`
- `scripts/update-anchor.ps1`

**Meta**:
- `README.md`
- `AUTOMATION.md`
- `CHANGELOG.md`

### Known Gaps (Inferred Items)

The following items could not be confirmed from code and are marked `[INFERRED]` in the KB:

- OpenIddict as OAuth2/OIDC auth server (file exists but host module not read)
- JWT Bearer claim extraction details (AuthenticationJwtBearerHandler not read)
- Redis usage in Customer Service (listed in stack but not traced in code)
- Hangfire registration in Customer Service (listed in stack but host module not read)
- Employee bulk import file format (EmployeeImportHelper exists but not read)
- Mail template field definitions (MailTemplate entity not readable at discovery time)
- gRPC channel registration in Customer Service application module
- Health check endpoint URLs
- Frontend JWT storage mechanism (localStorage vs httpOnly cookie)
- Mobile app API base URL configuration

### Next Steps for KB Maintainers

1. Read individual controller implementations to populate exact route tables.
2. Read `CustomerManagementHttpApiHostModule.cs` to confirm Hangfire + gRPC registration.
3. Read `AuthenticationJwtBearerHandler.cs` to confirm JWT claim extraction.
4. Read `EmployeeAppService.cs` to confirm import method signature.
5. Read `MailTemplate.cs` to confirm entity fields.
6. Promote verified items from `.discovery/inferred-assumptions.md` to `.discovery/confirmed-facts.md`.
