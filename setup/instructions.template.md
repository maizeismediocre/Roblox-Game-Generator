# {{GAME_NAME}} — Session Instructions

You are helping me build the Roblox game "{{GAME_NAME}}" in my open Roblox Studio session through the Studio MCP tools. The work is split into numbered task files in this folder. Follow these rules every session.

## Keep going, but stop at task-file ends and topic changes
- Work through the items one after another WITHOUT stopping to wait for me. I do not need to say "continue".
- STOP after finishing an item (tested, logged, saved, committed, pushed) when EITHER:
  1. it was the END OF A TASK FILE (its last item is done and its STATUS is COMPLETE), or
  2. the NEXT item/phase is UNRELATED to the one just finished (different system or topic, e.g. sounds -> UI, art -> animation code), so I can clear the context window before it.
  When you stop: send me a push notification (PushNotification tool) with a one-line summary and what is next, give the progress update, then wait for me. Do not start the next item until I say so.
- Related items (same system, building on each other) go straight on without stopping.
- These rules override the task files wherever they say "STOP", "wait for me", "wait for my approval" or "remind me to save".
- Instead of me testing, YOU test every item properly (see "Doing the task") before ticking it.
- At approval checkpoints (plans, proposals, art reviews, etc.), make the sensible choice yourself and record it in the progress log under the section's decisions, so I can review and change it later.
- Otherwise only stop early when you are genuinely blocked on something only I can do or give you (see "If something goes wrong").
- Before each task, tell me which effort level suits it (high for models, art and QA; medium for plain code and text).

## Checkbox meanings
- "- [ ]" = not started
- "- [~]" = built, but part of it needs ME (something you can't test or provide yourself); what's needed is in the progress log
- "- [x]" = built and passed your tests

## Finding the next task
1. Don't open every task file: grep just the STATUS lines (`grep -n STATUS 0*.md`) of
   01_build.md, 02_economy.md, 03_art.md, 04_polish.md, 05_liveops.md, 06_quality_qa.md, 07_store_page.md
   (06 = full quality QA pass: it must be COMPLETE before any store-page pictures)
2. Skip any file whose STATUS line says COMPLETE (never read it); read only the first file that isn't.
3. In the first file that is not complete, find the first "- [ ]" item. That is the next task. Items marked "- [~]" don't block you; just mention them in your progress updates.
4. Never run anything in a manual/ folder unless I explicitly ask for it by name.

## Handoff check (first thing every session)
- Run `git log -5` and read the last commits' descriptions. If any has a "HANDOFF" section, finish/check those items before anything else and tell me what it said (the `handoff` skill).
- Whenever a task is left unfinished (session ending, blocked, stopping mid-item): save the game with the `save-game` skill, then commit (and push, if the repo has a remote) with a "HANDOFF" section in the commit description saying what is done, what is NOT done, what needs checking, and where it is in Studio.
- If an earlier HANDOFF is still open, the new note repeats it in full and adds the new part after it.
- Open or closed: the newest commit with a "HANDOFF" or "HANDOFF CLOSED" line decides. Partly finished = a new HANDOFF with finished items marked "[done]". Fully finished = the commit that completes it says "HANDOFF CLOSED (was <hash>): all done", and only when the matching task-file checkboxes are ticked "- [x]".

## Studio check (every session, quick)
- Confirm the Studio MCP tools respond (`list_roblox_studios`, then list the children of Workspace). If they don't, STOP and tell me: Roblox Studio must be open with the game, and Studio's MCP server must be on (Assistant window > ... > Manage MCP Servers > Enable Studio as MCP server). After turning it on, I restart Claude with the desktop shortcut.
- If the `save-game` skill still says `{{PLACE_ID}}`, the game has never been saved to Roblox: do its "First save" section before anything else.

## Start-of-session health check - only when I ask
Don't run the full health check at the start of a session; go straight from the handoff check to the next task. Run it (the `health-check` skill) only if I ask for it, or after a big change that touched the core loop. It:
- reads the in-game progress log at ServerStorage/DevNotes/Progress,
- checks the items ticked in the task files really exist in the game (if the checklists, the log and the game disagree, STOP and explain; don't guess or rebuild without my approval),
- smoke-tests the core loop as far as it exists (including leave and rejoin to confirm data saved) and checks the Output window.
  - If saving fails because Studio has no DataStore access, tell me to turn on "Enable Studio Access to API Services" in Game Settings > Security (the game must be saved to Roblox first), and wait.

## Doing the task
1. Read the whole task file, not just the current item, because its rules sections apply to every item in it.
2. Complete only that one item, following its task file's instructions and rules.
3. Test it properly yourself:
   - Playtest every feature of the new work, including failure paths and edge cases (e.g. can't afford, limits, rate limits, rejoin and check it saved).
   - Re-run the core loop smoke test (the `health-check` scripts, once they exist), so new work hasn't broken old work.
   - Check the Output window and fix any errors or warnings, then test again.
   - If a test needs 2 or more players, use the `start-2p-test` skill to start it yourself.
4. Update the in-game progress log as the task file describes, using the `log-phase` skill.

## Finishing the task
5. Mark the item "- [x]" (or "- [~]" if part of it needs me). If it is the file's first started item, change STATUS to IN PROGRESS. If every item is "- [x]", change STATUS to COMPLETE.
6. Only ever edit the STATUS line and checkboxes in task files. Never change, delete or rewrite the task instructions themselves (unless I ask you to add or change an item).
7. If the item added a feature players can see, add it to `store_page/description.txt` (the `player-text` skill).
8. Save the game with the `save-game` skill (Save to Roblox + Save to File over "{{BACKUP_FILE}}").
9. Commit to git: stage the changed files (task files, backup .rbxl, skills, etc.) and commit with a short message such as "Build Phase 3: Shops". Do NOT add a Co-Authored-By line or any other AI attribution. Then push it (`git push`) if the repo has a remote. If the push fails, tell me why and carry on; never force-push.
10. Give me a short progress update: what you built, what you tested and the results, any decisions you made at approval checkpoints, and anything that needs me. Then go straight on to the next item - unless that finished the task file or the next item is unrelated: then notify me and STOP (see "Keep going, but stop at task-file ends and topic changes").

## If something goes wrong
- If a task can't be completed (missing assets, broken connection, something you need from me such as sound IDs, Robux product IDs, uploads or account settings), leave it as "- [ ]" (or "- [~]" if the rest is built), write what is blocking it in the progress log, tell me exactly what you need, and move on to the next item that isn't blocked by it. If nothing else can be done, stop.
- Never publish the game (File > Publish to Roblox) unless I ask. Saving to Roblox is fine.
