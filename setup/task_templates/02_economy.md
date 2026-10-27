# 02 — Economy (what the currency is for)

STATUS: NOT STARTED

- [ ] Economy Step 1 — Economy plan and balance
<!-- GENERATE: one "- [ ] Economy Step N — <Title>" line per step below (usually 4-6 steps in total). -->

---

You are working in my open Roblox Studio session for "{{GAME_NAME}}" through the Studio MCP tools. The core game (01_build.md) is built. Your job is to give players meaningful things to spend their currency on, in the Economy Steps below. Inspect the existing structure, scripts, config modules and save data first, and reuse existing systems (save system, configs, core loop, shops, UI) rather than rebuilding them.

## RULES
- Server is authoritative for all purchases, upgrades and currency changes. Validate every request: the player can afford it, meets requirements, and isn't spamming. Never trust the client.
- All prices, stats, tiers, durations and multipliers live in config modules in ReplicatedStorage/Shared/Config so I can rebalance without touching code.
- Any save format change must bump the data version and add a migration. Never remove or rename existing saved fields. Existing players keep everything they own.
- New gear/items get simple block-built placeholder models (ModelKit), clearly named, so the Art phases can replace them later.
- Keep it fair: everything important must be reachable by playing. Robux may speed things up but never be the only way.
- Comment the code clearly. I am learning.

## PROGRESS LOG AND SAVING
- Add or update an "ECONOMY STEPS" section in ServerStorage/DevNotes/Progress (never remove or change other sections), using the `log-phase` skill.
- After each step, record: which steps are complete, where the main scripts and configs are, current prices and balance values, any known problems, and any decisions made.
- Save with the `save-game` skill and commit after each step.

## ECONOMY STEP 1 — Economy plan and balance
Before building anything, write a short economy plan (an approval checkpoint: decide it yourself and record it in the progress log):
- Roughly how much currency per hour a new, a mid-game and a late-game player earns.
- A price curve for every upgrade line, so a new player buys their first upgrade within about 5 minutes, unlocks the second area within about 1–2 hours, and reaches the end goal (e.g. prestige) after roughly 15–25 hours of play.
- Which upgrades are one-time purchases and which are recurring (consumables).
- A spreadsheet-style table of every price and value, put into the config modules.

<!-- GENERATE: the remaining economy steps for THIS game, each as "## ECONOMY STEP N — <Title>" with 3-6 specific bullets. Pick from what fits the pitch: gear/tool upgrade tiers (each tier visibly better and needed for harder content), area unlocks (gates + prices + a clear "locked" look), home/shop/base upgrades, consumables (short boosts, never pay-to-win), a prestige/rebirth loop that keeps cosmetics and collection, and a sink for late-game currency. Each step names its config module and its UI. -->
