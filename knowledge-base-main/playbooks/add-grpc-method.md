# Playbook: Add a New gRPC Method

> CMN gRPC topology:
> - **Server**: Administration API on `:50051` (TLS HTTP/2)
> - **Client**: Customer API (connects to Admin API via configured channel)
> - gRPC services: `AdministrationServicePermissionGrpc`, `AdministrationServiceMailTemplateGrpc`
> - All gRPC handlers use `[DisableAuditing]` + `[IntegrationService]`
> - All gRPC handlers use **silent fail** — catch exceptions and return error in response, never throw

---

## Step 1 — Add RPC and Messages to Proto File

Location: `swt-cmn-administration-api/CMN.AdministrationService.HttpApi.Host/Protos/*.proto`

```proto
// Add new message types
message GetDepartmentRequest {
    string department_id = 1;
}

message DepartmentResponse {
    bool is_success = 1;
    string department_id = 2;
    string name = 3;
    string error = 4;
}

// Add to the existing service definition
service AdministrationServicePermission {
    // ... existing RPCs ...
    rpc GetDepartment(GetDepartmentRequest) returns (DepartmentResponse);
}
```

**Rules**:
- Use `snake_case` for field names in proto (generated C# will be PascalCase)
- All response messages must include an error field (string) for silent-fail pattern
- Boolean `is_success` for mutation responses; for query responses use the presence of data as success indicator

---

## Step 2 — Regenerate gRPC Code

Administration API server side:
```bash
cd swt-cmn-administration-api
dotnet build   # triggers Grpc.Tools codegen from .proto files
```

Customer API client side (if proto is shared):
```bash
cd swt-cmn-customer-api
dotnet build
```

Verify generated files appear in `obj/Debug/netX.X/Protos/` — `*.cs` and `*Grpc.cs`.

---

## Step 3 — Implement Server Handler (Administration API)

Location: `swt-cmn-administration-api/CMN.AdministrationService.HttpApi.Host/Grpc/AdministrationServicePermissionGrpc.cs`
(or create a new `AdministrationService{Feature}Grpc.cs` for a new gRPC service)

```csharp
[DisableAuditing]
[IntegrationService]
public class AdministrationServicePermissionGrpc
    : AdministrationServicePermissionBase   // generated base class
{
    private readonly IDepartmentAppService _departmentAppService;

    public AdministrationServicePermissionGrpc(IDepartmentAppService departmentAppService)
    {
        _departmentAppService = departmentAppService;
    }

    public override async Task<DepartmentResponse> GetDepartment(
        GetDepartmentRequest request, ServerCallContext context)
    {
        try
        {
            var result = await _departmentAppService.GetAsync(Guid.Parse(request.DepartmentId));
            return new DepartmentResponse
            {
                IsSuccess = true,
                DepartmentId = result.Id.ToString(),
                Name = result.Name,
                Error = string.Empty
            };
        }
        catch (Exception ex)
        {
            // MANDATORY: silent fail — never propagate exception to gRPC caller
            return new DepartmentResponse
            {
                IsSuccess = false,
                Error = ex.Message
            };
        }
    }
}
```

**Mandatory rules**:
- Class attribute: `[DisableAuditing]` — prevents audit log spam from integration calls
- Class attribute: `[IntegrationService]` — marks as cross-service endpoint
- Every method body **must** be wrapped in `try { ... } catch (Exception ex) { return error response }`
- For mutations: wrap in `IUnitOfWorkManager.Begin()` before calling app service
- Never call `DbContext` or repositories directly — delegate to app service interface

**For mutations (write operations) — add UnitOfWork**:
```csharp
public override async Task<MutationResponse> CreateFoo(
    CreateFooRequest request, ServerCallContext context)
{
    try
    {
        using var uow = _unitOfWorkManager.Begin();
        var result = await _fooAppService.CreateAsync(...);
        await uow.CompleteAsync();
        return new MutationResponse { IsSuccess = true };
    }
    catch (Exception ex)
    {
        return new MutationResponse { IsSuccess = false, Error = ex.Message };
    }
}
```

---

## Step 4 — Register New gRPC Service (if new service file)

Location: `swt-cmn-administration-api/CMN.AdministrationService.HttpApi.Host/Program.cs`
(or the host module's `OnApplicationInitialization`)

```csharp
app.UseEndpoints(endpoints =>
{
    // ... existing ...
    endpoints.MapGrpcService<AdministrationServiceFeatureGrpc>();
});
```

If adding to an **existing** gRPC service class (e.g., `AdministrationServicePermissionGrpc`), no registration change is needed.

---

## Step 5 — Add Client Method (Customer API)

Location: `swt-cmn-customer-api/src/CMN.CustomerManagement.Application/Grpc/IAdministrationServicePermissionGrpc.cs`
(or create corresponding interface file)

```csharp
public interface IAdministrationServicePermissionGrpc
{
    // ... existing ...
    Task<DepartmentResponse> GetDepartmentAsync(string departmentId);
}
```

Implement the method in the gRPC client wrapper (if one exists), or inject the generated gRPC client directly into the app service:

```csharp
private readonly AdministrationServicePermission.AdministrationServicePermissionClient _grpcClient;

public async Task<string?> GetDepartmentNameAsync(Guid departmentId)
{
    try
    {
        var response = await _grpcClient.GetDepartmentAsync(new GetDepartmentRequest
        {
            DepartmentId = departmentId.ToString()
        });
        return response.IsSuccess ? response.Name : null;
    }
    catch
    {
        return null;    // mirror the silent-fail contract on the client side
    }
}
```

---

## Step 6 — Verify Channel Configuration

Customer API's gRPC channel to Administration API is configured in `appsettings*.json`:

```json
"RemoteServices": {
    "AdministrationService": {
        "BaseUrl": "https://localhost:50051"
    }
}
```

Confirm `appsettings.Development.json` has the correct address for local dev. No code change needed if the channel is already registered.

---

## Step 7 — Integration Test

```bash
# Start Administration API (gRPC server must be running on :50051)
cd swt-cmn-administration-api
dotnet run --project CMN.AdministrationService.HttpApi.Host

# Run Customer API integration test that calls the new method
cd swt-cmn-customer-api
dotnet test --filter "GrpcIntegration"
```

Test must verify:
- Happy path returns expected data
- Error path (entity not found) returns `IsSuccess = false` with error message, does NOT throw

---

## Step 8 — Update Knowledge Base

- [ ] Add new RPC to `services/administration-api.md` gRPC section
- [ ] Add client usage to `services/customer-api.md` gRPC client section
- [ ] Update `diagrams/grpc-cross-service.mermaid` with new sequence
- [ ] Update `06-integrations.md` gRPC section if new service type
- [ ] Add CHANGELOG entry (`ADD` type)
