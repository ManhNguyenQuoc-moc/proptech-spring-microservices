<#
.SYNOPSIS
    Scans CMN source code for domain event publishers and handlers.

.DESCRIPTION
    Finds:
      - ILocalEventBus.PublishAsync<T>() calls (event publishers)
      - ILocalEventHandler<T> implementations (event handlers)
    Compares published event types against features[].events_published in manifest.yml.

    Reports:
      [NEW]   — event published in code, not in manifest features[].events_published
      [STALE] — event in manifest, no publisher found in code

.PARAMETER RepoRoot
.PARAMETER KBRoot
.PARAMETER ReturnObjects
#>

param(
    [string]$RepoRoot     = (Get-Location).Path,
    [string]$KBRoot       = "swt-cmn-knowledge-base",
    [switch]$ReturnObjects
)

# ── Scan for event publishers ─────────────────────────────────────────────────

$searchDir = Join-Path $RepoRoot "swt-cmn-administration-api\src"

$codePublishedEvents = [System.Collections.Generic.List[hashtable]]::new()
$codeHandlers        = [System.Collections.Generic.List[hashtable]]::new()

if (Test-Path $searchDir) {
    $csFiles = Get-ChildItem -Path $searchDir -Recurse -Filter "*.cs" -ErrorAction SilentlyContinue

    foreach ($file in $csFiles) {
        $content = Get-Content $file.FullName -Raw

        # Publishers: _localEventBus.PublishAsync(new EventName(...))
        #             or PublishAsync<EventName>(...)
        $publishMatches = [regex]::Matches($content,
            'PublishAsync\s*(?:<\s*(\w+Event)\s*>)?\s*\(\s*new\s+(\w+Event)\s*[(\{]',
            [System.Text.RegularExpressions.RegexOptions]::Singleline)

        foreach ($m in $publishMatches) {
            $eventName = if ($m.Groups[1].Value) { $m.Groups[1].Value } else { $m.Groups[2].Value }
            if ($eventName) {
                $codePublishedEvents.Add(@{
                    Event  = $eventName
                    File   = $file.FullName.Replace($RepoRoot, '').TrimStart('\')
                })
            }
        }

        # Handlers: class X : ILocalEventHandler<EventName>
        $handlerMatches = [regex]::Matches($content,
            'class\s+(\w+)\s*:.*?ILocalEventHandler\s*<\s*(\w+Event)\s*>')

        foreach ($m in $handlerMatches) {
            $codeHandlers.Add(@{
                HandlerClass = $m.Groups[1].Value
                EventName    = $m.Groups[2].Value
                File         = $file.FullName.Replace($RepoRoot, '').TrimStart('\')
            })
        }
    }
}

# ── Load manifest.yml events_published ───────────────────────────────────────

$manifestPath = Join-Path (Join-Path $RepoRoot $KBRoot) "_meta\manifest.yml"
$manifestEvents = @()

if (Test-Path $manifestPath) {
    $manifestContent = (Get-Content $manifestPath -Raw) -replace '\r\n', "`n"
    # Find ALL events_published: blocks across all features
    $allEventsSections = [regex]::Matches($manifestContent,
        'events_published:\s*\n((?:\s+- \w+\n?)+)',
        [System.Text.RegularExpressions.RegexOptions]::Multiline)
    $allEvents = [System.Collections.Generic.List[string]]::new()
    foreach ($section in $allEventsSections) {
        $eventMatches = [regex]::Matches($section.Groups[1].Value, '-\s+(\w+Event)')
        foreach ($m in $eventMatches) { $allEvents.Add($m.Groups[1].Value) }
    }
    $manifestEvents = $allEvents | Sort-Object -Unique
}

# ── Compare ───────────────────────────────────────────────────────────────────

$driftItems  = [System.Collections.Generic.List[PSCustomObject]]::new()
$codeEventNames = $codePublishedEvents | ForEach-Object { $_.Event } | Sort-Object -Unique

# NEW: event published in code, not in manifest
foreach ($eventName in $codeEventNames) {
    if ($eventName -notin $manifestEvents) {
        $pub = $codePublishedEvents | Where-Object { $_.Event -eq $eventName } | Select-Object -First 1
        $handler = $codeHandlers | Where-Object { $_.EventName -eq $eventName } | Select-Object -First 1
        $handlerNote = if ($handler) { "Handler: $($handler.HandlerClass)" } else { "No handler found" }

        $driftItems.Add([PSCustomObject]@{
            Status      = 'NEW'
            Description = "Event '$eventName' published in $($pub.File) — $handlerNote"
            Action      = "Add to _meta/manifest.yml → relevant feature's events_published[] and update diagrams/event-choreography.mermaid"
            Detail      = @{ Publisher = $pub; Handler = $handler }
        })
    }
}

# STALE: in manifest, no publisher found
foreach ($eventName in $manifestEvents) {
    if ($eventName -notin $codeEventNames) {
        $driftItems.Add([PSCustomObject]@{
            Status      = 'STALE'
            Description = "Event '$eventName' in manifest events_published but no PublishAsync call found"
            Action      = "Verify if event was renamed/removed; update manifest.yml and event-choreography.mermaid"
            Detail      = $null
        })
    }
}

# ── Bonus: unhandled events ───────────────────────────────────────────────────
# Warn about published events with no handler (potential bug)
foreach ($eventName in $codeEventNames) {
    $hasHandler = $codeHandlers | Where-Object { $_.EventName -eq $eventName }
    if (-not $hasHandler) {
        Write-Host "[WARN] Event '$eventName' is published but has no ILocalEventHandler<T> found." -ForegroundColor Magenta
    }
}

# ── Output ────────────────────────────────────────────────────────────────────

if ($ReturnObjects) { return $driftItems }

Write-Host ""
Write-Host "=== EVENT SCAN ===" -ForegroundColor Cyan
Write-Host "Events published in code : $($codeEventNames.Count)" -ForegroundColor Gray
Write-Host "Event handlers found     : $($codeHandlers.Count)" -ForegroundColor Gray
Write-Host "Events in manifest       : $($manifestEvents.Count)" -ForegroundColor Gray
Write-Host ""

if ($driftItems.Count -eq 0) {
    Write-Host "[OK] No event drift detected." -ForegroundColor Green
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
