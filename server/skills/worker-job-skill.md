# Skill: Background Worker / Job

> Use when: scheduling periodic work (background worker) or enqueuing deferred work (background job).
> ABP background jobs abstraction is registered in `AdministrationServiceTestBaseModule` (disabled in tests).
> No production background workers exist in this codebase yet — follow ABP conventions below.

---

## Background Job (one-shot, enqueued)

Use ABP's `IBackgroundJobManager` to enqueue work that should run asynchronously outside the current request.

### Job Args (data contract)

**Path**: `src/CMN.AdministrationService.Domain/Jobs/{Name}JobArgs.cs`
**Namespace**: `CMN.AdministrationService.Jobs`

```csharp
using System;

namespace CMN.AdministrationService.Jobs
{
    [Serializable]
    public class {Name}JobArgs
    {
        public Guid EntityId { get; set; }
        public string AdditionalData { get; set; }
        // Primitive types only — serialized to queue store
    }
}
```

### Job Handler

**Path**: `src/CMN.AdministrationService.Application/Jobs/{Name}Job.cs`
**Namespace**: `CMN.AdministrationService.Jobs`

```csharp
using Volo.Abp.BackgroundJobs;
using Volo.Abp.DependencyInjection;
using System.Threading.Tasks;

namespace CMN.AdministrationService.Jobs
{
    public class {Name}Job(
        // Inject services
        IRepository<MyEntity, Guid> repository
        ) : AsyncBackgroundJob<{Name}JobArgs>, ITransientDependency
    {
        public override async Task ExecuteAsync({Name}JobArgs args)
        {
            // Perform work — runs in a separate UoW automatically
            var entity = await repository.GetAsync(args.EntityId);
            // ...
        }
    }
}
```

### Enqueuing from an App Service

```csharp
// Inject IBackgroundJobManager
private readonly IBackgroundJobManager _backgroundJobManager;

// Enqueue
await _backgroundJobManager.EnqueueAsync(new {Name}JobArgs
{
    EntityId = entity.Id,
});
```

---

## Background Worker (recurring)

Use ABP's `AsyncPeriodicBackgroundWorkerBase` for periodic tasks (polling, cleanup, scheduled checks).

### Worker

**Path**: `src/CMN.AdministrationService.Application/Workers/{Name}Worker.cs`
**Namespace**: `CMN.AdministrationService.Workers`

```csharp
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Threading.Tasks;
using Volo.Abp.BackgroundWorkers;
using Volo.Abp.Threading;

namespace CMN.AdministrationService.Workers
{
    public class {Name}Worker : AsyncPeriodicBackgroundWorkerBase
    {
        public {Name}Worker(AbpAsyncTimer timer, IServiceScopeFactory serviceScopeFactory)
            : base(timer, serviceScopeFactory)
        {
            Timer.Period = 60_000; // milliseconds
        }

        protected override async Task DoWorkAsync(PeriodicBackgroundWorkerContext workerContext)
        {
            var repo = workerContext.ServiceProvider
                .GetRequiredService<IRepository<MyEntity, Guid>>();

            // Periodic work here
        }
    }
}
```

### Registering the Worker

In `AdministrationServiceApplicationModule.ConfigureServices`:

```csharp
context.Services.AddHostedService<{Name}Worker>();
// OR use ABP's registration:
// Configure<AbpBackgroundWorkerOptions>(options => options.IsEnabled = true);
```

---

## Rules

- Job args must be `[Serializable]` and contain only primitive types (they are persisted).
- Job handlers and workers get a fresh `IServiceScope` per execution — resolve scoped services from `workerContext.ServiceProvider`.
- Background jobs are disabled in tests (`IsJobExecutionEnabled = false` in `AdministrationServiceTestBaseModule`).
- Do not inject scoped services directly into worker constructors — always resolve from the worker context scope.
- For one-shot async work triggered from an HTTP request, prefer `IBackgroundJobManager.EnqueueAsync` over fire-and-forget `Task.Run`.
