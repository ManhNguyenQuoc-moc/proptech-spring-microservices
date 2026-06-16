#!/usr/bin/env pwsh
# validate-kb.ps1
# Validates the CMN Knowledge Base for structural completeness and anchor integrity.
# Run from the swt-cmn-knowledge-base/ directory.

param(
    [string]$KbRoot = $PSScriptRoot + "\.."
)

$errors = @()
$warnings = @()
$passed = @()

Write-Host "`n=== CMN Knowledge Base Validator ===" -ForegroundColor Cyan
Write-Host "KB Root: $KbRoot`n"

# ── 1. Check required files exist ───────────────────────────────────────────
$required = @(
    "README.md",
    "AUTOMATION.md",
    "CHANGELOG.md",
    "_meta\kb-schema.yaml",
    "_meta\anchors.md",
    "_meta\sync-config.yaml",
    "_templates\service-doc-template.md",
    "_templates\entity-template.md",
    "_templates\api-endpoint-template.md",
    "_sync\sync-rules.md",
    ".discovery\confirmed-facts.md",
    ".discovery\inferred-assumptions.md",
    "00-glossary.md",
    "01-architecture.md",
    "02-tech-stack.md",
    "03-conventions.md",
    "04-business-domain.md",
    "05-flows.md",
    "06-integrations.md",
    "07-security-permissions.md",
    "08-deployment-cicd.md",
    "services\administration-api.md",
    "services\customer-api.md",
    "services\web-gateway.md",
    "services\administration-web-app.md",
    "services\web-app.md",
    "services\mobile-app.md",
    "diagrams\architecture.mermaid",
    "diagrams\entity-relations.mermaid",
    "diagrams\data-flow.mermaid",
    "playbooks\onboarding.md",
    "playbooks\add-new-endpoint.md",
    "playbooks\add-new-entity.md",
    "playbooks\add-frontend-page.md"
)

Write-Host "Checking required files..." -ForegroundColor Yellow
foreach ($file in $required) {
    $fullPath = Join-Path $KbRoot $file
    if (Test-Path $fullPath) {
        $passed += "  [OK] $file"
    } else {
        $errors += "  [MISSING] $file"
    }
}

# ── 2. Check anchor integrity ────────────────────────────────────────────────
Write-Host "Checking anchor integrity..." -ForegroundColor Yellow

$anchors = @(
    @{ file = "services\administration-api.md"; anchor = "admin-entities" },
    @{ file = "services\administration-api.md"; anchor = "admin-controllers" },
    @{ file = "services\customer-api.md"; anchor = "customer-entities" },
    @{ file = "services\customer-api.md"; anchor = "customer-controllers" },
    @{ file = "services\web-gateway.md"; anchor = "gateway-routes" },
    @{ file = "01-architecture.md"; anchor = "gateway-routes" },
    @{ file = "03-conventions.md"; anchor = "error-http-map" },
    @{ file = "03-conventions.md"; anchor = "api-response-shape" },
    @{ file = "03-conventions.md"; anchor = "layer-rules" },
    @{ file = "06-integrations.md"; anchor = "grpc-contracts" },
    @{ file = "services\administration-web-app.md"; anchor = "admin-webapp-pages" },
    @{ file = "services\mobile-app.md"; anchor = "mobile-features" },
    @{ file = "02-tech-stack.md"; anchor = "tech-stack-matrix" }
)

foreach ($a in $anchors) {
    $fullPath = Join-Path $KbRoot $a.file
    if (Test-Path $fullPath) {
        $content = Get-Content $fullPath -Raw
        $openTag = "<!-- KB-ANCHOR: $($a.anchor) -->"
        $closeTag = "<!-- /KB-ANCHOR: $($a.anchor) -->"
        if ($content -match [regex]::Escape($openTag) -and $content -match [regex]::Escape($closeTag)) {
            $passed += "  [OK] Anchor '$($a.anchor)' in $($a.file)"
        } else {
            $errors += "  [MISSING ANCHOR] '$($a.anchor)' in $($a.file)"
        }
    }
}

# ── 3. Check for [INFERRED] markers ─────────────────────────────────────────
Write-Host "Counting inferred assumptions..." -ForegroundColor Yellow
$allMd = Get-ChildItem -Path $KbRoot -Filter "*.md" -Recurse | Where-Object { $_.FullName -notmatch "\\node_modules\\" }
$inferredCount = 0
foreach ($f in $allMd) {
    $c = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
    if ($c -match "\[INFERRED\]") {
        $matches = [regex]::Matches($c, "\[INFERRED\]")
        $inferredCount += $matches.Count
    }
}
$warnings += "  [INFO] Found $inferredCount [INFERRED] markers — verify these against code"

# ── 4. Check diagrams are valid Mermaid (basic check) ───────────────────────
Write-Host "Checking diagrams..." -ForegroundColor Yellow
$diagrams = Get-ChildItem -Path (Join-Path $KbRoot "diagrams") -Filter "*.mermaid" -ErrorAction SilentlyContinue
foreach ($d in $diagrams) {
    $content = Get-Content $d.FullName -Raw
    if ($content -match "^(graph|sequenceDiagram|erDiagram|---)" ) {
        $passed += "  [OK] Diagram: $($d.Name)"
    } else {
        $warnings += "  [WARN] Diagram may be malformed: $($d.Name)"
    }
}

# ── 5. Print results ──────────────────────────────────────────────────────────
Write-Host "`n--- PASSED ---" -ForegroundColor Green
$passed | ForEach-Object { Write-Host $_ -ForegroundColor Green }

if ($warnings.Count -gt 0) {
    Write-Host "`n--- WARNINGS ---" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
}

if ($errors.Count -gt 0) {
    Write-Host "`n--- ERRORS ---" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    Write-Host "`nValidation FAILED: $($errors.Count) error(s)" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nValidation PASSED ($($passed.Count) checks, $($warnings.Count) warnings)" -ForegroundColor Green
    exit 0
}
