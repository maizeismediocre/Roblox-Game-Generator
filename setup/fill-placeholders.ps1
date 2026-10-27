# Fills the template placeholders in every text file of a new game project (used by SETUP.md step 6d).
# Usage:
#   powershell -ExecutionPolicy Bypass -File setup\fill-placeholders.ps1 -ProjectDir "C:\...\MyGame" -GameName "My Game" -GameId "MyGame"
# Writes UTF-8 WITHOUT a BOM (a BOM breaks the --- header of SKILL.md files).
param(
    [Parameter(Mandatory)][string]$ProjectDir,
    [Parameter(Mandatory)][string]$GameName,
    [Parameter(Mandatory)][string]$GameId
)
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
