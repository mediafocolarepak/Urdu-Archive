$root = "H:\URDU\StandaloneApp"
$deploy = "$root\github-deploy"

function Pull-File($srcRelPath, $destRelPath, [switch]$stripVersion) {
    $src = Join-Path $deploy $srcRelPath
    $dest = Join-Path $root $destRelPath
    $content = Get-Content $src -Raw -Encoding UTF8
    if ($stripVersion) { $content = $content -replace '\?v=[A-Za-z0-9._-]+', '?v=__V__' }
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
    [System.IO.File]::WriteAllText($dest, $content, (New-Object System.Text.UTF8Encoding $false))
    Write-Output "Synced: $destRelPath"
}

# JS modules - strip real version tokens back to the __V__ placeholder
Get-ChildItem "$deploy\js" -Filter "*.js" | ForEach-Object { Pull-File "js\$($_.Name)" "js\$($_.Name)" -stripVersion }

# Shell HTML - deploy's index.html is team.html's published form
Pull-File "index.html" "team.html" -stripVersion
Pull-File "tests.html" "tests.html" -stripVersion

# CSS
Pull-File "css\style.css" "css\style.css"

# New PWA assets - no __V__ tokens in these
Pull-File "manifest.json" "manifest.json"
Pull-File "sw.js" "sw.js"
Copy-Item "$deploy\icons" "$root\icons" -Recurse -Force

# SQL migration history (versioned in $deploy\supabase\ since 2026-08-29 - the older
# $deploy\sql\ folder is unrelated legacy from a different contributor's tag-taxonomy work,
# left alone here on purpose).
Copy-Item "$deploy\supabase\*.sql" "$root\supabase\" -Force

Write-Output ""
Write-Output "Done. Review with: git -C github-deploy status  (should be clean after this)"
