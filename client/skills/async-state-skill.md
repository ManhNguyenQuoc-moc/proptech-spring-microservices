# Skill: Async State

## Scope

Managing async data flows — deciding between Redux, `useSWTMutation`, and Context. Covers thunk dispatch patterns, loading states, and re-fetch after mutations.

---

## Decision Matrix

| Scenario | Use |
|----------|-----|
| Paginated list shared across the page | Redux `createAsyncThunk` |
| Mutation (create/update/delete) | `useSWTMutation` |
| Navigation guards, sidebar state | Context API |
| One-off fetch, local to a small component | `useSWTMutation` (or inline `useEffect`) |

---

## Loading State Pattern

**First-time skeleton** — use `useSWTInitLoading` when you only want to show a skeleton on the initial load, not on re-fetches:

```tsx
const { data, isLoading } = useAppSelector((s) => s.administrationServiceEmployee.employeeList);
const isInitialLoad = useSWTInitLoading(isLoading);

return (
  <>
    <SWTRenderIf condition={isInitialLoad}>
      <SWTSkeleton />
    </SWTRenderIf>
    <SWTRenderIf condition={!isInitialLoad}>
      <SWTTable dataSource={data?.items ?? []} isLoading={isLoading} ... />
    </SWTRenderIf>
  </>
);
```

**Inline loading** — pass `isLoading` directly to `SWTTable` (shows AntD's built-in spinner):
```tsx
<SWTTable dataSource={data?.items ?? []} loading={isLoading} ... />
```

---

## Initial Fetch Pattern

Dispatch on mount, include default pagination:

```tsx
useEffect(() => {
  dispatch(administrationServiceStore.employee.getEmployeeList({
    page: DEFAULT_PAGE,
    fetch: DEFAULT_PAGE_SIZE,
    keyword: "",
  }));
}, []);
```

---

## Re-fetch After Mutation

After a successful create/update/delete, re-dispatch the last input to refresh the list:

```tsx
const { input } = useAppSelector((s) => s.administrationServiceEmployee.employeeList);

const { mutation } = useSWTMutation<boolean, string>({
  mutationFn: (id) => administrationService.employeeService.deleteAsync(id),
  onSuccess: () => {
    showNotificationSuccess("Xóa thành công.");
    dispatch(administrationServiceStore.employee.getEmployeeList(input)); // re-fetch with same params
  },
});
```

---

## Pagination Change Pattern

```tsx
const handlePageChange = (page: number, fetch: number) => {
  dispatch(administrationServiceStore.employee.getEmployeeList({
    ...input,  // preserve filters
    page,
    fetch,
  }));
};

<SWTTable
  pagination={{
    totalCount: data?.totalCount ?? 0,
    page: input.page,
    fetch: input.fetch,
    onChange: handlePageChange,
  }}
/>
```

---

## Filter + Pagination Reset Pattern

When filters change, reset to page 1:

```tsx
const handleFilterChange = (allValues: any) => {
  dispatch(administrationServiceStore.employee.getEmployeeList({
    ...input,
    ...allValues,
    page: DEFAULT_PAGE,  // always reset page on filter change
  }));
};
```

---

## useSWTMutation — Async Loading States

`useSWTMutation` provides two loading flags:

- `isLoading` — true on every call
- `isInitLoading` — true only on the first call (useful for button-triggered full-page loads)

```tsx
const { mutation, isLoading, isInitLoading } = useSWTMutation<OutputDto, InputDto>({
  mutationFn: (input) => service.createAsync(input),
  onSuccess: (res) => { ... },
});

// Button shows spinner on every submit:
<SWTButton loading={isLoading} htmlType="submit">Lưu</SWTButton>
```

---

## Error Handling

HTTP errors are handled globally in `@core/http/index.ts` interceptors:
- 400: notification shown automatically
- 401: token refresh attempted
- 403/404/500: redirect

Do not add `.catch()` in service functions or `onError` in `useSWTMutation` unless you need component-specific error UI beyond the global notification.

If you do use `onError`:
```tsx
onError: (err) => {
  // err is the rejected response.data from the interceptor
  // showNotificationError already called globally — only add component-level UI here
}
```
