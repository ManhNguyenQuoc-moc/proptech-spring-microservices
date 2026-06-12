# Skill: Custom Hooks

## Scope

Creating or modifying hooks in `src/@core/hooks/`.

---

## Before Writing

```
semantic_search_nodes("useSWT")   # find existing hooks before creating a new one
query_graph(pattern="callers_of", node="@core/hooks::useSWTMutation")  # check usage patterns
```

---

## Existing Hooks

| Hook | File | Purpose |
|------|------|---------|
| `useSWTMutation` | `useSWTMutation.tsx` | Wraps any async mutation with `isLoading`, `isInitLoading`, `data`, `input` |
| `useSWTInitLoading` | `useSWTInitLoading.ts` | Returns `true` only on the first load, `false` after |
| `useSWTRouter` | `useSWTRouter.tsx` | Wraps `useNavigate` from react-router-dom |
| `useSWTTitle` | `useSWTTitle.tsx` | Sets `document.title` via `useEffect` |

---

## useSWTMutation — Primary Mutation Hook

Use this hook for ALL create/update/delete operations. Do NOT manage loading state manually.

```tsx
const { mutation, isLoading, isInitLoading, data, input } = useSWTMutation<OutputType, InputType>({
  mutationFn: (input) => administrationService.myService.createAsync(input),
  onSuccess: (res) => {
    if (res) {
      showNotificationSuccess("Tạo thành công.");
    }
  },
  onError: (err) => {
    // optional — global interceptor already shows notification for HTTP errors
  },
});

// Invoke:
mutation({ name: "value" } as InputType);
```

**Return values:**
- `mutation(input)` — triggers the async call
- `isLoading` — true while pending
- `isInitLoading` — true only on the very first call (useful for full-page skeletons)
- `data` — last successful response
- `input` — last input passed to `mutation()`

---

## useSWTInitLoading — First-Load Skeleton

```tsx
// In a component that receives isLoading from Redux:
const isInitialLoad = useSWTInitLoading(isLoading);

return (
  <SWTRenderIf condition={isInitialLoad}>
    <SWTSkeleton />
  </SWTRenderIf>
);
```

---

## useSWTRouter — Navigation

```tsx
const { navigate } = useSWTRouter();

navigate("/administration/employee");
navigate(-1); // go back
```

Never call `window.location.href` inside a component — always use `useSWTRouter`. The exception is auth redirects in `@core/http/index.ts` (interceptor context, no React).

---

## useSWTTitle — Page Title

```tsx
const EmployeePage = () => {
  useSWTTitle("Danh sách nhân viên");
  return <EmployeeList />;
};
```

Call at the top of the `index.tsx` feature component. Not in sub-components.

---

## Creating a New Hook

File name: `useSWT{PascalName}.ts` or `.tsx` (use `.tsx` if it returns JSX or uses JSX inside).

Template:
```ts
import { useState, useEffect } from "react";

type UseSWT{Name}Props = {
  // input shape
};

const useSWT{Name} = ({ ... }: UseSWT{Name}Props) => {
  const [value, setValue] = useState<ValueType>(initial);

  useEffect(() => {
    // side effect
    return () => {
      // cleanup
    };
  }, []);

  return { value };
};

export default useSWT{Name};
```

**Rules:**
- Export default.
- Props shape typed with local type — not `any`.
- Cleanup all subscriptions/timers in `useEffect` return.
- No direct `window.location.href` — use `useSWTRouter` if navigation needed.
