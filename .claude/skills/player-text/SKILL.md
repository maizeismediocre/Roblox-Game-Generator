---
name: player-text
description: Rules for any {{GAME_NAME}} text players or the store will read - in-game text (UI labels, buttons, tips, hints, notifications, NPC speech, signs, item descriptions, tutorial, What's New), pass/product text, update notes and the store description (store_page/description.txt). Use every time such text is written or changed, when a finished item adds a feature players can see (it goes in the store description), or when the user types /player-text.
---

# Writing text for players and the store

## How to write it
Follow https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing. Check the finished text against it.
- Simple English, short sentences, specific facts. Many players are 9-13: words a 9-year-old knows.
- No puffery words (vibrant, boasts, showcase, additionally, ensure, seamless, immersive...).
- No "not just X, but Y". No lists of three just for rhythm.
- No em dashes. No emoji or bold labels as headings.
- Font colours: colourful or white, never grey/black.
- Names: no internet slang; web-search every new name (CLAUDE.md Names rule).

## Weekly / live-ops wording
- Never promise hand-made "new content every week". Describe the AUTOMATIC weekly rotation, e.g. "Featured items, events and challenges change every Saturday!"
- Weekly content must need no manual work.

## Store description (`store_page/description.txt`)
- The only description file. Plain text, ready to paste into the Creator Hub. Edit it; never start a new one.
- Under 1,000 characters. No numbers (no item counts).
- Keep the credits line (CC BY, if any) at the end and the TITLE OPTIONS block below it.
- Only describe features that are built and tested in the game.
- **After every finished item that adds a feature players can see**, add it here before that item's commit. If it pushes the text over 1,000 characters, shorten other lines.
