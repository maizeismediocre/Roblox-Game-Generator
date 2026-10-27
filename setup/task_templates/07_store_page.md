# 07 — Store page screenshots, icon and description

STATUS: NOT STARTED

- [ ] Store Step 1 — Final description
<!-- GENERATE: one "- [ ] Store Step N — Scene: <name>" line per thumbnail scene below (5-6 scenes), then the fixed steps: "Scene: game icon", "Game pass and developer product icons", "Thumbnail and icon finishing guide", "Clean up", numbered on from the scenes. Also replace "<N>", "<N+1>"... in the step headings below with the real numbers. -->

---

You are working in my open Roblox Studio session for "{{GAME_NAME}}" through the Studio MCP tools. The game is finished and I need material for its Roblox store page: a description, thumbnail screenshots, a game icon, and icons for every game pass and developer product. All images come from posed in-game renders of the real game, because they are free, carry no licensing risk, and honestly show what players will get. Inspect the existing game first and use only real game assets. Do not change any gameplay code.

For each scene step: build or arrange the scene, position the camera for a strong 16:9 shot, hide all UI except where noted, and make the lighting look its best. Take the picture yourself where you can (the `screen-capture` skill; a full-screen grab with `.claude/skills/start-2p-test/scripts/studio-input.ps1 -Action shot`); only if that can't give a clean full-size image, tell me exactly how to take it. Put all staging objects in a Workspace folder called "ThumbnailStaging", and keep a list in the progress log of anything you change (lighting, camera, UI visibility) so it can be restored.

## PROGRESS LOG AND SAVING
- Add or update a "STORE PAGE" section in ServerStorage/DevNotes/Progress (never remove or change other sections) with which steps are done and everything changed for staging (`log-phase`).
- At the end of each step, save with `save-game`, then commit + push.

## WHERE THE IMAGES GO
All store page files live in the `store_page/` folder, named step number + scene:
```
store_page/
  description.txt  the description + title options
  thumbnails/      02_<scene>.png ... (16:9, 1920x1080)
  icon/            <step>_icon_A_<subject>.png, _B_, _C_   (512x512)
  passes/          <step>_pass_<name>.png, <step>_product_<name>.png  (512x512, one per real pass/product)
```
- Each folder holds ONLY the finished, edited images.
- Each raw capture is saved into its folder with "_raw" added (e.g. thumbnails/02_coop_raw.png). Claude edits it with `py tools/store_edit.py` (crop, resize, text overlay on thumbnails only, font: Fredoka in tools/fonts) into the clean name, checks the result opens at the right size and looks right (with `--preview` phone/tiny/circle copies), then DELETES the _raw file.
- Retakes: add _v2, _v3 until one is picked; then delete the others and rename the chosen one to the clean name.
- <name> = the pass/product's internal Id from the monetisation config, lower_snake_case.

## STORE STEP 1 — Final description
Read the whole game (and the progress log) and finish `store_page/description.txt` (the `player-text` skill): under 1,000 characters, short sections, only features that exist and work, the automatic weekly rotation, no numbers. Keep the credits line (CC BY) at the end and the TITLE OPTIONS block below it (3 short titles under 50 characters). Approval checkpoint: pick the best title yourself and record it. (No Studio changes in this step.)

<!-- GENERATE: 5-6 scene steps for THIS game, each "## STORE STEP N — Scene: <name>" with 1-3 sentences describing a dynamic, honest shot of a real feature: e.g. friends doing the co-op feature together (funny moment), the best-looking base/shop/home fully upgraded, the rarest collectible close up with its glow, a line-up of variants, a wide shot of all areas/progression, a live event. -->

## STORE STEP <N> — Scene: game icon
Stage a scene for the game icon. Roblox icons are square (512x512) and usually seen very small, so:
- The cutest, most recognisable subject of the game, close up, doing something happy, with gentle sparkles.
- A simple, uncluttered background (a plain backdrop part or a soft sky), with a soft glow or rim light behind the subject.
- One clear focal point with bold, readable shapes. No text, no UI. Centred with even space so it crops to a square (and a circle) without cutting anything off.
Make 2-3 alternative compositions (A/B/C) so I can test which icon gets more clicks.

## STORE STEP <N+1> — Game pass and developer product icons
Read the monetisation config for the actual list of passes and products (don't assume it). For each one, stage a simple square icon scene using real game assets that honestly shows what the purchase gives:
- They look like one matching family: same lighting, same camera distance, a consistent background colour per type (e.g. gold for VIP, green for boosts, blue for gameplay passes, yellow for currency).
- One clear centred subject with generous space round it (shown small, may be cropped to a circle), bold shapes, no small text (a big "x2" is OK only if it stays readable tiny).
I upload each finished icon in the Creator Dashboard. Don't ask me for the image ids: read each one's IconImageAssetId yourself with MarketplaceService:GetProductInfo (Enum.InfoType.GamePass / Product), then put them in the monetisation config and use them in the in-game shop UI.

## STORE STEP <N+2> — Thumbnail and icon finishing guide
No Studio changes. For each thumbnail, a short bold text overlay (2–4 words, readable on a phone) and where it goes; do the editing with `tools/store_edit.py` and check every result by eye. Then give me: the sizes (thumbnails 16:9 1920x1080; icons 512x512), how to upload the icon, thumbnails and pass/product icons in the Creator Dashboard, how to run icon/thumbnail tests there, and a reminder that they must honestly represent the game.

## STORE STEP <N+3> — Clean up
Delete the ThumbnailStaging folder and restore everything listed in the progress log (lighting, camera, UI visibility). Playtest to confirm the game is back to normal and there are no errors in Output.
