# 01 — Build (core game)

STATUS: NOT STARTED

- [ ] Build Phase 1 — Foundations
<!-- GENERATE: one "- [ ] Build Phase N — <Title>" line per phase below, in order (usually 6-9 phases in total, ending with "Monetisation" and "Polish + launch checklist"). -->

---

You are an expert Roblox developer working directly in my open Roblox Studio session through the Studio MCP tools. Build the MVP of my game "{{GAME_NAME}}" in the Build Phases below. Before each phase, inspect the current DataModel so you don't duplicate or overwrite existing work. After each phase, playtest, check the output log for errors and fix them.

## GAME CONCEPT
<!-- GENERATE: 2-4 short paragraphs from the pitch card: what the game is, players per server, the core loop step by step, the hook, progression, the co-op/social side, the areas, and the tone (e.g. "cute, colourful and funny, not violent"). Specific, plain English. -->

## TECHNICAL RULES (apply to every phase)
- Luau with --!strict where practical. Organise code into ModuleScripts:
  ServerScriptService/Server (services), ReplicatedStorage/Shared (config + shared modules), StarterPlayerScripts/Client (UI + input).
- The server is authoritative. Never trust the client for currency, rewards, progress or inventory. Validate every RemoteEvent/RemoteFunction (type checks, distance checks, rate limits).
- All tunable values (stats, prices, timers, odds, spawn tables) go in config modules in ReplicatedStorage/Shared/Config so I can edit balance without touching logic.
- Save data with DataStoreService using session locking, retries with backoff, autosave every 60–120 seconds, and save on PlayerRemoving and BindToClose. Include a data version number for future migrations.
- Anything that progresses while the player is away is calculated from saved os.time() timestamps when they rejoin. No loops running for offline players.
- Must run well on mobile. Use touch-friendly UI with scaled sizes (UIScale/AnchorPoint, nothing off-screen on a phone). Keep part counts modest and use StreamingEnabled.
- Models are built from plain parts in the chunky block style with ServerStorage/ArtTools/ModelKit (see the `model-qa` skill), never meshes. Simple placeholder versions are fine in Build; name them clearly so the Art phases can replace them.
- Server-side test helpers live in ServerStorage/DevTools (BindableFunctions such as GiveCurrency, GoTo, Spawn...), so tests can act on the live game. execute_luau gets its own copy of modules, so tests use DevTools, never `require` of a service.
- Comment the code clearly. I am learning.

## PROGRESS LOG AND SAVING
- The progress log is a ModuleScript at ServerStorage/DevNotes/Progress (it is never run; it only holds notes as a comment block). Keep build notes under a "BUILD PHASES" heading, and never remove or change any other section. Finished work is written up in ServerStorage/DevNotes/ProgressArchive (the `log-phase` skill).
- After finishing each phase, update BUILD PHASES with: which phases are complete, what each one does and where its main scripts and configs are, any known bugs or unfinished parts, and any decisions made during testing. Keep it concise and up to date; rewrite outdated notes rather than just appending.
- Save with the `save-game` skill and commit after each phase.

## BUILD PHASE 1 — Foundations
- First save: if this place has never been saved to Roblox, do the "First save" section of the `save-game` skill with me (it creates the game on my Roblox account), then turn on Game Settings > Security > "Enable Studio Access to API Services" (needed for DataStores in Studio tests).
- Folder/module structure as above. Turn on StreamingEnabled.
- ServerStorage/DevNotes with the Progress and ProgressArchive ModuleScripts (comment blocks only; Progress starts with the GAME CONCEPT in 3-5 lines, then the BUILD PHASES section).
- ServerStorage/ArtTools: install `ModelKit` and `SceneryScan` from this repo's `studio_tools/*.luau` (create the ModuleScripts and set their Source). Self-test: build a small test recipe (a Body block, a "Round" part, one floating part, two clipping parts of different features), check that Check reports the floating part and nothing round is left, FindClipping reports the clip, Turnaround builds 4 copies; then delete the test copies. Fix ModelKit if anything fails.
- A Workspace.ArtReview folder with a ReviewFloor (a big flat part at x ≈ 3000, off the map) for model reviews.
- Player data service with the save rules above (session lock, retries, autosave, BindToClose, data version) and the fields this game needs from the start: <!-- GENERATE: the starting save fields for this game, e.g. currency, owned items (each with id + type + any stats), unlocks, settings. -->
- A currency leaderstat and a minimal HUD showing it.
- Config modules for the main content: <!-- GENERATE: the starting config, e.g. "15 creature species across 4 rarities (Common, Uncommon, Rare, Legendary), each with a name, base value, growth time, the area it appears in and a placeholder colour". Use real numbers. -->
- ServerStorage/DevTools with the first helpers (GiveCurrency, ResetData, GoTo).

<!-- GENERATE: the remaining build phases, each as "## BUILD PHASE N — <Title>" followed by 3-8 specific bullet points, in the style of Phase 1. Together they must deliver the whole pitch card as a working MVP:
  - the core loop (each step playable and validated on the server),
  - the main areas/zones and how they are reached,
  - progression (upgrades/unlocks) and the main collection,
  - social + retention (e.g. visiting, likes, daily reward with streak, a collection book),
  - the co-op feature(s) from the pitch (validated on the server, tested with 2 players via `start-2p-test`; helping must be rewarding and never needed to progress),
  - "Monetisation (fair, not pay-to-win)": MarketplaceService with placeholder ids in Config/Monetisation; the pitch's game passes and developer products; ProcessReceipt idempotent and saved before returning PurchaseGranted; no paid random items,
  - "Polish + launch checklist" (last): a 60-second guided tutorial of the core loop; sound effect and particle hooks (placeholders, real sounds come in 04_polish.md); a review of all remotes for exploit risks; health-check smoke-test scripts for the core loop in `.claude/skills/health-check/scripts/` (one execute_luau call per file, each returning "PASS ..." or "FAIL ...", see that skill) with the table in its SKILL.md filled in; and a written checklist of what I must do by hand before publishing (pass/product ids, icon and thumbnails, the maturity questionnaire, settings such as API access).
Keep each phase one clear topic. -->
