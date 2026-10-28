# Roblox game template — first-time setup (for Claude)

The user has asked you to read this file. Run the setup below from start to finish. It turns this template into a ready-to-build Roblox game project: pick a genre, generate an original game idea, write the task files, write `instructions.md`, delete the setup files, and offer desktop shortcuts.

## Rules while setting up
- The user may be a total beginner. Plain, friendly English; short progress lines; no jargon without a few words explaining it.
- Use the AskUserQuestion tool for every choice (the user can always type their own answer with "Other").
- Don't change anything outside the project folder, except the copy step (step 5) and the desktop shortcuts (step 8, Claude CLI only).
- Never install anything without asking first (CLAUDE.md "Installs").
- Files with Windows paths or backslashes: write them with the Write tool, not shell heredocs (heredocs mangle `\\`).
- Everything in CLAUDE.md "Always" applies to the idea too: original game, no offensive or religious symbols, no slang names, web-searched names.

## 1. Where are we?
- `TEMPLATE` = this folder. If it contains `TEMPLATE_MASTER.txt`, it is the user's master copy: never change or delete anything in it. The game project will be a COPY made in step 5, and every later step works in the copy (`PROJECT` = the new folder; use absolute paths and `git -C`).
- Otherwise the user already copied the template: `PROJECT` = this folder and you work in place.

## 2. Quick checks (one progress line, don't stop on problems)
Run these and report one line, e.g. "Checks: git OK, Claude OK, Studio MCP found".
- `git --version` (needed for saving history). If missing, tell the user it's needed and offer to explain how to install Git for Windows (don't install it yourself).
- `$env:CLAUDE_CODE_ENTRYPOINT` (PowerShell): `cli` = the terminal Claude CLI (desktop shortcuts are offered in step 8); anything else = no shortcuts. Only when it is `cli`, also check `where.exe claude` (the shortcuts need it).
- `Test-Path "$env:LOCALAPPDATA\Roblox\mcp.bat"` (PowerShell). This is the Roblox Studio MCP server that `.mcp.json` starts automatically.
  - If it's missing, Studio's MCP server hasn't been turned on yet. Tell the user: open Roblox Studio, open the **Assistant** window, click its **...** button (top right) > **Settings** > **MCP Servers** tab, and turn on **Enable Studio as MCP server** (if the menus look different, web-search "Roblox Studio enable MCP server" and give the current steps). Then restart Claude in the project (type `/exit`, then `claude` in the same window; or later use the desktop shortcut once it exists). Setup carries on without it; only the game building needs it.
- If the Roblox_Studio tools are available now, call `list_roblox_studios` and note whether Studio is open.

## 3. Pick a genre
Ask (AskUserQuestion, header "Genre"): "What kind of game do you want to make?" with options:
1. **Random genre (Recommended)** - "I'll roll a random genre; you can reroll it as many times as you like."
2. **Show me the list** - "See all the genres and pick one."
3. **Simulator** - "Collect, upgrade, grow numbers, unlock new areas."
4. **Tycoon** - "Build and run a business that earns money while you play."
(The user can type any genre or mix under "Other", e.g. "cosy fishing + farming".)

- **Random:** pick with real randomness, never by choosing yourself:
  `Get-Content "<TEMPLATE>\setup\genres.txt" | Where-Object { $_ -and -not $_.StartsWith('#') } | Get-Random` (PowerShell). Each line is `Genre | short description`. Leave out genres already rolled this session (add `| Where-Object { $_ -notlike 'Obby*' }` etc.).
- **List:** show `setup/genres.txt` as a numbered list (genre + description), then ask them to type a number or a name (plain text answer is fine).
- Show the genre with its one-line description and ask (header "Genre"): "Keep <Genre>?" options **Keep it** / **Reroll** / **Choose from the list**. Repeat until they keep one.

## 4. Generate the game idea
Write ONE original game idea for the chosen genre. It must be:
- **Original.** Not a copy of a specific existing game (its map, characters, names, story or exact twist), even renamed. Use the genre's common mechanics, then add a twist of your own.
- **Fun in 30 seconds, worth coming back to for weeks:** a short core loop (30-90 s) with something satisfying in it, long-term progression (upgrades, areas, collection), and a reason to come back (automatic weekly rotation, daily reward, seasonal events).
- **Better with friends, fine alone:** at least one real co-op or social feature (helping, trading, visiting, teaming up), never needed to progress.
- **Friendly:** for players 9+; cute or funny, not gory; no gambling mechanics; no real-world religion, politics or brands.
- **Buildable by Claude through the Studio MCP:** players are normal Roblox avatars; every model is built from plain parts in a chunky block style (no custom meshes, no Blender, no hand-made animations); one place with several areas (no extra places); mobile-friendly controls (tap, joystick, a few big buttons). An MVP that fits in 6-9 build phases.
- **Fair monetisation:** game passes and developer products for specific, known things (cosmetics, convenience, boosts); nothing pay-to-win, no paid random items (no paid eggs/crates/gacha).

Before showing it: web-search the game name (`"<Name>" Roblox`, `"<Name>" game`) and every named creature/item in the pitch; swap any name that's taken or is slang.

Show it as a pitch card (plain text, short lines):
```
<Game Name>   (other name ideas: <Alt 1>, <Alt 2>)
Genre: <genre>
Pitch: <one sentence>
Core loop: <step> -> <step> -> <step> -> (repeat)
The hook: <what makes it fun / different>
Progression: <what you unlock and upgrade>
With friends: <the co-op/social feature>
Collect: <the main things to collect, e.g. 15 creatures in 4 rarities>
World: <3-4 areas>
Look: <art style in one line: blocky part-built, colour palette, mood>
Weekly: <what changes automatically every week>
Events: <seasonal/holiday events, or "none">
Robux: <2-3 passes, 1-2 products>
```
Ask (header "Idea"): "Do you want to make this game?" options **Yes, use this idea** / **New idea, same genre** / **Change the genre** (back to step 3). The user can type changes under "Other": apply them and show the card again. Repeat until they say yes.

Then fix the names (AskUserQuestion if they want to pick from the name ideas):
- `GAME_NAME` = the display name, e.g. `Critter Haul`.
- `GAME_ID` = GAME_NAME in CamelCase with only letters and digits, e.g. `CritterHaul`.

## 5. Project options (one AskUserQuestion with these questions)
1. **Only if TEMPLATE is the master copy:** "Where should I make the game folder?" (header "Folder") options: `<Documents>\Roblox Games\<GAME_ID>` (Recommended) / `<Desktop>\<GAME_ID>` (find real paths with `[Environment]::GetFolderPath('MyDocuments')` / `'Desktop'`; OneDrive can move them). Refuse a folder that already exists and isn't empty.
2. "Back up the project to GitHub?" (header "GitHub") only if `gh auth status` works: **Private GitHub repo (Recommended)** / **Only on this PC**. If gh is missing or not logged in, don't ask: use local git and mention they can add GitHub later.

Then, if TEMPLATE is the master copy, copy it (PowerShell): `robocopy "<TEMPLATE>" "<PROJECT>" /E /XD .git /XF TEMPLATE_MASTER.txt` (robocopy exit codes 0-7 mean success). Check `PROJECT\SETUP.md` exists. From here on, every path is inside PROJECT.

## 6. Write the project files (all inside PROJECT)
Post a progress line per file. Read each template only when you write it.

**a. Task files.** For each template in `setup/task_templates/`, write the file of the same name into the PROJECT root. Keep every fixed section word for word. Replace every `<!-- GENERATE: ... -->` block with content for THIS game, following the instructions inside the block, in the same style as the fixed text (plain English, specific numbers, "- [ ]" checklist lines matching the `## ...` headings). Rules:
- Scope: the build phases deliver the whole pitch card as a working MVP. Later files (economy, art, polish, live-ops, QA, store page) are tailored to the game's systems and names.
- If the pitch has no seasonal events, leave out the seasonal-events part of `05_liveops.md` (as the GENERATE block says).
- STATUS lines start as `STATUS: NOT STARTED`; every item starts `- [ ]`.
- After writing, grep the new files: no `GENERATE` or `{{` left (except `{{GAME_NAME}}`-style placeholders, which step 6d fills).

**b. instructions.md.** Copy `setup/instructions.template.md` to `PROJECT/instructions.md`. Its task-file list must match the files you wrote.

**c. Skills.** In `.claude/skills/`:
- `new-character` and `seasonal-event` each have a `## GAME-SPECIFIC` section: fill it for this game (what the game calls them, where their config/models live, sizes, rarities, the art style lines from the pitch). If the game has NO such thing (e.g. a racing game with no creatures or NPC types; no seasonal events), delete that skill's folder and its line in CLAUDE.md "Run the skill for the moment".
- `model-qa` section 0 "ART STYLE": replace the `<!-- GENERATE -->` block with this game's style lines (from the pitch's Look + the template's chunky block rules).
- `log-phase`: fill the section table (one row per task file, its progress-log section name).

**d. Fill the placeholders.** Run (PowerShell):
`powershell -ExecutionPolicy Bypass -File "<PROJECT>\setup\fill-placeholders.ps1" -ProjectDir "<PROJECT>" -GameName "<GAME_NAME>" -GameId "<GAME_ID>"`
It replaces `{{GAME_NAME}}`, `{{GAME_ID}}`, `{{PROJECT_DIR}}`, and `{{BACKUP_FILE}}` in every text file (UTF-8, no BOM) and lists any `{{...}}` left. Only `{{PLACE_ID}}` (filled at the first Save to Roblox, see `save-game`) may remain.

**e. Store page + readme.**
- `store_page/description.txt`: keep the template's structure; fill the TITLE OPTIONS with the 3 name ideas. The description itself stays empty until features are built and tested (`player-text`).
- Replace `README.md` with a short project readme: the pitch card, how to start a session (if shortcuts were made: "double-click the '<GAME_NAME> - Claude (auto)' shortcut, or"; always: "open Claude in this folder and type: read instructions.md and continue"), and the task-file list.

**f. Remove setup.** In PROJECT: delete the block between `<!-- SETUP-PENDING:START` and `SETUP-PENDING:END -->` (both lines included) from CLAUDE.md, then delete `SETUP.md` and the `setup/` folder. Check `TEMPLATE_MASTER.txt` is not in PROJECT.

**g. Git.** `git -C "<PROJECT>" init -b main`, `git add -A`, commit "Project setup: <GAME_NAME> (<genre>)". If `git config user.name` / `user.email` are empty, ask the user what to use (only for this repo: `git -C ... config user.name ...`). No AI trailer (CLAUDE.md). If GitHub was chosen: `gh repo create <GAME_ID> --private --source "<PROJECT>" --push` (if the name is taken, ask for another).

## 7. Studio connection
- If the Roblox_Studio tools work: say "Studio MCP connected" (one line).
- If not: give the step-2 instructions for turning on Studio's MCP server once more, and say Build Phase 1 starts by checking the connection.
- Tell the user what to have ready for the first session: Roblox Studio open with a NEW **Baseplate** place (File > New > Baseplate). Build Phase 1 does the first "Save to Roblox" with them, which creates the game on their Roblox account.

## 8. Desktop shortcuts (only in the Claude CLI)
The shortcuts open the command-line Claude (`claude` in a terminal), so only offer them when setup is running there. Check (PowerShell): `$env:CLAUDE_CODE_ENTRYPOINT`.
- If it is NOT exactly `cli` (e.g. the Claude desktop app, an IDE extension, the web): skip this step completely, don't ask and don't make shortcuts. Just tell the user that next time they open the game folder (<PROJECT>) as the project in the same app and type "read instructions.md and continue".
- If it is `cli`: ask as below.

Ask (header "Shortcuts"): "Make two desktop shortcuts for this game?" with options:
- **Yes, make both (Recommended)** - "'<GAME_NAME> - Claude' opens Claude in the game folder. '<GAME_NAME> - Claude (auto)' also types 'read instructions.md and continue' for you. Both start a Remote Control session named '<GAME_NAME>', so you can follow along from your phone or another computer."
- **No thanks**
If yes, run (PowerShell): `powershell -ExecutionPolicy Bypass -File "<PROJECT>\tools\make-shortcuts.ps1" -ProjectDir "<PROJECT>" -Name "<GAME_NAME>"` and report the two shortcut paths it prints. (The script stays in `tools/` so they can be remade later.)

## 9. Finish
Give a short summary: the game (name + pitch line), the folder, the task files and their item counts, GitHub status, the shortcuts, and the first task (`01_build.md` Build Phase 1) with the effort level to use (high). Then:
- If setup ran from the master template: "This window is still in the template folder. Close it and start the game with the new shortcut" (if shortcuts were made) or "open <PROJECT> as the project and type: read instructions.md and continue" (if not).
- Otherwise: "Good time to /clear now, then type: read instructions.md and continue".
