# Skill: Anti-Patterns

## Scope

Patterns explicitly avoided in this codebase. Enforce these during code review and code generation.

---

## Component Anti-Patterns

### Using AntD primitives directly in pages
```tsx
// FORBIDDEN
import { Button } from "antd";
<Button type="primary">Click</Button>

// CORRECT
import SWTButton from "@/src/@core/component/AntD/SWTButton";
<SWTButton variant="primary">Click</SWTButton>
```

### Inline ternary returning null
```tsx
// FORBIDDEN
{list.length > 0 ? <SWTTable ... /> : null}

// CORRECT
<SWTRenderIf condition={list.length > 0}>
  <SWTTable ... />
</SWTRenderIf>
```

### Inline icon SVG in component files
```tsx
// FORBIDDEN
<svg width="24" height="24"><path ... /></svg>

// CORRECT — create a file in @core/component/SWTIcon/iconoir/ and import it
<SWTSearchEngineIcon width={24} height={24} />
```

---

## HTTP Anti-Patterns

### Importing axios directly in service files
```ts
// FORBIDDEN
import axios from "axios";
const response = await axios.get(...);

// CORRECT
import http from "@/src/@core/http";
const { data } = await http.get<ApiResult<T>>(url);
```

### Accessing nested response without destructuring
```ts
// FORBIDDEN
const response = await http.get(...);
return response.data.data;

// CORRECT
const { data } = await http.get<ApiResult<T>>(url);
return data.data;
```

### Error handling inside service functions
```ts
// FORBIDDEN — interceptor already handles it globally
const getListAsync = async (params) => {
  try {
    const { data } = await http.get(...);
    return data.data;
  } catch (error) {
    showNotificationError("...");
    return null;
  }
};

// CORRECT — no try/catch in service functions
const getListAsync = async (params) => {
  const { data } = await http.get<ApiResult<T>>(url, { params });
  return data.data;
};
```

---

## State Management Anti-Patterns

### Raw useDispatch / useSelector
```ts
// FORBIDDEN
import { useDispatch, useSelector } from "react-redux";
const dispatch = useDispatch();

// CORRECT
import { useAppDispatch, useAppSelector } from "@/src/store/hook";
const dispatch = useAppDispatch();
```

### Local useState for async list data
```ts
// FORBIDDEN
const [employees, setEmployees] = useState([]);
useEffect(() => {
  employeeService.getListAsync(...).then(setEmployees);
}, []);

// CORRECT — use Redux slice for list data
const { data, isLoading } = useAppSelector((s) => s.administrationServiceEmployee.employeeList);
dispatch(administrationServiceStore.employee.getEmployeeList(...));
```

### Redux for mutation loading state
```ts
// FORBIDDEN — managing mutation loading in a slice
.addCase(createEmployee.pending, (state) => { state.createLoading = true; })

// CORRECT — use useSWTMutation which manages its own loading state
const { mutation, isLoading } = useSWTMutation({ mutationFn: createAsync, ... });
```

### Derived data in slice state
```ts
// FORBIDDEN — computing in the slice
.addCase(getList.fulfilled, (state, action) => {
  state.employeeCount = action.payload.data.totalCount;  // derived
  state.activeEmployees = action.payload.data.items.filter(e => e.isActive);  // derived
})

// CORRECT — compute in component or selector
const activeEmployees = data?.items.filter(e => e.isActive) ?? [];
```

---

## Routing Anti-Patterns

### window.location.href in components
```ts
// FORBIDDEN inside React components
window.location.href = "/administration/employee";

// CORRECT
const { navigate } = useSWTRouter();
navigate("/administration/employee");
```

### React.lazy instead of @loadable/component
```ts
// FORBIDDEN
const Page = React.lazy(() => import("..."));

// CORRECT
import loadable from "@loadable/component";
const Page = loadable(() => import("..."));
```

---

## Form Anti-Patterns

### Inline validation messages
```tsx
// FORBIDDEN
rules={[{ required: true, message: "Không được để trống" }]}

// CORRECT
rules={[rules.required]}
```

### Missing trimStringsInObject before submit
```ts
// FORBIDDEN
const onSubmit = (values: any) => {
  mutation(values);
};

// CORRECT
const onSubmit = (values: any) => {
  mutation(convert.trimStringsInObject(values) as InputDto);
};
```

---

## Typing Anti-Patterns

### any in DTO interfaces
```ts
// FORBIDDEN
export interface EmployeeOutputDto {
  metadata: any;
}

// CORRECT
export interface EmployeeOutputDto {
  metadata: Record<string, unknown>;
}
```

### Missing generic on ApiResult
```ts
// FORBIDDEN
const { data } = await http.get(`${rootPath}${path}`);

// CORRECT
const { data } = await http.get<ApiResult<OutputDto>>(`${rootPath}${path}`);
```

---

## Notification Anti-Patterns

### Direct AntD message/notification calls
```ts
// FORBIDDEN
import { message } from "antd";
message.error("...");

// CORRECT
import { showNotificationError } from "@/src/@core/utils/message";
showNotificationError("...");
// or
import { SWTNotificationError } from "@/src/@core/component/SWTNotification";
SWTNotificationError("Title", "Description");
```
