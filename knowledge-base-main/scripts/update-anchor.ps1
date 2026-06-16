#!/usr/bin/env pwsh
# update-anchor.ps1
# Updates content between KB anchor tags in a target file.
# Usage: .\update-anchor.ps1 -File "services\administration-api.md" -Anchor "admin-entities" -Content "new content here"

param(
    [Parameter(Mandatory)][string]$File,
    [Parameter(Mandatory)][string]$Anchor,
    [Parameter(Mandatory)][string]$Content,
    [string]$KbRoot = $PSScriptRoot + "\.."
)

$fullPath = Join-Path $KbRoot $File

if (-not (Test-Path $fullPath)) {
    Write-Error "File not found: $fullPath"
    exit 1
}

$openTag = "<!-- KB-ANCHOR: $Anchor -->"
$closeTag = "<!-- /KB-ANCHOR: $Anchor -->"

$fileContent = Get-Content $fullPath -Raw

if (-not ($fileContent -match [regex]::Escape($openTag))) {
    Write-Error "Anchor '$Anchor' not found in $File"
    exit 1
}

# Replace content between anchor tags
$pattern = "(?s)(" + [regex]::Escape($openTag) + ").*?(" + [regex]::Escape($closeTag) + ")"
$replacement = "`$1`n$Content`n`$2"
$newContent = [regex]::Replace($fileContent, $pattern, $replacement)

Set-Content -Path $fullPath -Value $newContent -NoNewline

Write-Host "Updated anchor '$Anchor' in $File" -ForegroundColor Green
Write-Host "Remember to add a CHANGELOG entry in CHANGELOG.md" -ForegroundColor Yellow
