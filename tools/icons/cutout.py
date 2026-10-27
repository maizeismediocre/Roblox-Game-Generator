"""Turns a photo run (shots.ps1) into finished pictures with the black outline.
Shots come in pairs per name: shot_001 = black backdrop, shot_002 = white backdrop, and so on, in the
order of the names given. Each shot is cropped to Studio's 3D view and then to a square in the middle
(so Studio's corner gizmos stay out), cut out (netmatte.py) and outlined (netfinish.py).
Usage: py -I cutout.py <shots_dir> <out_dir> <tilt_degrees> <name1,name2,...> [first_shot_number]
  tilt 0 = upright (most models); 35 = diagonal (long thin tools such as nets, swords, wands).
VIEW and SQUARE below were measured with Studio maximised on a 2560x1440 screen - measure them again from one shot on a new PC (see the model-photos skill)."""
import os, subprocess, sys
from PIL import Image

VIEW = (4, 166, 2144, 1318)   # Studio's 3D view inside the screenshot
SQUARE = (494, 12, 1646, 1152)  # a square in the middle of the view (skips the view's top edge)
here = os.path.dirname(os.path.abspath(__file__))
shots, out, tilt, names = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4].split(",")
first = int(sys.argv[5]) if len(sys.argv) > 5 else 1
tmp = os.path.join(out, "_tmp")
os.makedirs(tmp, exist_ok=True)
for i, name in enumerate(names):
    paths = []
    for k, tag in ((0, "b"), (1, "w")):
        n = first + i * 2 + k
        im = Image.open(os.path.join(shots, f"shot_{n:03d}.png")).convert("RGB")
        p = os.path.join(tmp, f"{name}_{tag}.png")
        im.crop(VIEW).crop(SQUARE).save(p)
        paths.append(p)
    cut = os.path.join(tmp, f"{name}_cut.png")
    subprocess.run([sys.executable, "-I", os.path.join(here, "netmatte.py"), paths[0], paths[1], cut], check=True, capture_output=True)
    subprocess.run([sys.executable, "-I", os.path.join(here, "netfinish.py"), cut, os.path.join(out, f"{name}.png"), tilt], check=True)
print("made", len(names))
