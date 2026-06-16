# Playbook: Add a New Domain Entity (.NET Service)

> Follow these steps in order. Read `swt-cmn-[service]/skills/entity-skill.md` first.

---

## Step 1: Create the Entity in Domain

Location: `src/CMN.[Service].Domain/Entities/Widget.cs`

```csharp
using System;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace CMN.AdministrationService.Entities
{
    public class Widget : FullAuditedEntity<Guid>, IMultiTenant
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public Guid? TenantId { get; private set; }

        protected Widget() { }

        public Widget(Guid id)
        {
            Id = id;
        }
    }
}
```

**Rules**:
- Extend `FullAuditedEntity<Guid>` — provides Id, soft-delete, full audit.
- Implement `IMultiTenant` — adds `TenantId` with `private set`.
- Protected parameterless constructor (ABP requirement) + constructor with `Id`.

---

## Step 2: Register in DbContext (EntityFrameworkCore)

Location: `src/CMN.[Service].EntityFrameworkCore/EntityFrameworkCore/[Service]DbContext.cs`

```csharp
public DbSet<Widget> Widgets { get; set; }
```

In `OnModelCreating`:

```csharp
// Administration Service — schema ADM
builder.Entity<Widget>(b =>
{
    b.ToTable(AdministrationServiceConsts.DbTablePrefix + "Widgets", AdministrationServiceConsts.DbSchema);
    b.ConfigureByConvention();
    b.Property(x => x.Name).IsRequired().HasMaxLength(256);
    b.Property(x => x.Description).HasMaxLength(1000);
});

// Customer Service — schema CM (ALWAYS explicit)
builder.Entity<Widget>(b =>
{
    b.ToTable(CustomerManagementConsts.DbTablePrefix + "Widgets", CustomerManagementConsts.DbSchema);
    b.ConfigureByConvention();
});
```

---

## Step 3: Create Migration

```bash
cd swt-cmn-[service-name]

dotnet ef migrations add Add_Widget \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

Review the generated migration before applying.

---

## Step 4: Apply Migration

```bash
dotnet run --project src/CMN.[Service].DbMigrator
```

Or during development:

```bash
dotnet ef database update \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

---

## Step 5: Add Repository Interface (if custom queries needed)

Location: `src/CMN.[Service].Domain/Repositories/IWidgetRepository.cs`

```csharp
public interface IWidgetRepository : IRepository<Widget, Guid>
{
    Task<Widget> FindByNameAsync(string name);
}
```

Implement in EntityFrameworkCore:
`src/CMN.[Service].EntityFrameworkCore/Repositories/WidgetRepository.cs`

---

## Step 6: Update Knowledge Base

- Add entity to `services/[service].md` under Domain Entities (anchor: `[service]-entities`).
- Add entity to `04-business-domain.md` with field table.
- Update `diagrams/entity-relations.mermaid` with the new entity and its relations.
- Add CHANGELOG entry.
