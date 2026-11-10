---
name: save-game
description: Save the open {{GAME_NAME}} place twice - File > Save to Roblox (cloud) and File > Save to File, overwriting "{{BACKUP_FILE}}" in the repo - using real clicks/keys, then refresh the text copies of the scripts in src/. Includes the very first Save to Roblox of a new place. Use after every finished task (before the commit), or when the user types /save-game or asks to save.
---

# Save {{GAME_NAME}} (to Roblox + backup file)

Place id: `{{PLACE_ID}}` (if this still shows the placeholder, do "First save" below first).
Backup file: `{{PROJECT_DIR}}\{{BACKUP_FILE}}` (the only backup; overwrite it every time, never make numbered copies).

Tools: `.claude/skills/start-2p-test/scripts/studio-input.ps1`, run with the PowerShell tool from the project folder as `powershell -ExecutionPolicy Bypass -File .claude/skills/start-2p-test/scripts/studio-input.ps1 -Action ...` (this spelling is approved in advance, so it doesn't stop to ask). Actions: `shot`, `click`, `keys` for shortcuts and special keys (SendKeys: `^`=Ctrl, `+`=Shift, `%`=Alt, `{ENTER}`), and `text` for typing a path or name exactly as written (never send a path with `keys`: brackets and `+ ^ % ~` in it would be read as shortcuts). The script only clicks and types in Roblox Studio windows and refuses anything else. If it refuses while Studio is in front, its message names the program it found: tell the user and stop; never look for a way round it. Save screenshots to the scratchpad and look at them with Read. Screen sizes differ between PCs and menus move, so ALWAYS find a menu item on a fresh screenshot before clicking it. Never click blind. When a click position is proven, write it into "Proven positions" below with the date, so later saves are faster.

- `-Text ''` fails (PowerShell drops the empty argument). To bring Studio to the front send a harmless key: `-Action keys -Text '{F15}' -Window 'Roblox Studio'`.
- If Studio isn't maximised, menu positions shift: press `{ESC}`, maximise the window, then screenshot again.

## 0. Before saving
- Stop any playtest first (`start_stop_play false`, and close any multi-client test windows). Saving during a test saves the wrong thing.
- Make sure no script editor has unsaved, half-typed changes.
- Camera: run (Edit) `workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed` (see `screen-capture`).

## First save (only once, for a brand-new place)
The place must exist on Roblox before DataStores work in Studio tests.
1. Bring Studio to the front, screenshot, click **File**, screenshot, click **Save to Roblox**. A dialog opens to create a new experience.
2. This dialog needs the user's choices (name, which account/group owns it). Fill in the name "{{GAME_NAME}}" and a one-line description from the README pitch, then ask the user to check the owner (the **Creator** box) and the two switches, and to click **Create**/**Save**. Tell them what the switches do and leave the choice to them: **Team Create** turns on collaboration and cloud autosave; **Data Sharing** lets Roblox use the experience's data to train its AI models unless it is switched off. Never change either switch yourself (give them click-by-click steps if they are new to Studio). Do NOT pick "Publish".
3. Read the ids in execute_luau (Edit): `return game.PlaceId .. " " .. game.GameId`. Replace `{{PLACE_ID}}` in this file with the PlaceId (use the Edit tool on this file only).
4. Turn on API access: ask the user to open **Home > Game Settings > Security**, switch on **Enable Studio Access to API Services**, and click **Save** (or do it with clicks, checking each step on a screenshot).
5. Then do "2. Save to File" below with the dialog way, so the backup file exists.

## 1. Save to Roblox
1. Bring Studio to the front (see above).
2. Screenshot, then click **File** in the top-left of the menu bar.
3. Screenshot, then click **Save to Roblox**. Do NOT click "Publish to Roblox": publishing makes the change live for players.
4. Screenshot. If a dialog appears (e.g. about collaborative editing or unpublished scripts), read it and choose the option that saves. If you're unsure, stop and ask the user.
5. **Prove the cloud save landed (no clicks):** in Bash, from the project folder, `py -I tools/cloud_save_time.py {{PLACE_ID}}`. It prints the last cloud save time (UTC) and how many seconds ago that was: it must be under about 120. If it is older, the click missed or the save failed: screenshot, then save again. Never report a cloud save without this check. (If it prints CHECK FAILED because the place is private, check the window title and Output for errors instead, and note that here.)

## 2. Save to File (overwrite the backup)
**Fast way (try first):** once the backup has been "Save to File As"'d in this Studio session, File > **Save to File** overwrites it straight away with no dialog, and the window title stays the cloud place. Then check the backup's modified time (step 4); if it did NOT change (Studio was restarted, or a dialog opened), use the dialog way.

Dialog way:
1. Bring Studio to the front, then press `^+s` (**Save to File As**). A Windows "Save As" dialog opens. If not, use File > **Save to File As** from the menu.
2. Screenshot. Click the File name box, press `^a`, then type the full path with `-Action text -Text '{{PROJECT_DIR}}\{{BACKUP_FILE}}'` and press `{ENTER}` with `-Action keys`. Screenshot before pressing Enter if the path has brackets or other unusual characters, and check the box shows it exactly.
3. If "already exists. Do you want to replace it?" appears, its default button is **No**: press `%y` (Alt+Y) or click **Yes**. Screenshot to confirm.
4. Check it worked: in Bash, `ls -la "{{PROJECT_DIR}}/{{BACKUP_FILE}}"` (forward slashes are fine). The modified time must be now.
5. Check the window title. If Studio now points at the local file instead of the cloud place, tell the user and record it here (future cloud saves may need File > Open from Roblox again).
6. Size: if the backup is over 50 MB, tell the user (GitHub refuses files over 100 MB, and every committed version adds to the repo).

## 3. Refresh the script copies
In Bash, from the project folder: `py -I tools/export_scripts.py "{{BACKUP_FILE}}" src`. It reads the backup just saved and writes every script as a text file under `src/`, so git shows what changed in the code and scripts can be read without Studio. It must print `EXPORTED <n> scripts`. If it prints `EXPORT FAILED`, the saves are still good: say so in the report, carry on, and fix `tools/export_scripts.py` when the current item is done. If the reason is zstd, Python is older than 3.14: tell the user to install Python 3.14 (README Part 1, step 6). Until then leave `src/` out and read code with `script_read`. Never edit files in `src/` by hand: the game doesn't read them, and the next save overwrites them.

## 4. Report
One line, e.g. "Saved to Roblox and overwrote {{BACKUP_FILE}} (13:42), 48 scripts exported". If a save failed, say which one and why. Don't commit a backup that failed to save.

## What goes in the commit
- Every commit: `src/`, `devnotes/`, task files and any other changed text files.
- The backup `.rbxl`: only the commit before a STOP and a HANDOFF commit. It is still overwritten on disk at every save; it is left out of the other commits because git keeps every version and the repo grows fast.

## Proven positions
(Add dated notes here as you learn them, e.g. "2026-01-05, 1920x1080 maximised: File (17,32), Save to Roblox (62,323), Save to File (50,287)".)
