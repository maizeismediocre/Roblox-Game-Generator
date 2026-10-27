# Roblox game template (for Claude Code + Roblox Studio)

A starter kit for making a Roblox game with Claude Code doing the building through the Roblox Studio MCP. Claude asks what genre you want (or rolls a random one you can reroll), invents an original game idea, writes a full step-by-step build plan for it, and then builds and tests the game in Studio task by task.

You don't need to know how to code. You do need a Windows PC, a Roblox account and a paid Claude plan, and about 30 minutes for the one-time setup below. Do the steps **in order**: some of them need the one before.

## Everything you need (with links)
| What | Needed? | Link |
|------|---------|------|
| Roblox account | Yes | https://www.roblox.com/account/signupredir |
| Roblox Studio | Yes | https://create.roblox.com/docs/studio/setup |
| Claude Pro or Max plan (the free plan doesn't include Claude Code) | Yes | https://claude.com/pricing |
| Git for Windows | Yes | https://git-scm.com/downloads/win |
| Claude Code | Yes | https://code.claude.com/docs/en/setup |
| This template | Yes | https://github.com/maizeismediocre/Roblox-Game-Generator |
| Studio's MCP server (a setting in Studio, nothing to download) | Yes | https://create.roblox.com/docs/studio/mcp |
| winget (Windows' app installer, used by the commands below; already on Windows 10/11) | Optional | https://learn.microsoft.com/en-us/windows/package-manager/winget/ |
| Python (for the picture tools) | Optional | https://www.python.org/downloads/windows/ |
| Pillow and NumPy (Python add-ons for the picture tools) | Optional | https://pypi.org/project/pillow/ and https://pypi.org/project/numpy/ |
| GitHub account (online backup) | Optional (recommended for an online backup) | https://github.com/signup |
| GitHub CLI (lets Claude make the private backup repo) | Optional | https://cli.github.com/ |

---

## Part 1 — One-time setup (do this once per PC)

### How to use PowerShell (you'll need it a few times)
PowerShell is a window where you type commands instead of clicking. You only need it for a few copy-and-paste steps.
- **Open it:** press the **Start** button (or the Windows key), type **PowerShell**, and click **Windows PowerShell**. A dark window opens with a line like `PS C:\Users\YourName>`. That line is the *prompt*: whatever you type appears after it.
- **Paste a command:** copy the command from this page, click inside the PowerShell window, then press **Ctrl+V** (or right-click) and press **Enter**.
- **Open it in a specific folder:** in File Explorer, open the folder, click the address bar at the top (where the folder path is), type `powershell` and press **Enter**. Or, on Windows 11, right-click an empty space in the folder and choose **Open in Terminal**.
- **"Close and reopen PowerShell"** means close the window with the **X** and open a new one as above. Newly installed programs only work in windows opened *after* the install.

### 1. Roblox Studio
1. No Roblox account yet? Make one at https://www.roblox.com/account/signupredir.
2. Go to https://create.roblox.com/docs/studio/setup, follow "Install Studio", and sign in with your Roblox account.
3. Leave it installed; you'll use it for every game.

### 2. Git (saves the history of your game; install it before Claude Code)
Claude Code on Windows works best with Git already installed, so do this step first.
1. Go to https://git-scm.com/downloads/win, download the installer and run it. Click **Next** on every page (the default options are fine), then **Install**, then **Finish**.
   Or, quicker: open PowerShell, paste this and press Enter (say **Yes** if Windows asks for permission):
   ```
   winget install --id Git.Git -e
   ```
   (winget is Windows' built-in app installer: https://learn.microsoft.com/en-us/windows/package-manager/winget/. If PowerShell says `winget` is not recognised, use the download page instead.)
2. Close and reopen PowerShell, type `git --version` and press Enter. If it shows something like `git version 2.x`, it worked.

### 3. Claude Code
Claude Code is the version of Claude that can work with files and programs on your PC. It needs a Claude **Pro or Max** plan (https://claude.com/pricing; the free plan can't use it). Full install guide: https://code.claude.com/docs/en/setup
1. Open PowerShell.
2. Paste this and press Enter. It shows nothing while it downloads, so wait until the prompt (`PS C:\...>`) comes back:
   ```
   irm https://claude.ai/install.ps1 | iex
   ```
3. Close and reopen PowerShell. Type `claude --version` and press Enter. If it shows a version number, it worked.
4. **Start Claude and sign in:** type `claude` and press Enter. Claude opens *inside* the PowerShell window. The first time, it walks you through a few screens. Use the **arrow keys** to choose and **Enter** to confirm:
   - Pick any colour theme.
   - Choose to log in with your **Claude account (subscription)**. Your web browser opens: sign in to Claude and click **Authorize**, then go back to the PowerShell window and press **Enter** to carry on.
   - If it asks whether you trust the files in this folder, choose **Yes**.
5. When you see a box where you can type a message, Claude is ready. **Leave this window open** for the next step.
   (If the install command doesn't work, follow the current instructions at https://code.claude.com/docs/en/setup.)

Useful to know: you **start** Claude by typing `claude` in PowerShell, and **close** it by typing `/exit` (or by closing the window). Commands that start with `/` are for Claude itself; everything else you type is a message to Claude.

### 4. Turn on Studio's MCP server (lets Claude control Studio)
"MCP" is the link that lets Claude click, build and test inside Roblox Studio. Roblox's guide: https://create.roblox.com/docs/studio/mcp
1. **Make sure Claude Code is open** in a PowerShell window (see step 3 above: type `claude` and press Enter if it isn't). Studio only offers to connect to Claude Code when it's installed and running.
2. Open Roblox Studio and open any place (e.g. **File > New > Baseplate**, or click **Baseplate** on Studio's start page).
3. Open the **Assistant** window: click the **Assistant** button in Studio's toolbar (near the top right), or find **Assistant** in the **Window** / **View** menu.
4. In the Assistant window, click the **...** (three dots) menu > **Manage MCP Servers**.
5. Turn on **Enable Studio as MCP server**.
6. Open the **Quick connect** dropdown and turn on **Claude Code**. If Claude Code isn't in the list, check Claude is open (step 1), then close and reopen Roblox Studio and try again.
7. Go back to the PowerShell window with Claude, type `/exit` and press Enter to close Claude (it picks up the new connection the next time it starts).
8. Check it worked: in the same PowerShell window, paste this and press Enter. It should say **True**:
   ```
   Test-Path "$env:LOCALAPPDATA\Roblox\mcp.bat"
   ```
Roblox sometimes moves menus. If yours look different, follow the current steps in Roblox's guide (link above). You only do this once: after this, the template's `.mcp.json` file connects Claude to Studio by itself every time you start Claude in a game folder (as long as Studio is open).

### 5. Download this template
1. Go to https://github.com/maizeismediocre/Roblox-Game-Generator, click the green **Code** button, then **Download ZIP**.
2. Open your **Downloads** folder, right-click the ZIP file, choose **Extract All...** and pick a place you'll find again, e.g. your **Documents** folder.
3. Open the extracted folder. You may need to go one folder deeper: the right folder is the one that contains `README.md`, `SETUP.md` and `CLAUDE.md`. This is the **template folder**; remember where it is.
   (If you know git: `git clone https://github.com/maizeismediocre/Roblox-Game-Generator.git` does the same.)

This folder stays as your master copy. Each new game is made as a copy of it in a separate folder, so you can reuse the template for as many games as you like.

### 6. Optional extras
- **Python + Pillow + NumPy** (for making icons and store-page images later on; Claude asks before using them). Python: https://www.python.org/downloads/windows/ (tick "Add python.exe to PATH" when installing), Pillow: https://pypi.org/project/pillow/, NumPy: https://pypi.org/project/numpy/. Or in PowerShell:
  ```
  winget install --id Python.Python.3.12 -e
  py -m pip install pillow numpy
  ```
- **GitHub backup** (keeps a copy of your game online, private). Recommended if you want an online backup of your work: without it, your game folder (the build plan, the backup copy of the game and Claude's notes on unfinished work) is only on this PC. The game itself is still saved to your Roblox account either way. Make a free account at https://github.com/signup, install the GitHub CLI from https://cli.github.com/, or in PowerShell:
  ```
  winget install --id GitHub.cli -e
  gh auth login
  ```
  Then pick GitHub.com, HTTPS, and "Login with a web browser". If this is set up, Claude offers to make a private GitHub repo for each new game.

---

## Part 2 — Start a new game (every time you want a new game)

1. Open **Roblox Studio** with a new place: **File > New > Baseplate**. Leave it open. (Always open Studio *before* starting Claude, so Claude can connect to it.)
2. Open the template folder in PowerShell: in File Explorer, open the **template folder** (the one with `README.md` and `SETUP.md` in it, from Part 1 step 5), click the address bar, type `powershell` and press Enter. The prompt should end with the template folder's name.
3. Type `claude` and press Enter. The first time in this folder, Claude may ask:
   - **Do you trust the files in this folder?** Choose **Yes**.
   - **Allow the Roblox_Studio MCP server?** Choose **Yes** (or "use this and all future MCP servers").
4. Type `read SETUP.md` and press Enter.
5. Answer Claude's questions. They appear as a list of choices: use the **arrow keys** and **Enter** to pick one, or choose **Other** / just type to write your own answer.

   Claude will also sometimes ask **"Do you want to proceed?"** before running a command or changing a file. Pick **Yes**, or **Yes, and don't ask again** for that kind of command, so it asks less often.
   - **Genre:** pick **Random** (reroll as often as you like), choose from the list, or type your own idea.
   - **Game idea:** Claude shows a short pitch card. Say yes, ask for a new idea, change the genre, or type what you'd like changed.
   - **Folder:** where to make the game (e.g. Documents\Roblox Games\YourGame). This template stays untouched, so you can reuse it for the next game.
   - **GitHub:** only asked if you did the GitHub extra above.
   - **Shortcuts:** only offered when Claude is running in PowerShell (not in the desktop app). Two desktop shortcuts:
     - **<Game> - Claude**: opens Claude in the game folder.
     - **<Game> - Claude (auto)**: the same, and types "read instructions.md and continue" for you.
     Both start a Remote Control session named after the game, so you can follow along from the Claude app on your phone (optional: sign in to the Claude app with the same account and look for the session named after your game).
6. When setup says it's done, close that PowerShell window (it's still in the template folder, not your game's folder).
7. Double-click **<Game> - Claude (auto)** on your desktop. Claude starts **Build Phase 1**.
   No shortcuts? Open your new **game folder** (the one you chose in step 5, not the template) in PowerShell the same way as step 2, type `claude`, press Enter, then type `read instructions.md and continue` and press Enter.

### The first session
- Claude asks you to help with the first **Save to Roblox** (it creates the game on your Roblox account): check the owner and click **Create**.
- It then asks you to turn on **Enable Studio Access to API Services** (needed for saving player data in tests): in Studio open **Game Settings** (in the **File** menu, or the **Game Settings** button on the **Home** tab), click **Security**, turn on **Enable Studio Access to API Services**, and click **Save**.
- After that Claude works on its own: it builds, tests, saves and moves on. You can watch, but don't click around in Studio while it's working, because it uses Studio too.
- **Effort level:** before each task Claude says which effort level suits it. To change it, type `/effort high` (or `/effort medium`) and press Enter. Higher effort gives better models and art but uses more of your Claude plan.
- **To stop Claude** in the middle of something, press **Esc**. Type a message to tell it what to do next.

### Every session after that
1. Open Roblox Studio with your game: from Studio's start page (**Recent** or **My Games**), or **File > Open from Roblox**.
2. Then double-click **<Game> - Claude (auto)** (or open the game folder in PowerShell, type `claude`, then `read instructions.md and continue`).
3. When Claude finishes a task file or a topic, it stops and says "Good time to /clear now". Type `/clear` and press Enter. This wipes Claude's short-term memory of the conversation so the next task starts fresh (your game and its progress are saved, so nothing is lost). Then type `read instructions.md and continue`. Or close the window and use the shortcut again.

### Usage limits
Claude Pro/Max plans have usage limits. If Claude says you've hit your limit, it tells you when it resets. Leave Studio and Claude open and, after the reset, type `continue`. If you closed everything, open Studio with the game and use the **(auto)** shortcut: Claude saves its place in git as it goes and picks up where it left off.

### Using the Claude desktop app instead of the terminal
The Code part of the Claude desktop app works too: open the template folder as the project and type `read SETUP.md`; later open the game folder and type `read instructions.md and continue`. No desktop shortcuts are made there. If the Studio tools don't show up in the app, connect it from Studio once: **Assistant > ... > Manage MCP Servers > Quick connect > Claude Desktop** (see https://create.roblox.com/docs/studio/mcp). The normal chat part of the desktop app can't do this (it can't run the scripts, saves or git).

---

## If something goes wrong
| Problem | Fix |
|---------|-----|
| `claude` is "not recognized" | Close and reopen PowerShell after installing. If it still fails, reinstall Claude Code (Part 1, step 3), or see https://code.claude.com/docs/en/troubleshoot-install. |
| `git` is "not recognized" | Close and reopen PowerShell after installing Git. If it still fails, run the Git installer again (Part 1, step 2). |
| Claude says it can't log in, or your plan doesn't include Claude Code | Claude Code needs a Pro or Max plan. Type `/login` in Claude to sign in again. |
| Claude says the Studio tools aren't connected | Studio must be open with a place, and its MCP server on (Part 1, step 4). If you opened Studio *after* Claude, type `/mcp` in Claude, pick **Roblox_Studio** and choose **Reconnect** (or type `/exit` and start Claude again). In Studio, **Assistant > ... > Manage MCP Servers** shows a green light when Claude is connected. |
| Claude Code isn't in Studio's **Quick connect** list | Make sure Claude is installed and open in PowerShell (Part 1, step 3), then close and reopen Studio. |
| `mcp.bat` doesn't exist (the check says **False**) | Studio's MCP server isn't turned on yet (Part 1, step 4). |
| PowerShell opened in the wrong folder | Close it and open the right folder in File Explorer first, then type `powershell` in its address bar. Setup must start in the template folder; game sessions must start in the game folder. |
| Player data doesn't save in tests | The game must be saved to Roblox once, and **Enable Studio Access to API Services** must be on (Game Settings > Security). |
| Claude stopped halfway | Start it again with the "(auto)" shortcut. It reads the last "HANDOFF" note in git and carries on. |
| Setup was interrupted | Delete the half-made game folder and run `read SETUP.md` in the template again. |
| You want the shortcuts again | Open the game folder in PowerShell and run `powershell -ExecutionPolicy Bypass -File tools\make-shortcuts.ps1 -ProjectDir "<game folder>" -Name "<Game Name>"`, replacing `<game folder>` with the folder's full path (copy it from File Explorer's address bar) and `<Game Name>` with your game's name. Or just ask Claude to remake them. |

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
