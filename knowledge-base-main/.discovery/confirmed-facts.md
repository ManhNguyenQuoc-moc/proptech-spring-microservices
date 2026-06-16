# Confirmed Facts

All items here are directly derived from source code as of 2026-05-23. Each fact includes a source reference.

---

## Monorepo

- Root: `d:\SWT_ITZ\Project\CMN`
- 6 service modules + 1 code-reviewer utility
- Source: top-level directory listing

## Administration Service

- Stack: .NET 9, ABP Framework, EF Core, SQL Server, Redis, FluentValidation, xUnit + Shouldly
- Source: `swt-cmn-administration-api/CLAUDE.md`
- Route prefix: `/cmn/administration-service/api`
- Source: `swt-cmn-administration-api/src/CMN.AdministrationService.Domain.Shared/AdministrationServiceSettingNames.cs`
- DB Schema: `"ADM"`
- Source: `swt-cmn-administration-api/CLAUDE.md`
- Dev port: `8088`
- Source: `swt-cmn-web-gateway/CMN.WebGateWay/appsettings.Development.json`
- Entities: `Employee`, `OrganizationUnit`, `Positions`, `MediaFile`, `MailTemplate`
- Source: `swt-cmn-administration-api/src/CMN.AdministrationService.Domain/Entities/`
- Controllers: `AdministrationServiceController`, `AuthController`, `EmployeeController`, `IdentityUserController`, `MediaFileController`, `PermissionController`, `RoleController`
- Source: file listing of `CMN.AdministrationService.HttpApi/Controllers/`
- App services: `AuthAppService`, `EmployeeAppService`, `IdentityUserAppService`, `MailTemplateAppService`, `MediaFileAppService`, `PermissionAppService`, `RoleAppService`
- Source: file listing of `CMN.AdministrationService.Application/`
- gRPC services: `AdministrationServicePermissionGrpc`, `AdministrationServiceMailTemplateGrpc`
- Source: `swt-cmn-administration-api/CMN.AdministrationService.HttpApi.Host/Grpc/`
- Employee has: Name, Code, Email, OtherEmail, OrganizationUnitId, PositionId, AvatarFileId, PhoneNumber, JoinedDate, DateOfBirth, NumberOfLogin, LastLoginTime, NextLoginTime, UserId, IsFirstLogin
- Source: `Employee.cs`
- OrganizationUnit has: DisplayName, Code, ParentCode, CodePath, NamePath
- Source: `OrganizationUnit.cs`
- Positions has: Name, OrganizationUnitId (FK to OrganizationUnit)
- Source: `Positions.cs`
- MediaFile integrates with Cloudinary (SecureUrl, PublicId, AssetId fields)
- Source: `MediaFile.cs`

## Customer Service

- Stack: .NET 9, ABP Framework, EF Core, SQL Server, Redis, FluentValidation, Hangfire
- Source: `swt-cmn-customer-api/CLAUDE.md`
- Route prefix: `/cmn/customer-management/api`
- Source: `swt-cmn-customer-api/src/CMN.CustomerManagement.Domain.Shared/CustomerManagementSettingNames.cs` (inferred)
- DB Schema: `"CM"`
- Source: `swt-cmn-customer-api/CLAUDE.md`
- Dev port: `44360`
- Source: `swt-cmn-web-gateway/CMN.WebGateWay/appsettings.Development.json`
- Entities: `Party` (stub — only TenantId field defined)
- Source: `Party.cs`
- Controllers: `CustomerManagementController`, `PartyController`
- Source: file listing of `CMN.CustomerManagement.HttpApi/Controllers/`
- gRPC client to Administration Service (Permission + shared protos)
- Source: `swt-cmn-customer-api/src/CMN.CustomerManagement.Application/obj/Debug/net9.0/GrpcClient/Protos/`

## Web Gateway

- Stack: .NET 9, YARP (Yet Another Reverse Proxy)
- Source: `swt-cmn-web-gateway/CMN.WebGateWay/Program.cs`
- Routes `/cmn/administration-service/**` → `http://localhost:8088`
- Routes `/cmn/customer-management/**` → `http://localhost:44360`
- Source: `appsettings.Development.json`
- Swagger UI at `/cmn/swagger`
- Source: `Program.cs`

## Admin Web App

- Stack: Vite 7, React 19, TypeScript 5.9, Ant Design 6, Redux Toolkit 2, Tailwind CSS 4, React Router 7
- Source: `package.json`
- Pages: auth/signin, (protected)/organization, (protected)/permission, (protected)/roles, (protected)/users
- Source: directory listing of `src/pages/`
- Services: administration.service.ts, auth.service.ts, employee.service.ts, masterdata.service.ts, permission.service.ts, role.service.ts
- Source: directory listing of `src/services/`
- Multi-tenancy: X-Tenant header from localStorage
- Source: `swt-cmn-administration-web-app/CLAUDE.md`
- Vietnamese locale (viVN for AntD)
- Source: `swt-cmn-administration-web-app/CLAUDE.md`
- Base protected route: `/administration`
- Source: `swt-cmn-administration-web-app/CLAUDE.md`

## Main Web App

- Stack: Next.js 16.1.1, React 19.2.3, TypeScript, Ant Design 6, Redux Toolkit 2, Tailwind CSS 4, Axios
- Source: `package.json`
- App Router pattern (src/app/ directory)
- Source: directory listing
- Services: administration-service, customer-management, auth, employee, masterdata, party
- Source: directory listing of `src/services/`
- Dev port: 4200
- Source: `package.json` scripts

## Mobile App

- App name: `itzone`
- Flutter SDK: ^3.5.3
- Source: `pubspec.yaml`
- State management: hooks_riverpod ^2.6.1 + flutter_hooks
- HTTP: Retrofit (code generation) + Dio
- Routing: go_router ^16.3.0
- I18n: easy_localization ^3.0.8
- Immutable models: freezed ^3.1.0
- Firebase: firebase_crashlytics, firebase_messaging, firebase_performance_dio
- Maps: google_maps_flutter, geolocator
- Features: home, login, otp, selfie, splash
- Source: `lib/features/` directory listing

## Shared Infrastructure

- `AppControllerBase` extends `AbpControllerBase`, provides `Success<TData>()` and `Success()` helper methods
- Source: `AppControllerBase.cs`
- `CMNAbpExceptionFilter` replaces ABP's default filter, maps exceptions to HTTP codes
- Source: `CMNAbpExceptionFilter.cs`
- `ApiResult<TData>` is the universal response envelope with `Status`, `StatusCode`, `Message`, `Data`, `Error`
- Source: `BaseResultDto.cs`
- All controllers decorated with `[Authorize]` at base class level
- Source: `AppControllerBase.cs`
- OpenIddict used for auth server
- Source: `swt-cmn-administration-api/src/CMN.AdministrationService.Domain/OpenIddict/`
