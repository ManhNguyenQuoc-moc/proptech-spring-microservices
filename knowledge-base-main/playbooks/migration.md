# Playbook: EF Core Database Migrations

> CMN uses EF Core with SQL Server. Migrations are stored per service.
>
> **Database**: `SWTCMN` at `100.69.37.126:1433`
> **Schemas**: `ADM` (Administration API), `CM` (Customer API)

---

## Current Migration State

### Administration API — 4 migrations
| Migration | Date | Description |
|---|---|---|
| `20251108...` | 2025-11-08 | (Phase 0 — initial) |
| `20251109...` | 2025-11-09 | |
| `20251114...` | 2025-11-14 | |
| `20251115...` | 2025-11-15 | |

### Customer API — 1 migration
| Migration | Date | Description |
|---|---|---|
| `20260103081306_Initial` | 2026-01-03 | Creates `CM.Party` table |

---

## Create a New Migration

```bash
cd swt-cmn-[service-directory]

dotnet ef migrations add {MigrationName} \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

**Naming convention**: `Add_{EntityName}`, `Add_{ColumnName}_To_{TableName}`, `Drop_{TableName}`, `Rename_{OldName}_To_{NewName}`.

---

## Review the Migration Before Applying

Open the generated file: `src/CMN.[Service].EntityFrameworkCore/Migrations/{timestamp}_{Name}.cs`

**Verify**:
- [ ] `CreateTable` uses the correct table name with prefix (`adm_` or `cm_`)
- [ ] Schema is `"ADM"` or `"CM"` — never empty or wrong schema
- [ ] All expected columns present with correct nullability
- [ ] `HasMaxLength` matches the consts used in `OnModelCreating`
- [ ] No unexpected `DropTable`, `DropColumn`, or `AlterColumn` for existing tables
- [ ] Index creation is correct (especially unique indexes)
- [ ] `Down()` method correctly reverses all operations in `Up()`

If the migration looks wrong: **do not apply it**. Fix `OnModelCreating` and regenerate:
```bash
dotnet ef migrations remove \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
# Then fix and re-run dotnet ef migrations add
```

---

## Apply Migration

### Via DbMigrator (preferred — also runs ABP seed data)

```bash
cd swt-cmn-[service-directory]
dotnet run --project src/CMN.[Service].DbMigrator
```

This applies all pending migrations AND runs the ABP data seeder (tenant seeding, permission seeding, etc.).

### Via EF CLI (development only — no seed data)

```bash
dotnet ef database update \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

### Apply to a specific migration

```bash
dotnet ef database update {MigrationName} \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

---

## Rollback a Migration

**Rollback to the previous migration**:
```bash
dotnet ef database update {PreviousMigrationName} \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

**Find the previous migration name**:
```bash
dotnet ef migrations list \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

**Then remove the migration file** (if not yet applied to production):
```bash
dotnet ef migrations remove \
  --project src/CMN.[Service].EntityFrameworkCore \
  --startup-project CMN.[Service].HttpApi.Host
```

> `migrations remove` only works if the migration has not been applied to any database. If already applied, use `database update {Previous}` first, then `migrations remove`.

---

## Migration for Column Changes

**Add nullable column** (safe — no data loss):
```csharp
// OnModelCreating — add property config
b.Property(x => x.NewColumn).HasMaxLength(200).IsRequired(false);
```

**Add non-nullable column** (requires default or backfill):
```csharp
// In migration Up():
migrationBuilder.AddColumn<string>(
    name: "NewColumn",
    schema: "ADM",
    table: "adm_Departments",
    maxLength: 200,
    nullable: false,
    defaultValue: "");  // ← provide default for existing rows

// Remove defaultValue from production once backfilled
```

**Rename column** (use `RenameColumn` — do NOT drop + add, which loses data):
```csharp
migrationBuilder.RenameColumn(
    name: "OldName",
    schema: "ADM",
    table: "adm_Departments",
    newName: "NewName");
```

---

## Seeded Data

The following are seeded by the DbMigrator on every run:

- Tenant `itzone` (ID: `019b8846-891c-7642-8381-1722468b8462`) — confirmed from Phase 0
- ABP default permissions
- ABP identity settings

To add custom seed data: implement `IDataSeedContributor` in the `Domain` project.

---

## Connection String Reference

```json
// appsettings.secrets.json (git-ignored, local dev only)
{
  "ConnectionStrings": {
    "Default": "Server=100.69.37.126,1433;Database=SWTCMN;User Id=...;Password=...;TrustServerCertificate=True"
  }
}
```

Never commit real credentials. Use `appsettings.secrets.json` locally.
