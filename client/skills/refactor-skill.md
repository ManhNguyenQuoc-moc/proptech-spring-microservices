# Skill: Refactor

## Scope

Safe refactoring of components, hooks, services, and slices in this codebase.

---

## Before Refactoring

Always use graph tools:

```
1. get_impact_radius(node)                         # how many callers will be affected
2. query_graph(pattern="callers_of", node="...")   # exact list of call sites
3. refactor_tool(mode="rename", ...)               # preview rename across codebase
4. query_graph(pattern="tests_for", ...)           # confirm no tests will break (currently none)
```

---

## Rename a Component

```
1. refactor_tool(mode="rename", old="SWTOldName", new="SWTNewName")
   → returns refactor_id with preview of all affected files
2. apply_refactor_tool(refactor_id, dry_run=true)  # review diff
3. apply_refactor_tool(refactor_id)                # apply
```

Rules:
- New name must keep `SWT` prefix.
- Update the folder name to match: `src/@core/component/AntD/SWT{NewName}/`.
- Update the default export name inside the file.

---

## Extract a Sub-Component

When a page component grows beyond ~150 lines, extract sub-components to `components/` folder:

1. Identify a cohesive JSX subtree.
2. Create `components/{Name}.tsx` in the same feature folder.
3. Move JSX + local state into the new component.
4. Pass data via typed props — no implicit global state sharing.
5. Import in the parent and render.

```tsx
// Before: inline in index.tsx
const EmployeeListPage = () => {
  // 200 lines with table + filter + actions inline
};

// After: composed
const EmployeeListPage = () => {
  return (
    <>
      <EmployeeFilter onChange={handleFilterChange} />
      <EmployeeTable dataSource={data?.items ?? []} isLoading={isLoading} />
    </>
  );
};
```

---

## Move a Utility Function

1. Identify the function and all callers via `query_graph`.
2. Move the function to the appropriate `@core/utils/` file.
3. Export from the `convert` / `get` / `validation` named object, not as a standalone export.
4. Update all import sites.

```ts
// Correct export shape in utils files:
export const convert = {
  trimStringsInObject,
  myNewHelper,  // add here, not as a standalone export
};
```

---

## Split a Large Slice

If a slice `index.ts` exceeds ~80 lines, split thunks and reducers:

```
store/{service}/{domain}/
├── index.ts          # createSlice only — import thunks
├── index.state.ts    # State type + initState
└── thunks/
    ├── getList.ts    # individual thunk files
    └── create.ts
```

---

## Merge Duplicate Service Functions

If two services call the same endpoint with different wrappers:

1. Use `query_graph(pattern="callers_of")` on both to find all callers.
2. Merge into one service function with a union type or optional params.
3. Update all callers.
4. Delete the duplicate.

---

## Safe Rename Rules

- Never rename AntD component prop names (e.g., `onChange`, `onFinish`) — these are AntD API surface.
- Never rename exported constants from `@core/const/index.ts` without a global search.
- Never rename DTO interface fields that mirror the backend API response — they will break deserialization.
- Always check `items.tsx` (route config) after renaming a page component — it's imported there.

---

## What NOT to Refactor

- The `http` singleton in `@core/http/index.ts` — changing interceptor logic affects all requests.
- `SidebarProvider` context shape — changing the context type breaks all sidebar-consuming components.
- `administrationService` object shape — changing keys breaks all Redux thunks that call service methods.
- `initState` shape — must match `ResponseDataWithInput<TInput, TData>` exactly, or `useAppSelector` selectors break.
