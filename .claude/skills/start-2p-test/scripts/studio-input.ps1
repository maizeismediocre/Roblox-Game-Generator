# Real mouse/keyboard input for Roblox Studio (UIAutomation Invoke does NOT work on Studio's Qt menus).
# Usage:
#   studio-input.ps1 -Action shot  -Out C:\path\shot.png     # full-screen screenshot (real screen size)
#   studio-input.ps1 -Action click -X 113 -Y 61               # left click at screen coords
#   studio-input.ps1 -Action type  -X 253 -Y 61 -Text 2       # click a box, select all, type the text exactly as written
#   studio-input.ps1 -Action text  -Text 'C:\Games (A)\x.rbxl' -Window 'Save As'
#       # type the text exactly as written into the box that has focus (file paths, names), no click
#   studio-input.ps1 -Action keys  -Text '^+s' -Window 'Roblox Studio'
#       # SendKeys text (^=Ctrl +=Shift %=Alt {ENTER}) to the foreground window, after activating -Window if given
#   studio-input.ps1 -Action list                                  # every Studio window: process id and title
#   studio-input.ps1 -Action keys -Text '{F15}' -ProcessId 1234    # bring ONE Studio window forward by process id
#       # (-ProcessId works with 'keys' and 'text'. Use it when two windows share a title, such as the two
#       #  "Place1" client windows of a 2-player test. {F15} is a key that does nothing.)
# 'type' and 'text' send plain text: the SendKeys special characters + ^ % ~ ( ) { } [ ] are typed as themselves.
# Use 'keys' only for shortcuts and special keys, never for paths or names.
#
# SAFETY: this script runs without asking the user, so it only ever acts on Roblox Studio. A click is refused
# unless the window under that point belongs to Studio, and keys are refused unless Studio (or one of its own
# dialogs, such as "Save As") is the front window. It will not click or type in a terminal, a browser or any
# other program. Do not add a way round this check.
param(
    [Parameter(Mandatory)][ValidateSet('shot', 'click', 'type', 'text', 'keys', 'list')][string]$Action,
    [int]$X, [int]$Y, [string]$Text, [string]$Out, [string]$Window, [int]$ProcessId
)
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
Add-Type @"
using System; using System.Runtime.InteropServices;
[StructLayout(LayoutKind.Sequential)] public struct StudioPoint { public int X; public int Y; }
public static class StudioInput {
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint x, uint y, uint d, UIntPtr e);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern IntPtr WindowFromPoint(StudioPoint p);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint processId);
}
"@
[StudioInput]::SetProcessDPIAware() | Out-Null

# The only programs this script may click or type in.
$StudioProcesses = 'RobloxStudioBeta', 'RobloxStudio'

function ProcessNameOf([IntPtr]$handle) {
    if ($handle -eq [IntPtr]::Zero) { return '(no window)' }
    $id = [uint32]0
    [void][StudioInput]::GetWindowThreadProcessId($handle, [ref]$id)
    try { (Get-Process -Id $id -ErrorAction Stop).ProcessName } catch { '(unknown)' }
}

function Assert-StudioInFront {
    $name = ProcessNameOf ([StudioInput]::GetForegroundWindow())
    if ($StudioProcesses -notcontains $name) {
        throw "Refused: the front window belongs to '$name', not Roblox Studio. Nothing was typed. Bring Studio to the front (-Window 'Roblox Studio') and try again."
    }
}

function Assert-StudioAt([int]$px, [int]$py) {
    $p = New-Object StudioPoint
    $p.X = $px; $p.Y = $py
    $name = ProcessNameOf ([StudioInput]::WindowFromPoint($p))
    if ($StudioProcesses -notcontains $name) {
        throw "Refused: the window at $px,$py belongs to '$name', not Roblox Studio. Nothing was clicked. Take a fresh screenshot and check where Studio is."
    }
}

function Click([int]$cx, [int]$cy) {
    Assert-StudioAt $cx $cy
    [StudioInput]::SetCursorPos($cx, $cy) | Out-Null
    Start-Sleep -Milliseconds 80
    [StudioInput]::mouse_event(0x02, 0, 0, 0, [UIntPtr]::Zero) # left down
    [StudioInput]::mouse_event(0x04, 0, 0, 0, [UIntPtr]::Zero) # left up
    Start-Sleep -Milliseconds 300
}

# Wraps each SendKeys special character in braces so it is typed as itself.
function Literal([string]$s) { $s -replace '([+^%~(){}\[\]])', '{$1}' }

function Activate([string]$title) {
    $shell = New-Object -ComObject WScript.Shell
    $ok = $shell.AppActivate($title)
    if (-not $ok) {
        # AppActivate only matches the START of a title, and Studio's is "<place or file> - Roblox Studio".
        # So look for a Studio window whose title contains the text and bring it forward by its process.
        $studio = Get-Process -Name $StudioProcesses -ErrorAction SilentlyContinue |
            Where-Object { $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle.IndexOf($title, [StringComparison]::OrdinalIgnoreCase) -ge 0 } |
            Select-Object -First 1
        if ($studio) { $ok = $shell.AppActivate($studio.Id) }
    }
    if (-not $ok) { throw "No window titled like '$title'" }
    Start-Sleep -Milliseconds 300
}

# Brings one Studio window forward by its process id (from -Action list). Refuses any other program.
function ActivateProcess([int]$id) {
    $proc = Get-Process -Id $id -ErrorAction SilentlyContinue
    if (-not $proc -or $StudioProcesses -notcontains $proc.ProcessName) {
        throw "Refused: process $id is not a Roblox Studio window. Run -Action list to see the Studio windows."
    }
    if (-not (New-Object -ComObject WScript.Shell).AppActivate($id)) { throw "Could not bring Studio process $id to the front" }
    Start-Sleep -Milliseconds 300
}

function Focus { if ($ProcessId) { ActivateProcess $ProcessId } elseif ($Window) { Activate $Window } }

function Send([string]$keys) {
    Assert-StudioInFront
    [System.Windows.Forms.SendKeys]::SendWait($keys)
}

try {
    switch ($Action) {
        'shot' {
            $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
            $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.CopyFromScreen($b.Location, [System.Drawing.Point]::Empty, $b.Size)
            $bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
            $g.Dispose(); $bmp.Dispose()
            "saved $Out ($($b.Width)x$($b.Height))"
        }
        'click' { Click $X $Y; "clicked $X,$Y" }
        'type' {
            Click $X $Y
            Send '^a'
            Send (Literal $Text)
            "typed '$Text' at $X,$Y"
        }
        'text' {
            Focus
            Send (Literal $Text)
            Start-Sleep -Milliseconds 300
            "typed '$Text'"
        }
        'list' {
            Get-Process -Name $StudioProcesses -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } |
                ForEach-Object { "$($_.Id)`t$($_.MainWindowTitle)" }
        }
        'keys' {
            Focus
            Send $Text
            Start-Sleep -Milliseconds 300
            "sent keys '$Text'"
        }
    }
} catch {
    $_.Exception.Message
    exit 1
}
