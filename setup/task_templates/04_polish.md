# 04 — Polish (sound, music, character/NPC animation, game feel)

STATUS: NOT STARTED

- [ ] Polish Step P1 — Audit
- [ ] Polish Step P2 — Sound system
- [ ] Polish Step P3 — Fill the sounds and music
- [ ] Polish Step P4 — Player character animations
- [ ] Polish Step P5 — NPC animations
- [ ] Polish Step P6 — UI and game-feel polish

---

You are working in my open Roblox Studio session for "{{GAME_NAME}}" through the Studio MCP tools. The game is built and has its art and animation. Your job is to add sound, music, character/NPC animation and UI polish. Inspect the existing structure, scripts and config modules first, and reuse existing systems (the animator, effects, UI, settings, the placeholder sound/particle hooks from the last Build Phase) rather than rebuilding them.

## RULES
- All sound ids, animation ids, volumes and timings live in config modules in ReplicatedStorage/Shared/Config (e.g. Config/Sounds).
- AUDIO LICENSING: the game may earn money, so every sound and music track must be free AND safe for commercial use in a Roblox game. Follow the `add-asset` skill (allowed creators, one new slot per new moment, record creator + source for every sound). If you are unsure whether a sound is safe, leave the slot empty and flag it for me.
- Animations and sounds are cosmetic and run on the client wherever possible. The server only tells clients what happened.
- Must run well on mobile: limit how many sounds play at once, and only animate characters and NPCs near the player's camera.
- Comment the code clearly. I am learning.

## PROGRESS LOG AND SAVING
- Add or update a "POLISH STEPS" section in ServerStorage/DevNotes/Progress (never remove or change other sections), using the `log-phase` skill: which steps are complete, where the main scripts and configs are, which sound/animation slots are filled or still empty, any sounds flagged for licensing checks, and any known problems or decisions.
- Save with the `save-game` skill and commit after each step.

## POLISH STEP P1 — Audit
List every moment in the game that should make a sound or play an animation (UI clicks, rewards, purchases, errors, every core-loop action, area changes, events, NPC actions...), what exists already, and what's missing. Record the list in the progress log; it drives P2-P6.

## POLISH STEP P2 — Sound system
- A client SoundController: plays sounds by slot name from Config/Sounds, with 2D UI sounds, 3D positional sounds, music per area with smooth crossfades, a cap on sounds playing at once, and pitch variation so repeats don't sound robotic.
- Settings: separate Music and Sound volume sliders, saved with the player's data.
- Loudness: measure each sound (RMS with an AudioAnalyzer in a playtest) and set its Volume from a loudness target table, so nothing is much louder than the rest.

## POLISH STEP P3 — Fill the sounds and music
- Fill every slot from the P1 list with a licensed sound (see `add-asset`; Creator Store API search: `https://apis.roblox.com/toolbox-service/v2/assets:search?searchCategoryType=Audio&query=<words>&maxPageSize=100`).
- One music track per area (calm, loopable, not too busy), plus short stingers for big moments.
- Every new moment gets its own slot and its own sound; never leave one silent or reuse another slot's sound.

## POLISH STEP P4 — Player character animations
- Custom animations for the game's player actions (e.g. carrying, using a tool, celebrating), made with code (Motor6D/CFrame tweens on R15) or allowed Roblox animation ids; they must blend with normal walking and work for every avatar size (R15).
- Test on a default avatar and a very small and very tall one.

## POLISH STEP P5 — NPC animations
- Any NPCs (shopkeepers, customers, enemies, guides) walk, idle and react (happy/sad/wave) with animations, look at players nearby, and never slide or T-pose. Only animate NPCs near the camera.
- If the game has no NPCs, make this step a check that nothing T-poses or slides and note that in the log.

## POLISH STEP P6 — UI and game-feel polish
- Consistent UI style: one font family, rounded corners, a clear colour per currency/action, icons from `add-asset` rules (downloaded, black outline), colourful or white text only.
- Juice: buttons pop when pressed, numbers count up, rewards fly to the counter, gentle screen effects for big moments (photosensitivity rules).
- Check every screen on phone, tablet and PC sizes (Device Emulator): nothing cut off, overlapping or too small to tap (at least 44 px).
