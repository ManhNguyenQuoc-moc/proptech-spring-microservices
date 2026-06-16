<#
.SYNOPSIS
    Scans all CMN controller files for HTTP endpoints and compares against manifest.yml.

.DESCRIPTION
    Finds [HttpGet], [HttpPost], [HttpPut], [HttpDelete], [HttpPatch] attributes in
    *Controller.cs files and compares the discovered (ControllerClass.MethodName) pairs
    against what is registered in _meta/manifest.yml features[].endpoints[].controller.

    Reports:
      [NEW]   — found in code, not referenced in manifest
      [STALE] — referenced in manifest, not found in code

.PARAMETER RepoRoot
    Path to the monorepo root.

.PARAMETER KBRoot
    Relative path to the knowledge base.

.PARAMETER ReturnObjects
    Switch: return PSCustomObject array instead of printing (used by detect-drift.ps1).
#>

param(
    [string]$RepoRoot     = (Get-Location).Path,
    [string]$KBRoot       = "swt-cmn-knowledge-base",
    [switch]$ReturnObjects
)

# ── Scan source code for controller methods ───────────────────────────────────

$controllerDirs = @(
    "swt-cmn-administration-api\src",
    "swt-cmn-customer-api\src"
)

$codeEndpoints = [System.Collections.Generic.List[hashtable]]::new()

foreach ($dir in $controllerDirs) {
    $fullDir = Join-Path $RepoRoot $dir
    if (-not (Test-Path $fullDir)) { continue }

    $controllerFiles = Get-ChildItem -Path $fullDir -Recurse -Filter "*Controller.cs" -ErrorAction SilentlyContinue

    foreach ($file in $controllerFiles) {
        $content      = (Get-Content $file.FullName -Raw) -replace '\r\n', "`n"
        $className    = [regex]::Match($content, 'class\s+(\w+Controller)').Groups[1].Value
        if (-not $className) { continue }

        # Find all HTTP method attributes with optional route, followed by the method signature
        # Handles: [HttpGet], [HttpPost], [HttpPost()], [HttpPost("route")]
        $pattern = '\[(Http(?:Get|Post|Put|Delete|Patch))(?:\("([^"]*?)"\)|\(\))?\][^\n]*\n(?:\s*\[.*?\]\n)*\s*(?:public\s+)?(?:override\s+)?(?:virtual\s+)?(?:async\s+)?(?:Task<[^>]+>|IActionResult|Task)\s+(\w+)\s*\('
        $matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)

        foreach ($m in $matches) {
            $httpMethod  = $m.Groups[1].Value -replace 'Http', ''
            $routeParam  = $m.Groups[2].Value
            $methodName  = $m.Groups[3].Value
            $controllerKey = "$className.$methodName"

            $codeEndpoints.Add(@{
                Controller = $controllerKey
                ClassName  = $className
                MethodName = $methodName
                HttpMethod = $httpMethod.ToUpper()
                Route      = if ($routeParam) { $routeParam } else { "(convention)" }
                File       = $file.FullName.Replace($RepoRoot, '').TrimStart('\')
            })
        }
    }
}

# ── Load manifest.yml endpoints ───────────────────────────────────────────────

$manifestPath = Join-Path (Join-Path $RepoRoot $KBRoot) "_meta\manifest.yml"
$manifestControllers = @()

if (Test-Path $manifestPath) {
    $manifestContent = Get-Content $manifestPath -Raw
    # Extract all controller references: "ControllerClass.MethodAsync"
    $controllerRefs = [regex]::Matches($manifestContent, '"([A-Z]\w+Controller\.\w+Async)"')
    $manifestControllers = $controllerRefs | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
}

# ── Compare ───────────────────────────────────────────────────────────────────

$driftItems = [System.Collections.Generic.List[PSCustomObject]]::new()
$codeKeys   = $codeEndpoints | ForEach-Object { $_.Controller } | Sort-Object -Unique

# NEW: in code, not in manifest
foreach ($key in $codeKeys) {
    if ($key -notin $manifestControllers) {
        $ep = $codeEndpoints | Where-Object { $_.Controller -eq $key } | Select-Object -First 1
        $driftItems.Add([PSCustomObject]@{
            Status      = 'NEW'
            Description = "$($ep.Controller) → $($ep.HttpMethod) (route: $($ep.Route))"
            Action      = "Add to _meta/manifest.yml features[] and 09-requirements/traceability-matrix.md"
            Detail      = $ep
        })
    }
}

# STALE: in manifest, not in code
foreach ($key in $manifestControllers) {
    if ($key -notin $codeKeys) {
        $driftItems.Add([PSCustomObject]@{
            Status      = 'STALE'
            Description = "$key — not found in any *Controller.cs"
            Action      = "Remove from _meta/manifest.yml features[] or verify controller was renamed"
            Detail      = $null
        })
    }
}

# ── Output ────────────────────────────────────────────────────────────────────

if ($ReturnObjects) {
    return $driftItems
}

Write-Host ""
Write-Host "=== ENDPOINT SCAN ===" -ForegroundColor Cyan
Write-Host "Controllers scanned : $($controllerFiles.Count)" -ForegroundColor Gray
Write-Host "Endpoints found     : $($codeEndpoints.Count)" -ForegroundColor Gray
Write-Host "Manifest references : $($manifestControllers.Count)" -ForegroundColor Gray
Write-Host ""

if ($driftItems.Count -eq 0) {
    Write-Host "[OK] No endpoint drift detected." -ForegroundColor Green
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
