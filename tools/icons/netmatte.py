"""Hotbar net icons: cut a net out of two Studio photos (same camera, black backdrop + white backdrop).
The difference between the two gives each pixel's see-through amount, so the net bag stays see-through.
Usage: py -I netmatte.py <black.jpg> <white.jpg> <out.png>   (256x256, transparent, centred)"""
import sys
from PIL import Image, ImageFilter

b = Image.open(sys.argv[1]).convert("RGB")
w = Image.open(sys.argv[2]).convert("RGB")
W, H = b.size
def corner(img):
    px = [img.getpixel((x, y)) for x in (W - 60, W - 30) for y in (H // 2, H - 40)]
    return [sum(p[i] for p in px) / len(px) for i in range(3)]
Bb, Bw = corner(b), corner(w)
out = Image.new("RGBA", (W, H))
bp, wp, op = b.load(), w.load(), out.load()
for y in range(H):
    for x in range(W):
        cb, cw = bp[x, y], wp[x, y]
        t = sum((cw[i] - cb[i]) / max(1, Bw[i] - Bb[i]) for i in range(3)) / 3  # 1 = background shows fully
        a = max(0.0, min(1.0, 1 - t))
        if a < 0.06:
            continue
        col = tuple(max(0, min(255, round((cb[i] - (1 - a) * Bb[i]) / a))) for i in range(3))
        op[x, y] = col + (round(a * 255),)
# drop the Studio axis gizmo in the top-left corner
for y in range(0, 140):
    for x in range(0, 120):
        op[x, y] = (0, 0, 0, 0)
# drop loose bits far smaller than the model (Studio's grid line / gizmos in a corner): they made the
# crop box bigger than the model, so it sat off-centre with a stray outlined dot (2026-10-26)
mask = out.getchannel("A").point(lambda v: 255 if v > 40 else 0)
small = mask.resize((max(1, W // 4), max(1, H // 4)), Image.BOX).point(lambda v: 255 if v > 0 else 0)
sw, sh = small.size
sp = small.load()
seen, comps = set(), []
for y in range(sh):
    for x in range(sw):
        if sp[x, y] and (x, y) not in seen:
            stack, comp = [(x, y)], []
            seen.add((x, y))
            while stack:
                p = stack.pop()
                comp.append(p)
                for q in ((p[0] + 1, p[1]), (p[0] - 1, p[1]), (p[0], p[1] + 1), (p[0], p[1] - 1)):
                    if 0 <= q[0] < sw and 0 <= q[1] < sh and sp[q] and q not in seen:
                        seen.add(q)
                        stack.append(q)
            comps.append(comp)
if len(comps) > 1:
    biggest = max(len(c) for c in comps)
    keep = Image.new("L", (sw, sh))
    kp = keep.load()
    for c in comps:
        if len(c) >= biggest * 0.02:
            for p in c:
                kp[p] = 255
    keep = keep.resize((W, H), Image.NEAREST).filter(ImageFilter.MaxFilter(9))
    out.putalpha(Image.composite(out.getchannel("A"), Image.new("L", (W, H)), keep))
box = out.getchannel("A").point(lambda v: 255 if v > 40 else 0).getbbox()
out = out.crop(box)
side = max(out.size)
sq = Image.new("RGBA", (side, side))
sq.paste(out, ((side - out.width) // 2, (side - out.height) // 2))
sq.resize((256, 256), Image.LANCZOS).save(sys.argv[3])
print("bg black", [round(v) for v in Bb], "white", [round(v) for v in Bw], "box", box)
