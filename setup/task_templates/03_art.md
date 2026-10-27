# 03 — Art and animation

STATUS: NOT STARTED

- [ ] Art Phase A — Style test
- [ ] Art Phase B — Full model set
- [ ] Art Phase C — Procedural animation
- [ ] Art Phase D — Effects and variant looks
- [ ] Art Phase E — Environment, gear and props
- [ ] Art Phase F — Lighting, skies and final pass

---

You are working in my open Roblox Studio session for "{{GAME_NAME}}" through the Studio MCP tools. The game works with placeholder models. Your job is to give it one consistent, polished art style. Inspect the existing models and the configs that point at them first, and keep every model's name and location so nothing else needs to change.

## PROGRESS LOG AND SAVING
- Add or update an "ART PHASES" section in ServerStorage/DevNotes/Progress (never remove or change other sections), using the `log-phase` skill: which phases are done, the style rules, approved/rejected models, where the recipes live, and anything that still needs work.
- Save with the `save-game` skill and commit after each phase.

## ART STYLE
<!-- GENERATE: 4-8 bullet lines describing THIS game's look, from the pitch's "Look" line, inside these fixed limits: everything is built from plain Roblox parts with ModelKit (blocks, wedges, the odd stepped-round block; never meshes, never spheres/cylinders); chunky and simple with big flat faces; SmoothPlastic look; soft cheerful main colours with 1-2 brighter accent colours per model; Neon only in deep saturated colours. Say what the main characters/creatures/vehicles look like (proportions, faces), what the world looks like per area, and the mood. These lines are also copied into the `model-qa` skill section 0. -->

## MODEL RULES
- Every model is a recipe in a ServerStorage/ArtTools recipe module (e.g. ArtTools/CharacterRecipes, ArtTools/PropRecipes) built with ModelKit: front = -Z, bottom at y = 0, a part named "Body" = the biggest part. Name parts by feature (first word = feature: `Wing`, `WingTip`) so FindClipping works.
- Every model passes the `model-qa` skill before it goes in (checks empty, photos from every side, side-by-side with its neighbours, common-sense review). New characters/creatures also follow `new-character`.
- Each thing is clearly ONE recognisable thing from its silhouette and colours; rarer/better things look more special (more detail, gentle glow accents, crowns, gems).
- Nothing resembling existing copyrighted characters or franchises. Nothing rude or offensive from any side (CLAUDE.md "Always").
- Keep part counts sensible for mobile (most models 15-45 parts).

## ART PHASE A — Style test
- Build 3 of the main models (a common one, a mid one, the best/rarest one) and one prop in the new style, place them in Workspace.ArtReview next to a default Roblox character for scale, run `model-qa` on them, and photograph them together.
- Approval checkpoint: decide yourself whether the style works and record it (with the photos' findings) in the progress log. These 4 set the quality bar for everything after.

## ART PHASE B — Full model set
- Build every remaining main model (characters/creatures/vehicles/items the game is about) in batches of 4, each batch through `model-qa` and a side-by-side photo with the Phase A models.
- Install each into its Assets location under the same name, so the game uses it everywhere. Move old placeholder versions to ServerStorage/ArtArchive until the end of this file.

## ART PHASE C — Procedural animation
- A reusable client ModuleScript (e.g. ReplicatedStorage/Shared/ModelAnimator) that animates block-built models with TweenService/CFrame maths on the client: idle (gentle bob/breathing, randomised so they don't move in sync), moving (hop or waddle), a happy/celebrate move, and appear/disappear poofs; parts tagged in recipes with `anim = {group, hinge, axis, phase}` move on their own (tails, ears, wings with `flap`), with the numbers in Config/Animation.
- Eyes named "Eye" blink. Flyers and floaters hover with a gentle bob and their wings flap.
- Animation runs only near the player's camera and cleans up when a model is destroyed. Photosensitivity rules apply (no fast flashing).

## ART PHASE D — Effects and variant looks
- Code-only looks for any variants/rarities/upgrades the game has (e.g. a colour shift with gentle sparkles, gold Metal with a soft glow, a bigger size), stackable and readable at a glance. No extra models.
- Particle and tween effects for the game's key moments (rewards, level-ups, unlocks), all smooth and gentle.

## ART PHASE E — Environment, gear and props
- Rebuild every prop, gear tier, shop/base piece and decoration in the style (each gear tier visibly fancier than the last), plus 5-8 decorations per area, as a modular kit of reusable pieces.
- Use Roblox Terrain where it suits the ground; everything else is part-built.
- Run `model-qa` per batch and `SceneryScan` over each finished area (nothing floating, flickering or doubled), then the common-sense review in place (everything held up by something, in a sensible spot, not blocking paths).

## ART PHASE F — Lighting, skies and final pass
- Lighting, Atmosphere and colour correction per area to suit the style, switching smoothly when the player changes area. Stylised skies (one per area, see the `add-asset` skill for uploaded images; at most ONE sun or moon per sky; stars are round dots, never pointed sparkles).
- Final pass: `SceneryScan` over the whole map, a walk-through photo set from player height, part counts per area, and a list of anything that still needs work. Remove ServerStorage/ArtArchive once everything is replaced.
