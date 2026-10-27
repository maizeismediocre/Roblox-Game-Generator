---
name: model-qa
description: Quality-check every {{GAME_NAME}} model you add or change (characters, creatures, props, scenery, gear, code-built pieces) - nothing clipping, floating, flickering, poking out or oddly shaped, and everything makes sense where it is (held up by something, in a sensible place) - with the automatic checks, photos from every side and a common-sense review. Also run it over everything changed at the end of a session. Use every time a new model is created or an existing one is reshaped, before swapping it into the game, or when the user types /model-qa.
---

# Model QA (run for EVERY new or changed model)

Models are done carefully, not lazily. A model is not finished until it passes all of this. Keep progress lines short.

Tools: `ServerStorage/ArtTools/ModelKit` (the builder + the checkers `Check`, `FindClipping`, `FindFlicker`, `FixFlicker`, `CheckPieces`, `Turnaround`, `Build`) and `ServerStorage/ArtTools/SceneryScan` (whole areas). Both are installed in Build Phase 1 from `studio_tools/*.luau`; if they are missing, install them first. The checkers take any Model, so use them on props and scenery too. Run them with `execute_luau` (Edit) via `local M = require(game.ServerStorage.ArtTools.ModelKit)`.

## 0. THE {{GAME_NAME}} ART STYLE (every model must match it)
ONE consistent art style across the whole game. The reference is the Art Phase A models (and later the best finished ones). Check every model against EACH line below and fix anything that doesn't match before it goes in.

**This game's look**
<!-- GENERATE (SETUP step 6c): this game's style lines from the pitch's "Look" (same lines as 03_art.md ART STYLE): main colours and mood, what the main characters/creatures/vehicles look like (proportions, size range in studs, faces), what each area looks like. -->

**Build (every game made from this template)**
- Made only from plain Roblox Parts (blocks + the odd wedge), never meshes, never spheres/cylinders (`Shape` Ball = 0). Round things are cubes, a cube turned 45 degrees, or 3 crossed blocks (ModelKit's "Round" shape does this).
- Chunky and simple: big flat faces, few large pieces, crisp edges. No thin spindly sticks (except strings/whiskers), no lumpy or "melted" clusters, no tiny noisy details.
- Smooth plastic look. Props/scenery: materials only for things really made of it (metal, fabric, wood, stone, grass, glass/crystal). **Moving models (characters, creatures, pets, vehicles): only SmoothPlastic, Neon, Glass and Metal** - Roblox lays material patterns in world space, so patterns slide across a model that moves (`ModelKit.Build` turns them smooth for recipes in `M.Moving`).

**Faces (characters and creatures)**
- `M.face` eyes: tall black rectangles (about 0.26-0.34 wide on a ~1.5-wide body), a small white shine square top-left, blush under the outer corners. Big and friendly, on a flat front.
- Every face has a mouth: a small black bar, or the snout/muzzle/beak is the mouth. Furry animals also get a nose. No coloured markings below the eyes that could look like an open mouth, lips or teeth.

**Legs and feet**
- Short, stubby, chunky legs, all the same length, tucked UNDER the body like a real standing animal. **No foot, leg or paw sticks out wider than the torso.**
- The right number of limbs for the real animal (4 legs in total for a quadruped, even when it holds something; birds 2 legs + 2 wings; insects 6). Every foot is visible from the front or side and touches the ground (floaters excepted).

**Colour**
- Soft, cheerful main colours with 1-2 brighter accent colours for the signature feature, which contrasts with the body so it reads from the player camera.
- No dull grey/brown/black bodies (dark only for small bits: noses, eyes, hooves). No dark-brown lumps on heads (they read as poo). Text is never grey or black.
- Neon only in deep, saturated colours, and glows are slow and gentle (at most 2 a second, no harsh flashing).

**Character + detail**
- Each model is clearly ONE recognisable thing: its 3-5 signature features from reference photos are big enough to read from the player camera. A stranger should be able to name it.
- Costume/holiday extras (hats, bows, held items) are small and sit ON the base model. They never replace its own features.
- More detail for rarer/better things (e.g. Common ~15-25 parts, Legendary ~30-45 with extra flair).
- Every side looks finished. Nothing rude or offensive from any side (no upright pink tubes, no zig-zag "S"/lightning shapes, nothing that reads as poo, a bottom or a symbol; no crosses or 4/6/8-point stars).

**Props and scenery**: the same block-built, chunky, cubes-not-spheres style, at a sensible scale next to players.

**The final test**: build it in one row with 2-3 of the best existing models of the same kind and photograph them together from the front at the same distance. If it looks smaller, skinnier, smaller-eyed, plainer, darker or more realistic than its neighbours, or a different style in any way, redo it.

## 1. Automatic checks (each one must come back empty)
For each model (a built copy, or the placed one in the world):
1. `M.Check(model)`: every part connected to the body (nothing floating), nothing flickers, nothing round.
2. `M.FindClipping(model)`: no two different features (first word of the part name: Wing vs Crown) cut into each other where you can see it. Name the parts by feature so this works.
   - It CAN'T see two copies of the same feature cutting into each other (two crystals both called "Shard"). Whenever a recipe repeats a thing, wrap each copy in `M.asPiece(m, id, fn)` and run `M.CheckPieces(model)` (model in the workspace): it must be empty. Don't filter checker output by name to make it pass - every overlap you allow must be one you looked at.
   - `require` caches modules inside a session: after editing a recipe, require a fresh Clone of ModelKit + the recipe module (in a temp Folder in ServerStorage, destroyed after) or you test the old recipe.
   - It also can't see a head block sunk into the body (both called Body...). Check in code that a head sits FLUSH against the Body (gap 0.000) or fully inside a bigger body, never half-sunk with the body's corners showing round it.
3. Flicker: `M.FixFlicker(model)`, then `M.FindFlicker(model)` must be empty.
4. Code-built pieces and scenery that aren't recipes: run the same functions on their Model/Folder (wrap them in a Model first if needed).
   - Whole areas (thousands of parts): `require(game.ServerStorage.ArtTools.SceneryScan).Scan({roots}, {support = {ground...}})` (grid-based, ~1 s; `.summary` = flicker / floating / dupes). Scan in PLAY on the server when the game builds or dresses things at runtime.
   - Fixing a hovering/sunk placed model: settle it on the REAL surface under it (a ray down, excluding the model), never by trusting its pivot. `ModelKit.Build` sets the pivot with `M.SetBottomPivot` (world-axis box).
5. Also check in code:
   - It sits on its surface (bottom within ~0.05 studs of the ground, not sunk, not hovering, unless it floats on purpose).
   - Nothing sticks out of its container (cage, stand, stall, fence line): compare the bounding box with the inside size.
   - Neon parts use deep, saturated colours.
   - Materials suit each part; moving models use only SmoothPlastic/Neon/Glass/Metal.
   - Round parts (`Shape ~= Block`): 0.

Fix every problem in the recipe, rebuild, and run the checks again.

## 1b. Compare with reference pictures
For EVERY model: find 2-3 real photos of what it is meant to be (web search; or download Wikimedia Commons pictures with curl into the scratchpad - `commons.wikimedia.org/w/api.php?action=query&list=search&srnamespace=6&srsearch=<words>&format=json` for file names, then `commons.wikimedia.org/wiki/Special:FilePath/<file>?width=700` - and look at them with Read). **Always FULL-BODY pictures**: the whole animal/thing in view; a head close-up hides the body shape, so fetch another. List its 3-5 signature features and check each one is on the model and readable from the player camera. If a stranger couldn't tell what it is, rebuild it.

## 2. Look at it from every side (by eye)
1. `M.Turnaround({names}, folder, z0)` in `Workspace.ArtReview.<Batch>`: 4 copies at 0/90/180/270 on the ReviewFloor at x ≈ 3000 (off the map). Point the camera there.
2. `screen_capture` with `camera_position` / `look_at_position` (see `screen-capture`): front, both sides, back, AND a high camera looking down. For big scenery, also from where a player stands (eye height ~5 studs) and from a distance.
3. Reject and fix anything that:
   - floats, clips into another detail, pokes out, or flickers
   - looks lumpy, melted or random (stray bits)
   - has the wrong number of limbs, or feet hidden, missing, in the wrong place or wider than the torso
   - clips while ANIMATED: also run FindClipping on the client's animated copy at extreme poses (ears/tail at swing peak, wings up and down)
   - reads as something else (a dark brown lump on a head read as poo)
   - could read as a hate symbol, a religious symbol or something rude
4. If `generate_mesh` is ever used (only when the user asks): add "Symmetrical solid single piece, crisp clean shapes and textures, no melting, no stray or floating bits." to the prompt, name only 2-3 features, maxTriangles ~1000-1500. Anything melted or with stray bits counts as a failed attempt.

## 2b. Self-review BEFORE showing anything
The user should never be the one to spot these. After the photos, write out a short critique of EVERY photo, answering each question with what you actually see, not what the recipe intended:
1. **What is it?** Cover the name: would a stranger say the right thing, or a similar one? List the signature features and where each sits on the real thing, and check the model matches that placement.
2. **Anything sunk or poking?** Head half inside a wider body, parts hidden inside others, feet wider than the torso, things floating.
3. **Anything reading as something else?** Pale bands under the eyes (teeth/mouth), tips poking up behind the head, dark lumps, rude or symbol shapes.
4. **Side by side with the best models:** same chunkiness, eye size, colour softness and level of detail?
5. **From every side:** blank backs, odd silhouettes, legs that look wrong from the side.
If any answer is "not sure", take a closer photo from the player camera (about 6-8 studs away, a little above) and look again. Fix everything found before saying it is done.

## 3. Does it make sense where it is? (common-sense review)
Look at each new or changed thing in its real spot in the game, not just on its own:
- **Held up by something real?** Lanterns, signs and lights hang from a ceiling, beam or bracket, or stand on a post or wall. Nothing hovers unless it's meant to.
- **Where it would really go?** Indoor things under the roof. Fences on the ground. Plants in pots or soil. Things face the way people see them.
- **Fits with what's around it?** Same style, sensible scale next to players, materials matching the same kind of thing elsewhere.
- **In the way?** Doesn't block paths, pads, prompts or the camera, and doesn't hide labels.
- **Anything left behind or half-done?** Old copies, fallback code still doing the old thing, review rows in the play area, temporary test settings.
For code-built pieces, read the placement code and check the numbers come from the real thing they attach to, not a guessed height.
At the end of a session, run this review over EVERYTHING changed in the session (git diff + the Studio changes listed in the progress log).

## 4. In play
Swap it in, then playtest where it's used (every place it appears, every variant/size). Check it isn't clipping into neighbours, players can't get stuck on it, and the Output has no errors.

## 5. Finish
- Camera: `workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed` (Edit) after the captures.
- Remove the review copies, or leave them in ArtReview if the user should look.
- In the progress log, one line: what was checked and the result, e.g. "QA: Check/Clipping/Flicker clean, 5 views, in play OK".
