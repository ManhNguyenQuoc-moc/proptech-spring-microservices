# Skill: Unit Testing

## Scope

Writing tests for this codebase. No test infrastructure exists yet — this skill scaffolds from scratch.

---

## Current State

No test files exist. No Jest, Vitest, Cypress, or Playwright config is present. When writing tests for the first time, bootstrap the framework first.

---

## Recommended Framework: Vitest + React Testing Library

Vitest integrates natively with Vite (the existing bundler) with zero config overhead.

### Install

```bash
npm install -D vitest @vitest/ui jsdom @testing-library/react @testing-library/user-event @testing-library/jest-dom
```

### vite.config.ts — add test config

```ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: ["./src/test-setup.ts"],
  },
});
```

### src/test-setup.ts

```ts
import "@testing-library/jest-dom";
```

### package.json — add script

```json
"scripts": {
  "test": "vitest",
  "test:ui": "vitest --ui"
}
```

---

## Test File Naming

Co-locate tests next to the file under test:

```
src/@core/utils/convert.ts
src/@core/utils/convert.test.ts

src/@core/hooks/useSWTMutation.tsx
src/@core/hooks/useSWTMutation.test.tsx
```

---

## Pure Utility Tests

No mocking needed for `@core/utils/`:

```ts
// convert.test.ts
import { describe, it, expect } from "vitest";
import { convert } from "./convert";

describe("trimStringsInObject", () => {
  it("trims string values", () => {
    expect(convert.trimStringsInObject({ name: "  John  " })).toEqual({ name: "John" });
  });

  it("handles nested objects", () => {
    expect(convert.trimStringsInObject({ address: { city: "  HCM  " } }))
      .toEqual({ address: { city: "HCM" } });
  });
});
```

---

## Custom Hook Tests

Use `renderHook` from RTL:

```tsx
// useSWTMutation.test.tsx
import { renderHook, act } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";
import useSWTMutation from "./useSWTMutation";

describe("useSWTMutation", () => {
  it("calls onSuccess with response", async () => {
    const mockFn = vi.fn().mockResolvedValue({ id: "1" });
    const onSuccess = vi.fn();

    const { result } = renderHook(() =>
      useSWTMutation({ mutationFn: mockFn, onSuccess })
    );

    await act(async () => {
      await result.current.mutation({ name: "test" });
    });

    expect(onSuccess).toHaveBeenCalledWith({ id: "1" });
    expect(result.current.isLoading).toBe(false);
  });
});
```

---

## Service Tests

Mock the `http` axios instance:

```ts
// auth.service.test.ts
import { describe, it, expect, vi, beforeEach } from "vitest";
import http from "@/src/@core/http";
import { authService } from "./auth.service";

vi.mock("@/src/@core/http", () => ({
  default: { post: vi.fn() },
}));

describe("authService.loginAsync", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("returns data.data from ApiResult", async () => {
    const mockResponse = {
      data: { data: { accessToken: "token123", refreshToken: "refresh456" }, status: "200", error: null, statusCode: 200, message: "", systemName: "" },
    };
    vi.mocked(http.post).mockResolvedValue(mockResponse);

    const result = await authService.loginAsync({ username: "user", password: "pass" });

    expect(result?.accessToken).toBe("token123");
    expect(http.post).toHaveBeenCalledWith(expect.stringContaining("/auth"), {
      username: "user",
      password: "pass",
    });
  });
});
```

---

## Redux Slice Tests

Test reducers and async thunks:

```ts
// employee/index.test.ts
import { describe, it, expect, vi } from "vitest";
import { employeeSlice, employeeActions } from "./index";
import { configureStore } from "@reduxjs/toolkit";

vi.mock("@/src/services/administration-service/administration.service", () => ({
  administrationService: {
    employeeService: {
      getListAsync: vi.fn().mockResolvedValue({ items: [], totalCount: 0 }),
    },
  },
}));

describe("employeeSlice", () => {
  it("sets isLoading true on pending", () => {
    const store = configureStore({ reducer: { employee: employeeSlice } });
    store.dispatch(employeeActions.getEmployeeList.pending("", { page: 1, fetch: 10 }));
    expect(store.getState().employee.employeeList.isLoading).toBe(true);
  });

  it("sets data on fulfilled", async () => {
    const store = configureStore({ reducer: { employee: employeeSlice } });
    await store.dispatch(employeeActions.getEmployeeList({ page: 1, fetch: 10 }));
    expect(store.getState().employee.employeeList.isLoading).toBe(false);
  });
});
```

---

## What NOT to Test

- `SWT*` component wrappers that only pass-through AntD props — AntD tests those.
- The axios interceptor behavior (`@core/http/index.ts`) — integration-level, hard to unit test without an HTTP server.
- `window.location.href` redirects — JSDOM doesn't support navigation.
