# Add Unit Test — CMN

Write targeted xUnit + Shouldly unit tests for CMN, driven by acceptance criteria.

## Arguments

$ARGUMENTS — specify what to test. Examples:
- "REQ-AUTH-001" — test all ACs for this requirement
- "AuthAppService.LoginAsync" — test a specific method
- "BR-EMP-001 — email uniqueness validation" — test a specific business rule
- "import session TTL — BR-IMPORT-003" — test a specific constraint
- "Employee bulk import 2-step flow — REQ-EMP-003 AC-EMP-003-01 through AC-EMP-003-04"

## Execution Protocol

### Step 0 — Parse Test Target

Extract:
- **REQ ID** (e.g., REQ-AUTH-001): tests should cover all ACs for this REQ
- **BR ID** (e.g., BR-EMP-001): test the specific rule's violation and happy path
- **Method** (e.g., AuthAppService.LoginAsync): test the method directly
- **AC IDs** (e.g., AC-AUTH-001-01): test specific acceptance criteria

### Step 1 — Load Acceptance Criteria (the test spec)

If REQ ID is known:
- Determine the domain file:
  - AUTH, EMP, MEDIA, NOTIF → `swt-cmn-knowledge-base/09-requirements/features/{domain-file}.md`
  - AUTH → `features/authentication.md`, EMP → `features/employee-management.md`, MEDIA/NOTIF → `features/media-notification.md`
- Read ONLY the section for the specific REQ (use `offset` + `limit` to target the REQ block)
- Extract: description, acceptance criteria (Given/When/Then statements), linked BRs

If only a method name is given (no REQ):
- Use `semantic_search_nodes` to find the method
- Read the method + its callee chain to understand expected behavior
- Derive test cases from the code logic

If BR ID is known:
- Read `swt-cmn-knowledge-base/09-requirements/business-rules.md` — only the BR section
- Test: violation case (should throw) + happy path (should succeed)

### Step 2 — Locate the Implementation

Use code-review-graph (not Grep/Glob):
```
semantic_search_nodes: "[MethodName] OR [AppServiceClass]"
query_graph: callees_of "[found-node]"  # understand dependencies
query_graph: tests_for "[found-node]"   # check if tests already exist
```

If tests already exist: read them first to understand the existing pattern, then extend rather than duplicate.

Read the implementation with targeted range:
```
Read: [file path] offset:[method start line] limit:[method length + ~20 lines]
```

### Step 3 — Find or Create Test Project

Check if Application.Tests project exists:
```
Glob: "swt-cmn-administration-api/src/*.Application.Tests/**/*.cs"
```

If test project exists: find the right test class for the feature.
If no test project (TD-008 — current state): create the project structure first:
1. Note: this is tracked as technical debt TD-008
2. Create `swt-cmn-administration-api/test/SWT.CMN.AdministrationService.Application.Tests/`
3. Add `.csproj` referencing: `xunit`, `xunit.runner.visualstudio`, `Shouldly`, `Microsoft.NET.Test.Sdk`, `NSubstitute` (or `Moq`)
4. Add base test class extending `AdministrationServiceTestBase`

### Step 4 — Write Tests

**One test method per AC** (Given/When/Then maps directly to Arrange/Act/Assert).

Template:
```csharp
[Fact]
public async Task [MethodName]_[Condition]_[ExpectedBehavior]()
{
    // Arrange — Given
    var [input] = new [InputDto]
    {
        // ... from AC "Given" clause
    };

    // Act — When
    var result = await _[appService].[MethodAsync]([input]);

    // Assert — Then (Shouldly)
    result.ShouldNotBeNull();
    result.[Field].ShouldBe([expectedValue]);
}

[Fact]
public async Task [MethodName]_[ViolationCondition]_ThrowsUserFriendlyException()
{
    // Arrange
    // ... setup violation state

    // Act & Assert
    await Should.ThrowAsync<UserFriendlyException>(
        async () => await _[appService].[MethodAsync]([input])
    );
}
```

**CMN test conventions**:
- Use `Shouldly` for assertions (`result.ShouldBe()`, `result.ShouldNotBeNull()`)
- Test the `UserFriendlyException` for each BR violation
- Do NOT mock `IRepository` directly — use in-memory SQLite or test DB (ABP pattern)
- For Redis-dependent tests: mock `IDistributedCache` / `IRedisClient`
- For email tests: mock `IMailTemplateAppService`
- Test naming: `[Method]_[State]_[ExpectedBehavior]` (PascalCase)

**AC coverage mapping** — for each AC write at minimum:
- 1 test for the happy path (AC conditions met → expected output)
- 1 test for each violation / error path in the AC

### Step 5 — Map ACs to Tests

Once tests are written, update the traceability matrix:

Read `swt-cmn-knowledge-base/09-requirements/traceability-matrix.md` — find the row for the REQ being tested.

Update the `Test File` column from `[Missing]` to the actual test file path.

Update `09-requirements/features/{domain}.md` — mark verified ACs with `[x]`:
```markdown
- [x] **AC-AUTH-001-01**: Given... (VERIFIED — [TestMethodName])
```

### Step 6 — Run Tests

```powershell
dotnet test swt-cmn-administration-api --filter "[TestClassName]"
```

Fix any failing tests. Do NOT mark ACs as verified until tests pass.

### Step 7 — Changelog

```powershell
.\swt-cmn-knowledge-base\scripts\update-changelog.ps1 `
  -Type "ADD" `
  -Description "Unit tests for [REQ-ID] — [N] ACs covered" `
  -Source "[TestClass].cs"
```

## Priority Test Order (based on highest-risk areas)

Given TD-008 (zero test coverage), prioritize in this order:

1. `BR-AUTH-005` / `BR-AUTH-006` — password reset single-use (security-critical)
2. `REQ-AUTH-001` / `REQ-AUTH-003` — login + token refresh (core auth flow)
3. `BR-EMP-001` — email/phone uniqueness (data integrity)
4. `BR-IMPORT-001` / `BR-IMPORT-002` — file size + row limits (input validation)
5. `REQ-MEDIA-001` — upload rollback on partial failure
6. `BR-NOTIF-001` — placeholder substitution (##Group.Field## syntax)
