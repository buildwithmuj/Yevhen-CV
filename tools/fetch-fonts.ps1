# Downloads DM Sans from Google Fonts and writes fonts-inline.css with every
# font file embedded as a base64 data URI.
#
# Why: the published artifact runs under a Content Security Policy that blocks
# external font hosts. Linking Google Fonts there fails silently and the page
# falls back to a system sans, so the faces have to travel with the file.
#
# Output (fonts-inline.css) is generated and git-ignored. Run this once before
# tools/build-artifact.ps1 on a fresh clone.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outFile = Join-Path $root "fonts-inline.css"

# A browser UA is required, otherwise Google serves legacy TTF instead of woff2.
$ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
$api = "https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,400..700;1,9..40,400..700&display=swap"

Write-Host "Fetching DM Sans stylesheet..."
$css = (Invoke-WebRequest -Uri $api -UserAgent $ua -UseBasicParsing).Content

$urls = [regex]::Matches($css, 'url\((https://fonts\.gstatic\.com/[^\)]+\.woff2)\)') |
        ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
if ($urls.Count -eq 0) { throw "No woff2 URLs found in the Google Fonts response." }

foreach ($u in $urls) {
    Write-Host "  inlining $([IO.Path]::GetFileName($u))"
    $bytes = (Invoke-WebRequest -Uri $u -UserAgent $ua -UseBasicParsing).Content
    $b64 = [Convert]::ToBase64String($bytes)
    $css = $css.Replace("url($u)", "url(data:font/woff2;base64,$b64)")
}

[IO.File]::WriteAllText($outFile, $css, (New-Object Text.UTF8Encoding($false)))
"fonts-inline.css: {0} font(s), {1} KB" -f $urls.Count, [math]::Round((Get-Item $outFile).Length / 1KB, 1)
