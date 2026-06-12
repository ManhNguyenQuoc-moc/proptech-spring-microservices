# Skill: Architecture

## Scope

Architecture decisions, layer boundaries, dependency rules, and module boundaries.

---

## Layer Diagram

```
┌─────────────────────────────────────────────┐
│  src/pages/(protected)/{feature}/           │  Feature pages
│  src/layouts/                               │  Shell chrome
└────────────────┬────────────────────────────┘
                 │ imports
┌────────────────▼────────────────────────────┐
│  src/store/{service}/{domain}/              │  Redux slices + thunks
└────────────────┬────────────────────────────┘
                 │ imports
┌────────────────▼────────────────────────────┐
│  src/services/{service}/{domain}/           │  API service functions
└────────────────┬────────────────────────────┘
                 │ imports
┌────────────────▼────────────────────────────┐
│  src/@core/http/index.ts                    │  Axios instance
│  src/@core/http/models/                     │  Shared DTO interfaces
└─────────────────────────────────────────────┘

Shared (imported by all layers):
  src/@core/component/    → UI components
  src/@core/hooks/        → Custom hooks
  src/@core/utils/        → Pure functions
  src/@core/const/        → Constants
  src/@core/provider/     → React contexts
```

**Dependency direction is strictly top-down.** Services never import from pages. Slices never import from pages. Pages may import from all lower layers.

---

## Module Boundaries

| Module | Owns | Must NOT import from |
|--------|------|---------------------|
| `@core/component` | UI primitives | `pages`, `store`, `services` |
| `@core/hooks` | Shared React hooks | `pages`, `store`, `services` |
| `@core/utils` | Pure functions | anything React |
| `@core/http` | Axios + interceptors + shared models | `pages`, `store`, `services` |
| `@core/provider` | React contexts | `pages`, `store`, `services` |
| `services` | API calls | `pages`, `store` |
| `store` | Redux slices | `pages`, `layouts` |
| `pages` | Feature UI | nothing outside `src` |
| `layouts` | Shell chrome | `pages` (only via `Outlet`) |

---

## Multi-Tenancy

- Tenant is stored in `localStorage` under key `X-Tenant`.
- The HTTP interceptor reads it on every request: `config.headers[TENANT_KEY] = localStorage.getItem(TENANT_KEY) ?? ""`.
- Tenant selection happens on the sign-in form (`onChangeTenant` handler).
- No tenant-specific routing — all tenants share the same page structure.

---

## Auth Flow

```
1. User selects tenant → stored in localStorage
2. User submits credentials → loginAsync → sets accessToken + refreshToken in cookies
3. Redirect to /employee (imperative, via window.location.href — acceptable at auth boundary)
4. Subsequent requests → interceptor reads accessToken cookie → injects Authorization header
5. 401 → refreshTokenAsync → retry original request
6. Logout → removeCookie(accessToken) + removeCookie(refreshToken) + redirect /signin
```

---

## Provider Stack (App.tsx)

Order matters — inner providers can access outer ones:

```
ConfigProvider (AntD locale: viVN)
  ThemeProvider (AntD token overrides + App wrapper for message context)
    MessageInitializer (initializes message/notification instances)
      SidebarProvider (sidebar state context)
        Suspense (fallback: SWTAppLoader)
          AppRoutes (react-router Routes)
```

---

## Adding a New Service Domain

1. Create service + models under `services/administration-service/{domain}/`.
2. Register in `administration.service.ts`.
3. Create slice + state under `store/administration-service/{domain}/`.
4. Register in `store/administration-service/index.ts` and `store/index.ts`.
5. Create page components under `pages/(protected)/{domain}/`.
6. Register routes in `@core/http/routes/items.tsx`.

---

## Adding a New External Service (non-administration)

If a new backend service is added (e.g., `reporting-service`):

1. Create `services/reporting-service/reporting-service.ts` with its own `rootPath`.
2. Create `store/reporting-service/` with its own slice hierarchy.
3. Register in root `store/index.ts`.
4. Never mix `administrationService` and the new service in the same slice.

---

## Forbidden Cross-Cuts

- `@core/utils` must not import from React or `@core/component`.
- Services must not import `useDispatch`, `useSelector`, or any React hook.
- Slices must not import React components.
- Page components must not be imported by other page components (use shared `@core/component` instead).
