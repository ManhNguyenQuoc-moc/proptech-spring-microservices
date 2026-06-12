# Skill: Local Domain Event

> Use when: publishing a domain event from an app service and handling it in an event handler.
> Reference implementations: `SendOTPEvent` / `SendOTPEventHandler`, `RecoveryPasswordEvent` / `RecoveryPasswordEventHandler`.

---

## Event Data Class

**Path**: `src/CMN.AdministrationService.Domain/Events/{Name}Event.cs`
**Namespace**: `CMN.AdministrationService.Events`

```csharp
namespace CMN.AdministrationService.Events
{
    public class {Name}Event
    {
        public Guid UserId { get; set; }
        public string Email { get; set; }
        // Use primitive types only — no entity references, no DbContext dependencies
    }
}
```

Rules:
- Plain POCO — no base class, no interfaces.
- Primitive data only: `Guid`, `string`, `int`, `DateTime`, etc.
- Never reference domain entities or repositories here.

---

## Event Handler

**Path**: `src/CMN.AdministrationService.Application/{Feature}/LocalEvents/{Name}EventHandler.cs`
**Namespace**: `CMN.AdministrationService.{Feature}.LocalEvents`

```csharp
using CMN.AdministrationService.Events;
using Volo.Abp.DependencyInjection;
using Volo.Abp.EventBus;
using System.Threading.Tasks;

namespace CMN.AdministrationService.{Feature}.LocalEvents
{
    public class {Name}EventHandler(
        // Inject services — prefer primary constructor
        IMailTemplateAppService mailTemplateAppService
        ) : ILocalEventHandler<{Name}Event>, ITransientDependency
    {
        public async Task HandleEventAsync({Name}Event eventData)
        {
            if (eventData == null) return;

            // Handle the event
            // Example: send email, update cache, trigger another operation
        }
    }
}
```

Rules:
- Implements `ILocalEventHandler<TEvent>` and `ITransientDependency`.
- `ITransientDependency` is required — ABP uses it for automatic handler discovery.
- Use primary constructor injection.
- Guard `if (eventData == null) return;` at the top.
- Handler runs in the same process as the publisher.

---

## Publishing an Event (from AppService)

```csharp
// Inject ILocalEventBus in the app service constructor
private readonly ILocalEventBus _localEventBus;

// Publish (does not require UoW to be active)
await _localEventBus.PublishAsync(new {Name}Event
{
    UserId = user.Id,
    Email  = user.Email,
});
```

Rules:
- `ILocalEventBus` is resolved from DI via field injection (classic constructor pattern, as in `AuthAppService`).
- Publish after the UoW `CompleteAsync()` if the handler must read committed data.
- If the event must be handled inside the same UoW, publish before `CompleteAsync()`.

---

## Full Example (from codebase)

Event: `SendOTPEvent { UserId, ExpireSeconds }`

Handler injects `IMailTemplateAppService`, `IdentityUserManager`, `IStringLocalizer`, `ICurrentTenant`, `IConfiguration`.
Handler calls `identityUserManager.FindByIdAsync(...)` then `mailTemplateAppService.SendEmailAsync(...)`.
Publisher (`AuthAppService.LoginAsync`) calls `_localEventBus.PublishAsync(new SendOTPEvent { UserId = user.Id, ExpireSeconds = AuthConsts.OTP_EXPIRE_SECONDS })`.
