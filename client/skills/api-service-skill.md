# Skill: API Service

## Scope

Creating or modifying service files in `src/services/` and the shared HTTP models in `src/@core/http/models/`.

---

## Before Writing

```
semantic_search_nodes("[Domain]Service")   # check if service already exists
query_graph(pattern="callers_of", node="[service]::methodAsync")  # find all call sites before changing signature
```

---

## Service File Structure

Location: `src/services/{service-name}/{domain}/{domain}.service.ts`

```ts
import http from "@/src/@core/http";
import { type {Input}InputDto } from "./models/input.model";
import { type {Output}OutputDto } from "./models/output.model";
import { type ApiResult } from "@/src/@core/http/models/ApiResult";
import { rootPath } from "../{service-name}.service";

const path = "/{resource}";

const getListAsync = async (params: Get{Domain}ListInputDto) => {
  const { data } = await http.get<ApiResult<Paged{Domain}OutputDto>>(`${rootPath}${path}`, { params });
  return data.data;
};

const getByIdAsync = async (id: string) => {
  const { data } = await http.get<ApiResult<{Domain}OutputDto>>(`${rootPath}${path}/${id}`);
  return data.data;
};

const createAsync = async (body: Create{Domain}InputDto) => {
  const { data } = await http.post<ApiResult<{Domain}OutputDto>>(`${rootPath}${path}`, body);
  return data.data;
};

const updateAsync = async (id: string, body: Update{Domain}InputDto) => {
  const { data } = await http.put<ApiResult<{Domain}OutputDto>>(`${rootPath}${path}/${id}`, body);
  return data.data;
};

const deleteAsync = async (id: string) => {
  const { data } = await http.delete<ApiResult<boolean>>(`${rootPath}${path}/${id}`);
  return data.data;
};

export const {domain}Service = {
  getListAsync,
  getByIdAsync,
  createAsync,
  updateAsync,
  deleteAsync,
};
```

---

## Service Registry

After creating a service, register it in `src/services/{service-name}/{service-name}.service.ts`:

```ts
import { {domain}Service } from "./{domain}/{domain}.service";

export const rootPath: string = get.rootPath("/{service-name}/api");

export const {serviceName}Service = {
  ...,
  {domain}Service,
};
```

---

## Input Model Pattern

Location: `src/services/{service-name}/{domain}/models/input.model.ts`

```ts
import { type PaginationWithSearchRequestDto } from "@/src/@core/http/models/PaginationWithSearchRequestDto";

export interface Get{Domain}ListInputDto extends PaginationWithSearchRequestDto {
  isActive?: boolean;
  // additional filters
}

export interface Create{Domain}InputDto {
  name: string;
  // required fields — no optional unless truly optional in the API contract
}

export interface Update{Domain}InputDto {
  name?: string;
  // partial update shape
}
```

---

## Output Model Pattern

Location: `src/services/{service-name}/{domain}/models/output.model.ts`

```ts
import { type PagedResultDto } from "@/src/@core/http/models/PagedResultDto";

export interface {Domain}OutputDto {
  id: string;
  name: string;
  isActive: boolean;
  // mirror the API response shape — no transformation here
}

export interface Paged{Domain}OutputDto extends PagedResultDto<{Domain}OutputDto> {
  extendData?: Record<string, any>;
}
```

---

## Shared Models (do not duplicate)

| Model | Location | Use |
|-------|----------|-----|
| `ApiResult<T>` | `@core/http/models/ApiResult` | All response wrappers |
| `PagedResultDto<T>` | `@core/http/models/PagedResultDto` | Paginated lists |
| `PaginationRequestDto` | `@core/http/models/PaginationWithSearchRequestDto` | `page` + `fetch` |
| `PaginationWithSearchRequestDto` | same | + `keyword` |
| `ResponseData<T>` | `@core/http/models/ResponseTypeDto` | Slice state (no input) |
| `ResponseDataWithInput<TIn, TData>` | same | Slice state (with input cache) |

---

## HTTP Rules

- Always import `http` from `@/src/@core/http` — never import axios directly.
- Always destructure `const { data } = await http.method(...)` — never access `response.data.data` inline.
- Params with arrays: pass via `{ params }` — qs serializer handles encoding.
- Never add error handling in service functions — the axios interceptor handles it globally.
- Return type inference: let TypeScript infer from `data.data` — no explicit return type annotation needed on simple getters.
