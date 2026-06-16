# Entity: [EntityName]

**Source**: `[path/to/Entity.cs]`
**Base**: `FullAuditedEntity<Guid>`
**Interface**: `IMultiTenant`
**DB Table**: `[SCHEMA].[TableName]`
**Service**: [owning service]

---

## Fields

| Field | Type | Nullable | Description |
|---|---|---|---|
| `Id` | `Guid` | No | PK (inherited) |
| `TenantId` | `Guid?` | Yes | Multi-tenancy discriminator |
| `CreationTime` | `DateTime` | No | Audit (inherited) |
| `CreatorId` | `Guid?` | Yes | Audit (inherited) |
| `LastModificationTime` | `DateTime?` | Yes | Audit (inherited) |
| `LastModifierId` | `Guid?` | Yes | Audit (inherited) |
| `IsDeleted` | `bool` | No | Soft-delete (inherited) |
| `DeleterId` | `Guid?` | Yes | Audit (inherited) |
| `DeletionTime` | `DateTime?` | Yes | Audit (inherited) |
| `FieldName` | `Type` | Yes/No | Description |

---

## Relations

| Relation | Target | FK | Cardinality |
|---|---|---|---|
| `NavigationProp` | `RelatedEntity` | `ForeignKeyId` | Many-to-One |

---

## Business Rules

- [Rule 1]
- [Rule 2]

---

## Produced Events

| Event | When |
|---|---|
| `XxxCreatedEvent` | On creation |
