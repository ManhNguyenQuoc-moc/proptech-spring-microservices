# API Endpoint: [METHOD] [route]

**Controller**: `[ControllerName]`
**App Service**: `[AppServiceName].[Method]()`
**Auth**: Bearer JWT required / Anonymous

---

## Request

```
[METHOD] /cmn/[service]/api/[resource]
Authorization: Bearer {token}
X-Tenant: {tenantId}
Content-Type: application/json
```

### Path Parameters

| Param | Type | Required | Description |
|---|---|---|---|
| `id` | `Guid` | Yes | Resource identifier |

### Query Parameters

| Param | Type | Required | Description |
|---|---|---|---|
| `page` | `int` | No | Page number (1-based) |
| `pageSize` | `int` | No | Items per page |

### Body (`[InputDtoName]`)

```json
{
  "field": "value"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `field` | `string` | Yes | MaxLength(256), NotEmpty |

---

## Response

### Success — 200

```json
{
  "status": "OK",
  "statusCode": 200,
  "message": "Success",
  "systemName": "System API",
  "data": { }
}
```

### Error — 400

```json
{
  "status": "NOTOK",
  "statusCode": 400,
  "message": "Not Success",
  "error": {
    "code": "LocalizationKey",
    "message": "Human-readable error"
  }
}
```

---

## Validator

Validator class: `[InputDtoName]Validator` (colocated in same file as DTO)

---

## Notes

- [Any non-obvious behavior]
