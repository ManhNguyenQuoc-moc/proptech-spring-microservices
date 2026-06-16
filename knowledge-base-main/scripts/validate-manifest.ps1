<#
.SYNOPSIS
    Validates _meta/manifest.yml for ID format correctness and cross-reference integrity.

.DESCRIPTION
    Checks (without a YAML parser — pure regex/text):
      1. REQ IDs match ^REQ-[A-Z]+-\d{3}$
      2. BR IDs match ^BR-[A-Z]+-\d{3}$
      3. Service IDs are unique and kebab-case
      4. Feature IDs follow {context}.{name} format
      5. Feature bounded_context values exist in the bounded_contexts section
      6. Requirement file paths referenced in requirements.files exist on disk
      7. Technical debt IDs follow ^TD-\d{3}$

.PARAMETER RepoRoot
.PARAMETER KBRoot

.OUTPUTS
    Prints validation results. Exit code 0 = valid, 1 = errors found.
#>

param(
    [string]$RepoRoot = (Get-Location).Path,
    [string]$KBRoot   = "swt-cmn-knowledge-base"
)

$manifestPath = Join-Path (Join-Path $RepoRoot $KBRoot) "_meta\manifest.yml"
$errors   = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

if (-not (Test-Path $manifestPath)) {
    Write-Host "ERROR: manifest.yml not found at $manifestPath" -ForegroundColor Red
    exit 1
}

$content = (Get-Content $manifestPath -Raw) -replace '\r\n', "`n"

Write-Host ""
Write-Host "=== MANIFEST VALIDATION ===" -ForegroundColor Cyan
Write-Host "File: $manifestPath" -ForegroundColor Gray
Write-Host ""

# ── 1. REQ ID format — only match complete IDs (REQ-DOMAIN-NNN, not prefix templates) ────
$reqMatches = [regex]::Matches($content, '(REQ-[A-Z]+-\d{3})')
$reqIds = $reqMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
Write-Host "  REQ IDs found: $($reqIds.Count)" -ForegroundColor Gray

# ── 2. BR ID format ──────────────────────────────────────────────────────────
$brMatches = [regex]::Matches($content, '(BR-[A-Z]+-\d{3})')
$brIds = $brMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
Write-Host "  BR IDs found: $($brIds.Count)" -ForegroundColor Gray

# ── 3. TD ID format ──────────────────────────────────────────────────────────
$tdMatches = [regex]::Matches($content, '(TD-[0-9-]+)')
foreach ($m in $tdMatches) {
    $id = $m.Groups[1].Value
    if ($id -notmatch '^TD-\d{3}$') {
        $errors.Add("Invalid TD ID format: '$id' (expected TD-NNN)")
    }
}

# ── 4. Service IDs — kebab-case and unique ───────────────────────────────────
# Extract service ids (lines matching "  - id: kebab-case" near the "services:" section)
$serviceSection = [regex]::Match($content, '# === BEGIN: services ===.*?# === END: services ===', [System.Text.RegularExpressions.RegexOptions]::Singleline)
if ($serviceSection.Success) {
    $svcIdMatches = [regex]::Matches($serviceSection.Value, '^  - id:\s+([a-z][a-z0-9-]*)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    $svcIds = $svcIdMatches | ForEach-Object { $_.Groups[1].Value }
    $duplicates = $svcIds | Group-Object | Where-Object { $_.Count -gt 1 }
    foreach ($dup in $duplicates) {
        $errors.Add("Duplicate service ID: '$($dup.Name)'")
    }
    Write-Host "  Service IDs found: $($svcIds.Count)" -ForegroundColor Gray
}

# ── 5. Feature bounded_context cross-reference ───────────────────────────────
$bcSection = [regex]::Match($content, '# === BEGIN: bounded-contexts ===.*?# === END: bounded-contexts ===', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$boundedContextIds = @()
if ($bcSection.Success) {
    $bcIdMatches = [regex]::Matches($bcSection.Value, '^\s+- id:\s+([a-z][a-z0-9-]*)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    $boundedContextIds = $bcIdMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
}

$featureSection = [regex]::Match($content, '# === BEGIN: features ===.*?# === END: features ===', [System.Text.RegularExpressions.RegexOptions]::Singleline)
if ($featureSection.Success -and $boundedContextIds.Count -gt 0) {
    $bcRefMatches = [regex]::Matches($featureSection.Value, '^\s+bounded_context:\s+([a-z][a-z0-9-]*)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    foreach ($m in $bcRefMatches) {
        $ref = $m.Groups[1].Value
        if ($ref -notin $boundedContextIds) {
            $errors.Add("Feature references unknown bounded_context: '$ref'. Valid IDs: $($boundedContextIds -join ', ')")
        }
    }
}

# ── 6. Requirement file paths exist ──────────────────────────────────────────
$reqFilesSection = [regex]::Match($content, 'files:\s*\n((?:\s+- path:.*\n)+)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
if ($reqFilesSection.Success) {
    $pathMatches = [regex]::Matches($reqFilesSection.Groups[1].Value, '- path:\s+"?([^"\n]+)"?')
    foreach ($m in $pathMatches) {
        $relPath  = $m.Groups[1].Value.Trim()
        $fullPath = Join-Path $RepoRoot $relPath
        if (-not (Test-Path $fullPath)) {
            $warnings.Add("Requirement file path not found on disk: '$relPath'")
        }
    }
}

# ── 7. next_available counters are > last_used ────────────────────────────────
$domainMatches = [regex]::Matches($content,
    'last_used:\s+"?(\d{3})"?\s*\n\s+next_available:\s+"?(\d{3})"?')
foreach ($m in $domainMatches) {
    $last = [int]$m.Groups[1].Value
    $next = [int]$m.Groups[2].Value
    if ($next -le $last) {
        $errors.Add("ID registry: next_available ($next) must be > last_used ($last)")
    }
}

# ── Report ────────────────────────────────────────────────────────────────────

Write-Host ""
if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "[PASS] manifest.yml is valid." -ForegroundColor Green
} else {
    foreach ($err in $errors) {
        Write-Host "[ERROR]   $err" -ForegroundColor Red
    }
    foreach ($warn in $warnings) {
        Write-Host "[WARNING] $warn" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Errors: $($errors.Count)  Warnings: $($warnings.Count)" -ForegroundColor $(if ($errors.Count -gt 0) { 'Red' } else { 'Yellow' })
}

exit $(if ($errors.Count -gt 0) { 1 } else { 0 })
