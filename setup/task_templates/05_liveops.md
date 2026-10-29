# 05 — Live-ops and automatic weekly rotation

STATUS: NOT STARTED

- [ ] System 1 — Data migrations
- [ ] System 2 — Feature flags
- [ ] System 3 — Admin commands
- [ ] System 4 — Shutdown safety
- [ ] System 5 — Event scheduler
- [ ] System 6 — Update log
- [ ] System 7 — Weekly seed, reset and countdown
- [ ] System 8 — Content pools
- [ ] System 9 — Apply the rotation
- [ ] System 10 — Weekly challenges
- [ ] System 11 — Rotation admin and testing tools
- [ ] System 12 — Weekly hype
- [ ] System 13 — Content library expansion
<!-- GENERATE: if the pitch has seasonal/holiday events, add "- [ ] System 14 — Seasonal events" and renumber the loading screen to 15. Otherwise leave it out (and leave out PART C below). -->
- [ ] System 14 — Loading screen
- [ ] Final check

---

You are working in my open Roblox Studio session for "{{GAME_NAME}}" through the Studio MCP tools. The core game is built and working. Inspect the existing structure, scripts and config modules first, and reuse existing systems (save system, configs, economy, animator, effects, SoundController, UI) rather than rebuilding them.

Build the Live-Ops Systems below IN ORDER, one at a time. After each system: playtest, check the Output window for errors and fix them.

## GLOBAL RULES
- Server is authoritative. Validate all RemoteEvents. Never trust the client for currency, items, rewards or progress.
- All tunable values (times, dates, pools, multipliers, rewards) live in config modules in ReplicatedStorage/Shared/Config, except admin UserIds, which live in a server-only config in ServerScriptService.
- Use UTC for all times and dates.
- Never remove or rename existing saved data fields. Any save format change must bump the data version and add a migration.
- Nothing a player owns is ever taken away by any system below.
- Weekly content must need NO manual work from me: everything changes automatically.
- New moments (event starts, challenge completions, rotation reset) use the existing SoundController and effects (new moments get new sound slots, see `add-asset`).
- Comment the code clearly. I am learning.

## PROGRESS LOG AND SAVING
- Add or update a "LIVE-OPS SYSTEMS" section in ServerStorage/DevNotes/Progress (never remove or change other sections), using the `log-phase` skill: which systems are complete, what each one does and where its main scripts and configs are, the current feature flag settings, any known bugs or unfinished parts, and any decisions made.
- Save with the `save-game` skill and commit after each system.

# PART A — LIVE-OPS FOUNDATIONS

## SYSTEM 1 — Data migrations
Make the save system check the data version on load and run migration functions in order (v1→v2→v3...), so updates never corrupt or wipe old saves. Add a test (a DevTools test, run in a playtest) that loads an old-format save and confirms it migrates correctly.

## SYSTEM 2 — Feature flags
A config module of on/off switches for features, so I can ship code early and switch it on later, or switch off something broken without a rollback. Every new system below must be behind its own flag.

## SYSTEM 3 — Admin commands
Commands usable only by UserIds in the server-only admin config, to: give myself currency or items for testing, start/stop events, and send an announcement to all servers via MessagingService (the announcement text is filtered with TextService like any player-written text). Reject and log attempts by anyone else. Write the command list to `Admin commands.txt` in the repo so I can find it.

## SYSTEM 4 — Shutdown safety
When I shut down servers to push an update, players see a friendly "Updating! Rejoin in a moment" message, and all data saves properly via BindToClose.

## SYSTEM 5 — Event scheduler
A server module that starts and ends limited-time events based on UTC start/end dates in a config module. Events can: add event-only content, change lighting and decorations, and apply multipliers. Nothing event-related is hardcoded outside the config. Include an admin command to start/stop any event manually.

## SYSTEM 6 — Update log
A "What's New" panel that opens automatically the first time a player joins after a new version (track the last version seen in saved data). Contents come from a config module listing versions, each with a title and bullet points (`player-text` rules). System 12 also feeds auto-generated weekly entries into this panel.

# PART B — AUTOMATIC WEEKLY ROTATION
Every Saturday at 15:00 UTC (configurable), the game automatically changes its featured content with no republishing. All servers must show identical content, so selection is deterministic.

## SYSTEM 7 — Weekly seed, reset and countdown
- Create ReplicatedStorage/Shared/WeeklyRotation (ModuleScript).
- Compute a week number from os.time() relative to a fixed start date in config. Use Random.new(weekNumber + a fixed salt from config) for all weekly picks.
- Expose: getCurrentWeek(), getSecondsUntilReset(), getRotation(weekNumber) returning that week's full rotation table.
- Servers open across the reset switch to the new rotation live, without restarting, and notify players in-game.
- A board in the hub/lobby and a small HUD timer counting down to the next reset.

## SYSTEM 8 — Content pools
All pools live in config modules. Each pool item that is added later gets `From = <week>` (current week + 2), so adding content never reshuffles the running week or past weeks.
<!-- GENERATE: the pools for THIS game, as bullets. Usually: which main content is "always" vs "rotating" vs "event" (and how many rotating picks per week, with no repeats within 2 weeks), a weekly event pool (3-5 events, each with multipliers and visuals), a "boost of the week", area variants (lighting/decoration/spawn mix), a weekly shop rotation (cosmetics), and weekly challenges (pick 3: easy, medium, hard; each with a goal type, target and reward). Use this game's own names. -->

## SYSTEM 9 — Apply the rotation
- Apply this week's picks through the existing systems (spawn tables, events via System 5, boosts, area variants, shop).
- Rotating content players already own stays fully usable, sellable and tradeable.
- Any collection/book UI marks rotating content as "In rotation this week" or "Returns later".

## SYSTEM 10 — Weekly challenges
- Track progress server-side, saved with the week number. Reset automatically when the week changes.
- Challenges UI with progress bars and claim buttons. Rewards granted server-side only, scaled to the economy's price curve (check the ECONOMY STEPS notes in the progress log).

## SYSTEM 11 — Rotation admin and testing tools
- Admin commands (via System 3) to: preview the rotation for any week number, force-refresh the rotation, and override any single pick for the current week.
- A debug function that prints the next 12 weeks of rotations so bad combinations or repeats are easy to spot.
- Test that two servers produce identical rotations, and that the reset switch works without a server restart.

## SYSTEM 12 — Weekly hype
- On the first join after a reset, show a "This Week in {{GAME_NAME}}" panel (via the System 6 update log), auto-generated from the rotation data. No manual writing needed.
- Tease ONE item from next week's rotation on the hub board (e.g. "Next week: a Legendary returns...").

## SYSTEM 13 — Content library expansion
- Report how many items are in each pool, and roughly how many weeks the rotation can run before it feels repetitive.
- Approval checkpoint (decide yourself, record it): enough new rotating content, events and challenges for at least 12 weeks without feeling repetitive (web-search every name).
- Build new models in batches of 4 with the `new-character` / `model-qa` skills, matching the quality of the existing ones, then add everything to the pools with `From = <week>`.

<!-- GENERATE: ONLY if the pitch has seasonal/holiday events, write PART C here:
# PART C — SEASONAL EVENTS
## SYSTEM 14 — Seasonal events
Bullets adapted from this outline: holiday events run AUTOMATICALLY every year with no republishing (a holiday calendar config: fixed dates as month/day, moving dates worked out by code or a 10-year table; a sensible family-friendly set such as New Year, Lunar New Year, Valentine's Day, Easter, Summer, Halloween, Christmas); each is live for two weeks around its date (10 days before, 4 after, 15:00 UTC, configurable; overlaps swap halfway) through the System 5 scheduler; themed event content for THIS game (e.g. 4 holiday creatures/items, one per rarity) built with the `seasonal-event` skill; a light themed touch in the hub plus real decorations that never block paths; the holiday replaces the weekly event while it runs; out of season, holiday content players own stays fully usable; hype entries via System 6/12 and a countdown to the next holiday; admin tools to preview any date and force a holiday on/off, tested with a faked date and two servers. Friendly and non-religious (no religious symbols). Then renumber PART D's system to 15.
Otherwise delete this comment. -->

# PART D — LOADING SCREEN

## SYSTEM 14 — Loading screen
A friendly loading screen so players aren't dropped into a half-loaded world. Players can wait while it loads or skip it at any time.
- Shown straight away on join from ReplicatedFirst (remove the default Roblox loading screen), in the game's art style and UI fonts/colours: the game title, a soft animated background, and a progress bar with a percentage.
- Real loading: preload the important assets with ContentProvider:PreloadAsync (area models, main models, UI images, music and key sounds), and wait for the character and the player's save data. The bar follows real progress (smoothed so it never jumps backwards), with a short friendly status line.
- Tips: rotate short tips every few seconds from a config module (`player-text` rules).
- Skip button: visible from the start (big enough to tap on mobile, usable with a gamepad). Skipping closes the screen at once and the rest keeps loading quietly; nothing breaks if a player skips straight away.
- When loading finishes: "Ready!" with a "Play" button (or a fade out after a few seconds). Smooth fade, never a flash. A 30-second time-out closes it so nobody is stuck; failed assets are logged in Output, not shown to the player.
- Respawns and teleports between areas do not show it again. Behind a feature flag (System 2).
- Test: normal join, skip immediately, a failed asset (time-out works), mobile and gamepad sizes, rejoin, and a 2-player test (`start-2p-test`) with no errors in Output.

# FINAL CHECK
Run a full regression playtest of the whole core loop plus an upgrade, a challenge, and a rejoin confirming all data saved. Confirm no errors in Output. Then write a checklist of which feature flags to switch on for launch, and record it in the progress log.
