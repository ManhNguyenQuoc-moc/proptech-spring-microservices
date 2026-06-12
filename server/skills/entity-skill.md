# Skill: Domain Entity

> Use when: adding a new domain entity, registering it in DbContext, or defining domain constants.
> Reference implementations: `Employee`, `Positions`, `MediaFile`, `OrganizationUnit`.

---

## Entity Template

**Path**: `src/CMN.AdministrationService.Domain/Entities/{Entity}.cs`
**Namespace**: `CMN.AdministrationService.Entities`

```csharp
using System;
using System.ComponentModel.DataAnnotations.Schema;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace CMN.AdministrationService.Entities
{
    public class {Entity} : FullAuditedEntity<Guid>, IMultiTenant
    {
        public string Name { get; set; }
        public string? OptionalField { get; set; }

        // FK to another domain entity
        public Guid? RelatedEntityId { get; set; }
        [ForeignKey(nameof(RelatedEntityId))]
        public RelatedEntity RelatedEntity { get; set; }

        // Multi-tenancy — private setter is mandatory
        public Guid? TenantId { get; private set; }
    }
}
```

### What `FullAuditedEntity<Guid>` provides
`Id`, `CreationTime`, `CreatorId`, `LastModificationTime`, `LastModifierId`,
`IsDeleted` (soft delete), `DeletionTime`, `DeleterId`.

Do NOT add these properties manually.

### Navigation property rules
- Always use `[ForeignKey(nameof(FkId))]` attribute on the navigation property.
- Foreign key field is nullable (`Guid?`) when the relationship is optional.
- Navigation property is non-nullable when the FK is required (inner join semantics).

### Multi-tenancy rule
`TenantId` **must** have `private set` — never `public set`.

---

## DbContext Registration

**File**: `src/CMN.AdministrationService.EntityFrameworkCore/EntityFrameworkCore/AdministrationServiceDbContext.cs`

1. Add the `DbSet`:
```csharp
public DbSet<{Entity}> {Entities} { get; set; }
```

2. No `modelBuilder.Entity<>()` block is needed for default conventions. Add one only for:
   - Non-default column types
   - Custom indexes
   - Explicit table name (if deviating from convention)

3. Schema is applied globally — all entities land in `"ADM"` automatically:
```csharp
builder.HasDefaultSchema(AdministrationServiceConsts.DbSchema);
```

4. After adding the `DbSet`, generate a migration from the `EntityFrameworkCore` project:
```
dotnet ef migrations add {DescriptiveMigrationName}
```

---

## Domain Constants Template

**Path**: `src/CMN.AdministrationService.Domain.Shared/{Feature}Consts.cs`
**Namespace**: `CMN.AdministrationService`

```csharp
namespace CMN.AdministrationService
{
    public class {Feature}Consts
    {
        // String field limits (integers, not readonly — matches existing pattern)
        public static int NameMaxLength { get; set; } = 250;
        public static int CodeMaxLength { get; set; } = 64;

        // Regex patterns as const strings
        // public const string SomeRegex = @"^...";
    }
}
```

**Rule**: Never inline magic numbers (lengths, regex) in validator code. Always declare in `ValidationConsts` or `{Feature}Consts` and reference by name.

---

## Checklist for a New Entity

- [ ] Class extends `FullAuditedEntity<Guid>` and implements `IMultiTenant`
- [ ] `TenantId` has `private set`
- [ ] All FK navigations use `[ForeignKey(nameof(...))]`
- [ ] `DbSet<>` added to `AdministrationServiceDbContext`
- [ ] Constants defined in `{Feature}Consts` in `Domain.Shared`
- [ ] Migration created
