# Skill: Media Upload

> Use when: handling IFormFile uploads, integrating with Cloudinary via MediaFileAppService, or replacing avatar files.
> Reference implementations: `EmployeeAppService.UpdateDetailAsync`, `EmployeeAppService.CreateAsync`, `MediaFileAppService`.

---

## IFormFile Conventions

- DTO field: `public IFormFile? AvatarFile { get; set; }` — always nullable.
- Controller binding: `[FromForm]` on the action parameter (not `[FromBody]`).
- Validate size and extension in the DTO validator (see `dto-validator-skill.md`).

---

## Upload Pattern

Inject `IMediaFileAppService` in the app service constructor.

```csharp
// Upload one or more files
var uploadedIds = await mediaFileAppService.UploadFileAsync(
    new List<UploadFileInputDto>
    {
        new UploadFileInputDto
        {
            File     = input.AvatarFile,   // IFormFile
            FileType = FileTypeEnum.Image  // from CMN.Shared.CrossCuttingConcerns.Enums
        }
    }
);

var newFileId = uploadedIds.FirstOrDefault();
entity.AvatarFileId = newFileId;   // store the ID, never the URL
```

**Always store `MediaFile.Id` (a `Guid`) on the entity — never store the URL directly.**

---

## Retrieve URL in Queries

Join with the `MediaFile` table and project `SecureUrl`:

```csharp
var mediaQ = await mediaFileRepository.GetQueryableAsync();

var query = from entity in entityQ
            join media in mediaQ on entity.AvatarFileId equals media.Id into mediaGroup
            from media in mediaGroup.DefaultIfEmpty()
            select new OutputDto
            {
                AvatarFileId = entity.AvatarFileId,
                AvatarUrl    = media != null ? media.SecureUrl : null,
            };
```

---

## Avatar Replacement Pattern

When updating an avatar, the old file must be soft-deleted **after** the UoW commits to avoid data inconsistency.

```csharp
using (var uow = unitOfWorkManager.Begin())
{
    // 1. Save old file ID before overwriting
    Guid? oldAvatarFileId = entity.AvatarFileId;

    if (input.AvatarFile != null)
    {
        var uploadedIds = await mediaFileAppService.UploadFileAsync(
            new List<UploadFileInputDto>
            {
                new UploadFileInputDto { File = input.AvatarFile, FileType = FileTypeEnum.Image }
            }
        );
        entity.AvatarFileId = uploadedIds.FirstOrDefault();
    }

    // 2. Save entity with new avatar ID
    await entityRepository.UpdateAsync(entity);
    await uow.CompleteAsync();

    // 3. Soft-delete old avatar AFTER commit (outside UoW scope)
    if (oldAvatarFileId.HasValue)
    {
        await mediaFileAppService.DeleteFileByIdAsync(oldAvatarFileId.Value);
    }
}
```

**Why after commit**: if the delete call fails, the entity still has a valid avatar. The old file may become orphaned but no data integrity is broken.

---

## File Type Enum

```csharp
// CMN.Shared.CrossCuttingConcerns.Enums.FileTypeEnum
FileTypeEnum.Image   // jpg, png, webp, etc.
FileTypeEnum.Video
FileTypeEnum.Raw
```

---

## Validation Constraints (defined in domain)

```csharp
// MediaFileConsts — reference these, don't hardcode values
MediaFileConsts.MaxAvatarSize           // max file size in bytes
MediaFileConsts.AllowedImageExtensions  // string[] of allowed extensions
```
