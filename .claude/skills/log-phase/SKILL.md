---
name: log-phase
description: Update the {{GAME_NAME}} in-game progress log (ServerStorage/DevNotes/Progress) when a phase/step/system is finished, including the mandatory NOT YET TESTED audit. Use during every task's wrap-up, before the end-of-task summary, or when the user types /log-phase.
---

# Update the {{GAME_NAME}} progress log

There are ModuleScripts in `ServerStorage/DevNotes`. They never run; each is one comment block. The user may be a beginner and uses them to keep track, so keep them concise, plain and up to date.
- `Progress` = what's open NOW (keep it under ~20k chars): each section's STATUS, every NOT YET TESTED item, TEMPORARY THINGS, OPEN QUESTIONS, NEXT UP. Rewrite outdated notes instead of appending.
- `ProgressArchive` (then `ProgressArchive2`, `3`...) = the full write-up of finished work. Roblox scripts max out at 200,000 chars: when the newest archive passes ~180,000, make the next one and append there. NEVER read an archive whole (that costs ~30k tokens). Only append, or search them with `execute_luau` that returns just the matching lines.

## 1. Read it
`script_read game.ServerStorage.DevNotes.Progress` (stop any playtest first, because script_read fails while playing). Don't read the archive.

## 2. Write the finished work up in the ARCHIVE
Append a block for the finished item at the end of the newest archive, just before the closing `]]`, with `execute_luau`, e.g. `s:gsub("%]%]%s*return nil%s*$", block .. "\n]]\n\nreturn nil\n")` - check the replace count is 1 (the block must stay INSIDE the comment, never after `return nil`). Head it with its section and date, e.g. "POLISH STEPS - P2 SOUND SYSTEM (done 2026-01-05)". Never change other sections. The current task file names its section:

| Task file | Section |
|-----------|---------|
<!-- GENERATE (SETUP step 6c): one row per task file, e.g. | 01_build.md | BUILD PHASES | -->

Each task file's "PROGRESS LOG AND SAVING" section lists what that section must contain. Read just that section of the current file and cover every item it lists.

## 3. Refresh Progress (the short one)
- **STATUS**: tick the finished item.
- **NOT YET TESTED**: audit (below).
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
Edit Progress with `multi_edit` (small targeted edits) or execute_luau setting `.Source` in edit mode. To confirm, return only the changed part, e.g. the archive's last ~300 characters. Don't read either whole script back. In the progress update, say that the log was updated. Saving is done by the `save-game` skill.
