# 06 — Full quality QA pass (before the store-page pictures)

STATUS: NOT STARTED

- [ ] QA Step 1 — Main model quality audit
- [ ] QA Step 2 — Models, props and scenery
- [ ] QA Step 3 — UI on every screen size
- [ ] QA Step 4 — Sounds and music
- [ ] QA Step 5 — Full gameplay run-through
- [ ] QA Step 6 — Data, live-ops and safety
- [ ] QA Step 7 — Fix list and your sign-off

---

You are working in my open Roblox Studio session for "{{GAME_NAME}}" through the Studio MCP tools. Before any store-page pictures are taken (07_store_page.md), check EVERYTHING in the game is of a quality I would be proud to show. The bar is the best models from Art Phase A: chunky, cheerful, clean, nothing broken, clipping, floating, flickering, plain or half-finished. Fix what you find (gameplay fixes are allowed here, unlike the Store Steps), test the fix, and log it. Anything only I can judge (feel, taste, listening) goes in the progress log as "- [~] needs you" with click-by-click steps.

Rules for every step:
- Use the skills: `new-character`, `model-qa`, `add-asset`, `player-text`, `start-2p-test`, `log-phase`, `save-game`.
- Photosensitivity, nothing offensive or rude from any side, no religious symbols, colourful or white text only (CLAUDE.md "Always").
- Prove things in code first; photos only where a look needs judging.

## PROGRESS LOG AND SAVING
Log each step in DevNotes/Progress under "QUALITY QA" (what was checked, how, what was found, what was fixed, what still needs me) and the full write-up in the archive (`log-phase`). Save with `save-game` and commit after each step.

## QA STEP 1 — Main model quality audit
Every main model (<!-- GENERATE: what this game's main models are, e.g. "every creature species: always, rotating, event and seasonal" or "every vehicle and racer" -->): measure it against the Art Phase A models (body size, eye size, part count per rarity), build them in rows of ~10 next to 2-3 of the best ones and photograph; check limb counts, blink, animation, hover/flap for flyers, its sound, every place it is shown (UI pictures not cropped, silhouettes when undiscovered) and every variant look. Rebuild any that looks worse than the best ones.
- **Rude-readings check:** look at every model from the front, sides, back and above and REDESIGN any that could read as rude or as a symbol (upright pink/skin-coloured tubes, nubs or knobs; two round lobes that read as a bottom; anything phallic; zig-zag "S"/lightning shapes; crosses or 4/6/8-point stars). When unsure, redesign it.
- **Anatomy + feet:** limbs match the real animal/thing (4-legged = 4 in total; birds 2 legs + 2 wings; insects 6); every foot visible from the front or side, under the body (never wider than the torso), touching the ground. Prove it in code (each Leg/Foot/Paw: bottom height and position under the Body) and with a side photo.
- **Faces:** every face has a mouth (or a beak/snout that is the mouth); furry animals also a nose; eyes the same size and level, shine on the same side as the others, both visible from a 3/4 view.
- **One art style:** every model looks like it belongs to ONE set (blocks not spheres, the same eyes, stubby legs, cheerful colours with a contrasting feature, the same detail per rarity, the same material rules). Anything that looks like it comes from a different game gets rebuilt.
- **Reference pictures:** for every model, 2-3 real full-body photos of what it is based on (`model-qa` 1b): its signature features are there and it reads as that thing.
- **Cubes, not spheres:** count Ball/Cylinder parts in every model (Assets, Workspace, ServerStorage): must be 0.
- **Animated clipping:** FindClipping on the client's animated copy at the extreme poses, not only the still model.
- **Readability:** photograph each in its own area from the default player camera 15-30 studs away: the signature feature and colour still read.
- **Names:** every name web-searched again and checked for internet slang.

## QA STEP 2 — Models, props and scenery
Run `model-qa` over every area, building, prop, gear tier and decoration (and seasonal areas/decor if the game has them): no clipping, floating, flicker, stray bits, things in odd places or blocking paths/prompts; the same style everywhere. `SceneryScan` every area (in play if the game dresses things at runtime). Photograph each area from where a player stands.
- Anything with legs (stools, tables, signs, statues) stands on all of them; scale makes sense next to a player avatar (doors, benches, fences).
- Walk the whole edge of every area in play: the player can't get stuck, fall through or climb out.
- Look at each area in every lighting/variant: no dark spots, lights without a source, or z-fighting seen from far away. Nothing important hidden behind scenery from the default camera.

## QA STEP 3 — UI on every screen size
Open every screen, panel, popup and notification on PC and in the Device Simulator (a small phone, a big phone, a tablet): nothing cut off or overlapping, text readable and colourful/white (never grey), buttons work and close, icons crisp, numbers formatted, the tutorial clear for a brand-new player.

## QA STEP 4 — Sounds and music
Every sound slot plays at the right moment and loudness, every main model/character has its own fitting sound (if the game gives them voices), every area has its own music. Licences recorded (`add-asset`). List anything that needs my ears as "- [~] needs you".

## QA STEP 5 — Full gameplay run-through
As a brand-new player: <!-- GENERATE: the full run-through for this game, e.g. "tutorial -> core loop x3 -> first upgrade -> every area unlock -> variants -> daily reward -> weekly challenges and rotation -> a forced live event (and holiday) -> rejoin" -->. Then a 2-player test of every co-op/social feature (`start-2p-test`). The Output stays clean and the frame rate is smooth in the busiest places (count parts, particles and lights).

## QA STEP 6 — Data, live-ops and safety
DataStore saving and rejoin, data migration, shutdown safety, admin commands, feature flags, the weekly rotation (and seasonal calendar) for the next 12 months, every remote's validation (try bad values from the client), text filtering (search every script for where player-written text is shown to others and confirm each goes through TextService filtering on the server, failing safe to nothing), no outside scripts (search the whole game for scripts the template didn't write, e.g. ones that came inside a Creator Store model, and any `require(<number>)`, `loadstring` or `getfenv`), and every DevTools test suite PASS.

## QA STEP 7 — Fix list and your sign-off
Put every remaining issue in one list with what was fixed and what is left. Then STOP: I play the game myself and say whether it's ready for pictures. Tick this step "- [x]" only after I approve.
