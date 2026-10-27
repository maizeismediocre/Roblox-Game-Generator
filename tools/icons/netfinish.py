"""Hotbar / Gear Shop net icons, step 2: tilt the cut-out net (from netmatte.py) so it fills a square
slot diagonally and give it the same dark-brown outline as the other UI icons (finish.py).
Usage: py -I netfinish.py <in.png> <out.png> [angle=35]"""
import sys
from PIL import Image, ImageFilter

src = Image.open(sys.argv[1]).convert("RGBA")
angle = float(sys.argv[3]) if len(sys.argv) > 3 else 35


def drop_specks(im):
    """Clears loose bits far smaller than the model (e.g. a faint corner of Studio's grid line).
    They used to count in the centring crop below and got their own outline dot (2026-10-26)."""
    a = im.getchannel("A")
    w, h = a.size
    data = a.tobytes()
    seen = bytearray(w * h)
    comps = []
    for start in range(w * h):
        if data[start] and not seen[start]:
            seen[start] = 1
            stack, comp = [start], []
            while stack:
                i = stack.pop()
                comp.append(i)
                x, y = i % w, i // w
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if 0 <= nx < w and 0 <= ny < h:
                        j = ny * w + nx
                        if data[j] and not seen[j]:
                            seen[j] = 1
                            stack.append(j)
            comps.append(comp)
    if len(comps) < 2:
        return im
    biggest = max(len(c) for c in comps)
    out = bytearray(data)
    for c in comps:
        if len(c) < biggest * 0.002:
            for i in c:
                out[i] = 0
    im.putalpha(Image.frombytes("L", (w, h), bytes(out)))
    return im


src = drop_specks(src)
W, BOX, FINAL = 512, int(512 * 0.80), 256
OUTLINE = (0, 0, 0)  # black (user 2026-10-25; was dark brown 60, 32, 12)
big = src.resize((src.width * 3, src.height * 3), Image.LANCZOS).rotate(-angle, resample=Image.BICUBIC, expand=True)
big = big.crop(big.getchannel("A").point(lambda v: 255 if v > 40 else 0).getbbox())
scale = BOX / max(big.size)
big = big.resize((max(1, round(big.width * scale)), max(1, round(big.height * scale))), Image.LANCZOS)
art = Image.new("RGBA", (W, W))
art.paste(big, ((W - big.width) // 2, (W - big.height) // 2))
alpha = art.getchannel("A")
ring = alpha.filter(ImageFilter.GaussianBlur(9)).point(lambda v: max(0, min(255, (v - 6) * 10)))
img = Image.new("RGBA", (W, W), OUTLINE + (0,))
img.putalpha(ring)
img.alpha_composite(art)
# last: centre the finished picture (outline included) on its canvas, so every picture sits in the
# middle of its disc (user 2026-10-26: "why aren't they centered properly anymore?")
bb = img.getchannel("A").point(lambda v: 255 if v > 0 else 0).getbbox()
if bb:
    piece = img.crop(bb)
    img = Image.new("RGBA", (W, W), OUTLINE + (0,))
    img.paste(piece, ((W - piece.width) // 2, (W - piece.height) // 2))
img.resize((FINAL, FINAL), Image.LANCZOS).save(sys.argv[2])
