---
name: health-check
description: Run the {{GAME_NAME}} health check - MCP check, progress-log vs game check, and the solo smoke test of the core loop (+ leave and rejoin). Use only when the user asks for it, after a big change to the core loop, or when the user types /health-check.
---

# {{GAME_NAME}} health check

Follow the steps in order. Do NOT re-read the game's scripts for this, and keep progress lines short.

Each file in `scripts/` is ONE `execute_luau` call. Read the file, replace any `{{PLACEHOLDER}}` and send it. Each script returns a single string that starts with `PASS` or `FAIL`. The scripts are written in the last Build Phase ("Polish + launch checklist") and updated whenever the core loop changes. If `scripts/` has no `.luau` files yet, do steps 1 and 3-5 only and say the smoke test doesn't exist yet.

## 1. Connection and game check
1. `list_roblox_studios` → `get_studio_state` → `search_game_tree path=Workspace max_depth=1`. This counts as the MCP check. If it fails, STOP and tell the user (Studio open? MCP server on?).
2. `script_read game.ServerStorage.DevNotes.Progress` (the short log; never read an archive whole). Then run ONE `search_game_tree path=ServerScriptService max_depth=4` and confirm the services for the ticked phases exist. If the checklists, the log and the game disagree, STOP and explain.

## 2. Smoke test (`start_stop_play true` first, then wait ~3 s so the save has loaded)
Run the scripts in the order of this table:

| # | Where | Script | Notes |
|---|-------|--------|-------|
<!-- Filled in the last Build Phase: one row per script, e.g. | a | SERVER | `scripts/a_spawn.server.luau` | returns the spawned item's id | -->

3. `get_console_output` BEFORE stopping (stopping clears it). Look for warnings and errors.
4. Rejoin: `start_stop_play false` → `start_stop_play true` → run the snapshot script again. The saved values must match the ones from before the rejoin.
5. `start_stop_play false`. Report in one line, e.g. "Health check passed: <loop steps> → rejoin all saved, no errors".

## Gotchas
- `execute_luau` returns only the FIRST return value, so return one string.
- execute_luau gets its OWN copy of modules. Use DevTools bindables + remotes, never `require(SomeService)`.
- `script_read` fails while playing. Read `.Source` via execute_luau, or stop first.
- Things that wander make `character_navigation` fail. Use a `Humanoid:MoveTo` loop that re-targets every 0.25 s.
- If Studio is already in Play mode at the start, `start_stop_play false` first (the Edit tree is unavailable while playing).
- The place owner owns every game pass in Studio tests, so pass effects are always on for the test player.
