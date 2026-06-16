# KB Anchors Registry

Anchors are stable IDs embedded in documentation. When code changes, find the anchor and update only the marked section.

## Anchor Format

```text
<!-- KB-ANCHOR: {id} -->
...content...
<!-- /KB-ANCHOR: {id} -->
```

## Registered Anchors

| Anchor ID | File | Description |
|---|---|---|
| `domain-entities` | `04-business-domain.md` | Current backend entity field list |
| `tech-stack-matrix` | `02-tech-stack.md` | Technology stack per backend/frontend app |
| `layer-rules` | `03-conventions.md` | Spring/Next layer ownership rules |

## Planned Anchors

Add service-specific anchors when the APIs mature:

- `listing-endpoints`
- `user-endpoints`
- `product-endpoints`
- `order-endpoints`
- `payment-endpoints`
- `customer-routes`
- `admin-routes`
