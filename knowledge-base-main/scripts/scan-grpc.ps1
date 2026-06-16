<#
.SYNOPSIS
    Scans CMN .proto files for gRPC service methods and compares against manifest.yml.

.DESCRIPTION
    Finds all 'rpc MethodName' declarations in *.proto files under the administration-api.
    Compares against integrations[grpc-channel].operations in _meta/manifest.yml.

    Reports:
      [NEW]   — rpc method in proto, not in manifest operations
      [STALE] — operation in manifest, not found in any proto file

.PARAMETER RepoRoot
.PARAMETER KBRoot
.PARAMETER ReturnObjects
#>

param(
    [string]$RepoRoot     = (Get-Location).Path,
    [string]$KBRoot       = "swt-cmn-knowledge-base",
    [switch]$ReturnObjects
)

# ── Scan .proto files ─────────────────────────────────────────────────────────

$protoSearchDirs = @(
    "swt-cmn-administration-api\src",
    "swt-cmn-administration-api\CMN.AdministrationService.HttpApi.Host"
)

$codeRpcMethods = [System.Collections.Generic.List[hashtable]]::new()

foreach ($dir in $protoSearchDirs) {
    $fullDir = Join-Path $RepoRoot $dir
    if (-not (Test-Path $fullDir)) { continue }

    $protoFiles = Get-ChildItem -Path $fullDir -Recurse -Filter "*.proto" -ErrorAction SilentlyContinue

    foreach ($file in $protoFiles) {
        $content = Get-Content $file.FullName -Raw

        # Extract service name
        $serviceMatch = [regex]::Match($content, 'service\s+(\w+)\s*\{')
        $serviceName  = if ($serviceMatch.Success) { $serviceMatch.Groups[1].Value } else { "Unknown" }

        # Extract all rpc methods: "rpc MethodName (Request) returns (Response);"
        $rpcMatches = [regex]::Matches($content, 'rpc\s+(\w+)\s*\(\s*(\w+)\s*\)\s+returns\s+\(\s*(\w+)\s*\)')
        foreach ($m in $rpcMatches) {
            $codeRpcMethods.Add(@{
                Service    = $serviceName
                Method     = $m.Groups[1].Value
                Request    = $m.Groups[2].Value
                Response   = $m.Groups[3].Value
                File       = $file.FullName.Replace($RepoRoot, '').TrimStart('\')
            })
        }
    }
}

# ── Load manifest.yml gRPC operations ─────────────────────────────────────────

$manifestPath = Join-Path (Join-Path $RepoRoot $KBRoot) "_meta\manifest.yml"
$manifestOperations = @()

if (Test-Path $manifestPath) {
    $manifestContent = (Get-Content $manifestPath -Raw) -replace '\r\n', "`n"
    # Use BEGIN/END anchors to scope to the integrations section only
    $intSection = [regex]::Match($manifestContent, '# === BEGIN: integrations ===(.*?)# === END: integrations ===', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($intSection.Success) {
        # Skip the "- id: grpc-channel" line itself; capture everything after it
        $grpcBlock = [regex]::Match($intSection.Groups[1].Value, '-\s+id:\s+grpc-channel[^\n]*\n([\s\S]+)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        if ($grpcBlock.Success) {
            # All "- id:" entries in the grpc-channel properties are operation IDs
            $opIdMatches = [regex]::Matches($grpcBlock.Groups[1].Value, '^\s+-\s+id:\s+(\w+)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
            $manifestOperations = $opIdMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
        }
    }
}

# ── Compare ───────────────────────────────────────────────────────────────────

$driftItems = [System.Collections.Generic.List[PSCustomObject]]::new()
$codeMethods = $codeRpcMethods | ForEach-Object { $_.Method } | Sort-Object -Unique

# NEW: rpc in proto, not in manifest
foreach ($method in $codeMethods) {
    if ($method -notin $manifestOperations) {
        $rpc = $codeRpcMethods | Where-Object { $_.Method -eq $method } | Select-Object -First 1
        $driftItems.Add([PSCustomObject]@{
            Status      = 'NEW'
            Description = "rpc $method ($($rpc.Request)) returns ($($rpc.Response)) in $($rpc.File)"
            Action      = "Add to _meta/manifest.yml integrations[grpc-channel].operations and update diagrams/grpc-cross-service.mermaid"
            Detail      = $rpc
        })
    }
}

# STALE: in manifest, not in any proto
foreach ($op in $manifestOperations) {
    if ($op -notin $codeMethods) {
        $driftItems.Add([PSCustomObject]@{
            Status      = 'STALE'
            Description = "Operation '$op' in manifest but not found in any .proto file"
            Action      = "Verify if the rpc was renamed or removed; update manifest.yml and grpc-cross-service.mermaid"
            Detail      = $null
        })
    }
}

# ── Output ────────────────────────────────────────────────────────────────────

if ($ReturnObjects) { return $driftItems }

Write-Host ""
Write-Host "=== GRPC SCAN ===" -ForegroundColor Cyan
Write-Host "Proto rpc methods found  : $($codeMethods.Count)" -ForegroundColor Gray
Write-Host "Manifest operations      : $($manifestOperations.Count)" -ForegroundColor Gray
Write-Host ""

if ($driftItems.Count -eq 0) {
    Write-Host "[OK] No gRPC drift detected." -ForegroundColor Green
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
