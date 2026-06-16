# Playbook: Add a Domain Event

> CMN uses **ABP local event bus** for domain events within a service.
> Existing events: `SendOTPEvent`, `RecoveryPasswordEvent`, `PasswordResetSuccessEvent` — all in Administration API.
>
> Use domain events for: decoupling side-effects (email sending, audit writes, cache invalidation) from the main business logic. The publisher does not know about the handler.

---

## When to Use Local vs Distributed Events

| Scenario | Event Type |
|---|---|
| Side-effect within the same service (same process) | `ILocalEventBus` (local) |
| Notify another service (cross-service) | `IDistributedEventBus` (not yet used in CMN) |

All current CMN events are **local**. Use `ILocalEventBus` unless cross-service notification is required.

---

## Step 1 — Define the Event Class

Location: `src/CMN.[Service].Domain/Events/{EventName}.cs`
(or `src/CMN.[Service].Application/Events/` if the event is application-level)

```csharp
namespace CMN.AdministrationService.Events
{
    public class EmployeeDeactivatedEvent
    {
        public Guid EmployeeId { get; set; }
        public Guid UserId { get; set; }
        public string EmployeeName { get; set; }
        public string Email { get; set; }
        public DateTime DeactivatedAt { get; set; }
    }
}
```

**Rules**:
- Plain class — no attributes, no base class required
- Include only the data the handler will need — do not include EF entities
- Use `Guid` for identifiers, never navigation objects

---

## Step 2 — Publish the Event

From an app service (`Application` layer):

```csharp
using Volo.Abp.EventBus.Local;

public class EmployeeAppService : AdministrationServiceAppService, IEmployeeAppService
{
    private readonly ILocalEventBus _localEventBus;

    public EmployeeAppService(ILocalEventBus localEventBus, ...)
    {
        _localEventBus = localEventBus;
    }

    public async Task DeactivateAsync(Guid id)
    {
        var employee = await _employeeRepository.GetAsync(id);

        employee.IsActive = false;
        await _employeeRepository.UpdateAsync(employee);

        // Publish AFTER the primary write — handler runs in same UoW by default
        await _localEventBus.PublishAsync(new EmployeeDeactivatedEvent
        {
            EmployeeId = employee.Id,
            UserId = employee.UserId,
            EmployeeName = employee.Name,
            Email = employee.Email,
            DeactivatedAt = Clock.Now
        });
    }
}
```

**Rules**:
- Call `PublishAsync` after the primary DB write, not before
- ABP local events run synchronously in the same Unit of Work by default
- Do not call `PublishAsync` from a controller — controllers have no business logic
- Reference `IClock` (inject `IClock`) for timestamps, never `DateTime.Now` directly

---

## Step 3 — Implement the Event Handler

Location: `src/CMN.[Service].Application/Events/{EventName}Handler.cs`
(or `.../LocalEvents/{EventName}Handler.cs` to match existing convention)

```csharp
using System.Threading.Tasks;
using Volo.Abp.DependencyInjection;
using Volo.Abp.EventBus;

namespace CMN.AdministrationService.Events
{
    public class EmployeeDeactivatedEventHandler
        : ILocalEventHandler<EmployeeDeactivatedEvent>, ITransientDependency
    {
        private readonly IMailTemplateAppService _mailTemplateAppService;

        public EmployeeDeactivatedEventHandler(IMailTemplateAppService mailTemplateAppService)
        {
            _mailTemplateAppService = mailTemplateAppService;
        }

        public async Task HandleEventAsync(EmployeeDeactivatedEvent eventData)
        {
            await _mailTemplateAppService.SendEmailAsync(
                MailTemplateConsts.EMPLOYEE_DEACTIVATED_CODE,
                new List<string> { eventData.Email },
                new Dictionary<string, string>
                {
                    [MailTemplateConsts.VariableKeys.UserName] = eventData.EmployeeName,
                    // add other placeholders
                }
            );
        }
    }
}
```

**Rules**:
- Implement `ILocalEventHandler<TEvent>` + `ITransientDependency` — ABP auto-discovers and registers
- Do NOT register manually in DI
- Handler runs in the same Unit of Work as the publisher by default
- If the handler should run independently (not roll back with the main operation), use `UnitOfWorkEventRecord` options — but this is advanced and not the default pattern in CMN
- Side-effects in handlers: email sending, cache invalidation, audit log writes only. Never primary business logic.

---

## Step 4 — Add Mail Template Code (if sending email)

If the event triggers an email, add the template code constant:

Location: `src/CMN.[Service].Domain.Shared/MailTemplateConsts.cs`

```csharp
public static class MailTemplateConsts
{
    // ... existing ...
    public const string EMPLOYEE_DEACTIVATED_CODE = "EMPLOYEE_DEACTIVATED";

    public static class VariableKeys
    {
        // ... existing ...
        public static class EmployeeDeactivated
        {
            public const string EmployeeName = "Employee.Name";
            public const string DeactivatedDate = "Employee.DeactivatedDate";
        }
    }
}
```

Then create the `MailTemplate` document in MongoDB (via admin UI or seed data) with the matching `Code` field and `##Employee.Name##` placeholders.

---

## Step 5 — Test the Handler

```csharp
[Fact]
public async Task EmployeeDeactivatedEventHandler_Should_Send_Email()
{
    // Arrange: replace IMailTemplateAppService with a mock/spy
    var mailService = Substitute.For<IMailTemplateAppService>();
    var handler = new EmployeeDeactivatedEventHandler(mailService);

    var eventData = new EmployeeDeactivatedEvent
    {
        EmployeeId = Guid.NewGuid(),
        EmployeeName = "Nguyen Van A",
        Email = "nva@example.com",
        DeactivatedAt = DateTime.Now
    };

    // Act
    await handler.HandleEventAsync(eventData);

    // Assert
    await mailService.Received(1).SendEmailAsync(
        MailTemplateConsts.EMPLOYEE_DEACTIVATED_CODE,
        Arg.Is<List<string>>(r => r.Contains("nva@example.com")),
        Arg.Any<Dictionary<string, string>>()
    );
}
```

Integration test — publish via `ILocalEventBus` and verify the side-effect:
```csharp
[Fact]
public async Task Publishing_EmployeeDeactivatedEvent_Should_Trigger_Handler()
{
    var eventBus = GetRequiredService<ILocalEventBus>();

    await eventBus.PublishAsync(new EmployeeDeactivatedEvent { ... });

    // verify email was sent or cache was invalidated
}
```

---

## Step 6 — Update Knowledge Base

- [ ] Add event to `services/[service].md` Domain Events section
- [ ] Add event + handler + action to `diagrams/event-choreography.mermaid`
- [ ] Add notification flow to `diagrams/notification-event-handlers.mermaid` if email-sending
- [ ] Update `04-business-domain.md` if the event represents a domain state transition
- [ ] Add CHANGELOG entry (`ADD` type)
