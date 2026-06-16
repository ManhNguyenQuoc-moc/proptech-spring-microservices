# Playbook: Add a New Domain Entity

> For adding a new domain entity to Administration API or Customer API.
> If you also need endpoints, run this playbook first, then [add-endpoint.md](add-endpoint.md).

---

## Step 1 — Plan the Entity

Before writing code, confirm:

| Decision | Administration API | Customer API |
|---|---|---|
| DB schema | `ADM` | `CM` |
| Table prefix const | `AdministrationServiceConsts.DbTablePrefix` = `"adm_"` | `CustomerManagementConsts.DbTablePrefix` = `"cm_"` |
| DB schema const | `AdministrationServiceConsts.DbSchema` = `"ADM"` | `CustomerManagementConsts.DbSchema` = `"CM"` |
| Namespace (entity) | `CMN.AdministrationService.Entities` | `CMN.CustomerManagement.Entities` |
| Multi-tenant | `IMultiTenant` (required) | `IMultiTenant` (required) |

Exception: `MailTemplate` does NOT implement `IMultiTenant` (system-wide template). Any new entity that should be available across all tenants follows this exception — document it explicitly.

---

## Step 2 — Define Consts

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

`ValidationConsts` reference (always use these):
| Const | Value |
|---|---|
| `ValidationConsts.Small` | 100 |
| `ValidationConsts.Medium` | 250 |
| `ValidationConsts.Large` | 500 |
| `ValidationConsts.Max` | 1000 |

---

## Step 3 — Create the Domain Entity

Location: `src/CMN.[Service].Domain/Entities/{EntityName}.cs`

```csharp
using System;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace CMN.AdministrationService.Entities
{
    public class Department : FullAuditedEntity<Guid>, IMultiTenant
    {
        public string Name { get; set; }
        public string Code { get; set; }
        public Guid? TenantId { get; private set; }

        protected Department() { }   // required by ABP EF Core

        public Department(Guid id)
        {
            Id = id;
        }
    }
}
```

**Rules**:
- Extend `FullAuditedEntity<Guid>` — provides `Id`, soft-delete (`IsDeleted`), full audit (`CreationTime`, `CreatorId`, `LastModificationTime`, etc.)
- Implement `IMultiTenant` — adds `TenantId { get; private set; }`
- Protected parameterless constructor is required by ABP's EF Core conventions
- Public constructor sets `Id` — do not assign `TenantId` manually (ABP DataFilter handles it)
- Field types: prefer `string`, `Guid`, `bool`, `int`, `long`, `DateTime`, `decimal` — no complex types in entity
- Navigation properties allowed but use only `Guid` FK properties in entity (not EF navigation objects)

---

## Step 4 — Register in DbContext

Location: `src/CMN.[Service].EntityFrameworkCore/EntityFrameworkCore/[Service]DbContext.cs`

**Add DbSet**:
```csharp
public DbSet<Department> Departments { get; set; }
```

**Add EF configuration in `OnModelCreating`**:

Administration API:
```csharp
builder.Entity<Department>(b =>
{
    b.ToTable(AdministrationServiceConsts.DbTablePrefix + "Departments",
              AdministrationServiceConsts.DbSchema);
    b.ConfigureByConvention();              // applies soft-delete, audit, multi-tenancy filters
    b.Property(x => x.Name)
        .IsRequired()
        .HasMaxLength(DepartmentConsts.NameMaxLength);
    b.Property(x => x.Code)
        .IsRequired()
        .HasMaxLength(DepartmentConsts.CodeMaxLength);
    b.HasIndex(x => new { x.Code, x.TenantId }).IsUnique();
});
```

Customer API:
```csharp
builder.Entity<Department>(b =>
{
    b.ToTable(CustomerManagementConsts.DbTablePrefix + "Departments",
              CustomerManagementConsts.DbSchema);
    b.ConfigureByConvention();
    b.Property(x => x.Name).IsRequired().HasMaxLength(DepartmentConsts.NameMaxLength);
});
```

**Rules**:
- Always call `b.ConfigureByConvention()` — never skip it
- Set `HasMaxLength` to match the const used in the validator
- Use `HasIndex(...).IsUnique()` for any unique-constraint fields
- The resulting table name will be: `adm_Departments` (schema `ADM`) or `cm_Departments` (schema `CM`)

---

## Step 5 — Create Migration

```bash
cd swt-cmn-[service-directory]

dotnet ef migrations add Add_{EntityName} \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

**Review the generated migration** — open the `*.cs` file and verify:
- `migrationBuilder.CreateTable` for the new entity
- Table name is `"adm_Departments"` (not `"Departments"` without prefix)
- Schema is `"ADM"` or `"CM"`
- All expected columns present
- No unexpected `DropColumn`, `DropTable`, or `AlterColumn` for existing tables

If the review reveals problems, fix `OnModelCreating` and re-run with `--force` to overwrite.

---

## Step 6 — Apply Migration

**Via DbMigrator** (preferred — seeds data too):
```bash
dotnet run --project src/CMN.[Service].DbMigrator
```

**Via EF directly** (development only):
```bash
dotnet ef database update \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

Verify in SQL Server: table `ADM.adm_Departments` (or `CM.cm_Departments`) exists with all expected columns.

---

## Step 7 — Add Custom Repository (if needed)

Only create a custom repository if the entity needs queries beyond what `IRepository<T, Guid>` provides (e.g., complex joins, raw SQL, bulk operations).

Interface: `src/CMN.[Service].Domain/Repositories/IDepartmentRepository.cs`
```csharp
public interface IDepartmentRepository : IRepository<Department, Guid>
{
    Task<Department?> FindByCodeAsync(string code, Guid? tenantId);
    Task<List<Department>> GetListByOrgUnitAsync(Guid orgUnitId);
}
```

Implementation: `src/CMN.[Service].EntityFrameworkCore/Repositories/DepartmentRepository.cs`
```csharp
public class DepartmentRepository
    : EfCoreRepository<[Service]DbContext, Department, Guid>, IDepartmentRepository
{
    public DepartmentRepository(IDbContextProvider<[Service]DbContext> dbContextProvider)
        : base(dbContextProvider) { }

    public async Task<Department?> FindByCodeAsync(string code, Guid? tenantId)
    {
        var db = await GetDbContextAsync();
        return await db.Departments
            .Where(d => d.Code == code && d.TenantId == tenantId)
            .FirstOrDefaultAsync();
    }
}
```

Register in `EntityFrameworkCoreModule.cs`:
```csharp
context.Services.AddTransient<IDepartmentRepository, DepartmentRepository>();
```

If no custom queries are needed, inject `IRepository<Department, Guid>` directly in the app service — no custom repository required.

---

## Step 8 — Update Knowledge Base

- [ ] Add entity to `services/[service].md` (Domain Entities section)
- [ ] Add entity and fields to `04-business-domain.md`
- [ ] Add entity node to `diagrams/entity-relations.mermaid`
- [ ] Add CHANGELOG entry (`ADD` type)
