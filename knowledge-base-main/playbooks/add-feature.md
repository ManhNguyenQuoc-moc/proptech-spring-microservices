# Playbook: Add a Full Feature (Backend + Frontend)

> End-to-end playbook for adding a new domain feature across the full stack.
> This orchestrates the component playbooks. Read it first, then execute each referenced playbook.

---

## Pre-Flight Checklist

Before writing any code:

- [ ] Read `swt-cmn-[service]/CLAUDE.md` for the target module
- [ ] Read `swt-cmn-[service]/skills/feature-module-skill.md`
- [ ] Confirm which service owns the feature (Administration API or Customer API)
- [ ] Name the feature: `{Feature}` (PascalCase, e.g. `Department`)
- [ ] Define the database schema (`ADM` or `CM`)
- [ ] List the required endpoints (CRUD subset)
- [ ] List the permission keys required (format: `AdministrationService.{Feature}.{Action}`)

---

## Phase 1 — Backend (Administration API or Customer API)

### Step 1.1 — Define domain consts

Location: `src/CMN.[Service].Domain.Shared/{Feature}/{Feature}Consts.cs`

```csharp
namespace CMN.AdministrationService
{
    public static class DepartmentConsts
    {
        public const int NameMaxLength = ValidationConsts.Medium;   // 250
        public const int CodeMaxLength = ValidationConsts.Small;    // 100
    }
}
```

Always reference `ValidationConsts` (Small=100, Medium=250, Large=500, Max=1000) instead of raw numbers.

---

### Step 1.2 — Create the domain entity

See **[add-entity.md](add-entity.md)** for the full entity playbook.

Key constraints:
- Extend `FullAuditedEntity<Guid>` + implement `IMultiTenant`
- Exception: do NOT implement `IMultiTenant` only if the entity is explicitly system-wide (like `MailTemplate`)
- Schema must match service: `AdministrationServiceConsts.DbSchema` = `"ADM"`, `CustomerManagementConsts.DbSchema` = `"CM"`

---

### Step 1.3 — Create migration

See **[migration.md](migration.md)** for the full migration playbook.

```bash
cd swt-cmn-administration-api
dotnet ef migrations add Add_{Feature} \
  --project src/CMN.AdministrationService.EntityFrameworkCore \
  --startup-project CMN.AdministrationService.HttpApi.Host
```

**Review the generated `.cs` migration file before proceeding.** Confirm:
- Table name matches: `adm_{Feature}s` (or `cm_{Feature}s`)
- All columns present with correct types and nullable flags
- No accidental drops of existing columns

---

### Step 1.4 — Add permission keys

Location: `src/CMN.AdministrationService.Application.Contracts/Permissions/AdministrationServicePermissions.cs`

```csharp
public static class Department
{
    public const string Default = GroupName + ".Department";
    public const string View   = Default + ".View";
    public const string Create = Default + ".Create";
    public const string Update = Default + ".Update";
    public const string Delete = Default + ".Delete";
}
```

Register in the permission definition provider in the same file's `Define()` method.

---

### Step 1.5 — Create DTOs + Validators

Location: `src/CMN.[Service].Application.Contracts/{Feature}/Dtos/`

```
Input/
  CreateDepartmentInputDto.cs     ← DTO + Validator in same file
  UpdateDepartmentInputDto.cs     ← DTO + Validator in same file
  GetListDepartmentInputDto.cs    ← query params, no validator needed
Output/
  DepartmentOutputDto.cs
```

Rules:
- Validator in same file as DTO — never separated
- Use `DepartmentConsts.*` for length limits — never raw ints
- Required string fields: `.NotEmpty().MaximumLength(...)` 
- Optional string fields: `.MaximumLength(...)`
- Email fields: `.EmailAddress()`

---

### Step 1.6 — Define the app service interface

Location: `src/CMN.[Service].Application.Contracts/{Feature}/IDepartmentAppService.cs`

```csharp
public interface IDepartmentAppService
{
    Task<DepartmentOutputDto>               GetAsync(Guid id);
    Task<PagedResultDto<DepartmentOutputDto>> GetListAsync(GetListDepartmentInputDto input);
    Task<DepartmentOutputDto>               CreateAsync(CreateDepartmentInputDto input);
    Task<DepartmentOutputDto>               UpdateAsync(Guid id, UpdateDepartmentInputDto input);
    Task                                    DeleteAsync(Guid id);
}
```

---

### Step 1.7 — Implement the app service

Location: `src/CMN.[Service].Application/{Feature}/DepartmentAppService.cs`

```csharp
public class DepartmentAppService : AdministrationServiceAppService, IDepartmentAppService
{
    private readonly IRepository<Department, Guid> _departmentRepository;

    public DepartmentAppService(IRepository<Department, Guid> departmentRepository)
    {
        _departmentRepository = departmentRepository;
    }

    public async Task<DepartmentOutputDto> GetAsync(Guid id)
    {
        var entity = await _departmentRepository.GetAsync(id);
        return MapToDto(entity);
    }

    public async Task<PagedResultDto<DepartmentOutputDto>> GetListAsync(GetListDepartmentInputDto input)
    {
        var query = (await _departmentRepository.GetQueryableAsync())
            .WhereIf(!input.Keyword.IsNullOrWhiteSpace(),
                e => e.Name.Contains(input.Keyword))
            .OrderBy(e => e.Name);

        var total = await AsyncExecuter.CountAsync(query);
        var items = await AsyncExecuter.ToListAsync(
            query.PageBy(input.SkipCount, input.MaxResultCount)
                 .Select(e => new DepartmentOutputDto { Id = e.Id, Name = e.Name, Code = e.Code })
        );
        return new PagedResultDto<DepartmentOutputDto>(total, items);
    }

    public async Task<DepartmentOutputDto> CreateAsync(CreateDepartmentInputDto input)
    {
        if (await _departmentRepository.AnyAsync(d => d.Code == input.Code))
            throw new UserFriendlyException(L["DuplicateDepartmentCode"]);

        var entity = new Department(GuidGenerator.Create())
        {
            Name = input.Name,
            Code = input.Code,
        };
        await _departmentRepository.InsertAsync(entity);
        return MapToDto(entity);
    }

    private static DepartmentOutputDto MapToDto(Department e) =>
        new() { Id = e.Id, Name = e.Name, Code = e.Code };
}
```

Rules:
- Inject `IRepository<T, Guid>` — never `DbContext`
- Inline `select new OutputDto { ... }` — never `ObjectMapper.Map`
- Throw `UserFriendlyException(L["LocalizationKey"])` for business errors
- Use `AsyncExecuter` for async LINQ (never `.ToListAsync()` directly)

---

### Step 1.8 — Add localization keys

Location: `src/CMN.[Service].Domain.Shared/Localization/en.json`
(and all locale files: `vi.json`, etc.)

```json
{
  "DepartmentNotFound": "Department not found.",
  "DuplicateDepartmentCode": "A department with this code already exists."
}
```

---

### Step 1.9 — Create the controller

See **[add-endpoint.md](add-endpoint.md)** for per-endpoint details.

```csharp
[Route($"{AdministrationServiceSettingNames.DefaultRoute}/departments")]
public class DepartmentController : AppControllerBase
{
    private readonly IDepartmentAppService _departmentAppService;

    public DepartmentController(IDepartmentAppService departmentAppService)
    {
        _departmentAppService = departmentAppService;
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetAsync(Guid id)
        => Success(await _departmentAppService.GetAsync(id));

    [HttpGet]
    public async Task<IActionResult> GetListAsync([FromQuery] GetListDepartmentInputDto input)
        => Success(await _departmentAppService.GetListAsync(input));

    [HttpPost]
    public async Task<IActionResult> CreateAsync([FromBody] CreateDepartmentInputDto input)
        => Success(await _departmentAppService.CreateAsync(input), HttpStatusCode.Created);

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateAsync(Guid id, [FromBody] UpdateDepartmentInputDto input)
        => Success(await _departmentAppService.UpdateAsync(id, input));

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteAsync(Guid id)
    {
        await _departmentAppService.DeleteAsync(id);
        return Success();
    }
}
```

Rules:
- Every action is a one-line expression body delegating to the app service
- Always `Success(...)` — never `Ok(...)`, `Json(...)`, or raw returns
- `AppControllerBase` carries `[Authorize]` — do not add `[AllowAnonymous]` unless explicitly required
- Add `[PermissionsAuthorize(AdministrationServicePermissions.Department.View)]` per action (can be commented out initially)

---

### Step 1.10 — Write tests

Location: `test/CMN.[Service].Application.Tests/{Feature}/DepartmentAppServiceTests.cs`

```csharp
public class DepartmentAppServiceTests : AdministrationServiceApplicationTestBase
{
    private readonly IDepartmentAppService _departmentAppService;

    public DepartmentAppServiceTests()
    {
        _departmentAppService = GetRequiredService<IDepartmentAppService>();
    }

    [Fact]
    public async Task CreateAsync_Should_Create_Department()
    {
        var result = await _departmentAppService.CreateAsync(
            new CreateDepartmentInputDto { Name = "Engineering", Code = "ENG" });

        result.ShouldNotBeNull();
        result.Code.ShouldBe("ENG");
    }

    [Fact]
    public async Task CreateAsync_Should_Throw_On_Duplicate_Code()
    {
        await _departmentAppService.CreateAsync(
            new CreateDepartmentInputDto { Name = "Engineering", Code = "ENG" });

        await Should.ThrowAsync<UserFriendlyException>(
            () => _departmentAppService.CreateAsync(
                new CreateDepartmentInputDto { Name = "Eng 2", Code = "ENG" }));
    }
}
```

---

## Phase 2 — Frontend (Admin Web App or Web App)

See **[add-frontend-page.md](add-frontend-page.md)** for the detailed frontend playbook.

Summary steps:
1. Create service: `src/services/administration-service/department/department.service.ts`
2. Create DTO models: `input.model.ts` + `output.model.ts`
3. Create Redux slice: `src/store/administration-service/department/index.ts`
4. Create page component: `src/pages/(protected)/departments/`
5. Register route + sidebar entry

**Import direction must be enforced**: `pages → store → services → @core/http`

---

## Phase 3 — Knowledge Base Update

- [ ] Add entity to `04-business-domain.md` (fields table, relationships)
- [ ] Add endpoints to `services/administration-api.md` route table (anchor: `adm-routes`)
- [ ] Add permission keys to `07-security-permissions.md`
- [ ] Update `diagrams/entity-relations.mermaid` with new entity
- [ ] Add CHANGELOG entry (`ADD` type)

---

## Verification Checklist

- [ ] `dotnet build` — zero errors
- [ ] `dotnet test` — all tests pass
- [ ] Swagger UI shows new endpoint at `/cmn/swagger`
- [ ] `POST` returns 201, `GET` returns 200, `DELETE` returns 200 with empty `data`
- [ ] 401 returned without Authorization header
- [ ] Frontend: list loads, pagination works, create modal submits
