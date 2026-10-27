param([long]$T0, [int]$Count, [int]$Step, [string]$Out)
# Grabs the main screen at T0 + i*Step + Step/2 (ms since 1970, UTC) for i = 0..Count-1.
# Uses the real size of the main screen (DPI aware), so it works on any monitor.
Add-Type -AssemblyName System.Drawing, System.Windows.Forms
Add-Type @"
using System; using System.Runtime.InteropServices;
public static class ShotsDpi { [DllImport("user32.dll")] public static extern bool SetProcessDPIAware(); }
"@
[ShotsDpi]::SetProcessDPIAware() | Out-Null
New-Item -ItemType Directory -Force $Out | Out-Null
$b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
$g = [System.Drawing.Graphics]::FromImage($bmp)
for ($i = 0; $i -lt $Count; $i++) {
    $due = $T0 + $i * $Step + [int]($Step / 2)
    $wait = $due - [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    if ($wait -gt 0) { Start-Sleep -Milliseconds $wait }
    $g.CopyFromScreen($b.Location, [System.Drawing.Point]::Empty, $bmp.Size)
    $bmp.Save((Join-Path $Out ("shot_{0:D3}.png" -f ($i + 1))), [System.Drawing.Imaging.ImageFormat]::Png)
}
$g.Dispose(); $bmp.Dispose()
"done $Count ($($b.Width)x$($b.Height))"
