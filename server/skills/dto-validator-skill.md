# Skill: DTO & Validator

> Use when: creating input DTOs, output DTOs, or FluentValidation validators.
> Reference implementations: `CreateEmployeeInputDto`, `UpdateEmployeeInputDto`, `EmployeeOutputDto`.

---

## Input DTO + Validator (Create)

**Path**: `src/CMN.AdministrationService.Application.Contracts/{Feature}/Dtos/Input/Create{Feature}InputDto.cs`
**Namespace**: `CMN.AdministrationService.{Feature}.Dtos.Input`

```csharp
using CMN.AdministrationService.Localization;
using CMN.Shared.CrossCuttingConcerns.ExtensionMethods;
using FluentValidation;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Localization;
using System;

namespace CMN.AdministrationService.{Feature}.Dtos.Input
{
    public class Create{Feature}InputDto
    {
        /// <summary>Vietnamese description</summary>
        public string Name { get; set; }

        public string? OptionalField { get; set; }
        public Guid? RelatedEntityId { get; set; }

        // For file upload endpoints only:
        // public IFormFile? AvatarFile { get; set; }
    }

    public class Create{Feature}InputValidator : AbstractValidator<Create{Feature}InputDto>
    {
        public Create{Feature}InputValidator(IStringLocalizer<AdministrationServiceResource> localizer)
        {
            // Required string — check not empty, then max length (separate rules)
            RuleFor(x => x.Name)
                .Must(x => !string.IsNullOrEmpty(x))
                .WithMessage(CommonExtensions.GetValidateMessage(localizer["NotEmpty"], localizer["{Feature}:Name"]));

            RuleFor(x => x.Name)
                .MaximumLength(ValidationConsts.MediumInputMaxLength)
                .WithMessage(CommonExtensions.GetValidateMessage(localizer["MaxLength"], localizer["{Feature}:Name"], ValidationConsts.MediumInputMaxLength));

            // Optional string — guard all rules with .When(...)
            RuleFor(x => x.OptionalField)
                .MaximumLength(ValidationConsts.SmallInputMaxLength)
                .WithMessage(CommonExtensions.GetValidateMessage(localizer["MaxLength"], localizer["{Feature}:OptionalField"], ValidationConsts.SmallInputMaxLength))
                .When(x => x.OptionalField != null);

            // Email format example
            // RuleFor(x => x.Email)
            //     .EmailAddress()
            //     .WithMessage(CommonExtensions.GetValidateMessage(localizer["InvalidValue"], localizer["User:Email"]))
            //     .When(x => x.Email != null);

            // Phone regex example
            // RuleFor(x => x.PhoneNumber)
            //     .Matches(EmployeeConsts.VietnamPhoneNumberRegex, RegexOptions.IgnoreCase)
            //     .WithMessage(CommonExtensions.GetValidateMessage(localizer["InvalidValue"], localizer["User:PhoneNumber"]))
            //     .When(x => !string.IsNullOrEmpty(x.PhoneNumber));
        }
    }
}
```

---

## Input DTO + Validator (Update — patch semantics)

**Path**: `src/CMN.AdministrationService.Application.Contracts/{Feature}/Dtos/Input/Update{Feature}InputDto.cs`

```csharp
using CMN.AdministrationService.Localization;
using CMN.Shared.CrossCuttingConcerns.ExtensionMethods;
using FluentValidation;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Localization;

namespace CMN.AdministrationService.{Feature}.Dtos.Input
{
    public class Update{Feature}InputDto
    {
        // All fields nullable — update only what is provided
        public string? Name { get; set; }
        public string? OptionalField { get; set; }

        // IFormFile is inherently nullable — [FromForm] binding only
        // public IFormFile? AvatarFile { get; set; }
    }

    public class Update{Feature}InputValidator : AbstractValidator<Update{Feature}InputDto>
    {
        public Update{Feature}InputValidator(IStringLocalizer<AdministrationServiceResource> localizer)
        {
            // Require at least one field to be provided
            RuleFor(inputDto => inputDto)
                .Must(HaveAtLeastOneField)
                .WithMessage(CommonExtensions.GetValidateMessage(localizer["DataInvalid"]));

            RuleFor(x => x.Name)
                .MaximumLength(ValidationConsts.MediumInputMaxLength)
                .WithMessage(CommonExtensions.GetValidateMessage(localizer["MaxLength"], localizer["{Feature}:Name"], ValidationConsts.MediumInputMaxLength))
                .When(x => x.Name != null);
        }

        private static bool HaveAtLeastOneField(Update{Feature}InputDto dto)
            => dto.Name != null || dto.OptionalField != null;
    }
}
```

---

## List Input DTO

**Path**: `src/CMN.AdministrationService.Application.Contracts/{Feature}/Dtos/Input/GetList{Feature}InputDto.cs`

```csharp
using CMN.Shared.CrossCuttingConcerns.Dtos.Pagination;
using FluentValidation;

namespace CMN.AdministrationService.{Feature}.Dtos.Input
{
    public class GetList{Feature}InputDto : PaginationWithSearchRequestDto
    {
        // Add optional filters
        public bool? IsActive { get; set; }
    }

    public class GetList{Feature}InputDtoValidator : AbstractValidator<GetList{Feature}InputDto>
    {
        // Leave empty if no rules beyond base DataAnnotations
    }
}
```

---

## Output DTO

**Path**: `src/CMN.AdministrationService.Application.Contracts/{Feature}/Dtos/Output/{Feature}OutputDto.cs`

```csharp
using System;
using System.Collections.Generic;

namespace CMN.AdministrationService.{Feature}.Dtos.Output
{
    public class {Feature}OutputDto
    {
        public Guid Id { get; set; }           // always first
        public string Name { get; set; }
        public string? OptionalField { get; set; }

        // Include navigation names — project them from joins, not from FK ids alone
        public Guid? RelatedEntityId { get; set; }
        public string? RelatedEntityName { get; set; }
    }

    // Primary constructor — no base class, no inheritance
    public class Paged{Feature}OutputDto(int totalCount, IReadOnlyList<{Feature}OutputDto> items)
    {
        public int TotalCount { get; set; } = totalCount;
        public IReadOnlyList<{Feature}OutputDto> Items { get; set; } = items;

        // Uncomment when aggregate counts must accompany the list:
        // public Dictionary<string, object> ExtendData { get; set; }
    }
}
```

---

## Validation Rules

### Message format
Always use `CommonExtensions.GetValidateMessage(localizer["RuleKey"], localizer["FieldKey"])`.
Never write raw error strings like `"Name is required"`.

### Length constants
Use `ValidationConsts` or domain-specific `{Feature}Consts`:
- `SmallInputMaxLength` = 100 (emails, codes)
- `MediumInputMaxLength` = 250 (names, titles)
- `LargeInputMaxLength` = 500
- `MaxInputMaxLength` = 1000

### Required field pattern
```csharp
RuleFor(x => x.Field)
    .Must(x => !string.IsNullOrEmpty(x))
    .WithMessage(CommonExtensions.GetValidateMessage(localizer["NotEmpty"], localizer["Feature:Field"]));
```

### Optional field pattern (always use `.When`)
```csharp
RuleFor(x => x.Field)
    .MaximumLength(ValidationConsts.SmallInputMaxLength)
    .WithMessage(...)
    .When(x => x.Field != null);
```

### File field validation
```csharp
RuleFor(x => x.AvatarFile)
    .Must(x => x.Length <= MediaFileConsts.MaxAvatarSize)
    .WithMessage(CommonExtensions.GetValidateMessage(localizer["OutOfSize"], MediaFileConsts.MaxAvatarSize))
    .Must(file => file.HasValidExtension(MediaFileConsts.AllowedImageExtensions))
    .WithMessage(CommonExtensions.GetValidateMessage(localizer["InvalidValue"], localizer["File"]))
    .When(x => x.AvatarFile != null);
```

### Colocate validator and DTO
The validator class is **always in the same `.cs` file** as its DTO. Never split them.
