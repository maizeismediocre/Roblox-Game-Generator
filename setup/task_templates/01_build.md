# 01 — Build (core game)

STATUS: NOT STARTED

- [ ] Build Phase 1 — Foundations
<!-- GENERATE: one "- [ ] Build Phase N — <Title>" line per phase below, in order (usually 6-9 phases in total, ending with "Monetisation" and "Polish + launch checklist"). Straight after the line of the phase that first makes the whole core loop playable from start to finish (usually Phase 2 or 3), add this line exactly: "- [ ] Fun check — I play the core loop (HUMAN CHECK)". If the genre has the Feel trait (SETUP step 4), also add "- [ ] Feel check — I try the controls (HUMAN CHECK)" straight after the line of the phase that builds the main controls. If that is the same phase as the fun check's, put the feel check first. -->

---

You are an expert Roblox developer working directly in my open Roblox Studio session through the Studio MCP tools. Build the MVP of my game "{{GAME_NAME}}" in the Build Phases below. Before each phase, inspect the current DataModel so you don't duplicate or overwrite existing work. After each phase, playtest, check the output log for errors and fix them.

## GAME CONCEPT
<!-- GENERATE: 2-4 short paragraphs from the pitch card: what the game is, players per server, the core loop step by step, the hook, progression, the co-op/social side, the areas, and the tone (e.g. "cute, colourful and funny, not violent"). Specific, plain English. -->

## GENRE CHECKLIST
<!-- GENERATE: from the genre profile (SETUP step 4). First line: "Genre: <genre>. <the profile's Keep it line, in this game's words>". Then one line per item of the profile's Must have line, reworded with this game's names, in the form "- <what must be true> (Phase N; proved by: <the test>)". Take the tests from the profile's Prove line and add one for any must-have it doesn't cover. -->
These lines are what make this game its genre. Rules for every phase:
- A phase is not finished until the checklist lines marked with its number pass. Write each test as a DevTools test that returns PASS or FAIL, so it can be run again later.
- Every line the core loop needs passes before the fun check.
- If a later change breaks a line, fix it before carrying on.
- Never drop or weaken a line to make a phase easier, and never replace the genre's own play with a shop or an upgrade menu. If a line turns out to be wrong for this game, ask me first.

## TECHNICAL RULES (apply to every phase)
- Luau with --!strict where practical. Organise code into ModuleScripts:
  ServerScriptService/Server (services), ReplicatedStorage/Shared (config + shared modules), StarterPlayerScripts/Client (UI + input).
- The server is authoritative. Never trust the client for currency, rewards, progress or inventory. Validate every RemoteEvent/RemoteFunction (type checks, distance checks, rate limits).
- Filter all player-written text before anyone else can see it (Roblox requires this, and unfiltered text can get the game taken down): pet/item names, signs, trade notes, admin announcements, anything typed. On the server, use TextService:FilterStringAsync, then GetNonChatStringForBroadcastAsync (shown to everyone) or GetNonChatStringForUserAsync (one viewer). If filtering errors, show nothing (or a default), never the raw text. Keep length limits on the server too. Text from config files doesn't need filtering. Studio filters little, so check it in the code, not only in tests.
- All tunable values (stats, prices, timers, odds, spawn tables) go in config modules in ReplicatedStorage/Shared/Config so I can edit balance without touching logic.
- Save data with DataStoreService using session locking, retries with backoff, autosave every 60–120 seconds, and save on PlayerRemoving and BindToClose. Include a data version number for future migrations.
- Session locking is the code most likely to lose or copy a player's data, and one Studio test only ever runs one server. Prove it with a DevTools test called SessionLockTest that uses the real DataStore and a test key (never a real player's key). It plays the part of a second server by writing a lock with a different server id into the key, then checks four things: with a fresh lock the load is refused (the player is kicked with a friendly message) and the stored data is unchanged; with a lock older than the time-out the load takes the lock over; a server that has lost its lock does not write on autosave or on leave; a normal leave releases the lock. Every check returns PASS or FAIL.
- No trading, gifting or any other way to move items or currency from one player to another. Two saves that must change together are the usual way items get copied. Co-op features reward each player on their own save.
- Anything that progresses while the player is away is calculated from saved os.time() timestamps when they rejoin. No loops running for offline players.
- Must run well on mobile. Use touch-friendly UI with scaled sizes (UIScale/AnchorPoint, nothing off-screen on a phone). Keep part counts modest and use StreamingEnabled.
- Models are built from plain parts in the chunky block style with ServerStorage/ArtTools/ModelKit (see the `model-qa` skill), never meshes. Simple placeholder versions are fine in Build; name them clearly so the Art phases can replace them.
- Server-side test helpers live in ServerStorage/DevTools (BindableFunctions such as GiveCurrency, GoTo, Spawn...), so tests can act on the live game. execute_luau gets its own copy of modules, so tests use DevTools, never `require` of a service. Every DevTools helper begins with `if not RunService:IsStudio() then return end`, so none of them does anything in the published game, and no RemoteEvent or admin command ever calls one.
- Comment the code clearly. I am learning.

## PROGRESS LOG AND SAVING
- The progress log is the file `devnotes/Progress.md` in this folder. Keep build notes under a "BUILD PHASES" heading, and never remove or change any other section. Finished work is written up in `devnotes/ProgressArchive.md` (the `log-phase` skill).
- After finishing each phase, update BUILD PHASES with: which phases are complete, what each one does and where its main scripts and configs are, any known bugs or unfinished parts, and any decisions made during testing. Keep it concise and up to date; rewrite outdated notes rather than just appending.
- Save with the `save-game` skill and commit after each phase.

## BUILD PHASE 1 — Foundations
- First save: if this place has never been saved to Roblox, do the "First save" section of the `save-game` skill with me (it creates the game on my Roblox account), then turn on Game Settings > Security > "Enable Studio Access to API Services" (needed for DataStores in Studio tests).
- Folder/module structure as above. Turn on StreamingEnabled.
- `devnotes/Progress.md`: write the GAME CONCEPT in 3-5 lines and start the BUILD PHASES section.
- Script copies: after the first save, run `py -I tools/export_scripts.py "{{BACKUP_FILE}}" src` (the `save-game` skill does this on every save). Count the scripts in the game with execute_luau (every Script, LocalScript and ModuleScript) and compare with the number it prints. Open two of the files in `src/` and compare them with the same scripts in Studio. If the export fails or the numbers differ, fix `tools/export_scripts.py` before going on (the `save-game` skill says what to do if it can't be fixed).
- ServerStorage/ArtTools: install `ModelKit` and `SceneryScan` from this repo's `studio_tools/*.luau` (create the ModuleScripts and set their Source). Self-test: build a small test recipe (a Body block, a "Round" part, one floating part, two clipping parts of different features), check that Check reports the floating part and nothing round is left, FindClipping reports the clip, Turnaround builds 4 copies; then delete the test copies. Fix ModelKit if anything fails.
- A Workspace.ArtReview folder with a ReviewFloor (a big flat part at x ≈ 3000, off the map) for model reviews.
- Player data service with the save rules above (session lock, retries, autosave, BindToClose, data version), with SessionLockTest passing, and the fields this game needs from the start: <!-- GENERATE: the starting save fields for this game, e.g. currency, owned items (each with id + type + any stats), unlocks, settings. -->
- The game's main number as a leaderstat, with a minimal HUD showing it: whatever this genre counts (coins, stage reached, wins, best time, stars).
- Config modules for the main content: <!-- GENERATE: the starting config, e.g. "15 creature species across 4 rarities (Common, Uncommon, Rare, Legendary), each with a name, base value, growth time, the area it appears in and a placeholder colour". Use real numbers. -->
- ServerStorage/DevTools with the first helpers: ResetData, GoTo, SessionLockTest, and one that sets the main number (GiveCurrency, SetStage or similar).

## FUN CHECK (HUMAN CHECK)
This item comes straight after the phase that first makes the whole core loop playable. It is one of the few places where you stop and wait for me (instructions.md, "Human checks").
- Before stopping: the core loop works from start to finish with no errors in Output, and the game is saved.
- Tell me, click by click, how to play it: press Play in Studio, where to walk, what to press, and what one full loop looks like. Ask me to play for about 10 minutes.
- Ask me four questions: Was it fun? Which part was boring or confusing? What did I want to do that the game didn't let me do? Should the idea change before more is built on it?
- Record my answers in `devnotes/Progress.md` under "FUN CHECK". If I ask for changes, make them now and test them, then ask me to play again.
- Tick this item only after I say the core loop is fun enough to carry on.

<!-- GENERATE: keep the FEEL CHECK section below only if the genre has the Feel trait (SETUP step 4). Otherwise delete the section. Delete this comment either way. -->
## FEEL CHECK (HUMAN CHECK)
This game depends on how its controls feel, which you can't judge for me. This item comes straight after the phase that builds the main controls. Stop and wait for me here too (instructions.md, "Human checks").
- Rule for every phase: each speed, acceleration, jump height, turn rate, timing window and camera value is a named number in ReplicatedStorage/Shared/Config/Feel, with a comment saying what it changes. Nothing about feel is a bare number in a script.
- Before stopping: prove the rules in code (the controls respond, limits hold, the server rejects impossible moves, it works with touch controls in the Device Emulator), and save.
- Tell me, click by click, how to try the controls for about 5 minutes, on PC and with the phone view if I can.
- Ask me: Does it do what I expect when I press something? Is anything too fast, too slow, too floaty or too stiff? Is anything hard to do on a phone? What would I change first?
- Change the Config/Feel numbers from my answers, tell me which numbers changed and by how much, and ask me to try again. Repeat until I say it feels right.
- Record the final numbers and my answers in `devnotes/Progress.md` under "FEEL CHECK". Tick this item only after I say so.
- Later on: when a phase or a later task file changes the controls or adds a new way to move, stop for a short feel check again before carrying on.

<!-- GENERATE: the remaining build phases, each as "## BUILD PHASE N — <Title>" followed by 3-8 specific bullet points, in the style of Phase 1. Together they must deliver the whole pitch card as a working MVP:
  - the core loop (each step playable and validated on the server),
  - the main areas/zones and how they are reached,
  - progression as the genre profile's Progress line has it (upgrades, unlocks, levels, records, a collection: only what fits this game),
  - social + retention (e.g. visiting, likes, daily reward with streak, records or a collection book),
  - the co-op feature(s) from the pitch (validated on the server, tested with 2 players via `start-2p-test`; helping must be rewarding and never needed to progress; no trading or gifting between players),
  - "Monetisation (fair, not pay-to-win)": MarketplaceService with placeholder ids in Config/Monetisation; the pitch's game passes and developer products; ProcessReceipt idempotent and saved before returning PurchaseGranted; no paid random items (this includes anything paid that changes random odds: see CLAUDE.md),
  - anything the genre's traits call for (SETUP step 4): computer players that fill empty places so one player can play a full round; saving and loading a player's plot with a piece limit; rewards and unlocks where there is no currency,
  - "Polish + launch checklist" (last): a 60-second guided tutorial of the core loop; sound effect and particle hooks (placeholders, real sounds come in 04_polish.md); a review of all remotes for exploit risks and of every place player-written text is shown (each goes through TextService filtering); health-check smoke-test scripts for the core loop and every GENRE CHECKLIST line in `.claude/skills/health-check/scripts/` (one execute_luau call per file, each returning "PASS ..." or "FAIL ...", see that skill) with the table in its SKILL.md filled in; and a written checklist of what I must do by hand before publishing (pass/product ids, icon and thumbnails, the maturity questionnaire, settings such as API access).
Keep each phase one clear topic. Put the phases in an order that makes the whole core loop playable as early as possible (by Phase 2 or 3), because the fun check follows that phase. Do not write a phase for the fun check: its section above is fixed. -->
