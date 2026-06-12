# Skill: Redux Store

## Scope

Creating or modifying Redux slices and async thunks in `src/store/`.

---

## Before Writing

```
semantic_search_nodes("[Domain]Slice")   # check if slice already exists
query_graph(pattern="callers_of", node="store/[service]/[domain]/index::employeeActions")
```

---

## When to Use Redux vs useSWTMutation

| Pattern | Use case |
|---------|----------|
| Redux `createAsyncThunk` | Paginated lists, data that persists across navigation, shared state between components |
| `useSWTMutation` | Create, update, delete — short-lived, component-scoped |

---

## File Structure

```
src/store/{service-name}/{domain}/
├── index.ts           # createAsyncThunk + createSlice + actions export
└── index.state.ts     # State type + initState
```

---

## index.state.ts Pattern

```ts
import { DEFAULT_PAGE, DEFAULT_PAGE_SIZE } from "@/src/@core/const";
import { type ResponseDataWithInput } from "@/src/@core/http/models/ResponseTypeDto";
import { type Get{Domain}ListInputDto } from "@/src/services/{service}/{domain}/models/input.model";
import { type Paged{Domain}OutputDto } from "@/src/services/{service}/{domain}/models/output.model";

export declare type {Domain}State = {
  {domain}List: ResponseDataWithInput<Get{Domain}ListInputDto, Paged{Domain}OutputDto>;
};

export const initState: {Domain}State = {
  {domain}List: {
    isLoading: false,
    data: {} as Paged{Domain}OutputDto,
    input: {
      page: DEFAULT_PAGE,
      fetch: DEFAULT_PAGE_SIZE,
      keyword: "",
    },
  },
};
```

---

## index.ts Pattern

```ts
import { {serviceName}Service } from "@/src/services/{service-name}/{service-name}.service";
import { createAsyncThunk, createSlice } from "@reduxjs/toolkit";
import { initState } from "./index.state";
import { type Get{Domain}ListInputDto } from "@/src/services/{service-name}/{domain}/models/input.model";

const serviceName = "{service-name}";

const get{Domain}List = createAsyncThunk(
  `/${serviceName}/{domain}/get{Domain}List`,
  async (params: Get{Domain}ListInputDto) => {
    const data = await {serviceName}Service.{domain}Service.getListAsync(params);
    return { data, input: params };
  },
);

export const {domain}Slice = createSlice({
  name: `${serviceName}/{domain}`,
  initialState: initState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(get{Domain}List.pending, (state) => {
        state.{domain}List.isLoading = true;
      })
      .addCase(get{Domain}List.fulfilled, (state, action) => {
        state.{domain}List.isLoading = false;
        state.{domain}List.data = action.payload.data;
        state.{domain}List.input = action.payload.input;
      })
      .addCase(get{Domain}List.rejected, (state) => {
        state.{domain}List.isLoading = false;
      });
  },
});

export default {domain}Slice.reducer;

export const {domain}Actions = {
  get{Domain}List,
};
```

---

## Service-level Registry (index.ts)

`src/store/{service-name}/index.ts`:
```ts
import {domain}Slice, { {domain}Actions } from "./{domain}";

export const {serviceName}Slice = {
  {domain}: {domain}Slice,
};

export const {serviceName}Store = {
  {domain}: {domain}Actions,
};
```

---

## Root Store Registration

`src/store/index.ts` — add new slice to `reducer`:
```ts
import { {serviceName}Slice } from "./{service-name}";

export const store = configureStore({
  reducer: {
    administrationServiceEmployee: administrationServiceSlice.employee,
    {serviceName}{Domain}: {serviceName}Slice.{domain}, // add here
  }
});
```

Update `RootState` type automatically via `ReturnType<typeof store.getState>`.

---

## Usage in Components

```tsx
import { useAppDispatch, useAppSelector } from "@/src/store/hook";
import { administrationServiceStore } from "@/src/store/administration-service";

const dispatch = useAppDispatch();
const { data, isLoading, input } = useAppSelector(
  (state) => state.administrationServiceEmployee.employeeList
);

// Trigger:
dispatch(administrationServiceStore.employee.getEmployeeList({ page: 1, fetch: 10 }));
```

---

## Thunk Naming Convention

Thunk action type: `/{serviceName}/{domain}/{actionName}` (matches the string passed to `createAsyncThunk`).

Example: `"/administration-service/employee/getEmployeeList"`

---

## State Shape Rules

- List state always uses `ResponseDataWithInput<TInput, TData>`.
- Single-item detail state uses `ResponseData<TData>`.
- `input` caches the last dispatched params — useful for re-fetching after mutations.
- Never store derived data in the slice — compute it in selectors or components.
