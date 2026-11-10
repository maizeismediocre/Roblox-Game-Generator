---
name: log-phase
description: Update the {{GAME_NAME}} progress log (devnotes/Progress.md in the repo) when a phase/step/system is finished, including the mandatory NOT YET TESTED audit. Use during every task's wrap-up, before the end-of-task summary, or when the user types /log-phase.
---

# Update the {{GAME_NAME}} progress log

The log is two plain files in the repo's `devnotes/` folder. They are read with the normal file tools (no Studio needed, also while a playtest runs) and git shows every change to them. The user may be a beginner and uses them to keep track, so keep them concise, plain and up to date.
- `devnotes/Progress.md` = what's open NOW (keep it under about 300 lines): each section's STATUS, every NOT YET TESTED item, NEEDS YOU, TEMPORARY THINGS, OPEN QUESTIONS, NEXT UP. Rewrite outdated notes instead of appending.
- `devnotes/ProgressArchive.md` = the full write-up of finished work. It only grows. NEVER read it whole: add to its end, or search it with Grep and read the matching lines.

## 1. Read it
Read `devnotes/Progress.md`. Don't read the archive.

## 2. Write the finished work up in the ARCHIVE
Add a block for the finished item at the end of `devnotes/ProgressArchive.md` without reading the file: write the block to a file in the scratchpad with the Write tool, then append it in Bash with `cat "<scratch file>" >> devnotes/ProgressArchive.md`. Head it with its section and date as a `##` heading, e.g. "## POLISH STEPS - P2 SOUND SYSTEM (done 2026-01-05)". Never change earlier blocks. The current task file names its section:

| Task file | Section |
|-----------|---------|
<!-- GENERATE (SETUP step 6c): one row per task file, e.g. | 01_build.md | BUILD PHASES | -->

Each task file's "PROGRESS LOG AND SAVING" section lists what that section must contain. Read just that section of the current file and cover every item it lists.

## 3. Refresh Progress (the short one)
- **STATUS**: tick the finished item.
- **NOT YET TESTED**: audit (below).
- **NEEDS YOU**: anything waiting for the user, with click-by-click steps. Human checks (the fun check, the QA sign-off, publishing, the first-week numbers) go here with the user's answers once given.
- **TEMPORARY THINGS**: anything added just for testing or as a placeholder, and when it should go.
- **NEXT UP**: the next unticked item from the task files.

## 4. NOT YET TESTED audit (never skip)
For the work just finished, list every feature, branch and edge case that was written in code but NOT proven by a test (yours or the user's): failure paths, limits, multi-player cases, save/rejoin cases, rate limits, purchases, etc. Add each one as:
```
- [Phase/step] <what is untested>
  How: <click-by-click steps a beginner can follow, and what "working" looks like>
```
Remove items that have now been tested. Every "not tested" item in your end-of-task summary must also be in the log, and the other way round.

## 5. Write and confirm
Edit `devnotes/Progress.md` with small targeted edits (the Edit tool). To confirm the archive, look at its last lines only (`tail -5 devnotes/ProgressArchive.md`). In the progress update, say that the log was updated. Both files go in the item's commit. Saving the game is done by the `save-game` skill.
