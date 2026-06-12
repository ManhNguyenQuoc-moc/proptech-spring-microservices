# Skill: Feature Module

## Scope

Adding a complete new feature (a domain object with list/create/edit/detail views) to the admin app. This skill orchestrates all other skills.

---

## Checklist

Before starting, use graph tools:
```
get_architecture_overview()   # understand current layer structure
semantic_search_nodes("[Feature]")  # confirm no existing feature
```

---

## Step 1 — Service Layer

Create in `src/services/administration-service/{domain}/`:

```
{domain}/
├── {domain}.service.ts       # getListAsync, getByIdAsync, createAsync, updateAsync, deleteAsync
└── models/
    ├── input.model.ts        # Get*InputDto, Create*InputDto, Update*InputDto
    └── output.model.ts       # *OutputDto, Paged*OutputDto
```

Register in `src/services/administration-service/administration.service.ts`:
```ts
export const administrationService = {
  authService,
  employeeService,
  {domain}Service,  // add here
};
```

See `skills/api-service-skill.md` for full templates.

---

## Step 2 — Redux Slice

Create in `src/store/administration-service/{domain}/`:

```
{domain}/
├── index.ts          # createAsyncThunk + createSlice
└── index.state.ts    # {Domain}State + initState
```

Register in `src/store/administration-service/index.ts`:
```ts
export const administrationServiceSlice = {
  employee: employeeSlice,
  {domain}: {domain}Slice,  // add here
};
```

Register in `src/store/index.ts` reducer.

See `skills/redux-store-skill.md` for full templates.

---

## Step 3 — Pages

Create in `src/pages/(protected)/{domain}/`:

```
{domain}/
├── list/
│   ├── index.tsx             # FeatureListPage — dispatches Redux, composes components
│   └── components/
│       ├── {Domain}Filter.tsx    # SWTFilter wrapper for this domain
│       ├── {Domain}Table.tsx     # SWTTable with column config
│       └── {Domain}Actions.tsx   # Toolbar (Create button, export, etc.)
├── create/
│   ├── index.tsx
│   └── components/
│       └── {Domain}Form.tsx      # SWTForm with useSWTMutation
└── detail/
    └── index.tsx
```

`list/index.tsx` pattern:
```tsx
import useSWTTitle from "@/src/@core/hooks/useSWTTitle";
import { useAppDispatch, useAppSelector } from "@/src/store/hook";
import { administrationServiceStore } from "@/src/store/administration-service";
import { DEFAULT_PAGE, DEFAULT_PAGE_SIZE } from "@/src/@core/const";

const {Domain}ListPage = () => {
  useSWTTitle("Danh sách {domain}");
  const dispatch = useAppDispatch();
  const { data, isLoading, input } = useAppSelector(
    (state) => state.administrationService{Domain}.{domain}List
  );

  useEffect(() => {
    dispatch(administrationServiceStore.{domain}.get{Domain}List({
      page: DEFAULT_PAGE,
      fetch: DEFAULT_PAGE_SIZE,
    }));
  }, []);

  const handleFilterChange = (values: any) => {
    dispatch(administrationServiceStore.{domain}.get{Domain}List({
      ...input,
      ...values,
      page: DEFAULT_PAGE,
    }));
  };

  const handlePageChange = (page: number, fetch: number) => {
    dispatch(administrationServiceStore.{domain}.get{Domain}List({ ...input, page, fetch }));
  };

  return (
    <div>
      <{Domain}Filter onChange={handleFilterChange} />
      <{Domain}Table
        dataSource={data?.items ?? []}
        isLoading={isLoading}
        pagination={{
          totalCount: data?.totalCount ?? 0,
          page: input.page,
          fetch: input.fetch,
          onChange: handlePageChange,
        }}
      />
    </div>
  );
};

export default {Domain}ListPage;
```

---

## Step 4 — Route Registration

Add routes to `src/@core/http/routes/items.tsx`:

```tsx
{
  path: "/administration/{domain}/list",
  element: <Loadable(() => import("@/src/pages/(protected)/{domain}/list")) />,
}
```

Use `@loadable/component` for lazy loading. See `skills/routing-skill.md`.

---

## Step 5 — Sidebar Entry

Add entry to `AppSideBar.tsx` nav config if the feature needs a sidebar link.

---

## Invariants

- Page components only import from `@core`, `services`, and `store`.
- Never import a page component directly from another page.
- Service and store creation must happen BEFORE page creation.
- Each feature domain owns its own slice, service, and page folder — no shared slices across features.
