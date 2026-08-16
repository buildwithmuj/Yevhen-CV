# Builds artifact.html from index.html for publishing on claude.ai.
#
# Artifacts are served as a single page under a strict Content Security Policy:
# no external requests, and no <!doctype>/<html>/<head>/<body> wrapper (the host
# supplies it). So this extracts the stylesheet and body, and swaps the Google
# Fonts <link> for the inlined faces produced by tools/fetch-fonts.ps1.
#
# Theme handling (light / dark / system) lives in index.html itself and needs no
# patching here.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$fontFile = Join-Path $root "fonts-inline.css"

if (-not (Test-Path $fontFile)) {
    throw "fonts-inline.css is missing. Run tools/fetch-fonts.ps1 first."
}

$src = [IO.File]::ReadAllText((Join-Path $root "index.html")) -replace "`r`n", "`n"
$fontCss = [IO.File]::ReadAllText($fontFile) -replace "`r`n", "`n"

$css = [regex]::Match($src, '(?s)<style>(.*?)</style>').Groups[1].Value
$body = [regex]::Match($src, '(?s)<body>(.*?)</body>').Groups[1].Value
if (-not $css -or -not $body) { throw "Could not extract <style>/<body> from index.html" }

$out = "<title>Yevhen Harmash</title>`n<style>`n" + $fontCss + "`n" + $css + "`n</style>`n" + $body
[IO.File]::WriteAllText((Join-Path $root "artifact.html"), $out, (New-Object Text.UTF8Encoding($false)))
"artifact.html: {0} KB" -f [math]::Round((Get-Item (Join-Path $root "artifact.html")).Length / 1KB, 1)
