---
name: seasonal-event
description: Build (or rebuild) one {{GAME_NAME}} seasonal/holiday event end to end - its event content, the themed area or decorations, lighting, music and the play tests. Use whenever the next holiday in the live-ops Seasonal events system is built, when an existing holiday is rethemed, or when the user types /seasonal-event.
---

# Seasonal / holiday event (one holiday at a time)

Everything is automatic once built: the holiday calendar config works out the dates, the event scheduler turns the event on and off, and the theme/decor switch with it. A holiday is DONE when every step below is done. Keep progress lines short.

## GAME-SPECIFIC
<!-- GENERATE (SETUP step 6c): fill in for this game, e.g.
- Where things live: holiday calendar config, holiday content config (e.g. 4 holiday creatures per holiday, one per rarity, with Rotation "holiday" and Holiday = "<Id>"), recipe module for holiday models and props, the themed area / hub decor build functions and where built themes are stored, music + ambience slots per holiday, lighting/sky looks per holiday.
- What each holiday must have (e.g. EXACTLY 4 holiday creatures, its OWN music track, a themed area that looks clearly different from every other holiday's).
- The order holidays are built in.
If the game has no seasonal events, SETUP deletes this skill instead. -->

## 1. Plan (approval checkpoint: decide yourself, log it)
- The event content for this holiday, each piece with a clear holiday signature in a colour that contrasts with its base. Friendly and NON-RELIGIOUS (no crosses, angels, halos, stars other than 5-pointed, crescents); no zig-zag / lightning shapes; nothing that could read as rude or a symbol.
- Web-search every name (`"<Name>" game`), reject anything used by another game/brand or that is slang.
- A theme that looks clearly different from the other holidays (colours, props, centrepiece), not just a recolour.

## 2. Content
Run `new-character` for each new character/creature and `model-qa` for each prop. Then a same-rarity line-up with the earlier holidays' content in `Workspace.ArtReview.<Holiday>` and a photo. Always build from a FRESH copy of the modules (require caches).

## 3. Theme, decorations, light, music
- **Its OWN music track** (and ambience if the game uses it), not shared with another holiday, fitting the holiday (`add-asset`; measure its loudness like the others).
- Theme props as recipes through `model-qa`. Keep paths, pads, prompts, shop fronts and the play space open. Particles (snow, confetti, petals) slow and soft - no flashing.
- Hub/lobby decorations go BESIDE things (lamp posts, planters, building corners), never on paths or prompts.
- Overlap check (part boxes, 0.05 tolerance) of the theme against itself and the map, and the decor against the hub: must be 0. Then `SceneryScan` (nothing floating/flickering).
- Lighting + sky per holiday: night looks keep daytime `ClockTime` (~14) with `CelestialBodiesShown = false` and low `Brightness` (Roblox darkens any skybox to black at night). Stars = soft round dots (never pointed sparkles); moons round (never crescents). At most ONE sun or moon per sky: a painted one -> `CelestialBodiesShown = false`; with Roblox's own, check only one is above the horizon at the look's ClockTime. Photo-check it (preload a new Sky first: uploads show late).
- Photos in Edit: clone the theme/decor into Workspace as `Tmp...Preview`, capture (path view, a close-up of the centrepiece, a wide view), then DELETE the previews and set the camera Fixed.

## 4. Play tests
1. Start play; force the holiday on with the DevTools/admin command. Check the area/decor/lighting/music switched over, on the server and a client.
2. Spawn/give each new piece of content and check it in the world, in every container and UI it appears in, with every variant look; client animation check over ~7 s (blink, hover).
3. Run every DevTools test suite: all PASS. (A holiday test that forces holidays off may need the holiday forced on again afterwards.)
4. Stop + start play with no holiday: content the player got during the holiday is still owned and usable; the area/decor is gone; the Output has only expected warnings.
5. Faked date tests (via the admin tools): the holiday turns on and off by itself without a restart, and two servers agree.

## 5. Finish
- Camera Fixed; no `Tmp...` previews or review rows left behind.
- `log-phase`: a "DONE - <HOLIDAY>" block, update what's NOT DONE, add NOT YET TESTED items.
- `save-game`, commit + push with any open HANDOFF repeated (finished parts "[done]"). Each holiday gets its own save + commit.
