<#
.SYNOPSIS
    CMN Knowledge Base drift detection — orchestrates all scanners and produces a report.

.DESCRIPTION
    Runs all scan-*.ps1 scripts and aggregates results into a single drift report.
    Exit code 0 = no drift. Exit code 1 = drift detected.

.PARAMETER RepoRoot
    Path to the monorepo root. Defaults to current directory.

.PARAMETER KBRoot
    Path to the knowledge base, relative to RepoRoot.

.PARAMETER OutputFormat
    Console (default) | JSON

.EXAMPLE
    .\swt-cmn-knowledge-base\scripts\detect-drift.ps1
    .\swt-cmn-knowledge-base\scripts\detect-drift.ps1 -OutputFormat JSON
#>

param(
    [string]$RepoRoot    = (Get-Location).Path,
    [string]$KBRoot      = "swt-cmn-knowledge-base",
    [string]$OutputFormat = "Console"
)

$ScriptsDir = Join-Path $KBRoot "scripts"
$Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# ── Run individual scanners ───────────────────────────────────────────────────

function Invoke-Scanner {
    param([string]$Script, [string]$Name)
    $scriptPath = Join-Path (Join-Path $RepoRoot $ScriptsDir) $Script
    if (-not (Test-Path $scriptPath)) {
        return @{ Scanner = $Name; Error = "Script not found: $scriptPath"; Items = @() }
    }
    try {
        $items = & $scriptPath -RepoRoot $RepoRoot -KBRoot $KBRoot -ReturnObjects
        return @{ Scanner = $Name; Error = $null; Items = @($items) }
    } catch {
        return @{ Scanner = $Name; Error = $_.Exception.Message; Items = @() }
    }
}

$endpointResult = Invoke-Scanner "scan-endpoints.ps1" "ENDPOINTS"
$entityResult   = Invoke-Scanner "scan-entities.ps1"  "ENTITIES"
$grpcResult     = Invoke-Scanner "scan-grpc.ps1"      "GRPC"
$eventResult    = Invoke-Scanner "scan-events.ps1"    "EVENTS"

# ── Aggregate ─────────────────────────────────────────────────────────────────

$allResults  = @($endpointResult, $entityResult, $grpcResult, $eventResult)
$totalDrift  = ($allResults | ForEach-Object { $_.Items.Count } | Measure-Object -Sum).Sum
$newCount    = ($allResults.Items | Where-Object { $_.Status -eq 'NEW'     }).Count
$staleCount  = ($allResults.Items | Where-Object { $_.Status -eq 'STALE'   }).Count
$changedCount= ($allResults.Items | Where-Object { $_.Status -eq 'CHANGED' }).Count

# ── Output ────────────────────────────────────────────────────────────────────

if ($OutputFormat -eq "JSON") {
    $report = @{
        Timestamp      = $Timestamp
        TotalDriftItems= $totalDrift
        New            = $newCount
        Stale          = $staleCount
        Changed        = $changedCount
        Scanners       = $allResults
    }
    $report | ConvertTo-Json -Depth 10
} else {
    Write-Host ""
    Write-Host "=== CMN KB DRIFT REPORT $Timestamp ===" -ForegroundColor Cyan
    Write-Host ""

    foreach ($result in $allResults) {
        $count = $result.Items.Count
        $label = if ($count -eq 0) { "[OK]" } else { "[$count drift items]" }
        $color = if ($count -eq 0) { "Green" } else { "Yellow" }

        Write-Host "$($result.Scanner) $label" -ForegroundColor $color

        if ($result.Error) {
            Write-Host "  ERROR: $($result.Error)" -ForegroundColor Red
        }

        foreach ($item in $result.Items) {
            $statusColor = switch ($item.Status) {
                'NEW'     { 'Yellow' }
                'STALE'   { 'Red' }
                'CHANGED' { 'Magenta' }
                default   { 'White' }
            }
            Write-Host "  [$($item.Status)]  $($item.Description)" -ForegroundColor $statusColor
            if ($item.Action) {
                Write-Host "          → $($item.Action)" -ForegroundColor DarkGray
            }
        }
        Write-Host ""
    }

    Write-Host "--- SUMMARY ---" -ForegroundColor Cyan
    Write-Host "Total drift items : $totalDrift"
    Write-Host "  NEW             : $newCount   (in code, not in KB)"
    Write-Host "  STALE           : $staleCount  (in KB, not in code)"
    Write-Host "  CHANGED         : $changedCount (signature mismatch)"

    if ($totalDrift -eq 0) {
        Write-Host ""
        Write-Host "No drift detected. KB is in sync." -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Drift detected. Update KB then run validate-manifest.ps1 + validate-anchors.ps1." -ForegroundColor Yellow
    }
}

exit $(if ($totalDrift -gt 0) { 1 } else { 0 })
