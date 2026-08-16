# Renders cv.html to Yevhen-Harmash-CV.pdf using headless Chrome or Edge.
# cv.html is the print-layout source of truth for the CV; edit it, then re-run.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$src = Join-Path $root "cv.html"
$out = Join-Path $root "Yevhen-Harmash-CV.pdf"

if (-not (Test-Path $src)) { throw "cv.html not found at $src" }

$candidates = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
)
$browser = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw "No Chrome or Edge found. Install one, or print cv.html to PDF from any browser." }

# file:// URI, with spaces escaped so paths like "Yevhen CV" resolve
$uri = "file:///" + ($src -replace '\\', '/' -replace ' ', '%20')

if (Test-Path $out) { Remove-Item $out -Force }
Write-Host "Rendering with $([IO.Path]::GetFileName($browser))..."

# virtual-time-budget gives webfonts time to load before the page is captured
& $browser --headless=new --disable-gpu --no-pdf-header-footer `
    --virtual-time-budget=8000 --print-to-pdf="$out" $uri 2>$null
Start-Sleep -Seconds 2

if (-not (Test-Path $out)) { throw "PDF was not produced." }
$bytes = [IO.File]::ReadAllBytes($out)
$pages = ([regex]::Matches([Text.Encoding]::ASCII.GetString($bytes), '/Type\s*/Page[^s]')).Count
"Yevhen-Harmash-CV.pdf: {0} KB, {1} page(s)" -f [math]::Round($bytes.Length / 1KB, 1), $pages
