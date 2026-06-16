# Client Web

## Summary

`client/client-web` is the customer-facing Next.js frontend app.

Admin/back-office UI is intentionally separated into `client/admin-portal`.

## Location

```text
client/client-web/
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
| `/` | Customer home |
| `/customer` | Customer home alias |

## Feature Structure

```text
src/features/
├── home/
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
- Customer theme tokens use teal as the primary color.
- Base global styles live in `src/styles/globals.css`.

## Dev Server

Default port: `3000`.

```powershell
npm install
npm run dev
```

## Known Gaps

- Authentication is not implemented.
- No API gateway is implemented.
- Backend endpoints are still sparse; only listing list/create is confirmed.
