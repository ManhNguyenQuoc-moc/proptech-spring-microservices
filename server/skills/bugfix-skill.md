# Skill: Bug Fix

> Use when: diagnosing and fixing a bug in any layer of this service.
> Always use the code graph for impact analysis before changing shared infrastructure.

---

## Diagnosis Workflow

### Step 1 — Locate the node
```
semantic_search_nodes_tool(query="method or class name")
```
Find the exact function, class, or file containing the bug.

### Step 2 — Trace callers
```
query_graph_tool(pattern="callers_of", node_id)
```
Understand what calls the broken code — changes here ripple upward.

### Step 3 — Assess blast radius before fixing
```
get_impact_radius_tool(node_id)
```
If the node has many dependents, plan the fix carefully to avoid regressions.

### Step 4 — Check existing tests
```
query_graph_tool(pattern="tests_for", node_id)
```
Run existing tests first. If there are none, write a failing test that reproduces the bug before fixing.

---

## Fix Patterns by Layer

### Controller bugs
- Wrong binding attribute (`[FromBody]` vs `[FromForm]`) — check whether the DTO has `IFormFile`.
- Missing `[AllowAnonymous]` on a public endpoint — add only after confirming with product owner.
- Action not returning `Success(...)` — wrap in `Success(await ...)`.

### App service bugs
- Missing `await uow.CompleteAsync()` — changes not persisted.
- Null reference after a query — add `?? throw new UserFriendlyException(L["EntityNotFound"])`.
- Stale entity after manager update — call `await entityRepository.UpdateAsync(entity)` after `userManager.UpdateAsync`.
- Missing `(await manager.SomeAsync(...)).CheckErrors()` — `IdentityResult` errors silently swallowed.
- Wrong UoW scope — `userManager` calls must be inside the same UoW scope as repository writes.

### Validator bugs
- Optional field rule missing `.When(x => x.Field != null)` — fires on nulls.
- Conflicting rules on same field — separate into distinct `RuleFor` chains.
- Wrong localizer key — check `en.json` / `vi.json` for the exact key.

### Query bugs
- Wrong JOIN type — INNER JOIN when LEFT JOIN needed (nullable FK).
- Filtering after `ToList()` instead of before — moves filtering to memory; convert to LINQ before materialization.
- `Skip/Take` applied on wrong queryable (after conditional where-clause reuse).

### Entity bugs
- `TenantId` with `public set` — data isolation leak; change to `private set`.
- Missing `[ForeignKey]` attribute — EF creates shadow FK column with wrong name.
- Missing `DbSet<>` registration — entity not tracked by EF.

---

## Fix Validation

After applying a fix:
1. Run the affected test(s).
2. If no test existed, write one that covers both the failing case and the happy path.
3. If the fix touches shared code, re-run `get_impact_radius_tool` and test affected callers.
