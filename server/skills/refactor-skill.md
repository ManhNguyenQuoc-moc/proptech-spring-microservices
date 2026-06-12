# Skill: Safe Refactor

> Use when: renaming symbols, extracting logic, reorganizing files, or removing dead code.
> Always run impact analysis before refactoring — shared infrastructure has wide blast radii.

---

## Pre-Refactor Workflow

### Step 1 — Find all references
```
refactor_tool(symbol_name)           →  all usages across the codebase
query_graph_tool(pattern="callers_of", node_id)  →  callers of the target
```

### Step 2 — Assess blast radius
```
get_impact_radius_tool(node_id)      →  dependents, affected flows, test coverage
```
If blast radius spans multiple bounded contexts or shared libraries, pause and confirm scope with the team.

### Step 3 — Check test coverage
```
query_graph_tool(pattern="tests_for", node_id)
```
Refactoring uncovered code is higher risk. Add tests first if coverage is zero.

### Step 4 — Check for dead code
```
refactor_tool(symbol_name)  →  zero-reference nodes are candidates for deletion
```

---

## Rename Rules

### Renaming a class or interface
1. Rename the type and its file.
2. Update all `using` statements.
3. Update any `[DependsOn(...)]` entries in module files.
4. Update `MEMORY.md` namespace map if the namespace changes.

### Renaming a method on an interface
1. Update the interface declaration.
2. Update the implementation in the AppService.
3. Update the controller call site.
4. Update all tests.

### Renaming a DTO property
1. Rename the property.
2. Update the validator `RuleFor(x => x.OldName)` → `RuleFor(x => x.NewName)`.
3. Update all LINQ projections that reference the old name.
4. Update any API client code or tests.

---

## Extraction Rules

### Extracting a private helper method
- Keep it `private static` if it has no dependency on injected services.
- Keep it `private` (instance) if it needs `this` injected services.
- Do not extract into a new service unless the logic is reused by 2+ app services.

### Moving shared logic to a shared library
Only move to `CMN.Shared.CrossCuttingConcerns` or `CMN.Shared.Hosting.Microservices` if:
- The logic is used by 2+ microservices (not just multiple features in this service).
- It is infrastructure-level (not domain-specific).

---

## What NOT to Refactor

- Do not change the base class of controllers or app services.
- Do not replace `IRepository<TEntity, Guid>` with a custom repository unless there is a specific reason.
- Do not introduce AutoMapper profiles to replace inline LINQ projections — this is a deliberate convention.
- Do not merge the validator file with the DTO file into separate files — keep them colocated.
- Do not change `UserFriendlyException` to a different exception type for business errors.
- Do not rename localization keys without updating the JSON resource files.
