# Skill: API Service

> Use when: writing a controller, app service interface, or app service implementation.
> Reference implementations: `EmployeeController`, `RoleController`, `EmployeeAppService`, `RoleAppService`.

---

## Controller

**Path**: `src/CMN.AdministrationService.HttpApi/Controllers/{Feature}/{Feature}Controller.cs`
**Namespace**: `CMN.AdministrationService.Controllers.{Feature}`

```csharp
using CMN.AdministrationService.{Feature};
using CMN.AdministrationService.{Feature}.Dtos.Input;
using CMN.Shared.Hosting.Microservices.HttpApi;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using Volo.Abp;

namespace CMN.AdministrationService.Controllers.{Feature}
{
    [Route($"{AdministrationServiceSettingNames.DefaultRoute}/{resource-name}")]
    public class {Feature}Controller(
        I{Feature}AppService {feature}AppService
        ) : AppControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> GetListAsync([FromQuery] GetList{Feature}InputDto input)
            => Success(await {feature}AppService.GetListAsync(input));

        [HttpGet("{id}")]
        public async Task<IActionResult> GetAsync(Guid id)
            => Success(await {feature}AppService.GetAsync(id));

        [HttpPost]
        public async Task<IActionResult> CreateAsync([FromBody] Create{Feature}InputDto input)
            => Success(await {feature}AppService.CreateAsync(input));

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateAsync(Guid id, [FromBody] Update{Feature}InputDto input)
            => Success(await {feature}AppService.UpdateAsync(id, input));

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAsync(Guid id)
            => Success(await {feature}AppService.DeleteAsync(id));
    }
}
```

**Binding rules**:
- `[FromQuery]` — GET list params.
- `[FromBody]` — POST/PUT with JSON only (no file).
- `[FromForm]` — POST/PUT that include `IFormFile`.
- `[AllowAnonymous]` — only on methods that genuinely bypass auth; controller-level `[Authorize]` is inherited from `AppControllerBase`.
- Every action is a single-line expression body (`=> Success(...)`). No logic allowed.

---

## App Service Interface

**Path**: `src/CMN.AdministrationService.Application.Contracts/{Feature}/I{Feature}AppService.cs`
**Namespace**: `CMN.AdministrationService.{Feature}`

```csharp
using CMN.AdministrationService.{Feature}.Dtos.Input;
using CMN.AdministrationService.{Feature}.Dtos.Output;
using System;
using System.Threading.Tasks;

namespace CMN.AdministrationService.{Feature}
{
    public interface I{Feature}AppService
    {
        Task<Paged{Feature}OutputDto> GetListAsync(GetList{Feature}InputDto input);
        Task<{Feature}OutputDto> GetAsync(Guid id);
        Task<Guid> CreateAsync(Create{Feature}InputDto input);
        Task<bool> UpdateAsync(Guid id, Update{Feature}InputDto input);
        Task<bool> DeleteAsync(Guid id);
    }
}
```

---

## App Service Implementation

**Path**: `src/CMN.AdministrationService.Application/{Feature}/{Feature}AppService.cs`
**Namespace**: `CMN.AdministrationService`

```csharp
using CMN.AdministrationService.{Feature};
using CMN.AdministrationService.{Feature}.Dtos.Input;
using CMN.AdministrationService.{Feature}.Dtos.Output;
using CMN.AdministrationService.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using Volo.Abp;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Uow;

namespace CMN.AdministrationService
{
    public class {Feature}AppService(
        IRepository<{Entity}, Guid> {entity}Repository,
        IUnitOfWorkManager unitOfWorkManager
        ) : AdministrationServiceAppService, I{Feature}AppService
    {
        public async Task<Paged{Feature}OutputDto> GetListAsync(GetList{Feature}InputDto input)
        {
            var keyword = input.Keyword?.Trim();
            var queryable = await {entity}Repository.GetQueryableAsync();

            var query = from item in queryable
                        where string.IsNullOrEmpty(keyword) || item.Name.Contains(keyword)
                        select new {Feature}OutputDto
                        {
                            Id   = item.Id,
                            Name = item.Name,
                        };

            var totalCount = await query.CountAsync();
            var items = await query
                .Skip((input.Page - 1) * input.Fetch)
                .Take(input.Fetch)
                .ToListAsync();

            return new Paged{Feature}OutputDto(totalCount, items);
        }

        public async Task<{Feature}OutputDto> GetAsync(Guid id)
        {
            var queryable = await {entity}Repository.GetQueryableAsync();
            return await queryable
                .Where(x => x.Id == id)
                .Select(x => new {Feature}OutputDto { Id = x.Id, Name = x.Name })
                .FirstOrDefaultAsync()
                ?? throw new UserFriendlyException(L["{Feature}NotFound"]);
        }

        public async Task<Guid> CreateAsync(Create{Feature}InputDto input)
        {
            using (var uow = unitOfWorkManager.Begin())
            {
                // 1. Duplicate / business constraint checks
                bool isDuplicate = await {entity}Repository.AnyAsync(x => x.Name == input.Name);
                if (isDuplicate) throw new UserFriendlyException(L["Duplicate{Feature}Name"]);

                // 2. Build entity — no factory method required unless domain logic warrants it
                var entity = new {Entity}
                {
                    Name = input.Name,
                };

                await {entity}Repository.InsertAsync(entity);
                await uow.CompleteAsync();
                return entity.Id;
            }
        }

        public async Task<bool> UpdateAsync(Guid id, Update{Feature}InputDto input)
        {
            using (var uow = unitOfWorkManager.Begin())
            {
                var queryable = await {entity}Repository.GetQueryableAsync();
                var entity = await queryable.Where(x => x.Id == id).FirstOrDefaultAsync()
                    ?? throw new UserFriendlyException(L["{Feature}NotFound"]);

                // Patch only fields that were provided (nullable = optional)
                if (input.Name != null) entity.Name = input.Name;

                await {entity}Repository.UpdateAsync(entity);
                await uow.CompleteAsync();
                return true;
            }
        }

        public async Task<bool> DeleteAsync(Guid id)
        {
            var entity = await {entity}Repository.GetAsync(id);
            await {entity}Repository.DeleteAsync(entity);
            return true;
        }
    }
}
```

---

## Implementation Rules

- **Primary constructor injection** for new services. Classic field-assigned constructor only when 5+ dependencies or `IOptions<T>` is involved (see `AuthAppService`).
- **UoW scope required** for any write that touches multiple repositories or managers: `using (var uow = unitOfWorkManager.Begin()) { ... await uow.CompleteAsync(); }`.
- **Check constraints before insert** — duplicate checks, existence checks, business rules — all before the first repository write.
- **Null-check optional update fields**: `if (input.Field != null) entity.Field = input.Field;`
- **`IdentityUserManager`** — inject when you need ASP.NET Identity operations (`SetEmailAsync`, `UpdateAsync`, `CheckPasswordAsync`). Its operations must also be inside a UoW.
- `(await manager.UpdateAsync(entity)).CheckErrors()` — always call `.CheckErrors()` on `IdentityResult`.
- **Return `Guid`** from `CreateAsync`. **Return `bool`** from `UpdateAsync`/`DeleteAsync`.
- App service namespace is always `CMN.AdministrationService` (not the feature sub-namespace).

---

## Pagination Math

```csharp
var totalCount = await query.CountAsync();
var items = await query
    .Skip((input.Page - 1) * input.Fetch)
    .Take(input.Fetch)
    .ToListAsync();
return new Paged{Feature}OutputDto(totalCount, items);
```

Pagination base: `PaginationWithSearchRequestDto` provides `Page` (default 1), `Fetch` (default 10, max 200), `Keyword`.
