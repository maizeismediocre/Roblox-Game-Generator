---
name: screen-capture
description: Rules for taking Studio screenshots in {{GAME_NAME}} with screen_capture or code that moves the camera - keeping the camera usable afterwards and fixing captures that hang. Use before any screen_capture or camera-moving execute_luau, or when the user types /screen-capture.
---

# Studio screenshots and the camera

- Screenshots are the most expensive tool. Prove things with code first; take only the photos a review needs.
- After any screen_capture or camera-moving code, run (Edit mode) `workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed`. Always before saving.
- A separate "photo camera" does NOT work; move `workspace.CurrentCamera`.
- If the camera keeps coming back Scriptable, destroy `workspace.CurrentCamera` (Studio makes a new one).
- **screen_capture hangs (~120s)** when Studio isn't the front window. Run `.claude/skills/start-2p-test/scripts/studio-input.ps1 -Action keys -Text '{F15}' -Window "Roblox Studio"` (PowerShell, `-ExecutionPolicy Bypass -File`), retry, then make sure the camera is Fixed.
- For a full-size picture of the whole screen (store pages, checking menus before clicking): `studio-input.ps1 -Action shot -Out <scratchpad>\shot.png`, then look at it with Read.
