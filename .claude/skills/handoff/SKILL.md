---
name: handoff
description: Write, update or close the {{GAME_NAME}} HANDOFF section in a commit message for unfinished work. Use when leaving a task unfinished, when committing while an earlier HANDOFF is still open, when all handoff items are done, or when the user types /handoff.
---

# Handoffs (unfinished work)

The newest commit whose message has "HANDOFF" or "HANDOFF CLOSED" decides whether a handoff is open. Find it with `git log -10 --format='%h %s%n%b' | grep -n HANDOFF` (look further back if needed).

## Leaving a task unfinished
1. `save-game` first (always, even near the usage limit).
2. Commit + push (push only if `git remote` shows one) with a "HANDOFF" section: done / NOT done / needs checking / where in Studio. Handoffs are read from local `git log`, so they work without GitHub.
3. Note it in the progress log (`log-phase`).

## Committing while a HANDOFF is open
- Every commit repeats the open HANDOFF in full, plus any new part. Finished items are marked "[done]".
- Copy it from the newest HANDOFF commit (`git log -1 --format=%B <hash>`), don't retype it from memory.

## Closing
- Only when the task-file checkbox(es) are "- [x]": commit with "HANDOFF CLOSED (was <hash>): all done".
