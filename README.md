# Roblox game template (for Claude Code + Roblox Studio)

A starter kit for making a Roblox game with Claude Code doing the building through the Roblox Studio MCP. Claude asks what genre you want (or rolls a random one you can reroll), invents an original game idea, writes a full step-by-step build plan for it, and then builds and tests the game in Studio task by task.

You don't need to know how to code. You do need a Windows PC, a Roblox account and a Claude account, and about 30 minutes for the one-time setup below.

## Everything you need (with links)
| What | Needed? | Link |
|------|---------|------|
| Roblox account | Yes | https://www.roblox.com/account/signupredir |
| Roblox Studio | Yes | https://create.roblox.com/docs/studio/setup |
| Claude plan that includes Claude Code | Yes | https://claude.com/pricing |
| Claude Code | Yes | https://code.claude.com/docs/en/setup |
| Git for Windows | Yes | https://git-scm.com/downloads/win |
| Studio's MCP server (a setting in Studio, nothing to download) | Yes | https://create.roblox.com/docs/studio/mcp |
| winget (Windows' app installer, used by the commands below; already on Windows 10/11) | Optional | https://learn.microsoft.com/en-us/windows/package-manager/winget/ |
| Python (for the picture tools) | Optional | https://www.python.org/downloads/windows/ |
| Pillow and NumPy (Python add-ons for the picture tools) | Optional | https://pypi.org/project/pillow/ and https://pypi.org/project/numpy/ |
| GitHub account (online backup) | Optional | https://github.com/signup |
| GitHub CLI (lets Claude make the private backup repo) | Optional | https://cli.github.com/ |

---

## Part 1 — One-time setup (do this once per PC)

### 1. Roblox Studio
1. No Roblox account yet? Make one at https://www.roblox.com/account/signupredir.
2. Go to https://create.roblox.com/docs/studio/setup, follow "Install Studio", and sign in with your Roblox account.
3. Leave it installed; you'll use it for every game.

### 2. Claude Code
Claude Code is the version of Claude that can work with files and programs on your PC. It needs a Claude plan that includes Claude Code (see https://claude.com/pricing) or an Anthropic API account. Full install guide: https://code.claude.com/docs/en/setup
1. Press **Start**, type **PowerShell**, and open **Windows PowerShell**.
2. Paste this and press Enter:
   ```
   irm https://claude.ai/install.ps1 | iex
   ```
3. Close PowerShell, open a new one, and type `claude --version`. If it shows a version number, it worked.
4. Type `claude` once and follow the steps to sign in. Then type `/exit` to close it.
   (If the install command doesn't work, follow the current instructions at https://code.claude.com/docs/en/setup.)

### 3. Git (saves the history of your game)
Download page: https://git-scm.com/downloads/win (install with the default options). Or, quicker, in PowerShell paste this and press Enter:
```
winget install --id Git.Git -e
```
Then close and reopen PowerShell and check `git --version` shows a version.
(winget is Windows' built-in app installer: https://learn.microsoft.com/en-us/windows/package-manager/winget/. If the `winget` command isn't found, use the download page instead.)

### 4. Turn on Studio's MCP server (lets Claude control Studio)
Roblox's guide: https://create.roblox.com/docs/studio/mcp
1. Open Roblox Studio and open any place (e.g. **File > New > Baseplate**).
2. Open the **Assistant** window.
3. Click the **...** menu in the Assistant window > **Manage MCP Servers**.
4. Turn on **Enable Studio as MCP server**, click **Quick connect** and follow the instuctions for **Claude Code CLI**.
5. Check it worked: in PowerShell, `Test-Path "$env:LOCALAPPDATA\Roblox\mcp.bat"` should say **True**.
Roblox sometimes moves menus. If yours look different, follow the current steps in Roblox's guide (link above). You only do this once: the template's `.mcp.json` file then connects Claude to Studio by itself every time.

### 5. Optional extras
- **Python + Pillow + NumPy** (for making icons and store-page images later on; Claude asks before using them). Python: https://www.python.org/downloads/windows/ (tick "Add python.exe to PATH" when installing), Pillow: https://pypi.org/project/pillow/, NumPy: https://pypi.org/project/numpy/. Or in PowerShell:
  ```
  winget install --id Python.Python.3.12 -e
  py -m pip install pillow numpy
  ```
- **GitHub backup** (keeps a copy of your game online, private). Make a free account at https://github.com/signup, install the GitHub CLI from https://cli.github.com/, or in PowerShell:
  ```
  winget install --id GitHub.cli -e
  gh auth login
  ```
  Then pick GitHub.com, HTTPS, and "Login with a web browser". If this is set up, Claude offers to make a private GitHub repo for each new game.

---

## Part 2 — Start a new game (every time you want a new game)

1. Open **Roblox Studio** with a new place: **File > New > Baseplate**. Leave it open.
2. Open this template folder in a terminal: in File Explorer, open the **Roblox template** folder, click the address bar, type `powershell` and press Enter.
3. Type `claude` and press Enter. (The first time, Claude may ask you to trust the folder and to allow the Roblox_Studio MCP server: say yes.)
4. Type **read SETUP.md** and press Enter.
5. Answer Claude's questions:
   - **Genre:** pick **Random** (reroll as often as you like), choose from the list, or type your own idea.
   - **Game idea:** Claude shows a short pitch card. Say yes, ask for a new idea, change the genre, or type what you'd like changed.
   - **Folder:** where to make the game (e.g. Documents\Roblox Games\YourGame). This template stays untouched, so you can reuse it for the next game.
   - **GitHub:** only asked if you did the GitHub extra above.
   - **Shortcuts:** only in the terminal (Claude CLI). Two desktop shortcuts:
     - **<Game> - Claude**: opens Claude in the game folder.
     - **<Game> - Claude (auto)**: the same, and types "read instructions.md and continue" for you.
     Both start a Remote Control session named after the game, so you can follow along from the Claude app on your phone.
6. When setup says it's done, close that terminal window.
7. Double-click **<Game> - Claude (auto)** on your desktop (or, without shortcuts: open the game folder in Claude and type `read instructions.md and continue`). Claude starts **Build Phase 1**.

### The first session
- Claude asks you to help with the first **Save to Roblox** (it creates the game on your Roblox account): check the owner and click **Create**. It then asks you to turn on **Game Settings > Security > Enable Studio Access to API Services** (needed for saving player data in tests).
- After that Claude works on its own: it builds, tests, saves and moves on. It tells you which **effort level** to use for each task (type `/effort` to change it).

### Every session after that
1. Open Roblox Studio with your game (**File > Open from Roblox**, or the recent list).
2. Double-click **<Game> - Claude (auto)**.
3. When Claude stops and says "Good time to /clear now", type `/clear` and then `read instructions.md and continue` (or close the window and use the shortcut again).

### Using the Claude desktop app instead of the terminal
The Code part of the Claude desktop app works too: open the template folder as the project and type `read SETUP.md`; later open the game folder and type `read instructions.md and continue`. No desktop shortcuts are made there. If the Studio tools don't show up in the app, connect it from Studio once: **Assistant > ... > Manage MCP Servers > Quick connect > Claude Desktop** (see https://create.roblox.com/docs/studio/mcp). The normal chat part of the desktop app can't do this (it can't run the scripts, saves or git).

---

## If something goes wrong
| Problem | Fix |
|---------|-----|
| `claude` is "not recognized" | Close and reopen PowerShell after installing. If it still fails, reinstall Claude Code (Part 1, step 2). |
| Claude says the Studio tools aren't connected | Studio must be open with a place, and its MCP server on (Part 1, step 4). Then restart Claude (close the window, use the shortcut). In Claude, `/mcp` shows the server's status. |
| `mcp.bat` doesn't exist | Studio's MCP server isn't turned on yet (Part 1, step 4). |
| Player data doesn't save in tests | The game must be saved to Roblox once, and **Enable Studio Access to API Services** must be on (Game Settings > Security). |
| Claude stopped halfway | Start it again with the "(auto)" shortcut. It reads the last "HANDOFF" note in git and carries on. |
| Setup was interrupted | Delete the half-made game folder and run `read SETUP.md` in the template again. |
| You want the shortcuts again | `powershell -ExecutionPolicy Bypass -File tools\make-shortcuts.ps1 -ProjectDir "<game folder>" -Name "<Game Name>"` (in the game folder). |

---

## What's inside
| Path | What it is |
|------|------------|
| `SETUP.md` | The first-run setup Claude follows (deleted from the game copy when done) |
| `setup/` | Genre list, the task-file and instructions templates, the placeholder filler |
| `CLAUDE.md` | The rules Claude follows in every session |
| `.mcp.json` | Connects Claude to Roblox Studio's MCP server automatically |
| `.claude/settings.json` | Auto-approves the Studio MCP server and its tools; reminds Claude where it was after `/clear` |
| `.claude/skills/` | Step-by-step skills: save-game, model-qa, new-character, seasonal-event, model-photos, log-phase, handoff, health-check, start-2p-test, screen-capture, player-text, add-asset |
| `studio_tools/` | Studio tool modules (ModelKit: blocky model builder + quality checkers; SceneryScan) installed into the game in Build Phase 1 |
| `tools/` | Picture tools (model cut-outs, store-page image editing, a font) and `make-shortcuts.ps1` |
| `store_page/` | Where the store description, thumbnails and icons go |
| `TEMPLATE_MASTER.txt` | Marks this folder as the master copy (setup copies instead of changing it) |

## How the work is organised
- Numbered task files (`01_build.md` ... `07_store_page.md`), each a checklist: build, economy, art, polish, live-ops, quality QA, store page. Claude does the first unticked item, tests it itself, logs it in the game (ServerStorage/DevNotes), saves the place (Save to Roblox + a backup `.rbxl` file), commits, and moves on. It stops at the end of each task file or when the topic changes, so you can `/clear` and continue fresh.
- Unfinished work is handed over in a "HANDOFF" note in the git commit, so the next session picks it up.
- Claude never publishes the game. When it's ready, you publish it yourself (File > Publish to Roblox) and fill in the store page with the description and pictures from `store_page/`.
