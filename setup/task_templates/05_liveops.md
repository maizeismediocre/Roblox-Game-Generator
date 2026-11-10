# 05 — Live-ops foundations

STATUS: NOT STARTED

- [ ] System 1 — Data migrations
- [ ] System 2 — Feature flags
- [ ] System 3 — Admin commands
- [ ] System 4 — Shutdown safety
- [ ] System 5 — Event scheduler
- [ ] System 6 — Update log
- [ ] System 7 — Loading screen
- [ ] Final check

---

You are working in my open Roblox Studio session for "{{GAME_NAME}}" through the Studio MCP tools. The core game is built and working. Inspect the existing structure, scripts and config modules first, and reuse existing systems (save system, configs, economy, animator, effects, SoundController, UI) rather than rebuilding them.

This file holds only what the game needs before it launches: safe updates, switches, admin tools and a loading screen. The automatic weekly rotation and the seasonal events are built after launch, in 09_weekly_rotation.md, once real players have shown the game is worth it.

Build the Live-Ops Systems below IN ORDER, one at a time. After each system: playtest, check the Output window for errors and fix them.

## GLOBAL RULES
- Server is authoritative. Validate all RemoteEvents. Never trust the client for currency, items, rewards or progress.
- All tunable values (times, dates, multipliers, rewards) live in config modules in ReplicatedStorage/Shared/Config, except admin UserIds, which live in a server-only config in ServerScriptService.
- Use UTC for all times and dates.
- Never remove or rename existing saved data fields. Any save format change must bump the data version and add a migration.
- Nothing a player owns is ever taken away by any system below.
- New moments (event starts, announcements) use the existing SoundController and effects (new moments get new sound slots, see `add-asset`).
- Comment the code clearly. I am learning.

## PROGRESS LOG AND SAVING
- Add or update a "LIVE-OPS SYSTEMS" section in `devnotes/Progress.md` (never remove or change other sections), using the `log-phase` skill: which systems are complete, what each one does and where its main scripts and configs are, the current feature flag settings, any known bugs or unfinished parts, and any decisions made.
- Save with the `save-game` skill and commit after each system.

## SYSTEM 1 — Data migrations
Make the save system check the data version on load and run migration functions in order (v1→v2→v3...), so updates never corrupt or wipe old saves. Add a test (a DevTools test, run in a playtest) that loads an old-format save and confirms it migrates correctly. Run SessionLockTest again afterwards: all four checks PASS.

## SYSTEM 2 — Feature flags
A config module of on/off switches for features, so I can ship code early and switch it on later, or switch off something broken without a rollback. Every new system below must be behind its own flag.

## SYSTEM 3 — Admin commands
Commands usable only by UserIds in the server-only admin config, to: give myself currency or items for testing, start/stop events, and send an announcement to all servers via MessagingService (the announcement text is filtered with TextService like any player-written text). Reject and log attempts by anyone else. Write the command list to `Admin commands.txt` in the repo so I can find it.

## SYSTEM 4 — Shutdown safety
When I shut down servers to push an update, players see a friendly "Updating! Rejoin in a moment" message, and all data saves properly via BindToClose.

## SYSTEM 5 — Event scheduler
A server module that starts and ends limited-time events based on UTC start/end dates in a config module. Events can: add event-only content, change lighting and decorations, and apply multipliers. Nothing event-related is hardcoded outside the config. Include an admin command to start/stop any event manually, and one launch event in the config (off until I set its dates) so the scheduler is tested with real content.

## SYSTEM 6 — Update log
A "What's New" panel that opens automatically the first time a player joins after a new version (track the last version seen in saved data). Contents come from a config module listing versions, each with a title and bullet points (`player-text` rules).

## SYSTEM 7 — Loading screen
A friendly loading screen so players aren't dropped into a half-loaded world. Players can wait while it loads or skip it at any time.
- Shown straight away on join from ReplicatedFirst (remove the default Roblox loading screen), in the game's art style and UI fonts/colours: the game title, a soft animated background, and a progress bar with a percentage.
- Real loading: preload the important assets with ContentProvider:PreloadAsync (area models, main models, UI images, music and key sounds), and wait for the character and the player's save data. The bar follows real progress (smoothed so it never jumps backwards), with a short friendly status line.
- Tips: rotate short tips every few seconds from a config module (`player-text` rules).
- Skip button: visible from the start (big enough to tap on mobile, usable with a gamepad). Skipping closes the screen at once and the rest keeps loading quietly; nothing breaks if a player skips straight away.
- When loading finishes: "Ready!" with a "Play" button (or a fade out after a few seconds). Smooth fade, never a flash. A 30-second time-out closes it so nobody is stuck; failed assets are logged in Output, not shown to the player.
- Respawns and teleports between areas do not show it again. Behind a feature flag (System 2).
- Test: normal join, skip immediately, a failed asset (time-out works), mobile and gamepad sizes, rejoin, and a 2-player test (`start-2p-test`) with no errors in Output.

# FINAL CHECK
Run a full regression playtest of the whole core loop plus an upgrade, a forced event, and a rejoin confirming all data saved. Confirm no errors in Output. Then write a checklist of which feature flags to switch on for launch, and record it in the progress log.
