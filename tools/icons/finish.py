"""Crop each white icon, centre it on a 256px canvas (content up to 212px), add a dark-brown outline.
Args: <out_dir> name=path[@bold] ... - bold (px at the 512 working size) thickens thin lines so
detailed downloaded icons match the chunky Kenney ones."""
import sys, os
from PIL import Image, ImageFilter

out_dir = sys.argv[1]
pairs = sys.argv[2:]  # name=path
W = 512          # working size
FINAL = 256
BOX = int(W * 0.80)
OUTLINE = (0, 0, 0)  # black (user 2026-10-25; was dark brown 60, 32, 12)

for pair in pairs:
    name, path = pair.split("=", 1)
    bold = 0
    if "@" in path:
        path, bold = path.rsplit("@", 1)
        bold = int(bold)
    src = Image.open(path).convert("RGBA")
    a = src.getchannel("A")
    bbox = a.getbbox()
    a = a.crop(bbox)
    scale = BOX / max(a.size)
    a = a.resize((max(1, round(a.width * scale)), max(1, round(a.height * scale))), Image.LANCZOS)
    if bold:
        a = a.filter(ImageFilter.MaxFilter(bold * 2 + 1))
        bb = a.getbbox()
        a = a.crop(bb).resize((round((bb[2] - bb[0]) * BOX / max(bb[2] - bb[0], bb[3] - bb[1])),
                               round((bb[3] - bb[1]) * BOX / max(bb[2] - bb[0], bb[3] - bb[1]))), Image.LANCZOS)
    alpha = Image.new("L", (W, W), 0)
    alpha.paste(a, ((W - a.width) // 2, (W - a.height) // 2))
    blur = alpha.filter(ImageFilter.GaussianBlur(11))
    ring = blur.point(lambda v: max(0, min(255, (v - 6) * 10)))
    img = Image.new("RGBA", (W, W), OUTLINE + (0,))
    img.putalpha(ring)
    white = Image.new("RGBA", (W, W), (255, 255, 255, 0))
    white.putalpha(alpha)
    img.alpha_composite(white)
    img = img.resize((FINAL, FINAL), Image.LANCZOS)
    img.save(os.path.join(out_dir, name + ".png"))
print("finished", len(pairs))
