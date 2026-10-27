---
name: start-2p-test
description: Start (or restart) a {{GAME_NAME}} 2-player Studio test (server + 2 clients) yourself with real mouse clicks, then find and drive the windows. Use whenever a test needs 2+ players, a co-op feel-test, or the user types /start-2p-test. Don't ask the user to start it.
---

# Start a 2-player Studio test

`start_stop_play` can only start SOLO tests, but Claude CAN start a multi-client test itself. Use real clicks via `scripts/studio-input.ps1` (run it with the PowerShell tool, `-ExecutionPolicy Bypass -File`). Save screenshots to the scratchpad and look at them with Read.

## Start it (the user's preferred way)
1. `-Action shot` and look at the main Studio window's top-left toolbar to confirm the positions below (they are approximate and depend on the screen size; when you have proven them on this PC, write them in here with the date).
2. Click the mode dropdown (normally says "Test", ≈ 50,61), take a screenshot, then click "Server".
3. `-Action type -X 253 -Y 61 -Text 2`: the small box with the player icon, to the right of the red stop button. Type the number of clients.
4. Click the blue play button (≈ 113,61).
5. Check: `list_roblox_studios` shows one entry per window (name is null). Server-side `#game.Players:GetPlayers()` should be 2.

Fallback that also worked: menu bar Test > Start Test Session > "Server and Clients" (F7) opens a Server window with 0 players. Then click Test > Add Clients in the Server window once per client.

To pick up code changes, end the session and start a new one the same way. Every restart gives NEW window ids.

## Which window is which
- Server window: `execute_luau` with datamodel Client fails ("Target is not reachable").
- On the others, `game.Players.LocalPlayer.Name` tells Player1 from Player2.
- Real input (`user_keyboard_input`: hold E for a ProximityPrompt, W/A/D to walk) works per window.
- A solo `start_stop_play` in the main Studio window still works while the multi-client test is open.

## Driving a feel-test with the user
- The user can only control one window ("it disconnects"). The user plays one player and Claude drives the other.
- Line the players up first with a server-side `Character:PivotTo`.
- From a player window's client, `prompt:InputHoldBegin()` / `InputHoldEnd()` triggers a ProximityPrompt more reliably than the E key once characters drift.
- Run a client driver loop on Claude's player (e.g. walk a route only while the user's player is helping), or a server-side `Humanoid:MoveTo` route that starts when the user does something (e.g. presses E).
- Log results with a server logger that writes to a workspace attribute.
- Studio test players can't receive each other's chat.

## Telling the user to run DevTools commands
Say they must type them in the window titled "... - Server" and include the player name, e.g. `GoTo:Invoke("<Area>", "Player1")`. In a player window they fail with "DevTools is not a valid member of ServerStorage".
