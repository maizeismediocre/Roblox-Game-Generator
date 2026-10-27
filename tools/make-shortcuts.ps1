# Makes two desktop shortcuts for a game project:
#   "<Name> - Claude"         opens Claude Code in the project folder
#   "<Name> - Claude (auto)"  the same, and types "read instructions.md and continue" for you
# Both start a Remote Control session called <Name>, so the session can be followed from the
# Claude app on another device.
# Usage:
#   powershell -ExecutionPolicy Bypass -File tools\make-shortcuts.ps1 -ProjectDir "C:\...\MyGame" -Name "My Game"
#   (-OutDir <folder> puts them somewhere other than the Desktop, e.g. for testing)
param(
    [Parameter(Mandatory)][string]$ProjectDir,
    [Parameter(Mandatory)][string]$Name,
    [string]$OutDir = [Environment]::GetFolderPath('Desktop')
)
$ProjectDir = (Resolve-Path $ProjectDir).Path.TrimEnd('\')
$claude = (Get-Command claude -ErrorAction SilentlyContinue).Source
if (-not $claude) { throw "Claude Code (claude) was not found on PATH. Install it or open a new terminal, then run this again." }
# names can't hold these characters in a file name or break the cmd line
$safe = ($Name -replace '[\\/:*?"<>|&^%]', '').Trim()
$cmd = Join-Path $env:WINDIR 'System32\cmd.exe'
$shell = New-Object -ComObject WScript.Shell
$made = @()
foreach ($auto in $false, $true) {
    $file = if ($auto) { "$safe - Claude (auto).lnk" } else { "$safe - Claude.lnk" }
    $prompt = if ($auto) { ' "read instructions.md and continue"' } else { '' }
    $lnk = $shell.CreateShortcut((Join-Path $OutDir $file))
    $lnk.TargetPath = $cmd
    # cmd /k "..." strips the outer quotes, so the inner quotes stay as they are
    $lnk.Arguments = "/k `"title Claude - $safe && cd /d `"$ProjectDir`" && claude --remote-control `"$safe`"$prompt`""
    $lnk.WorkingDirectory = $ProjectDir
    $lnk.IconLocation = "$claude,0"
    $lnk.Description = if ($auto) { "Claude Code for $safe (continues the next task)" } else { "Claude Code for $safe" }
    $lnk.Save()
    $made += (Join-Path $OutDir $file)
}
"Made:"
$made | ForEach-Object { "  $_" }
