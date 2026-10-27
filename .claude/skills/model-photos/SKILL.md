---
name: model-photos
description: Take clean pictures (icons) of {{GAME_NAME}} models - characters, variants, gear, items or any model - with a see-through background and the UI's black outline, then upload them and put the ids in the game. Use whenever a picture/icon of a model is needed or a model changed and its picture must be retaken, or when the user types /model-photos.
---

# Pictures of models

Every model picture in the game is made the same way: the model is photographed in Studio twice - against a BLACK and a WHITE backdrop, same camera - and the two photos are compared to cut it out exactly (see-through background, see-through parts stay see-through). Then a black outline is added like the UI icons. Never draw or generate a picture of a model; avoid live 3D ViewportFrames where a picture will do (they look blurry and cost frame rate).

Tools (repo `tools/icons`): `shots.ps1` (grabs the screen on a clock), `cutout.py` (crop + cut out + outline a whole run), `netmatte.py` / `netfinish.py` (the two steps), `sheet.py` (preview sheet). They need Python with Pillow (`py -m pip show pillow`; ask before installing it). Record here where each kind of picture lives (folder in `tools/icons/<kind>` -> the module/config the game reads ids from) as you make them.

## 1. Build the photo stage (execute_luau, Edit)
- Far from the map (x 12000+, y 300). For each model: two copies, one in front of a black backdrop Part and one in front of a white one (SmoothPlastic, 60x60x1, 20 studs behind the model, facing the camera). Destroy scripts, sounds, particles and lights in the copies; Anchored, CastShadow off.
- Pose: `PivotTo(CFrame.new(pos))` (front = -Z). Keep the model's real in-game pose (don't tuck wings etc.); draw wide ones bigger in the UI instead.
- Camera (a friendly 3/4 angle): FOV 30, `dir = (CFrame.Angles(0, -math.rad(28), 0) * CFrame.Angles(math.rad(14), 0, 0)).LookVector`, `distance = size.Magnitude / 2 / math.tan(math.rad(15)) * 1.02`, camera at `box.Position + dir * distance` looking at `box.Position`. Store each shot's CFrame (black copy, then white copy, per model, in order) in CFrameValues under the stage.
- Variant looks (glows, highlights, colour shifts): photograph the REAL in-game look (the game's own effect code applied to the copy), never a tint laid over a picture. Random sparkles break the black/white match: remove them. Highlights: make a FRESH `Clone()` per shot and `Destroy()` it after (Studio stops drawing reused Highlights after a few hundred shots).

## 2. Run the camera and grab the screen together
- execute_luau (Edit): `T0 = DateTime.now().UnixTimestampMillis + 12000`, `task.spawn` a loop that sets CameraType Scriptable + FieldOfView 30 and the CFrame of shot i at `T0 + (i-1)*1500` (set them on EVERY shot, or Studio's editor camera takes over); afterwards FOV 70 and CameraType Fixed. Return T0.
- PowerShell: bring Studio to the front (`.claude/skills/start-2p-test/scripts/studio-input.ps1 -Action keys -Text '{F15}' -Window 'Roblox Studio'`), then `powershell -ExecutionPolicy Bypass -File tools/icons/shots.ps1 -T0 <T0> -Count <shots> -Step 1500 -Out <scratchpad>/shots` (grabs each shot half a step after the camera moves). Studio must stay in front and maximised; the PC must not be used during the run (~1.5 s a shot).
- Check 2-3 pairs before going on (same pose in both, model centred, nothing in front). If a run comes out as sky / a wide view, the editor camera took over: fix the loop and run again.

## 3. Cut out + outline
- First time on this PC: open one shot and measure Studio's 3D view box; set `VIEW` (the 3D view inside the screenshot) and `SQUARE` (a square in the middle of the view) at the top of `tools/icons/cutout.py`, and note the screen size and date in its docstring.
- `py -I tools/icons/cutout.py <scratchpad>/shots <out_dir> <tilt> <name1,name2,...>` - tilt 0 for most models, 35 for long thin tools (fills a square slot diagonally).
- Look at a `sheet.py` preview: outline all the way round, no lines/gizmos, nothing cut off.

## 4. Upload + use
Serve the folder (`py -I -m http.server 8765 --bind 127.0.0.1 --directory <dir>` in the background), `upload_image` with `http://127.0.0.1:8765/<file>` (up to ~30 per call; retry any time-outs), stop the server. Put the ids where the game reads them. Remove the photo stage; camera FieldOfView 70 + CameraType Fixed.

## 5. Check + finish
Playtest everywhere the picture shows (book, shop, hotbar, loading screen...) and photograph it. Then save-game and commit (pictures + any tool changes in the repo).

## Rules
- Outline: black. Undiscovered / not found = solid black (ImageColor3 0,0,0).
- A model changed -> retake its picture (and its variant pictures) in the same session.
- Photosensitivity: any animated picture fades smoothly, at most 2 a second.
