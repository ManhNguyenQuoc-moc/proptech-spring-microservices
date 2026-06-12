# Skill: Unit & Integration Tests

> Use when: writing xUnit tests for app services, repositories, or domain logic.
> Reference implementations: `SampleAppServiceTests`, `AdministrationServiceTestDataSeedContributor`.
> Test runner: xUnit · Assertions: Shouldly · DI: ABP autofac test module.

---

## Test Class Structure

### Application service test (integrates with in-memory DB)

**Path**: `test/CMN.AdministrationService.Application.Tests/{Feature}/{Feature}AppServiceTests.cs`
**Namespace**: `CMN.AdministrationService`

```csharp
using Shouldly;
using System;
using System.Threading.Tasks;
using Volo.Abp.Modularity;
using Xunit;

namespace CMN.AdministrationService
{
    public abstract class {Feature}AppServiceTests<TStartupModule>
        : AdministrationServiceApplicationTestBase<TStartupModule>
        where TStartupModule : IAbpModule
    {
        private readonly I{Feature}AppService _{feature}AppService;

        protected {Feature}AppServiceTests()
        {
            _{feature}AppService = GetRequiredService<I{Feature}AppService>();
        }

        [Fact]
        public async Task GetListAsync_Should_Return_Seeded_Items()
        {
            // Arrange — seed data handled by AdministrationServiceTestDataSeedContributor

            // Act
            var result = await _{feature}AppService.GetListAsync(
                new GetList{Feature}InputDto { Page = 1, Fetch = 10 }
            );

            // Assert
            result.TotalCount.ShouldBeGreaterThan(0);
            result.Items.ShouldNotBeNull();
        }

        [Fact]
        public async Task CreateAsync_Should_Return_New_Id()
        {
            // Act
            var id = await _{feature}AppService.CreateAsync(new Create{Feature}InputDto
            {
                Name = "Test {Feature}",
            });

            // Assert
            id.ShouldNotBe(Guid.Empty);
        }

        [Fact]
        public async Task GetAsync_Should_Throw_When_Not_Found()
        {
            // Act & Assert
            await Should.ThrowAsync<Volo.Abp.UserFriendlyException>(
                () => _{feature}AppService.GetAsync(Guid.NewGuid())
            );
        }
    }
}
```

### Concrete test class (hooks into EF test module)

**Path**: `test/CMN.AdministrationService.EntityFrameworkCore.Tests/EntityFrameworkCore/{Feature}/EfCore{Feature}AppServiceTests.cs`

```csharp
namespace CMN.AdministrationService.EntityFrameworkCore
{
    public class EfCore{Feature}AppServiceTests
        : {Feature}AppServiceTests<AdministrationServiceEntityFrameworkCoreTestModule>
    {
        // No additional code needed — inherits all tests
    }
}
```

---

## Test Data Seeding

**File**: `test/CMN.AdministrationService.TestBase/AdministrationServiceTestDataSeedContributor.cs`

```csharp
public class AdministrationServiceTestDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    private readonly IRepository<{Entity}, Guid> _{entity}Repository;
    private readonly ICurrentTenant _currentTenant;

    public AdministrationServiceTestDataSeedContributor(
        IRepository<{Entity}, Guid> {entity}Repository,
        ICurrentTenant currentTenant)
    {
        _{entity}Repository = {entity}Repository;
        _currentTenant = currentTenant;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        using (_currentTenant.Change(context?.TenantId))
        {
            await _{entity}Repository.InsertAsync(new {Entity}
            {
                Name = "Seed{Feature}1",
            });
        }
    }
}
```

---

## Shouldly Assertion Patterns

```csharp
// Equality
result.ShouldBe(expected);
result.ShouldNotBe(unexpected);

// Null / empty
result.ShouldNotBeNull();
result.ShouldBeNull();
result.ShouldNotBeEmpty();

// Collections
result.TotalCount.ShouldBeGreaterThan(0);
result.Items.ShouldContain(x => x.Name == "expected");
result.Items.Count.ShouldBe(2);

// Exceptions
await Should.ThrowAsync<UserFriendlyException>(() => service.MethodAsync(...));
```

---

## Service Resolution

```csharp
// Resolve from ABP DI container inside test class
var service = GetRequiredService<IMyService>();
var repo    = GetRequiredService<IRepository<MyEntity, Guid>>();
```

---

## Test Module Chain

```
AdministrationServiceEntityFrameworkCoreTestModule
  → AdministrationServiceApplicationModule
  → AdministrationServiceDomainTestModule
    → AdministrationServiceTestBaseModule
      → AbpAutofacModule + AbpTestBaseModule
```

- `AdministrationServiceTestBaseModule` calls `IDataSeeder.SeedAsync()` on init.
- Background jobs are disabled in tests: `options.IsJobExecutionEnabled = false`.
- Authorization is bypassed: `context.Services.AddAlwaysAllowAuthorization()`.
- Use `FakeCurrentPrincipalAccessor` (in `TestBase/Security/`) to mock identity context.

---

## Test Naming Convention

```
{MethodName}_Should_{ExpectedBehavior}_When_{Condition}

// Examples:
GetAsync_Should_Throw_When_NotFound
CreateAsync_Should_Return_NewId_When_ValidInput
UpdateAsync_Should_UpdateName_When_NameProvided
```
