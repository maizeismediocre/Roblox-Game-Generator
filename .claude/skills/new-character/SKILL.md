---
name: new-character
description: Create a new {{GAME_NAME}} character type end to end (creature, pet, enemy, NPC or similar) - name check, reference pictures, part-built model recipe, animation, model QA, install into Assets, config, its sound, UI picture and in-game tests. Use EVERY time a new character/creature type is added or an existing one's model is rebuilt, or when the user types /new-character.
---

# New character / creature (run for EVERY new type)

It is not finished until every step below is done. Keep progress lines short.

## GAME-SPECIFIC
<!-- GENERATE (SETUP step 6c): fill in for this game, e.g.
- What the game calls them: "critters" (species), rarities Common / Uncommon / Rare / Legendary.
- Recipes: ServerStorage/ArtTools/CharacterRecipes (R.<Id> = function(m, B) ... end; M.Moving.<Id> = true).
- Installed models: ReplicatedStorage/Assets/Characters/<Id>.
- Config: ReplicatedStorage/Shared/Config/<Name> fields (Id, DisplayName, Rarity, Value, Area, Rotation, Color, Description ...) and the spawn tables.
- Size: about 1.7-2.5 studs tall, Body about 1.3-1.7 wide; part counts per rarity.
- Where players see them: in the world, carried, on display, in the collection book (picture via model-photos), in the shop ...
If the game has no character/creature types at all, SETUP deletes this skill instead. -->

## 1. Name
- Web-search every new name (`"<Name>" game`, `"<Name>" creature`). Reject names used by other games/brands/cards and anything close to a famous character.
- **No internet slang:** split the name into its parts and reject any part that is internet/urban slang, even a mild one ("bop", "shade", "sus", "rizz", "simp"...).
- Id = CamelCase, never changed once saved data can hold it. Renames change only `DisplayName`.

## 1b. Look at reference pictures FIRST
- Before writing any recipe (new or rebuild), look up real pictures of the animal/thing it is based on and LOOK at them (`model-qa` 1b: Wikimedia Commons with curl if no browser). **Always FULL-BODY pictures** (nose to tail, legs in view). Also look at 1-2 good blocky/voxel versions of it for ideas.
- Write down its 3-5 signature features (head shape, ears, colours, patterns, how it stands) and make sure every one is in the model, big enough to read from the player camera. "A box with a face + a hat" is too simple.
- After building, put a reference picture and the model side by side: if a stranger couldn't tell what it is, redo it.

## 2. Model = BUILT FROM PARTS (never generate_mesh unless the user asks)
- A recipe in the recipe module named above, using `M.part` and `M.face` from ModelKit (see `studio_tools/ModelKit.luau` header). Add `M.Moving.<Id> = true` so patterned materials are removed.
- Front = -Z, bottom at y = 0. A part named "Body" = the biggest part. Look at a same-rarity one for size.
- Name parts by feature (first word = feature: `Wing`, `WingTip`) so `FindClipping` works; pieces of one body (segments, neck into head) share the first word on purpose.
- Neon only in deep, saturated colours. No lightning-bolt / zig-zag "S" shapes, nothing that reads as rude or as a symbol, no dark brown lumps on heads, no upright pink tubes (lay worm-like shapes flat).
- Materials: only Metal (gold, iron) or Glass (crystal, ice) besides SmoothPlastic/Neon.
- `require` caches modules: test edits on a fresh copy (clone ModelKit + the recipe module into a temp Folder in ServerStorage, require the clone, destroy the folder).

## 3. Animation (every one moves)
- An entry in the animation config (from Art Phase C, e.g. `Config/Animation`) with at least one moving group: tag parts in the recipe with `anim = {group, hinge, axis, phase}` and set how they move (swing, bob, pulse, spin...). Parts that must move together (a face on a nodding head) all need the same tag - never animate the part an untagged face sits on.
- **Flyers hover AND flap:** anything with wings, or that floats by nature, hovers with a gentle bob; wings are tagged `flap = {side = ±1, hinge = <wing root>}`. A model with wings that only walks is a bug.
- **Move like the real animal:** look up how it moves (bees buzz fast with small wing arcs; birds flap slower and bigger; legged animals WALK with legs stepping in turn, not hop - only real hoppers like rabbits and frogs hop).
- **Every one blinks:** the animator blinks parts named exactly "Eye" (taller than wide; "Shine" parts hide during the blink). Use `M.face` or name the pupils "Eye".
- **Fits its containers:** if it is carried, caged, displayed or held, check it fits inside at every pose (fold wings in if needed), measured on the client's animated copy.
- Photosensitivity: glows/flickers 2 a second or slower, fades to white at strength 0.5 or less.

## 3b. Same quality as the best existing ones
Before installing, compare with 2-3 of the best existing ones of the SAME rarity (Turnaround them next to each other and photograph the row):
- Detail: a similar part count for its rarity - real shaping (segments, steps, tapered wings), not one box with a face.
- A clear signature feature that tells you what it is from any side, in a colour that CONTRASTS with the body.
- Chunky proportions: one big body (or a big head block FLUSH against the body's front), big eyes, short stubby legs tucked under the body (never wider than the torso), the right number of limbs.
- A face with a mouth (or a snout/beak that is the mouth); furry animals also get a nose.
- Every side finished (tail, markings or a pattern on the back).

## 4. Model QA
Run the `model-qa` skill (Check, FindClipping, FindFlicker all empty; Turnaround photos from every side and above; self-review; common-sense review). Fix and rebuild until clean.

## 5. Install
`local m = M.Build("<Id>"); m.Name = "<Id>"; m.Parent = <the Assets folder named above>` (replace any old one), so the game uses it everywhere.

## 6. Config
- Add it to the config named above with values matched to same-area, same-rarity ones, and to the spawn table(s) with a weight like its peers.
- **Weekly rotation:** a new rotating one MUST get `RotationFrom = <current week + 2>` (or `From`), so adding it doesn't reshuffle the running week or past weeks. Prove it: the current week's rotation is the same before and after.
- Run the game's DevTools test suites for rotation/config (if they exist) - all PASS.

## 6b. Its sound
- If the game gives characters voices/sounds: every type gets its OWN sound that FITS it (a frog croaks, an owl hoots, a bee buzzes), never another slot's sound. A real animal makes that real animal's noise (or the closest real animal the library has), never a toy/human/magic sound. Follow `add-asset` (allowed creators, record creator + source), measure its loudness and set its Volume like the others.

## 7. Picture + in-game tests
- Its UI picture (book, shop, inventory...): take it with `model-photos`, or check the live portrait shows it uncropped (and as a dark silhouette when undiscovered, if the game has that).
- Spawn/give it with DevTools in a playtest (execute_luau modules are separate copies - use the DevTools bindables to act on the live game).
- Check animation in code on the CLIENT over ~7 s: parts move relative to Body, "Eye" Size.Y drops (blink), hover height for floaters, wing angle range for flyers.
- Then the full core loop with it, every variant look, and the Output clean.

## 8. Record
Progress log line: name, rarity, area, value, recipe module, animation groups, sound, QA result.
