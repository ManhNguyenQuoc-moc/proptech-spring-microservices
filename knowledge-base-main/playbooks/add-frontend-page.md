# Playbook: Add a New Frontend Page (Admin Web App or Web App)

> Load the relevant skill file first: `swt-cmn-administration-web-app/skills/feature-module-skill.md`

This playbook covers adding a complete feature page with list view, including service, store slice, and UI.

---

## Step 1: Create the Service

Location: `src/services/{feature}/widget.service.ts`

```typescript
import http from '@core/http';
import { ApiResult } from '@core/type';
import type { GetWidgetListInputDto, WidgetOutputDto, CreateWidgetInputDto } from './output.model';

export const getWidgetListAsync = async (params: GetWidgetListInputDto): Promise<PagedResultWidgetOutputDto> => {
  const { data } = await http.get<ApiResult<PagedResultWidgetOutputDto>>(
    '/cmn/administration-service/api/widgets',
    { params }
  );
  return data.data;
};

export const createWidgetAsync = async (input: CreateWidgetInputDto): Promise<WidgetOutputDto> => {
  const { data } = await http.post<ApiResult<WidgetOutputDto>>(
    '/cmn/administration-service/api/widgets',
    input
  );
  return data.data;
};
```

**Rules**:
- Never import `axios` directly.
- Always return `data.data` (unwrap the `ApiResult` envelope).
- Named exports only (no default export).
- Suffix all methods with `Async`.

---

## Step 2: Create DTO Models

`src/services/{feature}/input.model.ts`:
```typescript
export interface GetWidgetListInputDto {
  page?: number;
  pageSize?: number;
  keyword?: string;
}

export interface CreateWidgetInputDto {
  name: string;
  description?: string;
}
```

`src/services/{feature}/output.model.ts`:
```typescript
export interface WidgetOutputDto {
  id: string;
  name: string;
  description?: string;
}

export interface PagedResultWidgetOutputDto {
  items: WidgetOutputDto[];
  totalCount: number;
}
```

---

## Step 3: Create Redux Slice (for list/pagination state)

`src/store/{feature}/index.state.ts`:
```typescript
import type { ResponseDataWithInput } from '@core/type';
import type { GetWidgetListInputDto, PagedResultWidgetOutputDto } from '@/services/widget';

export interface WidgetState {
  list: ResponseDataWithInput<GetWidgetListInputDto, PagedResultWidgetOutputDto>;
}

export const initState: WidgetState = {
  list: {
    data: { items: [], totalCount: 0 },
    input: { page: 1, pageSize: 10 },
    loading: false,
  }
};
```

`src/store/{feature}/index.slice.ts`:
```typescript
import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import type { WidgetState } from './index.state';
import { initState } from './index.state';
import { getWidgetListAsync } from '@/services/widget';
import type { GetWidgetListInputDto } from '@/services/widget';

const getWidgetList = createAsyncThunk(
  'widget/getList',
  async (input: GetWidgetListInputDto) => {
    return { input, data: await getWidgetListAsync(input) };
  }
);

const widgetSlice = createSlice({
  name: 'widget',
  initialState: initState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(getWidgetList.pending, (state) => {
        state.list.loading = true;
      })
      .addCase(getWidgetList.fulfilled, (state, { payload }) => {
        state.list.loading = false;
        state.list.input = payload.input;
        state.list.data = payload.data;
      })
      .addCase(getWidgetList.rejected, (state) => {
        state.list.loading = false;
      });
  }
});

export const widgetActions = { getWidgetList };
export default widgetSlice.reducer;
```

---

## Step 4: Create the Page Component

`src/pages/(protected)/widgets/list/index.tsx`:
```tsx
import { memo, useEffect } from 'react';
import { useAppDispatch, useAppSelector } from '@/store/hook';
import { widgetActions } from '@/store/widget';
import SWTTable from '@core/component/AntD/SWTTable';
import SWTRenderIf from '@core/component/SWTRenderIf';
import type { WidgetOutputDto } from '@/services/widget';

const WidgetListPage = memo(() => {
  const dispatch = useAppDispatch();
  const { list } = useAppSelector(state => state.widget);

  useEffect(() => {
    dispatch(widgetActions.getWidgetList({ page: 1, pageSize: 10 }));
  }, [dispatch]);

  const columns = [
    { title: 'Tên', dataIndex: 'name', key: 'name' },
    { title: 'Mô tả', dataIndex: 'description', key: 'description' },
  ];

  return (
    <div>
      <SWTTable<WidgetOutputDto>
        loading={list.loading}
        dataSource={list.data.items}
        columns={columns}
        rowKey="id"
        pagination={{ total: list.data.totalCount }}
      />
    </div>
  );
});

export default WidgetListPage;
```

---

## Step 5: Register Route

Add to the router configuration in `src/@core/models/routes/`:
```typescript
{ path: '/administration/widgets', element: <WidgetListPage /> }
```

Add to the sidebar navigation in `src/layouts/AppSideBar.tsx`.

---

## Step 6: For Mutations (Create/Update/Delete)

Use `useSWTMutation` hook (not Redux) for short-lived async operations:

```tsx
const { mutate, loading } = useSWTMutation(createWidgetAsync, {
  onSuccess: () => {
    showNotificationSuccess('Tạo thành công!');
    dispatch(widgetActions.getWidgetList({ page: 1, pageSize: 10 }));
  }
});
```

---

## Step 7: Update Knowledge Base

- Add page to `services/[webapp].md` under Pages (anchor: `[webapp]-pages`).
- Add CHANGELOG entry.
