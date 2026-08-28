param(
  [string]$Message = "Update app"
)

$root = "H:\URDU\StandaloneApp"
$deploy = "$root\github-deploy"
$token = Get-Date -Format "yyyyMMddHHmmss"

function Publish-File($relPath, $destRelPath) {
    $src = Join-Path $root $relPath
    $dest = Join-Path $deploy $destRelPath
    $content = Get-Content $src -Raw -Encoding UTF8
    $content = $content -replace '__V__', $token
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
    [System.IO.File]::WriteAllText($dest, $content, (New-Object System.Text.UTF8Encoding $false))
}

Publish-File "team.html" "index.html"
Publish-File "tests.html" "tests.html"
Get-ChildItem "$root\js" -Filter "*.js" | ForEach-Object { Publish-File "js\$($_.Name)" "js\$($_.Name)" }
Copy-Item "$root\css\style.css" "$deploy\css\style.css" -Force
Copy-Item "$root\manifest.json" "$deploy\manifest.json" -Force
Copy-Item "$root\sw.js" "$deploy\sw.js" -Force
if (-not (Test-Path "$deploy\icons")) { New-Item -ItemType Directory -Force -Path "$deploy\icons" | Out-Null }
Copy-Item "$root\icons\*" "$deploy\icons\" -Recurse -Force

Write-Output "Version token: $token"

$leftovers = Get-ChildItem $deploy -Recurse -Include *.html, *.js | Select-String '__V__'
if ($leftovers) {
    Write-Output "WARNING: __V__ placeholder left unsubstituted - fix before pushing:"
    $leftovers | ForEach-Object { Write-Output "  $($_.Path):$($_.LineNumber)" }
    exit 1
}
Write-Output "OK: no leftover __V__ placeholders."

Push-Location $deploy
git add -A
git commit -m $Message
git push
Pop-Location

Write-Output ""
Write-Output "Published. Verify with:"
Write-Output "  curl.exe -s `"https://mediafocolarepak.github.io/Urdu-Archive/js/app.js?v=$token`""
