# Discovery Log

## Session: 2026-05-23

### Phase 1 — Monorepo Structure

- Listed top-level directories: 7 service modules + config files
- Identified existing `swt-cmn-knowledge-base/` directory (empty)
- Confirmed `.code-review-graph/` per-module knowledge graphs exist
- Noted `AGENTS.md` and `CLAUDE.md` present at monorepo root and per-module

### Phase 2 — Module CLAUDE.md Files Read

- `swt-cmn-administration-api/CLAUDE.md` — full engineering rules, invariants, skill system
- `swt-cmn-customer-api/CLAUDE.md` — full engineering rules, namespace conventions, error patterns
- `swt-cmn-web-gateway/CLAUDE.md` — only code-review-graph MCP instructions, no module-specific rules
- `swt-cmn-administration-web-app/CLAUDE.md` — architecture invariants, naming rules, layer rules, component/state/form rules
- `swt-cmn-web-app/CLAUDE.md` — architecture invariants, naming invariants, generation rules
- `swt-cmn-mobile-app/CLAUDE.md` — only code-review-graph MCP instructions, no module-specific rules

### Phase 2 — Source Files Read

**Configuration**:
- `appsettings.Development.json` (web-gateway) — confirmed YARP routes and backend ports
- `package.json` (admin-web-app, web-app) — confirmed exact dependency versions
- `pubspec.yaml` (mobile-app) — confirmed Flutter dependencies

**Entities**:
- `Employee.cs` — 14 fields, FK to OrganizationUnit and Positions
- `OrganizationUnit.cs` — 5 fields, hierarchical (CodePath, NamePath)
- `Positions.cs` — 2 fields, FK to OrganizationUnit
- `MediaFile.cs` — Cloudinary integration (SecureUrl, PublicId, AssetId)
- `Party.cs` — stub entity, only TenantId

**Shared Infrastructure**:
- `AppControllerBase.cs` — base controller, `[Authorize]`, `Success<T>()` wrapper
- `CMNAbpExceptionFilter.cs` — exception → HTTP mapping, replaces ABP default
- `BaseResultDto.cs` / `ApiResult<TData>` — universal response envelope

**Application Layer**:
- Listed all app service files in Administration Service
- Listed all controller files in Administration and Customer services
- Listed gRPC services in Administration

**Frontend**:
- Listed pages, services, store structure for admin-web-app
- Listed src directory structure for web-app (Next.js)
- Listed features in mobile-app

### Tools Used

- PowerShell `Get-ChildItem` for directory listings
- `Read` tool for file contents
- `Glob` for CS file discovery
- code-review-graph MCP tools: attempted but unavailable (connection error)

### Gaps / Not Yet Read

- Individual controller implementations (EmployeeController, PermissionController, etc.)
- Application service implementations
- EF Core DbContext (table mappings, indexes)
- Frontend store slices and hooks
- Mobile app route definitions (go_router config)
- `.env` files (git-ignored, local-only)
- `appsettings.secrets.json` (git-ignored)
