# Fills the template placeholders in every text file of a new game project (used by SETUP.md step 6d).
# Usage:
#   powershell -ExecutionPolicy Bypass -File setup\fill-placeholders.ps1 -ProjectDir "C:\...\MyGame" -GameName "My Game" -GameId "MyGame"
# Writes UTF-8 WITHOUT a BOM (a BOM breaks the --- header of SKILL.md files).
param(
    [Parameter(Mandatory)][string]$ProjectDir,
    [Parameter(Mandatory)][string]$GameName,
    [Parameter(Mandatory)][string]$GameId
)
# The name goes into file names, skill headers and typed paths, so it must be plain (SETUP.md step 4).
if ($GameName -cnotmatch '^[A-Za-z0-9]+( [A-Za-z0-9]+)*$') {
    throw "GameName '$GameName' must be letters, digits and single spaces only (no : ' ! & - or other punctuation). The store title can have punctuation later."
}
if ($GameId -cnotmatch '^[A-Za-z][A-Za-z0-9]*$') {
    throw "GameId '$GameId' must be letters and digits only, starting with a letter."
}
$ProjectDir = (Resolve-Path $ProjectDir).Path.TrimEnd('\')
$map = [ordered]@{
    '{{GAME_NAME}}'   = $GameName
    '{{GAME_ID}}'     = $GameId
    '{{PROJECT_DIR}}' = $ProjectDir
    '{{BACKUP_FILE}}' = "$GameName Backup.rbxl"
}
$exts = '.md', '.txt', '.json', '.luau', '.lua', '.ps1', '.py'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$changed = 0
Get-ChildItem -Path $ProjectDir -Recurse -File |
    Where-Object { $exts -contains $_.Extension.ToLower() -and $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\setup\\' } |
    ForEach-Object {
        $text = [System.IO.File]::ReadAllText($_.FullName)
        $new = $text
        foreach ($k in $map.Keys) { $new = $new.Replace($k, $map[$k]) }
        if ($new -ne $text) { [System.IO.File]::WriteAllText($_.FullName, $new, $utf8); $changed++ }
    }
"Filled placeholders in $changed file(s)."
$left = Get-ChildItem -Path $ProjectDir -Recurse -File |
    Where-Object { $exts -contains $_.Extension.ToLower() -and $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\setup\\' } |
    Select-String -Pattern '\{\{(GAME_NAME|GAME_ID|PROJECT_DIR|BACKUP_FILE)\}\}'
if ($left) {
    "Placeholders still left (fix these):"
    $left | ForEach-Object { "  $($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
} else {
    "No placeholders left (except {{PLACE_ID}}, filled at the first Save to Roblox)."
}
