# Client Workspace

This folder contains frontend application code and AI assistant guidance.

## Structure

```text
client/
├── commands/      # Frontend AI task prompts, not runtime app code
├── skills/        # Frontend AI task rules, not runtime app code
├── client-web/    # Customer-facing Next.js app
└── admin-portal/  # Admin/back-office Next.js app
```

## Current Frontend Direction

The frontend is split into two Next.js apps:

- `client-web`: public/customer-facing pages.
- `admin-portal`: admin/back-office pages.

Both apps own their own `src/` trees.
