# Skill: Performance

## Scope

Performance optimization patterns for components, hooks, and state in this codebase.

---

## Before Optimizing

Use graph tools to understand impact before memoizing:

```
get_impact_radius(node)   # how many callers does this component have
query_graph(pattern="callers_of", node="SWTFilter")   # who renders this component
```

---

## Component Memoization

Apply `memo()` when a component:
- Receives callback props from a frequently-re-rendering parent
- Renders a list item repeated many times
- Is a filter bar or toolbar with stable props

```tsx
// Correct — SWTFilter wrapped in memo to prevent re-render on parent state changes
export default memo(SWTFilter);
```

Do NOT memoize:
- Simple wrappers with 0-1 props
- Components that render once and never re-render
- Components where the parent rarely re-renders

---

## Code Splitting

All page components in `items.tsx` use `@loadable/component` — this is already the pattern. Ensure every new page follows it:

```tsx
import loadable from "@loadable/component";

const EmployeeListPage = loadable(() => import("@/src/pages/(protected)/employee/list"));
```

`Suspense` with `SWTAppLoader` fallback is already configured at the `App` level — do not add nested `Suspense` boundaries unless you have a specific reason.

---

## Filter Debounce

`SWTFilter` already debounces `onChange` by 300ms via `setTimeout`. Do not add additional debounce in the parent `handleFilterChange`. Only reset the timer if rapid filter changes should cancel previous dispatches.

---

## useMemo / useCallback

Use only when profiling reveals a concrete problem:

```tsx
// useMemo — expensive derivation from slice data
const activeEmployees = useMemo(
  () => data?.items.filter(e => e.isActive) ?? [],
  [data?.items]
);

// useCallback — stable callback passed as prop to memo'd child
const handlePageChange = useCallback(
  (page: number, fetch: number) => {
    dispatch(actions.getList({ ...input, page, fetch }));
  },
  [dispatch, input]
);
```

Do NOT apply `useMemo` / `useCallback` preemptively to every handler.

---

## Avoiding Re-fetches

The `input` field in each slice state caches the last dispatched params. Use it to re-fetch with the same params after a mutation:

```tsx
const { input } = useAppSelector((s) => s.administrationServiceEmployee.employeeList);

// After delete:
dispatch(administrationServiceStore.employee.getEmployeeList(input));
// Uses cached page/filters — no need to reset pagination
```

---

## SWTTable

- Always pass explicit `rowKey` if items don't have an `id` field.
- `pagination={false}` is already set inside `SWTTable` — do not pass AntD's `pagination` prop. Use the custom `SWTPaginationProps` shape instead.
- `SWTEmpty` is already the default `locale.emptyText` — do not add a custom empty state.

---

## Image Optimization

`antd-img-crop` is available for image upload/crop flows. Use it with `SWTUpload` when handling profile images or avatar uploads.

---

## Font Loading

`"Be Vietnam Pro"` is the project font (AntD token). Ensure it is loaded from `globals.css` or `index.html` before the AntD config applies — otherwise a flash of unstyled text occurs on first load.
