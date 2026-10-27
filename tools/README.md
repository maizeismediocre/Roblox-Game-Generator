# tools

- `make-shortcuts.ps1` - makes the two desktop shortcuts for this game ("<Game> - Claude" and "<Game> - Claude (auto)", both with a Remote Control session named after the game).
  Run: `powershell -ExecutionPolicy Bypass -File tools\make-shortcuts.ps1 -ProjectDir "<this folder>" -Name "<Game Name>"`

- `store_edit.py` - turns a raw store-page screenshot (`store_page/<thumbnails|icon|passes>/<name>_raw.png`) into the finished image `<name>.png` in the same folder, then deletes the raw. Thumbnails: 16:9 crop, 1920x1080, optional text overlay. Icons/passes: square crop, 512x512, no text. Needs Python + Pillow.
  Run: `py tools/store_edit.py <raw> [--text "PLAY WITH FRIENDS!"] [--pos bottom|top|top-left|...] [--focus 0.5,0.5] [--preview <dir>] [--keep-raw]`. `--preview` writes a phone-size thumbnail, or a tiny + circle-cropped icon, for checking.

- `icons/` - pictures of the game's models and UI icons (the `model-photos` and `add-asset` skills):
  - `shots.ps1` grabs the screen on a clock while Studio's camera steps through the shots.
  - `cutout.py` crops a whole run, cuts each model out from its black + white backdrop pair (`netmatte.py`) and adds the black outline (`netfinish.py`). Set `VIEW`/`SQUARE` for this PC's screen the first time.
  - `finish.py` turns a white downloaded icon into a finished one (crop, centre, optional bold, black outline); `colour.py` bakes colours into an icon; `sheet.py` makes preview sheets.
  Needs Python + Pillow (and numpy for some).

- `fonts/Fredoka.ttf` - text font for store_edit.py. Source: Google Fonts (github.com/google/fonts, ofl/fredoka), by The Fredoka Project Authors. Licence: SIL Open Font License 1.1 (`fonts/OFL.txt`) - commercial use allowed, no fee, no attribution needed in the images.
