# 08 — Launch and first numbers

STATUS: NOT STARTED

- [ ] Launch Step 1 — Analytics events
- [ ] Launch Step 2 — Launch checklist
- [ ] Launch Step 3 — Publish (HUMAN CHECK)
- [ ] Launch Step 4 — First-week review (HUMAN CHECK)

---

You are working in my open Roblox Studio session for "{{GAME_NAME}}" through the Studio MCP tools. The game is built, checked (06_quality_qa.md) and has its store page material (07_store_page.md). This file gets it in front of real players and reads the first numbers, before any more content is built. Steps 3 and 4 are human checks: you stop and wait for me (instructions.md, "Human checks").

## RULES
- Never publish the game yourself (File > Publish to Roblox, or any other way). I publish it in Step 3.
- Analytics events are sent from the server only. Never put a player's name, typed text or any other personal detail in an event.
- Event names and funnel steps live in a config module in ReplicatedStorage/Shared/Config (e.g. Config/Analytics), behind a feature flag.
- Comment the code clearly. I am learning.

## PROGRESS LOG AND SAVING
- Add or update a "LAUNCH" section in `devnotes/Progress.md` (never remove or change other sections), using the `log-phase` skill: which steps are done, the event list, the launch checklist with what is ticked, the numbers I report in Step 4 and what was decided.
- Save with the `save-game` skill and commit after each step.

## LAUNCH STEP 1 — Analytics events
Roblox shows visits, playtime and retention without any code. These events add what it can't see by itself: where new players give up, and whether the economy is balanced. Read the current Roblox guide first (https://create.roblox.com/docs/production/analytics/event-types and the AnalyticsService class page) and use the methods it documents today.
- One server module (e.g. ServerScriptService/Server/Analytics) wraps every AnalyticsService call in pcall, so the rest of the code calls `Analytics.funnel(player, step)` and never AnalyticsService itself.
- Onboarding funnel (AnalyticsService:LogOnboardingFunnelStepEvent): one step per stage of a new player's first session, in order. <!-- GENERATE: the 5-8 funnel steps for THIS game, e.g. "1 joined, 2 finished the tutorial, 3 first full core loop, 4 first sale, 5 first upgrade bought, 6 second area unlocked". Each step is logged once per player (saved in their data). -->
- Economy events (AnalyticsService:LogEconomyEvent): every time currency is earned or spent, with the amount, the balance after it, and what it was for (the item or upgrade id).
- Custom events (AnalyticsService:LogCustomEvent) for the few things worth counting that the two above miss: <!-- GENERATE: 3-5 for this game, e.g. "co-op help given", "daily reward claimed (with streak length)", "shop opened". -->
- Testing: Roblox only accepts events from a published game, so nothing reaches the dashboard from a Studio playtest. In Studio the wrapper module records each call in a list that a DevTools test can read. Test with that list: each event is recorded once at the right moment with the right values, a call that errors never breaks gameplay, and switching the flag off stops every event. The real check is in Step 3, after I publish.

## LAUNCH STEP 2 — Launch checklist
Take the hand-written checklist from the last Build Phase and the flag list from 05_liveops.md, check each line against the game as it is now, and write the result to `Launch checklist.txt` in the repo as click-by-click steps for me. It must cover:
- Game passes and developer products: I create each one in the Creator Dashboard and upload its icon from `store_page/passes/`. You read the ids and put them in the monetisation config (07_store_page.md says how).
- The store page: name, description from `store_page/description.txt`, icon, thumbnails, genre, and which devices are allowed.
- The Maturity and Compliance questionnaire, which Roblox requires before a game can be public. List the honest answers for this game.
- Settings: maximum players per server, private servers on or off, API access, and which feature flags are on for launch.
- The admin list has my UserId and nobody else's.
- A last full run of the `health-check` skill and SessionLockTest, both passing.
Anything you can do yourself, do. Mark every line that needs me with "YOU:".

## LAUNCH STEP 3 — Publish (HUMAN CHECK)
STOP and wait for me. Tell me the launch checklist is ready and what is left on it. I go through the "YOU:" lines, publish the game (File > Publish to Roblox) and set it to Public. When I say it is live:
- Check it from outside Studio as far as you can (the store page loads, the pass and product ids resolve with MarketplaceService:GetProductInfo).
- Ask me to play one full session in the live game (not Studio), then tell me where the events should show up in the Creator Dashboard (Analytics > Funnel and Economy) and that they can take up to a day to appear. If they don't, fix the wrapper module and ask me to publish again.
- Record the launch date and the published version in the progress log.
- Tell me what to watch for in the first days: errors in the Creator Dashboard's error report, and players getting stuck (the funnel).
Tick this step only after I say the game is live.

## LAUNCH STEP 4 — First-week review (HUMAN CHECK)
STOP and wait until I come back with numbers. They need about a week of real players. Tell me exactly where to find each one in the Creator Dashboard (Analytics), then ask me for:
- Visits, and the average playtime per visit.
- Day 1 retention (how many new players come back the next day), and Day 7 if there is enough data.
- The onboarding funnel: how many players reach each step.
- The economy charts: how much currency is earned and spent, and on what.
- The most common errors in the error report.
Then, from those numbers:
- Name the biggest drop in the funnel and propose up to three fixes for it. Build the ones I agree to, test them, and tell me to publish again.
- Fix every error that real players hit.
- Give me a plain recommendation on 09_weekly_rotation.md: build it now, or first improve the core game and review again. A weekly rotation gives returning players something new. It does not make a first session more fun, so if few players come back on Day 1, the core loop and the tutorial come first.
Record the numbers, the fixes and my decision in the progress log. Tick this step only after I decide.
