"""Edit a raw store-page screenshot into its finished image, then delete the raw.

Usage:
  py tools/store_edit.py store_page/thumbnails/02_coop_chaos_raw.png --text "PLAY WITH FRIENDS!" --pos bottom
  py tools/store_edit.py store_page/icon/08_icon_A_mossbun_raw.png --focus 0.5,0.45
  (add --keep-raw to test without deleting, --preview <dir> to write small check copies)

The folder decides the format:
  thumbnails/     -> crop to 16:9, 1920x1080, optional text overlay (Fredoka Bold, thick outline)
  icon/, passes/  -> crop to square, 512x512, no text
Output = same folder, same name without "_raw". The raw is deleted only after the output
has been re-opened and checked for the right size.
"""
import argparse
import os
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
FONT = os.path.join(HERE, "fonts", "Fredoka.ttf")
SIZES = {"thumbnails": (1920, 1080), "icon": (512, 512), "passes": (512, 512)}
TEXT_FILL = (255, 255, 255)
TEXT_OUTLINE = (40, 22, 70)
SHADOW = (0, 0, 0, 110)


def crop_cover(img, size, focus):
    """Largest crop with the target aspect, centred on focus (0-1 x,y), then resize."""
    w, h = img.size
    tw, th = size
    if w / h > tw / th:
        cw, ch = round(h * tw / th), h
    else:
        cw, ch = w, round(w * th / tw)
    left = min(max(round(focus[0] * w - cw / 2), 0), w - cw)
    top = min(max(round(focus[1] * h - ch / 2), 0), h - ch)
    return img.crop((left, top, left + cw, top + ch)).resize(size, Image.LANCZOS)


def load_font(px):
    font = ImageFont.truetype(FONT, px)
    try:
        font.set_variation_by_name("Bold")
    except Exception:
        pass
    return font


def add_text(img, text, pos):
    W, H = img.size
    px = int(H * 0.14)
    while True:
        font = load_font(px)
        stroke = max(4, px // 9)
        box = ImageDraw.Draw(img).textbbox((0, 0), text, font=font, stroke_width=stroke)
        tw, th = box[2] - box[0], box[3] - box[1]
        if tw <= W * 0.86 or px <= 40:
            break
        px -= 4
    margin = int(H * 0.06)
    x = {"left": margin, "right": W - margin - tw}.get(pos.split("-")[-1], (W - tw) // 2)
    y = margin if pos.startswith("top") else H - margin - th
    x, y = x - box[0], y - box[1]

    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    off = max(3, px // 18)
    d.text((x + off, y + off), text, font=font, fill=SHADOW, stroke_width=stroke, stroke_fill=SHADOW)
    d.text((x, y), text, font=font, fill=TEXT_FILL, stroke_width=stroke, stroke_fill=TEXT_OUTLINE)
    return Image.alpha_composite(img.convert("RGBA"), layer)


def write_previews(out, kind, preview_dir):
    os.makedirs(preview_dir, exist_ok=True)
    img = Image.open(out).convert("RGBA")
    base = os.path.splitext(os.path.basename(out))[0]
    if kind == "thumbnails":
        img.resize((480, 270), Image.LANCZOS).save(os.path.join(preview_dir, base + "_phone.png"))
    else:
        small = img.resize((100, 100), Image.LANCZOS)
        small.save(os.path.join(preview_dir, base + "_tiny.png"))
        mask = Image.new("L", img.size, 0)
        ImageDraw.Draw(mask).ellipse((0, 0, img.size[0] - 1, img.size[1] - 1), fill=255)
        circle = Image.new("RGBA", img.size, (255, 255, 255, 0))
        circle.paste(img, (0, 0), mask)
        circle.save(os.path.join(preview_dir, base + "_circle.png"))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("raw")
    ap.add_argument("--text", default="")
    ap.add_argument("--pos", default="bottom",
                    help="top, bottom, top-left, top-right, bottom-left, bottom-right")
    ap.add_argument("--focus", default="0.5,0.5", help="crop centre as x,y from 0 to 1")
    ap.add_argument("--keep-raw", action="store_true")
    ap.add_argument("--preview", default="")
    a = ap.parse_args()

    raw = os.path.abspath(a.raw)
    stem, ext = os.path.splitext(raw)
    if not stem.endswith("_raw"):
        sys.exit("FAIL: file name must end in _raw: " + raw)
    kind = os.path.basename(os.path.dirname(raw))
    if kind not in SIZES:
        sys.exit("FAIL: raw must be inside store_page/thumbnails, icon or passes")
    if a.text and kind != "thumbnails":
        sys.exit("FAIL: icons get no text")
    size = SIZES[kind]
    focus = tuple(float(v) for v in a.focus.split(","))
    out = stem[:-4] + ".png"

    img = crop_cover(Image.open(raw).convert("RGB"), size, focus)
    if a.text:
        img = add_text(img, a.text, a.pos)
    img.convert("RGB").save(out, optimize=True)

    with Image.open(out) as check:
        check.load()
        if check.size != size:
            sys.exit("FAIL: output is %sx%s, expected %sx%s" % (check.size + size))
    if a.preview:
        write_previews(out, kind, a.preview)
    if not a.keep_raw:
        os.remove(raw)
    print("PASS %s (%dx%d)%s" % (out, size[0], size[1], "" if a.keep_raw else ", raw deleted"))


if __name__ == "__main__":
    main()
