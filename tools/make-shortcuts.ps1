# Makes a desktop shortcut for a game project:
#   "<Name> - Keep Building"  opens Claude Code in the project folder and types "read instructions.md and continue"
# (To talk to Claude instead, press Esc once it starts and type.)
# It starts a Remote Control session called <Name> (the same as typing /rc), so the session can be
# followed and steered from the Claude app on a phone or another computer. -NoRemoteControl leaves it out.
# Usage:
#   powershell -ExecutionPolicy Bypass -File tools\make-shortcuts.ps1 -ProjectDir "C:\...\MyGame" -Name "My Game"
#   (-NoRemoteControl makes it without Remote Control)
#   (-OutDir <folder> puts it somewhere other than the Desktop, e.g. for testing)
param(
    [Parameter(Mandatory)][string]$ProjectDir,
    [Parameter(Mandatory)][string]$Name,
    [string]$OutDir = [Environment]::GetFolderPath('Desktop'),
    [switch]$NoRemoteControl
)
$ProjectDir = (Resolve-Path $ProjectDir).Path.TrimEnd('\')
$claude = (Get-Command claude -ErrorAction SilentlyContinue).Source
if (-not $claude) { throw "Claude Code (claude) was not found on PATH. Install it or open a new terminal, then run this again." }
# names can't hold these characters in a file name or break the cmd line
$safe = ($Name -replace '[\\/:*?"<>|&^%]', '').Trim()
$cmd = Join-Path $env:WINDIR 'System32\cmd.exe'
$rc = if ($NoRemoteControl) { '' } else { " --remote-control `"$safe`"" }
$file = Join-Path $OutDir "$safe - Keep Building.lnk"
$shell = New-Object -ComObject WScript.Shell
$lnk = $shell.CreateShortcut($file)
$lnk.TargetPath = $cmd
# cmd /k "..." strips the outer quotes, so the inner quotes stay as they are
$lnk.Arguments = "/k `"title Claude - $safe && cd /d `"$ProjectDir`" && claude$rc `"read instructions.md and continue`"`""
$lnk.WorkingDirectory = $ProjectDir
$lnk.IconLocation = "$claude,0"
$lnk.Description = "Claude Code for $safe (continues the next task)"
$lnk.Save()
"Made:"
"  $file"
