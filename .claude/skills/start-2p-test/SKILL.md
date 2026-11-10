---
name: start-2p-test
description: Start (or restart) a {{GAME_NAME}} 2-player Studio test (server + 2 clients) yourself with real mouse clicks, then find and drive the windows. Use whenever a test needs 2+ players, a co-op feel-test, or the user types /start-2p-test. Don't ask the user to start it.
---

# Start a 2-player Studio test

`start_stop_play` can only start SOLO tests, but Claude CAN start a multi-client test itself. Use real clicks via `scripts/studio-input.ps1` (run it with the PowerShell tool, `-ExecutionPolicy Bypass -File`). Save screenshots to the scratchpad and look at them with Read.

## Start it (the user's preferred way)
1. `-Action list` to see every Studio window (process id and title). Check the main window's title is the place you are working on: the user may have opened a different place since you last looked. Bring it forward with `-Action keys -Text '{F15}' -ProcessId <id>` ({F15} is a key that does nothing), then `-Action shot` and look at its top-left toolbar to confirm the positions below. Never click from remembered positions without a fresh screenshot; a click in the wrong window or place can start a playtest there (they are approximate and depend on the screen size; when you have proven them on this PC, write them in here with the date).
2. Click the mode dropdown (normally says "Test", ≈ 50,61), take a screenshot, then click "Server & Clients" (older Studio versions call it "Server").
3. `-Action type -X 253 -Y 61 -Text 2`: the small box with the player icon, to the right of the red stop button. Type the number of clients.
4. Click the blue play button (≈ 113,61).
5. Check: `list_roblox_studios` shows one entry per window (name is null). Server-side `#game.Players:GetPlayers()` should be 2.

Fallback that also worked: menu bar Test > Start Test Session > "Server and Clients" (F7) opens a Server window with 0 players. Then click Test > Add Clients in the Server window once per client.

To end the session: bring the main Studio window (the one with the place's name) to the front, open the **Test** menu and click **End Session**. The red button in the toolbar and Shift+F5 do not end a multi-client session. Check with `list_roblox_studios` that only the main window is left.

To pick up code changes, end the session and start a new one the same way. Every restart gives NEW window ids.

Proven on 2026-11-10 (2560x1440, Studio maximised): mode dropdown (49,61), "Server & Clients" (70,160), client count box (254,62), play (113,62), Test menu (184,33), End Session (222,386). The server and both clients were up about 25 seconds after pressing play.

## Which window is which
- Server window: `execute_luau` with datamodel Client fails ("Target is not reachable").
- On the others, `game.Players.LocalPlayer.Name` tells Player1 from Player2.
- Both client windows are titled "Place1 - Roblox Studio", so `-Window` can't tell them apart. Bring a window forward by its process id instead: `-Action list`, then `-Action keys -Text '{F15}' -ProcessId <id>`.
- To match a process id to a player: in each client, add a temporary ScreenGui with a big TextLabel showing `LocalPlayer.Name` (white text). Bring each window forward by process id and take a screenshot: the label shows whose window it is. The labels vanish when the session ends. Proven on 2026-11-10: each client came to the front on request, three switches in a row.
- A client window may open smaller than the screen. Take a screenshot after bringing it forward before clicking in it.
- `-Action keys` with {F15} brings a window forward but the game itself doesn't see that key, so it can't be used to check which player received input.
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
