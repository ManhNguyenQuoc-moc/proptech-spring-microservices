# Fix Bug — CMN

Systematically locate and fix a bug in the CMN system with minimal token usage.

## Arguments

$ARGUMENTS — describe the bug. Examples:
- "login API trả về 500 khi employee.Code không có trong DB"
- "AuthController.LoginAsync throws NullReferenceException khi tenant header rỗng"
- "import employee bỏ qua row đúng nhưng count sai — REQ-EMP-003"
- "frontend không refresh token khi nhận 401 từ /api/employee"

## Execution Protocol

### Step 0 — Parse Bug Report

Extract:
- **Symptom**: what the user observes (error message, wrong behavior, wrong output)
- **Entry point**: endpoint URL, controller method, or UI action (if known)
- **Service**: which service (admin-api / customer-api / web-app / admin-web-app / mobile)
- **REQ ID**: if user mentions one (REQ-XXX-NNN)

### Step 1 — Find the Code (code-review-graph first — no file reads yet)

Use graph tools to locate the bug site efficiently:

```
semantic_search_nodes: "[ControllerName] OR [MethodName] OR [symptom keyword]"
```

Then narrow with:
```
query_graph: callers_of "[entry point method]"   # trace from controller down
query_graph: callees_of "[suspected method]"     # trace dependencies
```

Use `get_review_context` on the 1-3 most relevant nodes to fetch source snippets. Do NOT use `Read` on whole files at this stage.

### Step 2 — Load Targeted KB Context

Load KB context ONLY for the affected domain. Do NOT read the full KB.

**If bug is in authentication**:
→ Read `swt-cmn-knowledge-base/09-requirements/features/authentication.md` (relevant REQ section only)
→ Read `swt-cmn-knowledge-base/06-authentication.md` (if needed for JWT/Redis context)

**If bug is in employee management**:
→ Read `swt-cmn-knowledge-base/09-requirements/features/employee-management.md` (relevant REQ only)

**If bug is in media/notifications**:
→ Read `swt-cmn-knowledge-base/09-requirements/features/media-notification.md` (relevant REQ only)

**For all bugs** — read only if the fix touches business rules:
→ Read `swt-cmn-knowledge-base/09-requirements/business-rules.md` — grep for the specific BR-XXX that applies

**For all bugs** — check forbidden patterns:
→ Read `swt-cmn-knowledge-base/03-conventions.md` — `## Forbidden Patterns` section only (skip rest)

### Step 3 — Diagnose

1. Read the specific method(s) found in Step 1 (targeted line range with `Read offset/limit`)
2. Identify the root cause — state it explicitly before touching code:
   - What is the incorrect behavior?
   - Which line/condition is wrong?
   - What is the correct behavior per the business rule or REQ?
3. Check if this is a known technical debt item — scan `_meta/manifest.yml` `technical_debt` section

### Step 4 — Fix

Apply the minimal fix that corrects the root cause. Do NOT refactor surrounding code.

CMN-specific patterns to verify in the fix:
- Error still uses `throw new UserFriendlyException(L["Key"])` (not raw exception)
- No `ObjectMapper.Map<>()` introduced
- No `DbContext` injected (use `IRepository<T, Guid>`)
- If fix changes business rule behavior: update `09-requirements/business-rules.md` source reference

### Step 5 — Verify

Run the app service method in isolation if possible. If tests exist, run them:
```powershell
dotnet test --filter "[TestClassName]"
```

If no tests (TD-008): manually trace the fixed flow and document the test case that would catch this.

### Step 6 — KB Update (if needed)

Only update KB if:
- The bug was caused by a documentation error (wrong behavior documented in KB)
- The fix resolves a known technical debt item (remove from manifest.yml technical_debt)
- The root cause reveals a missing business rule

If KB updated:
```powershell
.\swt-cmn-knowledge-base\scripts\update-changelog.ps1 `
  -Type "FIX" `
  -Description "[brief bug description] in [ControllerClass.MethodAsync]" `
  -Source "[file where fix was applied]"
```

## Known CMN Bug Patterns (check these first)

| Symptom | Likely Cause | Check |
|---|---|---|
| 401 on valid token | `sessionId` claim mismatch in Redis key | Redis key format: `{userId}:{sessionId}` |
| 401 loops on refresh | Old refresh token not deleted before new one issued | `RefreshLoginAsync` — Redis DEL before SET |
| 500 on tenant-isolated query | Missing `ICurrentTenant` scope | Check AbpMultiTenancy setup |
| Import session expired | >30 min between validate and execute | Redis TTL: `import_employee_{sessionId}` |
| Email not received in test env | IsTesting=true redirecting | `Settings:Abp.Mailing.IsTesting` |
| Password reset link invalid | URL-encoded token double-encoded | `IStringEncryptionService.Decrypt` + `Uri.UnescapeDataString` |
| gRPC call returning IsSuccess=false silently | Exception swallowed in catch block | BR-GRPC-001: check catch block format |
