# Playbook: Add an ABP Background Job

> CMN uses **ABP Background Jobs** (NOT Hangfire). Jobs are stored in SQL Server via EF Core.
> No custom job handlers were found in the codebase at Phase 3 — this playbook creates the first one.
>
> Use background jobs for: deferred work after a request completes (e.g., sending a report, cleanup tasks, scheduled processing). Do NOT use background jobs for email — email is sent synchronously via domain event handlers and `IEmailSender`.

---

## Step 1 — Define Job Args

Location: `src/CMN.[Service].Application.Contracts/BackgroundJobs/{JobName}Args.cs`

```csharp
using System;

namespace CMN.AdministrationService.BackgroundJobs
{
    [Serializable]
    public class GenerateReportArgs
    {
        public Guid TenantId { get; set; }
        public Guid RequestedByUserId { get; set; }
        public DateTime FromDate { get; set; }
        public DateTime ToDate { get; set; }
    }
}
```

**Rules**:
- Must be `[Serializable]` — ABP serializes args to JSON for SQL Server storage
- Use only primitive types, `Guid`, `DateTime`, `string`, and simple structs — no EF entities or complex objects
- Keep args small — they are persisted in the database

---

## Step 2 — Implement the Job Handler

Location: `src/CMN.[Service].Application/BackgroundJobs/{JobName}Job.cs`

```csharp
using System.Threading.Tasks;
using Volo.Abp.BackgroundJobs;
using Volo.Abp.DependencyInjection;

namespace CMN.AdministrationService.BackgroundJobs
{
    public class GenerateReportJob
        : AsyncBackgroundJob<GenerateReportArgs>, ITransientDependency
    {
        private readonly IReportAppService _reportAppService;

        public GenerateReportJob(IReportAppService reportAppService)
        {
            _reportAppService = reportAppService;
        }

        public override async Task ExecuteAsync(GenerateReportArgs args)
        {
            await _reportAppService.GenerateAsync(
                args.TenantId,
                args.RequestedByUserId,
                args.FromDate,
                args.ToDate
            );
        }
    }
}
```

**Rules**:
- Extend `AsyncBackgroundJob<TArgs>` — not the synchronous `BackgroundJob<TArgs>`
- Implement `ITransientDependency` — ABP auto-registers it in DI; do NOT register manually
- Never inject `DbContext` directly — inject app service interfaces or repositories
- `ExecuteAsync` must be idempotent where possible — ABP will retry on failure
- Failures increment `TryCount`; ABP applies exponential backoff and retries up to the configured max

---

## Step 3 — Enqueue the Job

From any app service (in `Application` layer):

```csharp
using Volo.Abp.BackgroundJobs;

public class ReportRequestAppService : AdministrationServiceAppService
{
    private readonly IBackgroundJobManager _backgroundJobManager;

    public ReportRequestAppService(IBackgroundJobManager backgroundJobManager)
    {
        _backgroundJobManager = backgroundJobManager;
    }

    public async Task RequestReportAsync(RequestReportInputDto input)
    {
        // ... validate, create DB record ...

        await _backgroundJobManager.EnqueueAsync(new GenerateReportArgs
        {
            TenantId = CurrentTenant.Id!.Value,
            RequestedByUserId = CurrentUser.Id!.Value,
            FromDate = input.FromDate,
            ToDate = input.ToDate,
        });
    }
}
```

**Rules**:
- Inject `IBackgroundJobManager` — never create job instances directly
- The job is persisted in `AbpBackgroundJobs` SQL Server table immediately
- Processing happens in-process on the ABP Background Worker polling interval
- Optional parameters: `priority` (default Normal), `delay` (defer execution)

---

## Step 4 — Verify ABP Background Jobs Are Enabled

Check host module (Administration API or Customer API) for:

```csharp
// In [Service]HttpApiHostModule.cs — should already be present
context.Services.AddAbpDbContext<[Service]DbContext>(options =>
{
    // ...
});
// Volo.Abp.BackgroundJobs.EntityFrameworkCore is referenced — jobs stored in SQL
```

Verify `Volo.Abp.BackgroundJobs.EntityFrameworkCore` is in the `.csproj` of the `EntityFrameworkCore` project. If missing:

```bash
dotnet add package Volo.Abp.BackgroundJobs.EntityFrameworkCore
```

And add `[DependsOn(typeof(AbpBackgroundJobsEntityFrameworkCoreModule))]` to the EF module.

---

## Step 5 — Test

```csharp
[Fact]
public async Task GenerateReportJob_Should_Execute()
{
    // Arrange
    var args = new GenerateReportArgs
    {
        TenantId = TestData.TenantId,
        RequestedByUserId = TestData.UserId,
        FromDate = DateTime.Today.AddDays(-7),
        ToDate = DateTime.Today
    };

    var job = GetRequiredService<GenerateReportJob>();

    // Act — execute directly (no queue needed in test)
    await job.ExecuteAsync(args);

    // Assert
    // ... verify the expected side effect ...
}
```

---

## Step 6 — Update Knowledge Base

- [ ] Add job to `services/[service].md` Background Jobs section
- [ ] If new pattern, update `worker-abp-background-jobs.mermaid`
- [ ] Add CHANGELOG entry (`ADD` type)
