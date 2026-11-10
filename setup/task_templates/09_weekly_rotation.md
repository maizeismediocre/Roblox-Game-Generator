# 09 — Automatic weekly rotation (after launch)

STATUS: NOT STARTED

- [ ] Rotation System 1 — Weekly seed, reset and countdown
- [ ] Rotation System 2 — Content pools
- [ ] Rotation System 3 — Apply the rotation
- [ ] Rotation System 4 — Weekly challenges
- [ ] Rotation System 5 — Rotation admin and testing tools
- [ ] Rotation System 6 — Weekly hype
- [ ] Rotation System 7 — Content library expansion
<!-- GENERATE: if the pitch has seasonal/holiday events, add "- [ ] Rotation System 8 — Seasonal events" here. Otherwise leave it out (and leave out PART B below). -->
- [ ] Final check

---

You are working in my open Roblox Studio session for "{{GAME_NAME}}" through the Studio MCP tools. The game is live (08_launch.md) and I decided in the first-week review to build this. Inspect the existing structure, scripts and config modules first, and reuse existing systems (save system, configs, economy, feature flags, admin commands, event scheduler, update log, animator, effects, SoundController, UI) rather than rebuilding them. "05 System N" below means a system from 05_liveops.md.

Every Saturday at 15:00 UTC (configurable), the game changes its featured content by itself, with no republishing. All servers must show identical content, so selection is deterministic.

Build the Rotation Systems below IN ORDER, one at a time. After each system: playtest, check the Output window for errors and fix them.

## GLOBAL RULES
- The game is live. Saving to Roblox does not change what players see: new systems reach players only when I publish. Build each system behind its own feature flag (05 System 2), off by default, and tell me when a set of systems is ready to publish and switch on.
- Server is authoritative. Validate all RemoteEvents. Never trust the client for currency, items, rewards or progress.
- All tunable values (times, dates, pools, multipliers, rewards) live in config modules in ReplicatedStorage/Shared/Config.
- Use UTC for all times and dates.
- Never remove or rename existing saved data fields. Any save format change must bump the data version and add a migration. Real players have saves now: test every migration on a copy of an old-format save first.
- Nothing a player owns is ever taken away by any system below.
- Weekly content must need NO manual work from me: everything changes automatically.
- New moments (challenge completions, rotation reset) use the existing SoundController and effects (new moments get new sound slots, see `add-asset`).
- Analytics: add an event for each new thing worth counting (a challenge claimed, the weekly panel opened), through the config from 08_launch.md.
- Comment the code clearly. I am learning.

## PROGRESS LOG AND SAVING
- Add or update a "WEEKLY ROTATION" section in `devnotes/Progress.md` (never remove or change other sections), using the `log-phase` skill: which systems are complete, what each one does and where its main scripts and configs are, the current feature flag settings, what is published and what is not, any known bugs or unfinished parts, and any decisions made.
- Save with the `save-game` skill and commit after each system.

# PART A — AUTOMATIC WEEKLY ROTATION

## ROTATION SYSTEM 1 — Weekly seed, reset and countdown
- Create ReplicatedStorage/Shared/WeeklyRotation (ModuleScript).
- Compute a week number from os.time() relative to a fixed start date in config. Use Random.new(weekNumber + a fixed salt from config) for all weekly picks.
- Expose: getCurrentWeek(), getSecondsUntilReset(), getRotation(weekNumber) returning that week's full rotation table.
- Servers open across the reset switch to the new rotation live, without restarting, and notify players in-game.
- A board in the hub/lobby and a small HUD timer counting down to the next reset.

## ROTATION SYSTEM 2 — Content pools
All pools live in config modules. Each pool item that is added later gets `From = <week>` (current week + 2), so adding content never reshuffles the running week or past weeks.
<!-- GENERATE: the pools for THIS game, as bullets. Usually: which main content is "always" vs "rotating" vs "event" (and how many rotating picks per week, with no repeats within 2 weeks), a weekly event pool (3-5 events, each with multipliers and visuals), a "boost of the week", area variants (lighting/decoration/spawn mix), a weekly shop rotation (cosmetics), and weekly challenges (pick 3: easy, medium, hard; each with a goal type, target and reward). Use this game's own names. -->

## ROTATION SYSTEM 3 — Apply the rotation
- Apply this week's picks through the existing systems (spawn tables, events via 05 System 5, boosts, area variants, shop).
- Rotating content players already own stays fully usable and sellable.
- Any collection/book UI marks rotating content as "In rotation this week" or "Returns later".

## ROTATION SYSTEM 4 — Weekly challenges
- Track progress server-side, saved with the week number. Reset automatically when the week changes.
- Challenges UI with progress bars and claim buttons. Rewards granted server-side only, scaled to the economy's price curve (check the ECONOMY STEPS notes in the progress log, and the economy numbers from the first-week review).

## ROTATION SYSTEM 5 — Rotation admin and testing tools
- Admin commands (via 05 System 3) to: preview the rotation for any week number, force-refresh the rotation, and override any single pick for the current week.
- A debug function that prints the next 12 weeks of rotations so bad combinations or repeats are easy to spot.
- Test that two servers produce identical rotations, and that the reset switch works without a server restart.

## ROTATION SYSTEM 6 — Weekly hype
- On the first join after a reset, show a "This Week in {{GAME_NAME}}" panel (via the 05 System 6 update log), auto-generated from the rotation data. No manual writing needed.
- Tease ONE item from next week's rotation on the hub board (e.g. "Next week: a Legendary returns...").
- Add the weekly rotation to `store_page/description.txt` (`player-text` rules) once it is published and switched on.

## ROTATION SYSTEM 7 — Content library expansion
- Report how many items are in each pool, and roughly how many weeks the rotation can run before it feels repetitive.
- Approval checkpoint (decide yourself, record it): enough new rotating content, events and challenges for at least 12 weeks without feeling repetitive (web-search every name).
- Build new models in batches of 4 with the `new-character` / `model-qa` skills, matching the quality of the existing ones, then add everything to the pools with `From = <week>`.

<!-- GENERATE: ONLY if the pitch has seasonal/holiday events, write PART B here:
# PART B — SEASONAL EVENTS
## ROTATION SYSTEM 8 — Seasonal events
Bullets adapted from this outline: holiday events run AUTOMATICALLY every year with no republishing (a holiday calendar config: fixed dates as month/day, moving dates worked out by code or a 10-year table; a sensible family-friendly set such as New Year, Lunar New Year, Valentine's Day, Easter, Summer, Halloween, Christmas); each is live for two weeks around its date (10 days before, 4 after, 15:00 UTC, configurable; overlaps swap halfway) through the 05 System 5 scheduler; themed event content for THIS game (e.g. 4 holiday creatures/items, one per rarity) built with the `seasonal-event` skill; a light themed touch in the hub plus real decorations that never block paths; the holiday replaces the weekly event while it runs; out of season, holiday content players own stays fully usable; hype entries via 05 System 6 and Rotation System 6, and a countdown to the next holiday; admin tools to preview any date and force a holiday on/off, tested with a faked date and two servers. Friendly and non-religious (no religious symbols).
Otherwise delete this comment. -->

# FINAL CHECK
Run a full regression playtest of the whole core loop plus an upgrade, a challenge, and a rejoin confirming all data saved. Print the rotation (and the seasonal calendar, if built) for the next 12 months and check it for repeats and bad combinations. Run every DevTools test suite and the `health-check` skill: all PASS, no errors in Output. Then write a checklist of which feature flags to switch on, and tell me the game is ready to publish.
