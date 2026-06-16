<#
.SYNOPSIS
    Scans CMN domain entity files and compares against KB documentation.

.DESCRIPTION
    Finds classes that extend FullAuditedEntity<Guid>, AuditedEntity<Guid>,
    FullAuditedAggregateRoot<Guid>, or Entity<Guid> in Domain project files.
    Compares against entity names documented in diagrams/entity-relations.mermaid.

    Reports:
      [NEW]   — entity in code, not in entity-relations.mermaid
      [STALE] — entity name in mermaid, no matching class in code

.PARAMETER RepoRoot
.PARAMETER KBRoot
.PARAMETER ReturnObjects
#>

param(
    [string]$RepoRoot     = (Get-Location).Path,
    [string]$KBRoot       = "swt-cmn-knowledge-base",
    [switch]$ReturnObjects
)

# ── Scan source code for entity classes ──────────────────────────────────────

$entityDirs = @(
    "swt-cmn-administration-api\src",
    "swt-cmn-customer-api\src"
)

# Entity base classes used in CMN (ABP patterns)
$entityBasePattern = 'FullAuditedEntity<Guid>|AuditedEntity<Guid>|FullAuditedAggregateRoot<Guid>|Entity<Guid>|CreationAuditedEntity<Guid>'

$codeEntities = [System.Collections.Generic.List[hashtable]]::new()

foreach ($dir in $entityDirs) {
    $fullDir = Join-Path $RepoRoot $dir
    if (-not (Test-Path $fullDir)) { continue }

    # Only scan files in paths containing '.Domain\' (ABP project name pattern, not Shared)
    $entityFiles = Get-ChildItem -Path $fullDir -Recurse -Filter "*.cs" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match '\.Domain\\' -and $_.FullName -notmatch '\.Domain\.Shared\\' }

    foreach ($file in $entityFiles) {
        $content = (Get-Content $file.FullName -Raw) -replace '\r\n', "`n"

        if ($content -notmatch $entityBasePattern) { continue }

        $classMatches = [regex]::Matches($content, 'class\s+(\w+)\s*(?::\s*[\w<>, ]+)?')
        foreach ($m in $classMatches) {
            $className = $m.Groups[1].Value
            # Skip if line doesn't contain an entity base class
            $lineStart = $content.LastIndexOf("`n", $m.Index)
            $lineEnd   = $content.IndexOf("`n", $m.Index)
            $line = $content.Substring([Math]::Max(0, $lineStart), [Math]::Max(0, $lineEnd - $lineStart))

            if ($line -match $entityBasePattern) {
                $codeEntities.Add(@{
                    Name = $className
                    File = $file.FullName.Replace($RepoRoot, '').TrimStart('\')
                })
            }
        }
    }
}

# ── Load entity-relations.mermaid for comparison ─────────────────────────────

$mermaidPath = Join-Path (Join-Path $RepoRoot $KBRoot) "diagrams\entity-relations.mermaid"
$mermaidEntities = @()

if (Test-Path $mermaidPath) {
    $mermaidContent = Get-Content $mermaidPath -Raw
    # Mermaid erDiagram entity blocks: "EntityName {" at start of line
    $mermaidMatches = [regex]::Matches($mermaidContent, '^\s+(\w+)\s*\{', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    $mermaidEntities = $mermaidMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
}

# ── Compare ───────────────────────────────────────────────────────────────────

$driftItems = [System.Collections.Generic.List[PSCustomObject]]::new()
$codeNames  = $codeEntities | ForEach-Object { $_.Name } | Sort-Object -Unique

# NEW: entity in code, not documented
foreach ($name in $codeNames) {
    if ($name -notin $mermaidEntities) {
        $entity = $codeEntities | Where-Object { $_.Name -eq $name } | Select-Object -First 1
        $driftItems.Add([PSCustomObject]@{
            Status      = 'NEW'
            Description = "Entity '$name' found in code ($($entity.File))"
            Action      = "Add entity block to diagrams/entity-relations.mermaid and 04-business-domain.md"
            Detail      = $entity
        })
    }
}

# STALE: in mermaid but no matching entity class
foreach ($name in $mermaidEntities) {
    if ($name -notin $codeNames) {
        $driftItems.Add([PSCustomObject]@{
            Status      = 'STALE'
            Description = "Entity '$name' in entity-relations.mermaid but no matching class found"
            Action      = "Verify entity was renamed or deleted; update mermaid and 04-business-domain.md"
            Detail      = $null
        })
    }
}

# ── Output ────────────────────────────────────────────────────────────────────

if ($ReturnObjects) { return $driftItems }

Write-Host ""
Write-Host "=== ENTITY SCAN ===" -ForegroundColor Cyan
Write-Host "Entities in code     : $($codeNames.Count)" -ForegroundColor Gray
Write-Host "Entities in mermaid  : $($mermaidEntities.Count)" -ForegroundColor Gray
Write-Host ""

if ($driftItems.Count -eq 0) {
    Write-Host "[OK] No entity drift detected." -ForegroundColor Green
} else {
    foreach ($item in $driftItems) {
        $color = if ($item.Status -eq 'NEW') { 'Yellow' } else { 'Red' }
        Write-Host "[$($item.Status)] $($item.Description)" -ForegroundColor $color
        Write-Host "       → $($item.Action)" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "Drift items: $($driftItems.Count)" -ForegroundColor Yellow
}

exit $(if ($driftItems.Count -gt 0) { 1 } else { 0 })
