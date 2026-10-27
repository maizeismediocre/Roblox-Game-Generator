---
name: save-game
description: Save the open {{GAME_NAME}} place twice - File > Save to Roblox (cloud) and File > Save to File, overwriting "{{BACKUP_FILE}}" in the repo - using real clicks/keys. Includes the very first Save to Roblox of a new place. Use after every finished task (before the commit), or when the user types /save-game or asks to save.
---

# Save {{GAME_NAME}} (to Roblox + backup file)

Place id: `{{PLACE_ID}}` (if this still shows the placeholder, do "First save" below first).
Backup file: `{{PROJECT_DIR}}\{{BACKUP_FILE}}` (the only backup; overwrite it every time, never make numbered copies).

Tools: `.claude/skills/start-2p-test/scripts/studio-input.ps1` (PowerShell tool, `-ExecutionPolicy Bypass -File`), actions `shot`, `click`, `keys` (SendKeys: `^`=Ctrl, `+`=Shift, `%`=Alt, `{ENTER}`). Save screenshots to the scratchpad and look at them with Read. Screen sizes differ between PCs and menus move, so ALWAYS find a menu item on a fresh screenshot before clicking it. Never click blind. When a click position is proven, write it into "Proven positions" below with the date, so later saves are faster.

- `-Text ''` fails (PowerShell drops the empty argument). To bring Studio to the front send a harmless key: `-Action keys -Text '{F15}' -Window 'Roblox Studio'`.
- If Studio isn't maximised, menu positions shift: press `{ESC}`, maximise the window, then screenshot again.

## 0. Before saving
- Stop any playtest first (`start_stop_play false`, and close any multi-client test windows). Saving during a test saves the wrong thing.
- Make sure no script editor has unsaved, half-typed changes.
- Camera: run (Edit) `workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed` (see `screen-capture`).

## First save (only once, for a brand-new place)
The place must exist on Roblox before DataStores work in Studio tests.
1. Bring Studio to the front, screenshot, click **File**, screenshot, click **Save to Roblox**. A dialog opens to create a new experience.
2. This dialog needs the user's choices (name, which account/group owns it). Fill in the name "{{GAME_NAME}}" and a one-line description from the README pitch, then ask the user to check the owner and click **Create**/**Save** (give them click-by-click steps if they are new to Studio). Do NOT pick "Publish".
3. Read the ids in execute_luau (Edit): `return game.PlaceId .. " " .. game.GameId`. Replace `{{PLACE_ID}}` in this file with the PlaceId (use the Edit tool on this file only).
4. Turn on API access: ask the user to open **Home > Game Settings > Security**, switch on **Enable Studio Access to API Services**, and click **Save** (or do it with clicks, checking each step on a screenshot).
5. Then do "2. Save to File" below with the dialog way, so the backup file exists.

## 1. Save to Roblox
1. Bring Studio to the front (see above).
2. Screenshot, then click **File** in the top-left of the menu bar.
3. Screenshot, then click **Save to Roblox**. Do NOT click "Publish to Roblox": publishing makes the change live for players.
4. Screenshot. If a dialog appears (e.g. about collaborative editing or unpublished scripts), read it and choose the option that saves. If you're unsure, stop and ask the user.
5. **Prove the cloud save landed (no clicks):** in Bash, `curl -s "https://economy.roblox.com/v2/assets/{{PLACE_ID}}/details" | py -I -c "import sys,json; print(json.load(sys.stdin)['Updated'])"`. The time (UTC) must be from the last minute or two. If it didn't change, the click missed or the save failed: screenshot, then save again. Never report a cloud save without this check. (If the place is private and this returns an error, check the window title and Output for errors instead, and note that here.)

## 2. Save to File (overwrite the backup)
**Fast way (try first):** once the backup has been "Save to File As"'d in this Studio session, File > **Save to File** overwrites it straight away with no dialog, and the window title stays the cloud place. Then check the backup's modified time (step 4); if it did NOT change (Studio was restarted, or a dialog opened), use the dialog way.

Dialog way:
1. Bring Studio to the front, then press `^+s` (**Save to File As**). A Windows "Save As" dialog opens. If not, use File > **Save to File As** from the menu.
2. Screenshot. Click the File name box, `^a`, type the full path `{{PROJECT_DIR}}\{{BACKUP_FILE}}`, press `{ENTER}`.
3. If "already exists. Do you want to replace it?" appears, its default button is **No**: press `%y` (Alt+Y) or click **Yes**. Screenshot to confirm.
4. Check it worked: in Bash, `ls -la "{{PROJECT_DIR}}/{{BACKUP_FILE}}"` (forward slashes are fine). The modified time must be now.
5. Check the window title. If Studio now points at the local file instead of the cloud place, tell the user and record it here (future cloud saves may need File > Open from Roblox again).

## 3. Report
One line, e.g. "Saved to Roblox and overwrote {{BACKUP_FILE}} (13:42)". If either save failed, say which one and why. Don't commit a backup that failed to save.

## Proven positions
(Add dated notes here as you learn them, e.g. "2026-01-05, 1920x1080 maximised: File (17,32), Save to Roblox (62,323), Save to File (50,287)".)
