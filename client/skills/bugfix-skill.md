# Skill: Bug Fix

## Scope

Diagnosing and fixing bugs in this codebase.

---

## Diagnosis Workflow

Use graph tools before reading files:

```
1. semantic_search_nodes("[symptom keyword]")     # locate relevant code
2. query_graph(pattern="callers_of", node="...")  # find what calls the broken function
3. get_affected_flows(file)                       # understand execution path
4. get_impact_radius(node)                        # measure blast radius of a fix
5. get_review_context([nodes])                    # read source of affected nodes
```

---

## Common Bug Categories

### 401 loop / token refresh

Symptom: Infinite 401 errors, user never redirected to login.

Check `@core/http/index.ts`:
- `isRefreshing` flag: prevents multiple concurrent refresh calls.
- `refreshPromise`: must be reset to `null` after resolution.
- After refresh, sets new tokens with `setCookie(ACCESS_TOKEN_KEY, ...)`.
- Current implementation has `refreshTokenAsync()` commented out — if 401 handling is needed, uncomment and implement.

### Notification not showing

Check:
1. `useMessageInit()` called inside `MessageInitializer` (in `App.tsx`). If `showNotificationError` is called before this initializes, it will silently fail.
2. `App` wrapper from `antd` must be the parent of any component calling `App.useApp()`.
3. The `notification` variable in `message.ts` is module-level — it's set once via `setMessageInstance`. If `showNotificationError` is called before `setMessageInstance`, it's undefined.

### Form not submitting

Check:
1. `SWTForm` must receive `form={form}` from `Form.useForm()`.
2. `SWTButton` must have `htmlType="submit"` — not `onClick`.
3. `onFinish` handler on `SWTForm` receives the validated values — not `onSubmit` on the button.
4. Validation errors prevent `onFinish` from firing — check form field `rules`.

### Redux state not updating

Check:
1. `useAppSelector` selector path matches the key in `configureStore` reducer map.
2. Thunk dispatched correctly: `dispatch(store.actions.getList(params))`.
3. `extraReducers` has all three cases: `.pending`, `.fulfilled`, `.rejected`.
4. `createSlice` name string is unique across all slices.

### Pagination not working

Check:
1. `SWTTable` receives `pagination` prop with `{ totalCount, page, fetch, onChange }`.
2. `onChange` dispatches the new `page`/`fetch` with the rest of `input` preserved via spread: `{ ...input, page, fetch }`.
3. `SWTRenderIf condition={pagination != null && pagination != undefined}` wrapping `SWTPagination` — confirm prop is passed.

### Cookie not set after login

Check `SignInForm.tsx`:
1. `setCookie(ACCESS_TOKEN_KEY, res.accessToken)` — confirm `setCookie` encodes properly.
2. Cookie path is `/` — accessible from all routes.
3. No `days` param means session cookie (cleared on browser close) — if persistence needed, pass `days`.
4. Check `VITE_TENANTS` env var is set and `localStorage.setItem(TENANT_KEY, value)` runs on tenant select.

### Sidebar state lost on navigation

`useSidebar()` reads from `SidebarProvider` context. If a component calls `useSidebar()` outside a `SidebarProvider`, it throws: _"useSidebar must be used within a SidebarProvider"_. Check that `AdminLayout` → `AppSidebar` → component chain is within the provider tree.

---

## Fix Pattern

1. Isolate the bug to the smallest possible scope.
2. Check graph for callers before changing a shared utility.
3. Apply fix only where needed — don't refactor surrounding code.
4. Run `get_impact_radius` after writing the fix to confirm no unintended breakage.
5. No new comments explaining the fix — commit message carries the context.
