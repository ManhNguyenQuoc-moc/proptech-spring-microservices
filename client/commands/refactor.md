# Refactor — CMN

Safely refactor CMN code using impact analysis before touching anything.

## Arguments

$ARGUMENTS — describe what to refactor. Examples:
- "tách import logic từ EmployeeAppService ra EmployeeImportAppService"
- "rename MediaFileAppService.UploadFileAsync → UploadAsync"
- "extract interface IAuthTokenService từ AuthAppService"
- "consolidate duplicate uniqueness check trong EmployeeAppService.CreateAsync và ValidateImportAsync"

## Execution Protocol

### Step 0 — Parse Refactor Intent

Extract:
- **Target**: class name, method name, or code region
- **Type**: rename | extract-class | extract-method | extract-interface | inline | consolidate | restructure
- **Service**: which CMN service (administration-api / customer-api / web-app / admin-web-app / mobile)

### Step 1 — Build Impact Map BEFORE Touching Code

**Do NOT write any code yet.** Use graph tools to understand the full blast radius.

```
semantic_search_nodes: "[TargetClass] OR [TargetMethod]"
```

Then:
```
get_impact_radius: "[node-id from above]"
```

Read the impact radius output carefully:
- How many callers?
- Are any callers in gRPC handlers? (gRPC changes require proto updates)
- Are any callers in event handlers?
- Is the target referenced in `_meta/manifest.yml`?

If impact radius > 10 files: confirm with user before proceeding.

### Step 2 — Check KB References

Check if the refactor target appears in KB documents. Do targeted text search only:

```
grep in swt-cmn-knowledge-base: "[TargetClassName]" or "[TargetMethodName]"
```

If found in KB:
- `_meta/manifest.yml`: note which features[], app_service, grpc_handler fields reference it
- `09-requirements/traceability-matrix.md`: note which rows reference the class/method
- `diagrams/*.mermaid`: note which diagrams show the class/method

These must be updated AFTER the code refactor.

### Step 3 — Read Architecture Constraints

Read `swt-cmn-knowledge-base/03-conventions.md` — `## Architecture Constraints` section only.

Critical constraints for refactoring in CMN:
- Custom JWT (not OpenIddict) — any auth refactor risks invalidating all tokens
- Single DB, two schemas — never move ADM entities into CM project or vice versa
- gRPC silent-fail contract — any gRPC handler refactor must preserve `try/catch` pattern
- Layer import direction — backend: Domain → Application → HttpApi; frontend: pages → store → services → @core/http

Identify if the refactor crosses any of these constraints. If yes: describe the constraint to the user and confirm they understand the risk.

### Step 4 — Confirm Plan with User

Before writing code, state:
1. **What will change**: list of files that will be modified
2. **What will NOT change**: public API contracts, route paths, DB schemas
3. **KB updates required**: which manifest.yml fields and which docs need updating
4. **Risk**: if any Architecture Constraint is involved

Then ask: "Shall I proceed?"

### Step 5 — Execute Refactor

Execute in this order to minimize broken states:

1. **Rename/move first** (if applicable) — use IDE rename to catch all references
2. **Update implementation** — preserve behavior, only change structure
3. **Update interfaces** (if applicable) — IAppService, IRepository signatures
4. **Update DI registration** (if applicable) — Module.cs dependency registration
5. **Update tests** (if exist) — update test project references

**CMN-specific rules during refactor**:
- If extracting a new class: it must implement `ITransientDependency` (ABP DI)
- If extracting a new AppService: must extend `AdministrationServiceAppService` (or equivalent base)
- If adding a new interface to Application.Contracts: must add FluentValidation validator in same file
- Never change the `Success(data)` response shape in controllers
- Never add `DbContext` to extracted classes — use `IRepository<T, Guid>`

### Step 6 — Build Verification

```powershell
cd swt-cmn-administration-api   # (or relevant service)
dotnet build
```

If build fails: fix compilation errors before continuing. Do NOT proceed with KB updates if build fails.

```powershell
dotnet test   # if tests exist
```

### Step 7 — Update KB

Update only what changed:

**If class/method name changed**:
- `_meta/manifest.yml` → update `app_service`, `grpc_handler`, `controller` fields
- `09-requirements/traceability-matrix.md` → update App Service Method and Controller columns

**If new class extracted**:
- Add to `_meta/manifest.yml` → features[] if it's a new app service
- Consider if it needs a bounded context entry

**Always**:
```powershell
.\swt-cmn-knowledge-base\scripts\validate-manifest.ps1
.\swt-cmn-knowledge-base\scripts\detect-drift.ps1
.\swt-cmn-knowledge-base\scripts\update-changelog.ps1 `
  -Type "UPDATE" `
  -Description "[refactor description]" `
  -Source "[target class/file]"
```

## Refactor Safety Rules

- **Never** refactor and add functionality in the same PR
- **Never** change a gRPC proto message structure without confirming both server and client are updated
- **Never** rename an entity property that maps to a DB column without a migration
- If refactoring `AuthAppService`: extra caution — any mistake logs out all users
- If refactoring `MailTemplateAppService`: extra caution — email sending is event-driven, test end-to-end
