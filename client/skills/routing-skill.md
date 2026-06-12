# Skill: Routing

## Scope

Adding or modifying routes in `src/@core/http/routes/`.

---

## Route Architecture

```
src/@core/http/routes/
├── index.tsx     # AppRoutes component — renders <Routes>
└── items.tsx     # Route config arrays: navItems, authItems
```

All routes nest under base path `/administration`.

---

## Route Config Shape

`items.tsx` exports two arrays:

```tsx
export type AppNavItems = {
  navItems?: {
    subItems?: {
      path: string;
      element: React.ReactNode;
    }[];
  }[];
};

export const navItems: AppNavItems[] = [...];   // protected routes
export const authItems: AppNavItems[] = [...];  // public auth routes
```

---

## Adding a Protected Route

In `src/@core/http/routes/items.tsx`, add to `navItems`:

```tsx
import loadable from "@loadable/component";

const {Domain}ListPage = loadable(
  () => import("@/src/pages/(protected)/{domain}/list")
);

export const navItems: AppNavItems[] = [
  {
    navItems: [
      {
        subItems: [
          {
            path: "/administration/{domain}/list",
            element: <{Domain}ListPage />,
          },
          {
            path: "/administration/{domain}/create",
            element: <{Domain}CreatePage />,
          },
        ],
      },
    ],
  },
];
```

---

## Adding an Auth Route

In `authItems`:
```tsx
export const authItems: AppNavItems[] = [
  {
    navItems: [
      {
        subItems: [
          {
            path: "/administration/signin",
            element: <SignIn />,
          },
        ],
      },
    ],
  },
];
```

---

## Lazy Loading

All page imports MUST use `@loadable/component`. Never use `React.lazy` — the project uses `@loadable/component` exclusively.

```tsx
import loadable from "@loadable/component";

const FeaturePage = loadable(() => import("@/src/pages/(protected)/feature/list"));
```

---

## AdminLayout Nesting

Protected routes are automatically wrapped by `AdminLayout` (sidebar + header):

```tsx
// AppRoutes — already configured this way
<Route path={baseUrl} element={<AdminLayout />}>
  {renderRoutes(navItems)}
</Route>
```

Do not wrap page components in `AdminLayout` manually.

---

## Navigation in Components

```tsx
// Correct
const { navigate } = useSWTRouter();
navigate("/administration/employee");

// Forbidden
window.location.href = "/administration/employee";
```

Exception: `@core/http/index.ts` interceptor can use `window.location.href` (no React context available there).

---

## Route Naming Convention

| Pattern | Example |
|---------|---------|
| List | `/administration/{domain}/list` |
| Create | `/administration/{domain}/create` |
| Edit | `/administration/{domain}/:id/edit` |
| Detail | `/administration/{domain}/:id` |
