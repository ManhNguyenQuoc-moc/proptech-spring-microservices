# Skill: Code Review

> Use when: reviewing a PR, reviewing changed files, or auditing a feature before merge.
> Always use the code graph tools first — they provide risk scores and impact analysis without reading every file.

---

## Review Workflow

### Step 1 — Detect changes and score risk
```
detect_changes_tool  →  risk-scored list of changed nodes
```
Focus on nodes with high risk scores first.

### Step 2 — Get source snippets for changed nodes
```
get_review_context_tool(node_ids=[...])  →  source code excerpts
```
More token-efficient than reading entire files.

### Step 3 — Assess blast radius
```
get_impact_radius_tool(node_id)  →  callers, dependents, affected tests
```
For any change to shared infrastructure (`AppControllerBase`, `AdministrationServiceAppService`, `CMNAbpExceptionFilter`, repositories), check blast radius before approving.

### Step 4 — Check test coverage
```
query_graph_tool(pattern="tests_for", node_id)  →  linked test nodes
```
Flag any changed business logic that has no test coverage.

### Step 5 — Check affected execution flows
```
get_affected_flows_tool  →  impacted call paths
```

---

## Review Checklist

### Architecture
- [ ] Controller extends `AppControllerBase`.
- [ ] All actions return `Success(...)` — no `Ok(...)`, `Json(...)`, or raw returns.
- [ ] No business logic inside the controller.
- [ ] App service extends `AdministrationServiceAppService`.
- [ ] No `DbContext` used directly in app services.
- [ ] New entity extends `FullAuditedEntity<Guid>` + `IMultiTenant`.

### Data Access
- [ ] Uses `IRepository<TEntity, Guid>.GetQueryableAsync()` for queries.
- [ ] No `ObjectMapper.Map<>()` — projection is inline LINQ `select new OutputDto { ... }`.
- [ ] Multi-step writes are wrapped in `unitOfWorkManager.Begin()` + `uow.CompleteAsync()`.
- [ ] Business constraint checks happen before the first write.

### DTOs & Validation
- [ ] Input DTO has a paired FluentValidation validator in the same file.
- [ ] Validator uses `CommonExtensions.GetValidateMessage(localizer["Rule"], localizer["Field"])`.
- [ ] String lengths reference `ValidationConsts` or `{Feature}Consts` — no magic numbers.
- [ ] Optional fields guarded with `.When(x => x.Field != null)`.
- [ ] Update DTO fields are all nullable (patch semantics).

### Error Handling
- [ ] Business errors use `throw new UserFriendlyException(L["Key"])`.
- [ ] No raw `Exception` or `InvalidOperationException` thrown for business errors.
- [ ] Mandatory lookups use `?? throw new UserFriendlyException(L["NotFound"])`.

### Entities
- [ ] `TenantId` has `private set`.
- [ ] FK navigations use `[ForeignKey(nameof(...))]`.
- [ ] New `DbSet<>` added to `AdministrationServiceDbContext`.
- [ ] Migration created.

### Security
- [ ] `[AllowAnonymous]` only where genuinely required — confirm with product owner.
- [ ] No sensitive data (tokens, passwords) logged or returned in error details.

### Tests
- [ ] New business logic has at least one test covering the happy path.
- [ ] Error / not-found path is tested with `Should.ThrowAsync<UserFriendlyException>`.

---

## Common Anti-patterns to Flag

See `skills/anti-patterns.md` for the full list. Quick flags:
- `return Ok(data)` instead of `return Success(data)` — **fail**.
- `ObjectMapper.Map<OutputDto>(entity)` — **fail**.
- `throw new Exception("...")` for a business rule — **fail**.
- Hardcoded string `"100"` or `500` where `ValidationConsts.SmallInputMaxLength` belongs — **fail**.
- Validator in a separate file from its DTO — **fail**.
- Missing `IMultiTenant` on a new entity — **fail**.
