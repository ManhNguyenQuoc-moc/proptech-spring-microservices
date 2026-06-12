# Skill: Component

## Scope

Creating or modifying React components in this codebase. Covers:
- `@core/component/AntD/SWT*` — AntD wrapper components
- `@core/component/SWT*` — custom non-AntD components
- `pages/**/components/` — page-local components
- `layouts/` — shell chrome components

---

## Before Writing

Run graph tools first:
```
semantic_search_nodes("SWT[ComponentName]")   # check if wrapper already exists
get_impact_radius("ComponentPath::ComponentName")  # understand callers before changing
```

---

## AntD Wrapper Pattern

All AntD primitives used in pages must be wrapped. Location: `src/@core/component/AntD/SWT{Name}/index.tsx`.

```tsx
import { AntDPrimitive, type AntDPrimitiveProps } from "antd";

type SWT{Name}Props = Omit<AntDPrimitiveProps, "size" | "type" | "variant"> & {
  size?: "sm" | "md" | "lg";
  variant?: "primary" | "outline";
};

const SWT{Name} = ({ size = "md", variant = "primary", ...props }: SWT{Name}Props) => {
  return <AntDPrimitive {...props} />;
};

export default SWT{Name};
```

**Rules:**
- Omit AntD props that are being re-typed with narrower types.
- Spread `...props` last.
- Export default only — no named export from component file.
- One component per folder, always at `index.tsx`.

---

## Custom Component Pattern

Non-AntD components live in `src/@core/component/SWT{Name}/`.

```tsx
type SWT{Name}Props = {
  condition: boolean;
  children: React.ReactNode;
};

const SWT{Name} = ({ condition, children }: SWT{Name}Props) => {
  return <>{condition ? children : null}</>;
};

export default SWT{Name};
```

---

## Conditional Rendering

Always use `SWTRenderIf` — never inline ternary returning `null`:

```tsx
// Correct
<SWTRenderIf condition={list.length > 0}>
  <SWTTable ... />
</SWTRenderIf>

// Forbidden
{list.length > 0 ? <SWTTable ... /> : null}
```

---

## Icon Component Pattern

Location: `src/@core/component/SWTIcon/iconoir/{icon-name}.tsx`.

```tsx
const MyIcon = ({ width = 24, height = 24, variant = "default", onClick, ...props }: IconProps) => (
  <svg width={width} height={height} onClick={onClick} {...props}>
    {/* SVG path */}
  </svg>
);

export default MyIcon;
```

File name: `kebab-case.tsx`. Export name: `PascalCase` with `SWT` prefix if it's a project icon.

---

## Page Component Structure

Pages follow a three-level hierarchy:

```
pages/[category]/[feature]/
├── page.tsx          # Route entry — thin wrapper, no logic
├── index.tsx         # Feature component — calls useSWTTitle, composes sub-components
└── components/       # Sub-components used only by this page
    └── {Name}.tsx
```

`page.tsx` example:
```tsx
import SignInForm from "./index";

const SignIn = () => <SignInForm />;
export default SignIn;
```

`index.tsx` example:
```tsx
import useSWTTitle from "@/src/@core/hooks/useSWTTitle";

const FeaturePage = () => {
  useSWTTitle("Page Title");
  return <FeatureDetail />;
};

export default FeaturePage;
```

---

## Styling Rules

- Use Tailwind utility classes for layout and spacing.
- Use AntD token overrides (in `themes/default/index.tsx`) for brand colors.
- Use `clsx(...)` to compose conditional class strings.
- Never write raw CSS in component files — extend `assets/css/globals.css`.

---

## memo() Usage

Apply `memo()` on components that:
- Receive callback props from a parent re-rendering frequently.
- Render a list of items (filter bars, table rows).

```tsx
export default memo(SWTFilter);
```

Do not memoize every component — only where there is demonstrated re-render cost.
