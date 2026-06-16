# Admin Portal

## Summary

`client/admin-portal` is the admin/back-office Next.js frontend app.

Customer-facing UI is intentionally separated into `client/client-web`.

## Location

```text
client/admin-portal/
├── package.json
├── next.config.ts
├── tsconfig.json
├── src/
│   ├── app/
│   ├── components/
│   ├── features/
│   ├── services/
│   ├── store/
│   ├── hooks/
│   ├── lib/
│   └── styles/
└── public/
```

## Routing Model

The app uses Next.js App Router.

| Route | Purpose |
|---|---|
| `/` | Admin dashboard |

## Feature Structure

```text
src/features/
├── dashboard/
└── listings/
```

## API Direction

Current backend APIs are direct service endpoints:

- Listing API: `http://localhost:8083/api/listings`

There is no gateway yet. Use environment variables for API bases:

```text
NEXT_PUBLIC_LISTING_SERVICE_URL=http://localhost:8083
```

## UI Foundation

- Ant Design is installed in this app.
- Root layout imports `antd/dist/reset.css`.
- `src/app/layout.tsx` wraps the app with `AntdRegistry`.
- `src/app/providers.tsx` wraps children with AntD `ConfigProvider` and `App`.
- Admin theme tokens use slate as the primary color.
- Base global styles live in `src/styles/globals.css`.

## Dev Server

Default port: `3001`.

```powershell
npm install
npm run dev
```

## Known Gaps

- Admin authentication is not implemented.
- Admin authorization is not implemented.
- No API gateway is implemented.
- Backend endpoints are still sparse; only listing list/create is confirmed.
