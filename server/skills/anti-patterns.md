# Skill: Anti-patterns

> Reference when: reviewing code, generating code, or checking if an approach is allowed.
> These are forbidden patterns derived from actual codebase conventions.

---

## Controller Anti-patterns

| Forbidden | Required instead |
|---|---|
| `return Ok(data)` | `return Success(data)` |
| `return Json(data)` | `return Success(data)` |
| `return data` (raw) | `return Success(data)` |
| Business logic in controller body | Move to app service |
| `[Route("api/v1/...")]` custom route | `[Route($"{AdministrationServiceSettingNames.DefaultRoute}/resource")]` |
| Controller not extending `AppControllerBase` | Must extend `AppControllerBase` |
| `[FromBody]` on a DTO with `IFormFile` | Use `[FromForm]` |
| `[FromForm]` on a JSON-only DTO | Use `[FromBody]` |

---

## App Service Anti-patterns

| Forbidden | Required instead |
|---|---|
| `ObjectMapper.Map<OutputDto>(entity)` | Inline LINQ `select new OutputDto { ... }` |
| `_dbContext.Employees.ToList()` | `await employeeRepository.GetQueryableAsync()` |
| `throw new Exception("msg")` | `throw new UserFriendlyException(L["LocalizationKey"])` |
| `throw new InvalidOperationException("msg")` | `throw new UserFriendlyException(L["LocalizationKey"])` |
| App service not extending `AdministrationServiceAppService` | Must extend `AdministrationServiceAppService` |
| Write operations without UoW on multi-step flows | Wrap in `unitOfWorkManager.Begin()` + `uow.CompleteAsync()` |
| Insert before constraint checks | Check duplicates/existence before first write |
| `(await manager.UpdateAsync(x))` without `.CheckErrors()` | Always call `.CheckErrors()` on `IdentityResult` |
| Catching exceptions to silently swallow them | Let propagate — `CMNAbpExceptionFilter` handles them |

---

## DTO Anti-patterns

| Forbidden | Required instead |
|---|---|
| Validator in a separate file from its DTO | Colocate in same `.cs` file |
| Raw string in validator message: `.WithMessage("Name is required")` | `CommonExtensions.GetValidateMessage(localizer["NotEmpty"], localizer["Feature:Field"])` |
| Hardcoded length: `.MaximumLength(100)` | `ValidationConsts.SmallInputMaxLength` or `{Feature}Consts.FieldMaxLength` |
| Optional field rule without `.When(...)` | Guard every optional rule with `.When(x => x.Field != null)` |
| Update DTO with non-nullable fields | All update fields must be nullable (patch semantics) |
| Inheriting from ABP's `PagedResultDto<T>` | Use custom primary-constructor paged result class |

---

## Entity Anti-patterns

| Forbidden | Required instead |
|---|---|
| Entity not extending `FullAuditedEntity<Guid>` | Must extend `FullAuditedEntity<Guid>` |
| Entity not implementing `IMultiTenant` | Must implement `IMultiTenant` |
| `public Guid? TenantId { get; set; }` | `public Guid? TenantId { get; private set; }` |
| FK navigation without `[ForeignKey(nameof(...))]` | Add `[ForeignKey]` attribute |
| Storing Cloudinary URL directly on entity | Store `MediaFile.Id` (Guid); join to get URL |
| Missing `DbSet<>` in `AdministrationServiceDbContext` | Register every new entity |

---

## Architecture Anti-patterns

| Forbidden | Reason |
|---|---|
| Controller calling another controller | Cross-controller calls violate layer boundaries |
| App service calling EF DbContext directly | Use `IRepository<TEntity, Guid>` |
| Domain entity referencing Application layer | Domain must not reference Application |
| Introducing a new response wrapper (not `ApiResult`) | `ApiResult` is the system-wide contract |
| Adding new base class for controllers | `AppControllerBase` is the only base |
| Registering services with non-ABP DI patterns | Use ABP module `ConfigureServices` only |
| Placing tests in src projects | Tests belong in `test/` projects only |

---

## Localization Anti-patterns

| Forbidden | Required instead |
|---|---|
| `throw new UserFriendlyException("User not found")` | `throw new UserFriendlyException(L["UserNotFound"])` |
| Hard-coded Vietnamese text in C# code | Define key in localization JSON, use `L["Key"]` |
| Validator message: `"Dữ liệu không hợp lệ"` | `CommonExtensions.GetValidateMessage(localizer["DataInvalid"])` |

---

## Query Anti-patterns

| Forbidden | Required instead |
|---|---|
| `.ToList()` before filtering | Filter in LINQ before materialization |
| `.AsEnumerable()` before filtering | Same — keep query in EF |
| `Select(x => x)` then map in memory | Project directly to OutputDto in LINQ |
| `ObjectMapper.Map<List<OutputDto>>(entities)` | Inline projection |
| INNER JOIN when FK is nullable | Use LEFT JOIN (`into ... from ... .DefaultIfEmpty()`) |
