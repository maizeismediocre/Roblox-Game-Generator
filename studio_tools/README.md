# Studio tool modules

Source for ModuleScripts that Build Phase 1 installs into the game (create the ModuleScript in Studio and set its Source to the file's text). They are edit-time tools: nothing in the running game requires them.

| File | Goes to | What it does |
|------|---------|--------------|
| `ModelKit.luau` | `ServerStorage/ArtTools/ModelKit` | Builds chunky block models from recipes (`part`, `face`, `star5`, `asPiece`, `Build`) and checks them: `Check` (floating, flicker, round parts), `FindClipping`, `FindFlicker`/`FixFlicker`, `CheckPieces`, `Turnaround` (4-side review rows). Used by the `model-qa` and `new-character` skills. |
| `SceneryScan.luau` | `ServerStorage/ArtTools/SceneryScan` | Scans whole areas (thousands of parts) for flicker, floating groups, duplicate and hidden parts. |

If you improve a module in Studio, copy its Source back here (and to the master template if it's a general fix) so the next game gets it too.
