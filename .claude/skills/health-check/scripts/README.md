# Health-check smoke-test scripts

Written by Claude in the last Build Phase ("Polish + launch checklist") and kept up to date when the core loop changes.

- One file = one `execute_luau` call. Name them in run order with where they run:
  `a_<step>.server.luau` (Server datamodel) or `b_<step>.client.luau` (Client datamodel).
- Each returns ONE string starting with `PASS` or `FAIL` plus a short detail, e.g. `PASS w11` or `FAIL could not reach target`.
- Values one script needs from another are `{{PLACEHOLDERS}}` filled in before sending (e.g. `{{ID}}`).
- Act on the live game only through remotes (client) and ServerStorage/DevTools bindables (server), never by requiring services.
- The last script is a snapshot (`h_snapshot.client.luau`-style) returning the saved values to compare after a rejoin.
- Add a row per script to the table in `../SKILL.md`.

Example (client, walk to a target that may move):
```lua
local hum = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
local root = hum.Parent:WaitForChild("HumanoidRootPart")
local deadline = os.clock() + 25
while (root.Position - target:GetPivot().Position).Magnitude > 7 do
	if os.clock() > deadline then return "FAIL could not reach target" end
	hum:MoveTo(target:GetPivot().Position)
	task.wait(0.25)
end
return "PASS reached"
```
