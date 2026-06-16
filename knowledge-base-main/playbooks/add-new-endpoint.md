# Playbook: Add a New API Endpoint (.NET Service)

> Follow these steps in order. Do not skip steps. Read the relevant skill file first.

**Prerequisite**: Read `swt-cmn-[service]/skills/api-service-skill.md` before starting.

---

## Step 1: Define the DTO(s) in Application.Contracts

Location: `src/CMN.[Service].Application.Contracts/{Feature}/Dtos/Input/`

```csharp
// CreateWidgetInputDto.cs
namespace CMN.AdministrationService.Widget.Dtos.Input
{
    public class CreateWidgetInputDto
    {
        public string Name { get; set; }
        public string Description { get; set; }
    }

    // Validator MUST be in the same file
    public class CreateWidgetInputDtoValidator : AbstractValidator<CreateWidgetInputDto>
    {
        public CreateWidgetInputDtoValidator()
        {
            RuleFor(x => x.Name).NotEmpty().MaximumLength(256);
            RuleFor(x => x.Description).MaximumLength(1000);
        }
    }
}
```

Also create `Output/WidgetOutputDto.cs` in the same namespace pattern.

---

## Step 2: Define the Interface in Application.Contracts

Location: `src/CMN.[Service].Application.Contracts/{Feature}/IWidgetAppService.cs`

```csharp
namespace CMN.AdministrationService.Widget
{
    public interface IWidgetAppService
    {
        Task<WidgetOutputDto> CreateAsync(CreateWidgetInputDto input);
        Task<PagedResultDto<WidgetOutputDto>> GetListAsync(GetWidgetListInputDto input);
        Task<WidgetOutputDto> GetAsync(Guid id);
        Task<WidgetOutputDto> UpdateAsync(Guid id, UpdateWidgetInputDto input);
        Task DeleteAsync(Guid id);
    }
}
```

---

## Step 3: Implement the App Service in Application

Location: `src/CMN.[Service].Application/{Feature}/WidgetAppService.cs`

```csharp
namespace CMN.AdministrationService
{
    public class WidgetAppService : AdministrationServiceAppService, IWidgetAppService
    {
        private readonly IRepository<Widget, Guid> _widgetRepository;

        public WidgetAppService(IRepository<Widget, Guid> widgetRepository)
        {
            _widgetRepository = widgetRepository;
        }

        public async Task<WidgetOutputDto> CreateAsync(CreateWidgetInputDto input)
        {
            // Check for duplicates if needed
            var existing = await _widgetRepository.FindAsync(w => w.Name == input.Name);
            if (existing != null)
                throw new UserFriendlyException(L["DuplicateWidgetName"]);

            var widget = new Widget(GuidGenerator.Create())
            {
                Name = input.Name,
                Description = input.Description
            };

            await _widgetRepository.InsertAsync(widget);

            return new WidgetOutputDto { Id = widget.Id, Name = widget.Name };
            // OR use inline projection:
            // return new WidgetOutputDto { Id = widget.Id, Name = widget.Name };
        }

        // ... other methods
    }
}
```

**Rules**:
- No `DbContext` — use `IRepository<Widget, Guid>`.
- No AutoMapper — use inline `new OutputDto { Id = entity.Id, ... }` for all mappings.
- Business errors via `throw new UserFriendlyException(L["LocalizationKey"])`.

---

## Step 4: Add the Controller in HttpApi

Location: `src/CMN.[Service].HttpApi/Controllers/WidgetController.cs`

```csharp
[Route($"{AdministrationServiceSettingNames.DefaultRoute}/widgets")]
namespace CMN.AdministrationService.Controllers.Widget
{
    public class WidgetController : AppControllerBase
    {
        private readonly IWidgetAppService _widgetService;

        public WidgetController(IWidgetAppService widgetService)
        {
            _widgetService = widgetService;
        }

        [HttpPost]
        public async Task<IActionResult> CreateAsync([FromBody] CreateWidgetInputDto input)
            => Success(await _widgetService.CreateAsync(input), HttpStatusCode.Created);

        [HttpGet]
        public async Task<IActionResult> GetListAsync([FromQuery] GetWidgetListInputDto input)
            => Success(await _widgetService.GetListAsync(input));

        [HttpGet("{id:guid}")]
        public async Task<IActionResult> GetAsync(Guid id)
            => Success(await _widgetService.GetAsync(id));

        [HttpPut("{id:guid}")]
        public async Task<IActionResult> UpdateAsync(Guid id, [FromBody] UpdateWidgetInputDto input)
            => Success(await _widgetService.UpdateAsync(id, input));

        [HttpDelete("{id:guid}")]
        public async Task<IActionResult> DeleteAsync(Guid id)
        {
            await _widgetService.DeleteAsync(id);
            return Success();
        }
    }
}
```

**Rules**:
- Single-line expression bodies — zero business logic.
- Always use `Success(...)` — never `Ok(...)` or raw returns.

---

## Step 5: Add Localization Keys

Location: `src/CMN.[Service].Domain.Shared/Localization/en.json` (and other locale files)

```json
{
  "WidgetNotFound": "Widget not found.",
  "DuplicateWidgetName": "A widget with this name already exists."
}
```

---

## Step 6: Add Entity (if new)

See playbook: [add-new-entity.md](add-new-entity.md)

---

## Step 7: Write Tests

Location: `test/CMN.[Service].Application.Tests/`

```csharp
public class WidgetAppServiceTests : AdministrationServiceApplicationTestBase
{
    private readonly IWidgetAppService _widgetService;

    public WidgetAppServiceTests()
    {
        _widgetService = GetRequiredService<IWidgetAppService>();
    }

    [Fact]
    public async Task CreateAsync_Should_Return_Widget()
    {
        var result = await _widgetService.CreateAsync(new CreateWidgetInputDto
        {
            Name = "Test Widget"
        });

        result.ShouldNotBeNull();
        result.Name.ShouldBe("Test Widget");
    }
}
```

---

## Step 8: Update Knowledge Base

- Add the new endpoint to `services/[service].md` under Controllers & Routes (anchor: `[service]-controllers`).
- If a new entity was added, update `04-business-domain.md` and `diagrams/entity-relations.mermaid`.
- Add a CHANGELOG entry in `CHANGELOG.md`.
