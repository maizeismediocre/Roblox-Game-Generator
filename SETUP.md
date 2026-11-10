# Roblox game template — first-time setup (for Claude)

The user has asked you to read this file. Run the setup below from start to finish. It turns this template into a ready-to-build Roblox game project: pick a genre, generate an original game idea, write the task files, write `instructions.md`, delete the setup files, and offer a desktop shortcut.

## Rules while setting up
- The user may be a total beginner. Plain, friendly English; short progress lines; no jargon without a few words explaining it.
- Use the AskUserQuestion tool for every choice (the user can always type their own answer with "Other").
- Don't change anything outside the project folder, except the copy step (step 5) and the desktop shortcut (step 8, Claude CLI only).
- Never install anything without asking first (CLAUDE.md "Installs").
- Files with Windows paths or backslashes: write them with the Write tool, not shell heredocs (heredocs mangle `\\`).
- Everything in CLAUDE.md "Always" applies to the idea too: original game, no offensive or religious symbols, no slang names, web-searched names.

## 1. Where are we?
- `TEMPLATE` = this folder. If it contains `TEMPLATE_MASTER.txt`, it is the user's master copy: never change or delete anything in it. The game project will be a COPY made in step 5, and every later step works in the copy (`PROJECT` = the new folder; use absolute paths and `git -C`).
- Otherwise the user already copied the template: `PROJECT` = this folder and you work in place.

## 2. Quick checks (one progress line, don't stop on problems)
Run these and report one line, e.g. "Checks: git OK, Python OK, Claude OK, Studio MCP found".
- `git --version` (needed for saving history). If missing, tell the user it's needed and offer to explain how to install Git for Windows (don't install it yourself).
- `py --version` (Python runs the save tools and the picture tools). It must be 3.14 or newer, because Studio's place files can't be read by older versions. If it fails or shows an older version, tell the user Python 3.14 is needed before the first build session and how to get it: paste `winget install --id Python.Python.3.14 -e` into PowerShell, then close and reopen the terminal (README Part 1, step 6). An older Python can stay installed. Don't install it yourself. Setup carries on without it.
- `$env:CLAUDE_CODE_ENTRYPOINT` (PowerShell): `cli` = the terminal Claude CLI (a desktop shortcut is offered in step 8); anything else = no shortcut. Only when it is `cli`, also check `where.exe claude` (the shortcut needs it).
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
  `Get-Content "<TEMPLATE>\setup\genres.txt" | Where-Object { $_ -and -not $_.StartsWith('#') } | Get-Random` (PowerShell). Each line is `Genre | short description`. Leave out genres already rolled this session (add `| Where-Object { $_ -notlike 'Tycoon*' }` etc.).
- **List:** show `setup/genres.txt` as a numbered list (genre + description), then ask them to type a number or a name (plain text answer is fine).
- Show the genre with its one-line description and ask (header "Genre"): "Keep <Genre>?" options **Keep it** / **Reroll** / **Choose from the list**. Repeat until they keep one.
- Every genre on the list, and any genre the user types, gets built. Step 4 ("Make it play like its genre") shapes the plan around what the genre needs.

## 4. Generate the game idea
Write ONE original game idea for the chosen genre. It must be:
- **Original.** Not a copy of a specific existing game (its map, characters, names, story or exact twist), even renamed. Use the genre's common mechanics, then add a twist of your own.
- **Fun in 30 seconds, worth coming back to for weeks:** a short core loop (30-90 s) with something satisfying in it, long-term progression of the kind the genre profile lists (it may be levels, records or unlocks, with no shop at all), and a reason to come back (a daily reward from the start; the automatic weekly rotation and seasonal events are planned in the pitch and built after launch).
- **Better with friends, fine alone:** at least one real co-op or social feature (helping, visiting, teaming up, playing against each other, showing off a collection), never needed to progress. No trading or gifting of items between players: moving items from one save to another is the usual way items get copied, and it is hard to make safe. Buying from and selling to the game's own shops and characters is fine.
- **Friendly:** for players 9+; cute or funny, not gory; no gambling mechanics; no real-world religion, politics or brands.
- **Buildable by Claude through the Studio MCP:** players are normal Roblox avatars; every model is built from plain parts in a chunky block style (no custom meshes, no Blender, no hand-made animations); one place with several areas (no extra places); mobile-friendly controls (tap, joystick, a few big buttons). An MVP that fits in 6-9 build phases.
- **Fair monetisation:** game passes and developer products for specific, known things (cosmetics, convenience, boosts that don't change random odds); nothing pay-to-win, no paid random items (no paid eggs/crates/gacha, and no paid luck boosts: see "Paid random items" in CLAUDE.md).

### Make it play like its genre
The fixed parts of the task files were written with collect-and-upgrade games in mind. Without this step every game drifts into a tycoon with a different look. Do this before writing the idea.

1. **Get the genre's profile.** `setup/genre_guide.md` has a seven-line profile for every genre in `setup/genres.txt`. Read only the chosen genre's block (Grep for its `## ` heading with 8 lines after it). For a typed genre, or a mix of two, write a profile with the same seven lines yourself, borrowing from the closest blocks, and show it to the user with the pitch card so they can correct it.
2. **Design the idea from the profile.** Its `Loop` line is the core loop, with this game's own twist. Every item on its `Must have` line is in the game. Its `Keep it` line is obeyed. Long-term progress is what its `Progress` line lists, which may have no shop in it at all.
3. **Apply the profile's traits.** A profile's `Traits` line names any of these. A genre can have several, or none.

| Trait | What the idea must include | What changes in the task files |
|-------|-----------------------------|--------------------------------|
| **Feel:** the fun depends on how the controls, timing or movement feel | Simple controls with few inputs that work on a phone. Forgiving timing. | Every speed, jump height, turn rate, timing window and camera value lives in a `Config/Feel` module. `01_build.md` keeps its FEEL CHECK section (a HUMAN CHECK) after the phase that builds the controls: Claude tests the rules in code, the user judges the feel, and Claude tunes the config from their answers. |
| **Several players:** a round is meant for more than one person | Computer-controlled players fill the empty places, so one player alone can play a full round at any time. Real players replace them as they join. | A build phase for the computer players (simple and fair, never better than a beginner). Rounds start with 1 player. Tests run alone with computer players and with `start-2p-test`. |
| **No currency:** there is nothing to buy with what you earn | What the player earns for playing (stars, medals, best times) and what it unlocks: new levels or worlds, cosmetics, harder modes. Nothing that lets a player pay to skip the game itself. | `02_economy.md` is about rewards and unlock pacing: how fast a player earns, what each unlock needs, and how long the content lasts. Its fixed lines about prices and currency per hour are rewritten for that (step 6a allows it). The weekly rotation in `09_weekly_rotation.md` rotates what the genre has: featured levels, modifiers, challenges. |
| **Building:** other players see what a player built or wrote | Players build from a fixed set of pieces on their own plot. No free drawing. Any text a player writes (signs, names) goes through Roblox's text filter. | A build phase for saving and loading a plot, with a piece limit per plot so the save stays small and the game runs well on a phone. |

Anything judged by ear (a rhythm game, music that must match the action): Claude can't hear, so whether it lines up is a feel check.

Never steer the user to a different genre, and never tell them a genre is a poor fit. The profile and the traits are how the plan is made to fit.

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
Content: <what there is a lot of, e.g. "15 creatures in 4 rarities", "40 stages in 4 worlds", "8 tracks and 6 karts">
World: <3-4 areas>
Look: <art style in one line: blocky part-built, colour palette, mood>
Weekly: <what changes automatically every week>
Events: <seasonal/holiday events, or "none">
Robux: <2-3 passes, 1-2 products>
Your part: <when the build will stop for the user, e.g. "a 10-minute fun check early on, 2 short controls checks, a sign-off before the store pictures, publishing">
```
Ask (header "Idea"): "Do you want to make this game?" options **Yes, use this idea** / **New idea, same genre** / **Change the genre** (back to step 3). The user can type changes under "Other": apply them and show the card again. Repeat until they say yes.

Then fix the names (AskUserQuestion if they want to pick from the name ideas):
- `GAME_NAME` = the working name, e.g. `Critter Haul`. Letters, digits and single spaces only: no colon, apostrophe, hyphen, `!`, `&` or other punctuation (it becomes part of file names, skill files and typed paths, and `fill-placeholders.ps1` refuses anything else). If the user wants punctuation in the title players see, put that version in the TITLE OPTIONS in `store_page/description.txt` (step 6e) and tell them the store title is set when they publish.
- `GAME_ID` = GAME_NAME in CamelCase with only letters and digits, starting with a letter, e.g. `CritterHaul`.

## 5. Project options (one AskUserQuestion with these questions)
1. **Only if TEMPLATE is the master copy:** "Where should I make the game folder?" (header "Folder") options: `<Documents>\Roblox Games\<GAME_ID>` (Recommended) / `<Desktop>\<GAME_ID>` (find real paths with `[Environment]::GetFolderPath('MyDocuments')` / `'Desktop'`; OneDrive can move them). Refuse a folder that already exists and isn't empty.
2. "Back up the project to GitHub?" (header "GitHub") only if `gh auth status` works: **Private GitHub repo (Recommended)** / **Only on this PC**. If gh is missing or not logged in, don't ask: use local git and mention they can add GitHub later.

Then, if TEMPLATE is the master copy, copy it (PowerShell): `robocopy "<TEMPLATE>" "<PROJECT>" /E /XD .git /XF TEMPLATE_MASTER.txt` (robocopy exit codes 0-7 mean success). Check `PROJECT\SETUP.md` exists. From here on, every path is inside PROJECT.

## 6. Write the project files (all inside PROJECT)
Post a progress line per file. Read each template only when you write it.

**a. Task files.** For each template in `setup/task_templates/`, write the file of the same name into the PROJECT root. Keep every fixed section word for word. Replace every `<!-- GENERATE: ... -->` block with content for THIS game, following the instructions inside the block, in the same style as the fixed text (plain English, specific numbers, "- [ ]" checklist lines matching the `## ...` headings). Rules:
- Scope: the build phases deliver the pitch card's core game as a working MVP. The pitch's "Weekly" and "Events" lines are built after launch, in `09_weekly_rotation.md`. Later files (economy, art, polish, live-ops foundations, QA, store page, launch, weekly rotation) are tailored to the game's systems and names.
- Human checks: `01_build.md` gets the "Fun check" line straight after the phase that first makes the whole core loop playable (its GENERATE block says how). Keep the "(HUMAN CHECK)" marks in `06_quality_qa.md` and `08_launch.md` exactly as they are.
- Genre traits (step 4, "Make it play like its genre"): apply the last column of the table for every trait the profile names. A genre with the Feel trait keeps the FEEL CHECK section of `01_build.md` and gets its checklist line; a genre without it has that section deleted.
- Genre checklist: fill the GENRE CHECKLIST section of `01_build.md` from the profile (its GENERATE block says how). `setup/` is deleted in step 6f, so this section is where the profile lives on in the game project.
- A fixed line that doesn't fit this game: the fixed text was written for games with a currency, upgrades and things to collect. If a fixed line can't apply (e.g. "currency per hour" in a game with no currency), rewrite that one line for this game and keep its purpose. Don't delete a rule about safety, saving, testing or fairness.
- If the pitch has no seasonal events, leave out the seasonal-events part of `09_weekly_rotation.md` (as the GENERATE block says).
- STATUS lines start as `STATUS: NOT STARTED`; every item starts `- [ ]`.
- After writing, grep the new files: no `GENERATE` or `{{` left (except `{{GAME_NAME}}`-style placeholders, which step 6d fills).

**a2. Genre fit check.** Before going on, check the nine task files against the genre profile, fix what fails, and check again. Then report one line, e.g. "Genre check: 6 of 6 must-haves planned, core loop playable by Phase 2, 4 lines rewritten".
1. Every `Must have` is built in a named build phase, and the GENRE CHECKLIST says which phase and which test proves it.
2. The phases before the fun check build the profile's `Loop`. If they build a shop, a menu or an upgrade screen first, reorder them.
3. Find every fixed line in the task files that mentions currency, prices, shops, upgrades, rarities, creatures, collecting or prestige (Grep for those words). If this game has that thing, the line stays. If it doesn't, the line is rewritten for what the game has (the rule above). No file may ask for a system the game doesn't have.
4. Every trait on the profile's `Traits` line has its change from the table in the files.
5. The skills fit the game: `new-character` and `seasonal-event` are kept only if the game has such things, and the `model-qa` style lines describe this game's main models (karts, courses, rooms, cards), which may not be creatures.
6. QA Step 5's run-through in `06_quality_qa.md` and the scenes in `07_store_page.md` show the genre's own play.
7. Read back test: from the task files alone, write two sentences on what a player does in their first five minutes. If it reads as "earn, buy, upgrade" and the profile's `Loop` says otherwise, rewrite the build phases and run this check again.

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
- Replace `README.md` with a short project readme: the pitch card, how to start a session (if the shortcut was made: "double-click the '<GAME_NAME> - Keep Building' shortcut, or"; always: "open Claude in this folder and type: read instructions.md and continue"), and the task-file list.

**f. Remove setup.** In PROJECT: delete the block between `<!-- SETUP-PENDING:START` and `SETUP-PENDING:END -->` (both lines included) from CLAUDE.md, then delete `SETUP.md` and the `setup/` folder. Check `TEMPLATE_MASTER.txt` is not in PROJECT.

**g. Git.** `git -C "<PROJECT>" init -b main`, `git add -A`, commit "Project setup: <GAME_NAME> (<genre>)". If `git config user.name` / `user.email` are empty, ask the user what to use (only for this repo: `git -C ... config user.name ...`). No AI trailer (CLAUDE.md). If GitHub was chosen: `gh repo create <GAME_ID> --private --source "<PROJECT>" --push` (if the name is taken, ask for another).

## 7. Studio connection
- If the Roblox_Studio tools work: say "Studio MCP connected" (one line).
- If not: give the step-2 instructions for turning on Studio's MCP server once more, and say Build Phase 1 starts by checking the connection.
- Tell the user what to have ready for the first session: Roblox Studio open with a NEW **Baseplate** place (File > New > Baseplate). Build Phase 1 does the first "Save to Roblox" with them, which creates the game on their Roblox account.

## 8. Desktop shortcut (only in the Claude CLI)
The shortcut opens the command-line Claude (`claude` in a terminal), so only offer it when setup is running there. Check (PowerShell): `$env:CLAUDE_CODE_ENTRYPOINT`.
- If it is NOT exactly `cli` (e.g. the Claude desktop app, an IDE extension, the web): skip this step completely, don't ask and don't make a shortcut. Just tell the user that next time they open the game folder (<PROJECT>) as the project in the same app and type "read instructions.md and continue".
- If it is `cli`: ask as below.

Ask (header "Shortcut"): "Make a desktop shortcut for this game?" with options:
- **Yes (Recommended)** - "'<GAME_NAME> - Keep Building' opens Claude in the game folder and carries on with the next task. To ask Claude something instead, press Esc once it starts and type."
- **No thanks**

In the same AskUserQuestion call, ask a second question (header "Remote ctrl"; only used if they say yes to the shortcut): "Should the shortcut also turn on Remote Control (the same as typing /rc in Claude)?" with options:
- **Yes, turn it on (Recommended)** - "Lets you watch and steer this Claude session from the Claude app on your phone, or from claude.ai/code on another computer, using the same Claude account. Useful because building takes hours: Claude often stops to ask 'Do you want to proceed?' or a question, and you can answer from your phone instead of the build waiting until you're back at your PC. Your PC must stay on with the Claude window open, since the work still happens there. Anyone signed in to your Claude account can control it, so keep that account's password safe."
- **No, just this PC** - "The session can only be used at this PC. You can still turn it on for one session by typing /rc in Claude."

If yes to the shortcut, run (PowerShell): `powershell -ExecutionPolicy Bypass -File "<PROJECT>\tools\make-shortcuts.ps1" -ProjectDir "<PROJECT>" -Name "<GAME_NAME>"`, adding ` -NoRemoteControl` if they said no to Remote Control, and report the shortcut path it prints. If Remote Control is on, tell them: sign in to the Claude app on their phone with the same account and look for the session named '<GAME_NAME>'; to get a phone notification when Claude needs an answer, type `/config` in Claude and turn on **Push when actions required**. (The script stays in `tools/` so it can be remade later.)

## 9. Finish
Give a short summary: the game (name + pitch line), the folder, the task files and their item counts, GitHub status, the shortcut, and the first task (`01_build.md` Build Phase 1) with the effort level to use (high). Tell them Claude builds on its own but stops for them at a few points (the pitch card's "Your part" line): the fun check early in the build (about 10 minutes of play), any feel checks, the sign-off after quality QA, publishing the game, and the first-week numbers. Then:
- If setup ran from the master template: "This window is still in the template folder. Close it and start the game with the new 'Keep Building' shortcut" (if the shortcut was made) or "open <PROJECT> as the project and type: read instructions.md and continue" (if not).
- Otherwise: "Good time to /clear now, then type: read instructions.md and continue".
