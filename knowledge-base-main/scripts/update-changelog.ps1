<#
.SYNOPSIS
    Generates a formatted CHANGELOG entry and prepends it to CHANGELOG.md.

.DESCRIPTION
    Creates a properly formatted changelog entry following the CMN KB format
    and inserts it at the top of the entries section in CHANGELOG.md.

.PARAMETER Type
    Entry type: ADD | UPDATE | FIX | REMOVE | VERIFY | INIT

.PARAMETER Description
    Short description of the change (appears in the heading).

.PARAMETER Source
    Source of the change (code file, PR number, or discovery session).

.PARAMETER Files
    Hashtable of { "filename" = "description" } pairs for the files section.
    Example: @{ "_meta/manifest.yml" = "Added 3 new feature entries" }

.PARAMETER Notes
    Optional free-text notes (bullet points, one string with newlines).

.PARAMETER DryRun
    Print the entry without modifying CHANGELOG.md.

.EXAMPLE
    .\update-changelog.ps1 `
        -Type "UPDATE" `
        -Description "Synced endpoints after EmployeeController.ExportAsync added" `
        -Source "swt-cmn-administration-api/src/.../EmployeeController.cs" `
        -Files @{ "_meta/manifest.yml" = "Added employee.export feature"; "09-requirements/traceability-matrix.md" = "Added REQ-EMP-006 row" }

.EXAMPLE
    .\update-changelog.ps1 -Type "FIX" -Description "Fixed stale gRPC operation in manifest" -DryRun
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("ADD","UPDATE","FIX","REMOVE","VERIFY","INIT")]
    [string]$Type,

    [Parameter(Mandatory)]
    [string]$Description,

    [string]$Source = "(manual KB maintenance)",

    [hashtable]$Files = @{},

    [string]$Notes = "",

    [string]$RepoRoot = (Get-Location).Path,
    [string]$KBRoot   = "swt-cmn-knowledge-base",

    [switch]$DryRun
)

$changelogPath = Join-Path (Join-Path $RepoRoot $KBRoot) "CHANGELOG.md"
$today         = Get-Date -Format "yyyy-MM-dd"

# ── Build the entry ───────────────────────────────────────────────────────────

$sb = [System.Text.StringBuilder]::new()

$null = $sb.AppendLine("## $today — $Type $Description")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("**Source**: $Source")

if ($Files.Count -gt 0) {
    $null = $sb.AppendLine("**Updated**:")
    $null = $sb.AppendLine("")
    $null = $sb.AppendLine("| File | Change |")
    $null = $sb.AppendLine("|---|---|")
    foreach ($kvp in $Files.GetEnumerator()) {
        $null = $sb.AppendLine("| ``$($kvp.Key)`` | $($kvp.Value) |")
    }
}

if ($Notes) {
    $null = $sb.AppendLine("")
    foreach ($note in ($Notes -split "`n")) {
        $note = $note.Trim()
        if ($note) {
            $null = $sb.AppendLine("- $note")
        }
    }
}

$null = $sb.AppendLine("")
$null = $sb.AppendLine("---")
$null = $sb.AppendLine("")

$entry = $sb.ToString()

# ── Dry run or apply ─────────────────────────────────────────────────────────

if ($DryRun) {
    Write-Host "=== DRY RUN — CHANGELOG ENTRY ===" -ForegroundColor Cyan
    Write-Host $entry
    Write-Host "==================================" -ForegroundColor Cyan
    return
}

if (-not (Test-Path $changelogPath)) {
    Write-Host "ERROR: CHANGELOG.md not found at $changelogPath" -ForegroundColor Red
    exit 1
}

$existing = Get-Content $changelogPath -Raw

# Insert after the header block (after the second "---" separator at the top)
# The CHANGELOG starts with a title, format block, then first "---"
$separatorIndex = $existing.IndexOf("`n---`n", 0)  # first ---
if ($separatorIndex -ge 0) {
    $insertAt = $separatorIndex + 5  # after "---\n"
    $newContent = $existing.Substring(0, $insertAt) + "`n" + $entry + $existing.Substring($insertAt)
} else {
    # Fallback: prepend after the first line
    $newContent = $existing + "`n" + $entry
}

Set-Content -Path $changelogPath -Value $newContent -Encoding UTF8 -NoNewline

Write-Host "[OK] CHANGELOG.md updated with $Type entry for '$Description'" -ForegroundColor Green
Write-Host "     Date: $today" -ForegroundColor Gray
