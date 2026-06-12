# Skill: Form & Validation

## Scope

Building forms with AntD `Form` + SWT wrappers, validation rules, and the `SWTFilter` debounce pattern.

---

## Standard Form Pattern

```tsx
import { Form } from "antd";
import SWTForm from "@/src/@core/component/AntD/SWTForm";
import SWTFormItem from "@/src/@core/component/AntD/SWTFormItem";
import SWTInput from "@/src/@core/component/AntD/SWTInput";
import SWTButton from "@/src/@core/component/AntD/SWTButton";
import { rules } from "@/src/@core/utils/rules";
import { convert } from "@/src/@core/utils/convert";
import useSWTMutation from "@/src/@core/hooks/useSWTMutation";
import { showNotificationSuccess } from "@/src/@core/utils/message";

const {Domain}Form = () => {
  const [form] = Form.useForm();

  const { mutation, isLoading } = useSWTMutation<OutputDto, InputDto>({
    mutationFn: (input) => administrationService.{domain}Service.createAsync(input),
    onSuccess: () => {
      showNotificationSuccess("Tạo thành công.");
      form.resetFields();
    },
  });

  const onSubmit = (values: any) => {
    mutation(convert.trimStringsInObject(values) as InputDto);
  };

  return (
    <SWTForm form={form} onFinish={onSubmit}>
      <SWTFormItem label="Tên" name="name" rules={[rules.required]}>
        <SWTInput label="Tên" />
      </SWTFormItem>
      <SWTButton htmlType="submit" loading={isLoading}>
        Lưu
      </SWTButton>
    </SWTForm>
  );
};
```

---

## Rules

Validation rules live in `src/@core/utils/rules.ts`. Extend there — never inline rules:

```ts
// rules.ts — add new rules here
const required = { required: true, message: "Thông tin không được để trống" };
const email = { type: "email" as const, message: "Email không hợp lệ" };
const maxLength = (max: number) => ({ max, message: `Tối đa ${max} ký tự` });

export const rules = {
  required,
  email,
  maxLength,
};
```

Usage:
```tsx
<SWTFormItem rules={[rules.required, rules.email]}>
  <SWTInput label="Email" />
</SWTFormItem>
```

---

## Convert Before Submit

Always call `convert.trimStringsInObject()` on raw form values before passing to a mutation. This:
- Trims whitespace from string values recursively
- Converts `dayjs` objects to ISO strings
- Handles nested objects and arrays

```ts
const onSubmit = (values: any) => {
  mutation(convert.trimStringsInObject(values) as CreateInputDto);
};
```

---

## Filter Form Pattern (SWTFilter)

For search/filter bars, use `SWTFilter` which debounces `onChange` by 300ms:

```tsx
import SWTFilter, { type FilterProps } from "@/src/@core/component/SWTFilter";

const filterItems: FilterProps[] = [
  {
    key: "keyword",
    title: "Tìm kiếm",
    type: "input",
    allowClear: true,
  },
  {
    key: "isActive",
    title: "Trạng thái",
    type: "select",
    options: [
      { label: "Hoạt động", value: "true" },
      { label: "Ngừng hoạt động", value: "false" },
    ],
  },
];

const handleFilterChange = (allValues: any, changedValues: any) => {
  dispatch(actions.getList({ ...currentInput, ...allValues, page: 1 }));
};

<SWTFilter
  filterItems={filterItems}
  onChange={handleFilterChange}
  defaultValues={{ page: 1, fetch: 10 }}
/>
```

---

## Password Toggle Pattern

```tsx
const [showPassword, setShowPassword] = useState(false);

<SWTFormItem label="Mật khẩu" name="password" rules={[rules.required]}>
  <SWTInput
    label="Mật khẩu"
    type={showPassword ? "text" : "password"}
    suffix={
      showPassword
        ? <SWTEyeIcon width={20} height={20} onClick={() => setShowPassword(false)} variant="primary" />
        : <SWTEyeClosedIcon width={20} height={20} onClick={() => setShowPassword(true)} variant="primary" />
    }
  />
</SWTFormItem>
```

---

## Form Reset & Pre-fill

```tsx
// Reset
form.resetFields();

// Pre-fill (edit mode)
useEffect(() => {
  if (initialData) {
    form.setFieldsValue(initialData);
  }
}, [initialData]);
```

---

## AntD Form Component Map

| Field type | Component |
|-----------|-----------|
| Text | `SWTInput` |
| Password | `SWTInput` with `type="password"` + eye toggle |
| Textarea | `SWTInputTextArea` |
| Number | `SWTInputNumber` |
| Select | `SWTSelect` |
| Date | `SWTDatePicker` |
| Date range | `SWTDatePickerRange` |
| Checkbox | `SWTCheckbox` |
| Checkbox group | `SWTCheckboxGroup` |
| Time | `SWTTimePicker` |
| File | `SWTUpload` |
