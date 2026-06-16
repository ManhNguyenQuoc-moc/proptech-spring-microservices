# Playbook: Add a New HTTP Endpoint

> For adding a single endpoint to an existing feature. If the feature itself is new, use [add-feature.md](add-feature.md) instead.

---

## Step 1 — Define the Input DTO and Validator

Location: `src/CMN.[Service].Application.Contracts/{Feature}/Dtos/Input/{Action}{Feature}InputDto.cs`

```csharp
namespace CMN.AdministrationService.Widget.Dtos.Input
{
    public class UpdateWidgetInputDto
    {
        public string Name { get; set; }
        public string? Description { get; set; }
    }

    public class UpdateWidgetInputDtoValidator : AbstractValidator<UpdateWidgetInputDto>
    {
        public UpdateWidgetInputDtoValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty()
                .MaximumLength(ValidationConsts.Medium);    // 250 — never a raw int

            RuleFor(x => x.Description)
                .MaximumLength(ValidationConsts.Large);     // 500
        }
    }
}
```

**Rules**:
- Validator is in the **same file** as the DTO — never separated
- Use `ValidationConsts` or `{Feature}Consts` for all max lengths — never magic numbers
- Optional strings: `.MaximumLength(...)` only (omit `NotEmpty`)
- Email fields: `.NotEmpty().EmailAddress().MaximumLength(ValidationConsts.Small)`
- Vietnam phone: `.Matches(EmployeeConsts.VietnamPhoneNumberRegex).MaximumLength(EmployeeConsts.PhoneNumberMaxLength)`

---

## Step 2 — Define the Output DTO (if new)

Location: `src/CMN.[Service].Application.Contracts/{Feature}/Dtos/Output/WidgetOutputDto.cs`

```csharp
namespace CMN.AdministrationService.Widget.Dtos.Output
{
    public class WidgetOutputDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public string? Description { get; set; }
    }
}
```

No attributes, no annotations — plain DTO only.

---

## Step 3 — Add Method to App Service Interface

Location: `src/CMN.[Service].Application.Contracts/{Feature}/IWidgetAppService.cs`

```csharp
Task<WidgetOutputDto> UpdateAsync(Guid id, UpdateWidgetInputDto input);
```

---

## Step 4 — Implement in App Service

Location: `src/CMN.[Service].Application/{Feature}/WidgetAppService.cs`

```csharp
public async Task<WidgetOutputDto> UpdateAsync(Guid id, UpdateWidgetInputDto input)
{
    var entity = await _widgetRepository.GetAsync(id);
    // throws EntityNotFoundException if not found — do not catch it

    entity.Name = input.Name;
    entity.Description = input.Description;

    await _widgetRepository.UpdateAsync(entity);

    return new WidgetOutputDto
    {
        Id = entity.Id,
        Name = entity.Name,
        Description = entity.Description,
    };
}
```

**Rules**:
- Inject `IRepository<T, Guid>` — never `DbContext`
- Use inline `new OutputDto { ... }` — never `ObjectMapper.Map`
- `GetAsync(id)` throws `EntityNotFoundException` automatically — do not add a null check that rethrows
- Business errors: `throw new UserFriendlyException(L["LocalizationKey"])`
- Never catch exceptions to return error shapes — `CMNAbpExceptionFilter` handles all mapping

---

## Step 5 — Add Controller Action

Location: `src/CMN.[Service].HttpApi/Controllers/{Feature}/WidgetController.cs`

```csharp
[HttpPut("{id:guid}")]
// [PermissionsAuthorize(AdministrationServicePermissions.Widget.Update)]  ← add and comment out initially
public async Task<IActionResult> UpdateAsync(Guid id, [FromBody] UpdateWidgetInputDto input)
    => Success(await _widgetAppService.UpdateAsync(id, input));
```

**Rules**:
- Controller action must be a **single-line expression body** — zero business logic
- Always `Success(...)` — never `Ok(...)`, `Json(...)`, or `return data`
- `AppControllerBase` already carries `[Authorize]` — do not remove it
- Use `[FromBody]` for POST/PUT/PATCH, `[FromQuery]` for GET, `[FromRoute]` for path params
- Add permission attribute commented out — not open `[AllowAnonymous]` (see Known Constraints in services/administration-api.md for the current `[AllowAnonymous]` situation)

---

## Step 6 — Add Localization Keys (if new errors)

Location: `src/CMN.[Service].Domain.Shared/Localization/en.json`

```json
{
  "WidgetNotFound": "Widget not found.",
  "DuplicateWidgetName": "A widget with this name already exists."
}
```

Add the same key to all locale files (`vi.json`, etc.).

---

## Step 7 — Write Test

Location: `test/CMN.[Service].Application.Tests/{Feature}/WidgetAppServiceTests.cs`

```csharp
[Fact]
public async Task UpdateAsync_Should_Update_Widget()
{
    // Arrange: create first
    var created = await _widgetService.CreateAsync(
        new CreateWidgetInputDto { Name = "Original" });

    // Act
    var result = await _widgetService.UpdateAsync(
        created.Id,
        new UpdateWidgetInputDto { Name = "Updated" });

    // Assert
    result.Name.ShouldBe("Updated");
}

[Fact]
public async Task UpdateAsync_Should_Throw_When_Not_Found()
{
    await Should.ThrowAsync<EntityNotFoundException>(
        () => _widgetService.UpdateAsync(Guid.NewGuid(), new UpdateWidgetInputDto { Name = "X" }));
}
```

---

## Step 8 — Update Knowledge Base

- Add endpoint to `services/[service].md` route table
- Add DTO fields to the DTO reference in `services/[service].md`
- Add CHANGELOG entry (`ADD` type)
