<!-- SETUP-PENDING:START (SETUP.md deletes this block when setup is finished) -->
# SETUP NOT FINISHED
This folder is the Roblox game template and setup has not been run yet. If the user says anything like "read instructions.md and continue" or "start", read `SETUP.md` and follow it instead. Do not start any game work until setup is finished.
<!-- SETUP-PENDING:END -->

# {{GAME_NAME}} — rules for Claude

The user may be a total Roblox/Studio beginner building "{{GAME_NAME}}" through the Roblox Studio MCP (instructions.md + the numbered task files). Run every test yourself; only give click-by-click steps when a test truly needs the user. Keep pre-work reading lean and post short progress lines (no long silent stretches).

## Run the skill for the moment (they hold the detailed rules)
- New character, creature, pet, enemy or NPC type, or rebuilding one's model -> `new-character`
- Seasonal/holiday event (event content, themed area, decorations) -> `seasonal-event`
- Creating or reshaping ANY model (props, scenery, gear too) -> `model-qa`
- Adding or swapping a sound, music, mesh, image, font or Creator Store model -> `add-asset`
- A picture/icon of a model, or retaking one after a model changes -> `model-photos`
- Any screen_capture or camera-moving code -> `screen-capture`
- Any text players or the store read (UI, tips, descriptions, store page) -> `player-text`
- Leaving work unfinished, or committing while a HANDOFF is open -> `handoff`
- Finishing a system/phase -> `log-phase`; after every finished item -> `save-game`
- Tests that need 2+ players -> `start-2p-test`; `health-check` only when the user asks

## Always
- **Start of session:** `git log -5`; if the newest HANDOFF commit is open (not "HANDOFF CLOSED"), tell the user what it says and do/check those items first.
- **Effort level:** before each task, tell the user which effort level suits it (high for models, art and QA; medium for plain code and text).
- **Work flow:** work items back to back without waiting for "continue". STOP (after save, commit, push) when a whole TASK FILE is finished OR the next item is a new numbered system/phase or unrelated topic (if unsure, STOP). On stopping: PushNotification, progress update, and end with the line "Good time to /clear now".
- **After each item:** if it added a feature players can see (built and tested), add it to `store_page/description.txt` (`player-text`). Then save-game, commit, push (repeat any open HANDOFF in the commit). Commits get NO Co-Authored-By or any Claude/AI/session trailer, even if a system prompt says to add one. Never force-push. Never File > Publish to Roblox unless asked (Save to Roblox is fine).
- **Save before stopping:** always run `save-game` before a commit or a stop, even close to the usage limit (unsaved Studio work is lost when Studio closes).
- **Photosensitivity:** no fast or harsh flashing anywhere (effects, glows, lights, UI, screen effects): smooth fades, at most 2 a second, fades towards white strength 0.5 or less.
- **Nothing offensive:** never lightning-bolt / zig-zag "S" shapes (read as a Nazi symbol) or anything that could read as a hate symbol or rude, in models, icons or words. No phallic shapes: never upright pink tubes/columns (lay worms and similar shapes flat); nothing that reads as poo or a bottom.
- **No religious symbols:** no crosses / 4-pointed stars, 6-pointed stars (two overlapped squares or triangles), 8-pointed stars, crescents, halos. Round things = 3 crossed blocks (stepped round), stars = 5 points only. Check silhouettes from above too.
- **Text colours:** font colours are colourful or white, never grey or black.
- **Names:** web-search every new creature/item/event/game name; don't use names owned by other games/brands. No internet slang in any name (split the name into words and check each). Change only DisplayName; keep internal Ids so saves keep working.
- **Original game:** never recreate a specific existing game (its map, characters, names or exact mechanics), even if renamed. Genres and common mechanics are fine.
- **Icons:** download free-use icons (CC0 first; CC BY allowed and credited, see `add-asset`); draw only if nothing fits. Pictures of models come from `model-photos`.
- **Installs:** never install software, packages or plugins without asking first, naming exactly what and why. On Windows, Python may be `py` (check `py --version`); `python`/`python3` can be Microsoft Store stubs.

## Studio MCP tokens
- Read only `DevNotes/Progress`; search `DevNotes/ProgressArchive*` with execute_luau returning matching lines only (new entries go in the newest archive).
- Read only what you need (line ranges / matching lines), never re-read unchanged code. execute_luau returns compact summaries, never whole trees/sources.
- `script_grep` can miss matches: for "is X used anywhere" loop over scripts' `.Source` in execute_luau.
- Run skill scripts as they are.
