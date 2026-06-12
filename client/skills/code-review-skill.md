# Skill: Code Review

## Scope

Reviewing PRs and local diffs in this codebase using graph-powered analysis.

---

## Review Workflow

Always use graph tools before reading files:

```
1. detect_changes()                          # risk-scored diff analysis
2. get_affected_flows(changed_file)          # execution paths impacted
3. get_impact_radius(changed_node)           # blast radius — callers affected
4. get_review_context(nodes)                 # fetch source snippets for flagged nodes
5. query_graph(pattern="tests_for", ...)     # check if tests exist for changed code
```

---

## Review Checklist

### Architecture
- [ ] Imports respect layer direction: `pages → store → services → @core/http`
- [ ] No service imports from pages or store
- [ ] No React hooks in service files
- [ ] New AntD primitives are wrapped in SWT components
- [ ] New features have their own service/slice folder — not sharing with other domains

### Naming
- [ ] Components have `SWT` prefix
- [ ] Hooks have `useSWT` prefix
- [ ] Service methods have `Async` suffix
- [ ] Input interfaces use `*InputDto` suffix
- [ ] Output interfaces use `*OutputDto` suffix
- [ ] Slice state type is `*State`, init constant is `initState`
- [ ] Thunk actions exported as `*Actions` object

### API/HTTP
- [ ] Imports `http` from `@/src/@core/http`, not axios directly
- [ ] Destructures `const { data } = await http.method(...)` and returns `data.data`
- [ ] Response typed as `ApiResult<T>` generic
- [ ] No try/catch in service functions (interceptor handles globally)
- [ ] Params arrays handled via `{ params }` with qs serializer (not manual encoding)

### State
- [ ] List state uses `ResponseDataWithInput<TInput, TData>` shape
- [ ] Uses `useAppDispatch` / `useAppSelector` (not raw)
- [ ] Mutations use `useSWTMutation`, not `useState` + async call
- [ ] No derived data stored in slice state

### Forms
- [ ] All validation rules from `@core/utils/rules.ts` — no inline messages
- [ ] `convert.trimStringsInObject()` called before `mutation()`
- [ ] Uses `SWTForm` + `SWTFormItem` — not raw AntD `Form.Item`

### Routing
- [ ] New routes use `@loadable/component` for lazy loading
- [ ] Navigation uses `useSWTRouter`, not `window.location.href`
- [ ] Protected routes added to `navItems`, public routes to `authItems`

### Notifications
- [ ] HTTP error notifications come from interceptor, not component
- [ ] Success notifications use `showNotificationSuccess` or `SWTNotificationSuccess`
- [ ] No direct `antd` `message.error()` / `notification.error()` calls

### TypeScript
- [ ] No `any` in DTOs — use explicit types or `Record<string, unknown>`
- [ ] No missing generics on `ApiResult<T>`, `PagedResultDto<T>`, `ResponseDataWithInput<,>`

---

## Risk Flags

Automatically flag these as high-risk:

1. **Changes to `@core/http/index.ts`** — affects all API calls app-wide
2. **Changes to `store/index.ts`** — affects Redux store shape
3. **Changes to `@core/provider/sidebar-provider/`** — breaks sidebar state everywhere
4. **Changes to `@core/utils/message.ts`** — breaks all notifications
5. **Changes to `@core/http/routes/items.tsx`** — may break navigation

For any of these, always run `get_impact_radius` before approving.

---

## Common Issues to Flag

- Missing `export const` on service object (only default export, no named export)
- `initState` not in a separate `index.state.ts` file
- `serviceName` constant not defined before thunk — string hardcoded instead
- `AdminLayout` manually wrapped around a page component (it's already in `AppRoutes`)
- `@loadable/component` not used for a new page import in `items.tsx`
- `SWTTable` used without `rowKey` — defaults to `"id"`, confirm the data has that field
