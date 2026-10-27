# Real mouse/keyboard input for Roblox Studio (UIAutomation Invoke does NOT work on Studio's Qt menus).
# Usage:
#   studio-input.ps1 -Action shot  -Out C:\path\shot.png     # full-screen screenshot (real screen size)
#   studio-input.ps1 -Action click -X 113 -Y 61               # left click at screen coords
#   studio-input.ps1 -Action type  -X 253 -Y 61 -Text 2       # click a box, select all, type text
#   studio-input.ps1 -Action keys  -Text '^+s' -Window 'Roblox Studio'
#       # SendKeys text (^=Ctrl +=Shift %=Alt {ENTER}) to the foreground window, after activating -Window if given
param(
    [Parameter(Mandatory)][ValidateSet('shot', 'click', 'type', 'keys')][string]$Action,
    [int]$X, [int]$Y, [string]$Text, [string]$Out, [string]$Window
)
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
Add-Type @"
using System; using System.Runtime.InteropServices;
public static class StudioInput {
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint x, uint y, uint d, UIntPtr e);
}
"@
[StudioInput]::SetProcessDPIAware() | Out-Null

function Click([int]$cx, [int]$cy) {
    [StudioInput]::SetCursorPos($cx, $cy) | Out-Null
    Start-Sleep -Milliseconds 80
    [StudioInput]::mouse_event(0x02, 0, 0, 0, [UIntPtr]::Zero) # left down
    [StudioInput]::mouse_event(0x04, 0, 0, 0, [UIntPtr]::Zero) # left up
    Start-Sleep -Milliseconds 300
}

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
        [System.Windows.Forms.SendKeys]::SendWait('^a')
        [System.Windows.Forms.SendKeys]::SendWait($Text)
        "typed '$Text' at $X,$Y"
    }
    'keys' {
        if ($Window) {
            $ok = (New-Object -ComObject WScript.Shell).AppActivate($Window)
            if (-not $ok) { throw "No window titled like '$Window'" }
            Start-Sleep -Milliseconds 300
        }
        [System.Windows.Forms.SendKeys]::SendWait($Text)
        Start-Sleep -Milliseconds 300
        "sent keys '$Text'"
    }
}
