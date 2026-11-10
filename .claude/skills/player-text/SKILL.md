---
name: player-text
description: Rules for any {{GAME_NAME}} text players or the store will read - in-game text (UI labels, buttons, tips, hints, notifications, NPC speech, signs, item descriptions, tutorial, What's New), pass/product text, update notes and the store description (store_page/description.txt). Use every time such text is written or changed, when a finished item adds a feature players can see (it goes in the store description), or when the user types /player-text.
---

# Writing text for players and the store

## How to write it
Simple English, short sentences, specific facts. Many players are 9-13: use words a 9-year-old knows. Say what the player does and gets ("Catch fish and sell them for coins"), not how good it is.

Check the finished text against this list. It is a short copy of https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing (no need to open the page; only re-read it if the user asks for the list to be updated).
- **Puffery words:** vibrant, rich, boasts, stunning, groundbreaking, nestled, seamless, immersive, robust, pivotal, crucial, key, vital, intricate, tapestry, testament, landscape, journey, delve, showcase, foster, enhance, leverage, elevate, unlock (as a figure of speech), dive in, valuable.
- **Importance claims:** "stands as", "serves as", "plays a key role", "is a testament to", "sets the stage for". Write "is" or "has" and state the fact.
- **Tacked-on "-ing" endings:** "..., making every visit feel fresh", "..., ensuring hours of fun", "highlighting", "showcasing", "reflecting". End the sentence at the fact.
- **Negative parallelism:** "not just X, but Y", "it's not X, it's Y", "no X, no Y, just Z", "Y rather than X".
- **Lists of three for rhythm:** "collect, upgrade and explore" is fine when those are the three things you do. Don't pad a list to three.
- **Vague claims:** "players love", "many say", "known for". Only say what is in the game.
- **Filler openers and closers:** "Additionally", "Moreover", "In summary", "Overall", "Whether you're X or Y", "Get ready to", "So what are you waiting for?".
- **Chat phrases:** "Certainly!", "I hope this helps", "Here is", "let me know".
- **Format:** no em dashes, no curly quotes, no emoji, no bold labels as headings, no Title Case Headings, no markdown symbols (`**`, `#`, `---`) in text players see.
- **Synonym swapping:** call a thing by one name every time (a "critter" stays a "critter", never "creature" then "companion").
- Font colours: colourful or white, never grey/black.
- Names: no internet slang; web-search every new name (CLAUDE.md Names rule).

## Weekly / live-ops wording
- Mention the weekly rotation only once `09_weekly_rotation.md` has built it and it is switched on. Before that, say nothing about weekly content.
- Never promise hand-made "new content every week". Describe the AUTOMATIC weekly rotation, e.g. "Featured items, events and challenges change every Saturday!"
- Weekly content must need no manual work.

## Store description (`store_page/description.txt`)
- The only description file. Plain text, ready to paste into the Creator Hub. Edit it; never start a new one.
- Under 1,000 characters. No numbers (no item counts).
- Keep the credits line (CC BY, if any) at the end and the TITLE OPTIONS block below it.
- Only describe features that are built and tested in the game.
- **After every finished item that adds a feature players can see**, add it here before that item's commit. If it pushes the text over 1,000 characters, shorten other lines.
