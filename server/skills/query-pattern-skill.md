# Skill: Query Patterns

> Use when: writing LINQ queries against multiple repositories, projecting to DTOs, or applying filters.
> Reference implementations: `EmployeeAppService.GetDetailAsync`, `EmployeeAppService.GetListAsync`, `RoleAppService.GetListAsync`.

---

## Basic Queryable Pattern

```csharp
var queryable = await {entity}Repository.GetQueryableAsync();

var query = from item in queryable
            where string.IsNullOrEmpty(keyword) || item.Name.Contains(keyword)
            select new {Feature}OutputDto
            {
                Id   = item.Id,
                Name = item.Name,
            };

var totalCount = await query.CountAsync();
var items = await query
    .Skip((input.Page - 1) * input.Fetch)
    .Take(input.Fetch)
    .ToListAsync();
```

Always project directly into the OutputDto inside the LINQ query. Never `.ToList()` then map.

---

## LEFT JOIN Pattern (optional relationship)

```csharp
var employeeQ      = await employeeRepository.GetQueryableAsync();
var positionQ      = await positionRepository.GetQueryableAsync();
var orgUnitQ       = await organizationUnitRepository.GetQueryableAsync();
var mediaFileQ     = await mediaFileRepository.GetQueryableAsync();

var query = from employee in employeeQ
            where employee.Id == id

            // INNER JOIN — required relationship (user must exist)
            join user in userQ on employee.UserId equals user.Id

            // LEFT JOIN — optional relationship (position may be null)
            join position in positionQ on employee.PositionId equals position.Id into positionGroup
            from position in positionGroup.DefaultIfEmpty()

            // LEFT JOIN — optional relationship (org may be null)
            join org in orgUnitQ on employee.OrganizationUnitId equals org.Id into orgGroup
            from org in orgGroup.DefaultIfEmpty()

            // LEFT JOIN — optional relationship (avatar may be null)
            join media in mediaFileQ on employee.AvatarFileId equals media.Id into mediaGroup
            from media in mediaGroup.DefaultIfEmpty()

            select new EmployeeOutputDto
            {
                Id                   = employee.Id,
                PositionName         = position != null ? position.Name : null,
                OrganizationUnitName = org      != null ? org.DisplayName : null,
                AvatarUrl            = media    != null ? media.SecureUrl : null,
                IsActive             = user.IsActive,
            };

var result = await query.FirstOrDefaultAsync()
    ?? throw new UserFriendlyException(L["UserNotFound"]);
```

### JOIN rules
- `join ... on ... equals ...` (no `into`) = **INNER JOIN** — use when the FK is required.
- `join ... into ... from ... .DefaultIfEmpty()` = **LEFT JOIN** — use when the FK is nullable.
- Always null-check navigation values in the projection: `position != null ? position.Name : null`.
- Get each queryable via `await repo.GetQueryableAsync()` — never access `DbContext` directly.

---

## Filtered Count Pattern

```csharp
var totalCount         = await query.CountAsync();
var totalActive        = await query.CountAsync(e => e.IsActive);
var totalInactive      = totalCount - totalActive;

// Apply filter after counting unfiltered totals
if (input.IsActive.HasValue)
{
    totalCount = await query.CountAsync(e => e.IsActive == input.IsActive.Value);
    query      = query.Where(e => e.IsActive == input.IsActive.Value);
}

var items = await query
    .Skip((input.Page - 1) * input.Fetch)
    .Take(input.Fetch)
    .ToListAsync();

var result = new PagedResultDto(totalCount, items);
result.ExtendData = new Dictionary<string, object>
{
    { "totalActive",   totalActive },
    { "totalInactive", totalInactive },
};
```

Use `ExtendData` (a `Dictionary<string, object>` on the paged result) when aggregate counts must accompany the list.

---

## Single Entity Projection Pattern

```csharp
var queryable = await {entity}Repository.GetQueryableAsync();
return await queryable
    .Where(x => x.Id == id)
    .Select(x => new {Feature}OutputDto
    {
        Id   = x.Id,
        Name = x.Name,
    })
    .FirstOrDefaultAsync()
    ?? throw new UserFriendlyException(L["{Feature}NotFound"]);
```

---

## Keyword Search Pattern

```csharp
var keyword = input.Keyword?.Trim();  // trim before use

var query = from item in queryable
            where string.IsNullOrEmpty(keyword)
                  || item.Name.Contains(keyword)
                  || item.Code.Contains(keyword)
            select ...;
```

Always trim `Keyword` before using in `Contains`. Always guard with `string.IsNullOrEmpty(keyword) ||` to return all rows when no keyword is provided.

---

## Queryable Rules

- Get queryables via `await repo.GetQueryableAsync()` — ABP repository abstraction.
- Multiple queryables can be composed in a single LINQ expression.
- All filtering, projection, and sorting happens **before** `ToListAsync()` — let EF translate to SQL.
- Never call `ToList()` mid-query and then filter in memory.
- Do not use `Select(x => x)` or `.AsEnumerable()` before filtering.
