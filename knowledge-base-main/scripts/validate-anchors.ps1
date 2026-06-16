<#
.SYNOPSIS
    Validates anchor markers in all KB markdown and YAML files.

.DESCRIPTION
    Scans all .md and .yml files in the knowledge base for anchor markers
    and reports any that are unmatched (BEGIN without END or vice versa).

    Markdown/HTML anchor syntax:
      <!-- BEGIN: section-id -->
      <!-- END: section-id -->

    YAML anchor syntax:
      # === BEGIN: section-id ===
      # === END: section-id ===

    Legacy anchor syntax (Phase 0, still honored):
      <!-- KB-ANCHOR: anchor-id -->
      <!-- /KB-ANCHOR: anchor-id -->

.PARAMETER RepoRoot
.PARAMETER KBRoot

.OUTPUTS
    Prints validation results. Exit code 0 = valid, 1 = errors found.
#>

param(
    [string]$RepoRoot = (Get-Location).Path,
    [string]$KBRoot   = "swt-cmn-knowledge-base"
)

$kbFullPath = Join-Path $RepoRoot $KBRoot
$errors     = [System.Collections.Generic.List[string]]::new()

if (-not (Test-Path $kbFullPath)) {
    Write-Host "ERROR: KB not found at $kbFullPath" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== ANCHOR VALIDATION ===" -ForegroundColor Cyan
Write-Host "KB path: $kbFullPath" -ForegroundColor Gray
Write-Host ""

$files = Get-ChildItem -Path $kbFullPath -Recurse -Include "*.md","*.yml" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\.git\\' }

$fileCount     = 0
$anchorCount   = 0

foreach ($file in $files) {
    $content  = Get-Content $file.FullName -Raw
    if (-not $content) { continue }

    $fileCount++
    $relPath = $file.FullName.Replace($kbFullPath, '').TrimStart('\')

    # Stack-based validation per file
    $openAnchors = @{}   # id → line number

    # Collect all anchor lines
    $lines = $content -split "`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line   = $lines[$i]
        $lineNo = $i + 1

        # Pattern 1: <!-- BEGIN: id --> and <!-- END: id -->
        if ($line -match '<!--\s*BEGIN:\s*([a-zA-Z0-9_-]+)\s*-->') {
            $id = $Matches[1]
            if ($openAnchors.ContainsKey($id)) {
                $errors.Add("${relPath}:${lineNo} — Nested or duplicate BEGIN for anchor '$id' (first opened at line $($openAnchors[$id]))")
            } else {
                $openAnchors[$id] = $lineNo
                $anchorCount++
            }
        }
        elseif ($line -match '<!--\s*END:\s*([a-zA-Z0-9_-]+)\s*-->') {
            $id = $Matches[1]
            if (-not $openAnchors.ContainsKey($id)) {
                $errors.Add("${relPath}:${lineNo} — END for '$id' without a preceding BEGIN")
            } else {
                $openAnchors.Remove($id)
            }
        }
        # Pattern 2: # === BEGIN: id === and # === END: id ===
        elseif ($line -match '#\s*===\s*BEGIN:\s*([a-zA-Z0-9_-]+)\s*===') {
            $id = $Matches[1]
            if ($openAnchors.ContainsKey($id)) {
                $errors.Add("${relPath}:${lineNo} — Nested or duplicate BEGIN for anchor '$id' (first opened at line $($openAnchors[$id]))")
            } else {
                $openAnchors[$id] = $lineNo
                $anchorCount++
            }
        }
        elseif ($line -match '#\s*===\s*END:\s*([a-zA-Z0-9_-]+)\s*===') {
            $id = $Matches[1]
            if (-not $openAnchors.ContainsKey($id)) {
                $errors.Add("${relPath}:${lineNo} — END for '$id' without a preceding BEGIN")
            } else {
                $openAnchors.Remove($id)
            }
        }
        # Pattern 3: Legacy <!-- KB-ANCHOR: id --> and <!-- /KB-ANCHOR: id -->
        elseif ($line -match '<!--\s*KB-ANCHOR:\s*([a-zA-Z0-9_-]+)\s*-->') {
            $id = "kb-anchor:$($Matches[1])"
            $openAnchors[$id] = $lineNo
            $anchorCount++
        }
        elseif ($line -match '<!--\s*/KB-ANCHOR:\s*([a-zA-Z0-9_-]+)\s*-->') {
            $id = "kb-anchor:$($Matches[1])"
            if (-not $openAnchors.ContainsKey($id)) {
                $errors.Add("${relPath}:${lineNo} — /KB-ANCHOR for '$($Matches[1])' without a preceding KB-ANCHOR")
            } else {
                $openAnchors.Remove($id)
            }
        }
    }

    # Remaining open anchors = unclosed BEGINs
    foreach ($unclosed in $openAnchors.Keys) {
        $cleanId = $unclosed -replace '^kb-anchor:', ''
        $errors.Add("${relPath}:$($openAnchors[$unclosed]) — BEGIN for '$cleanId' was never closed with END")
    }
}

# ── Report ────────────────────────────────────────────────────────────────────

Write-Host "Files scanned   : $fileCount" -ForegroundColor Gray
Write-Host "Anchors found   : $anchorCount" -ForegroundColor Gray
Write-Host ""

if ($errors.Count -eq 0) {
    Write-Host "[PASS] All anchor markers are valid." -ForegroundColor Green
} else {
    foreach ($err in $errors) {
        Write-Host "[ERROR] $err" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Anchor errors: $($errors.Count)" -ForegroundColor Red
}

exit $(if ($errors.Count -gt 0) { 1 } else { 0 })
