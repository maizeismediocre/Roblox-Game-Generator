"""Copies every script out of a saved place file (.rbxl) into text files, so git can show code changes.

Usage (from the project folder):  py -I tools/export_scripts.py "<Game> Backup.rbxl" src

Writes one file per script under the output folder, following the game tree:
    src/ServerScriptService/Server/DataService.server.luau          (Script)
    src/StarterPlayer/StarterPlayerScripts/Client/Hud.client.luau   (LocalScript)
    src/ReplicatedStorage/Shared/Config/Prices.luau                 (ModuleScript)
Files for scripts that no longer exist are deleted. The folder is only a copy for reading and for
git history. The game never loads it, and editing it changes nothing in Studio.

Needs Python 3.14 or newer and no add-ons. Roblox Studio packs place files with zstd, which Python
can only read from 3.14. (Older place files packed with LZ4 are read on any Python 3.)
Prints "EXPORTED <n> scripts ..." on success, or "EXPORT FAILED: <reason>" and exit code 1.
"""
import os
import struct
import sys

MAGIC = b"<roblox!\x89\xff\r\n\x1a\n"
ZSTD_MAGIC = b"\x28\xb5\x2f\xfd"
MARKER = ".export_scripts"
SUFFIX = {"Script": ".server.luau", "LocalScript": ".client.luau", "ModuleScript": ".luau"}
BAD_CHARS = '<>:"/\\|?*'
RESERVED = {"CON", "PRN", "AUX", "NUL"} | {"COM%d" % i for i in range(1, 10)} | {"LPT%d" % i for i in range(1, 10)}


class ExportError(Exception):
    pass


def lz4_block(src, out_len):
    """Decompresses one raw LZ4 block."""
    dst = bytearray()
    i, n = 0, len(src)
    while i < n:
        token = src[i]
        i += 1
        lit = token >> 4
        if lit == 15:
            while True:
                b = src[i]
                i += 1
                lit += b
                if b != 255:
                    break
        dst += src[i:i + lit]
        i += lit
        if i >= n:
            break
        offset = src[i] | (src[i + 1] << 8)
        i += 2
        length = token & 15
        if length == 15:
            while True:
                b = src[i]
                i += 1
                length += b
                if b != 255:
                    break
        length += 4
        start = len(dst) - offset
        if offset == 0 or start < 0:
            raise ExportError("bad LZ4 data")
        if offset >= length:
            dst += dst[start:start + length]
        else:  # the copy overlaps itself: repeat the last <offset> bytes
            pattern = bytes(dst[start:])
            dst += (pattern * (length // offset + 1))[:length]
    if len(dst) != out_len:
        raise ExportError("LZ4 chunk has the wrong size")
    return bytes(dst)


def zstd_frame(src):
    try:
        from compression import zstd  # Python 3.14+
        return zstd.decompress(src)
    except ImportError:
        pass
    try:
        import zstandard
        return zstandard.ZstdDecompressor().decompressobj().decompress(src)
    except ImportError:
        raise ExportError("this place file is packed with zstd, which needs Python 3.14 or newer "
                          "(this is Python %d.%d)" % sys.version_info[:2])


def chunks(data):
    """Yields (name, payload) for every chunk in the file."""
    if data[:14] != MAGIC:
        raise ExportError("not a binary .rbxl file (an .rbxlx XML file is not supported)")
    pos = 32
    while pos + 16 <= len(data):
        name = data[pos:pos + 4]
        packed, size = struct.unpack_from("<II", data, pos + 4)
        pos += 16
        if packed == 0:
            payload = data[pos:pos + size]
            pos += size
        else:
            raw = data[pos:pos + packed]
            pos += packed
            payload = zstd_frame(raw) if raw[:4] == ZSTD_MAGIC else lz4_block(raw, size)
        yield name, payload
        if name == b"END\x00":
            return
    raise ExportError("the file ends early (was it saved completely?)")


def read_string(buf, pos):
    (length,) = struct.unpack_from("<I", buf, pos)
    pos += 4
    return buf[pos:pos + length], pos + length


def read_referents(buf, pos, count):
    """Reads <count> ids: bytes interleaved, zigzag encoded, each one a step from the last."""
    out, total = [], 0
    for k in range(count):
        v = ((buf[pos + k] << 24) | (buf[pos + count + k] << 16)
             | (buf[pos + 2 * count + k] << 8) | buf[pos + 3 * count + k])
        total += (v >> 1) ^ -(v & 1)
        out.append(total)
    return out, pos + 4 * count


def read_place(path):
    """Returns ({id: class name}, {id: name}, {id: source}, {id: parent id})."""
    with open(path, "rb") as f:
        data = f.read()
    class_of, ids_of_class, name_of, source_of, parent_of = {}, {}, {}, {}, {}
    for chunk, buf in chunks(data):
        if chunk == b"INST":
            (class_id,) = struct.unpack_from("<I", buf, 0)
            class_name, pos = read_string(buf, 4)
            (count,) = struct.unpack_from("<I", buf, pos + 1)
            ids, _ = read_referents(buf, pos + 5, count)
            ids_of_class[class_id] = ids
            for i in ids:
                class_of[i] = class_name.decode("utf-8", "replace")
        elif chunk == b"PROP":
            (class_id,) = struct.unpack_from("<I", buf, 0)
            prop, pos = read_string(buf, 4)
            if prop not in (b"Name", b"Source") or buf[pos] != 0x01:  # 0x01 = string values
                continue
            target = name_of if prop == b"Name" else source_of
            pos += 1
            for i in ids_of_class.get(class_id, []):
                value, pos = read_string(buf, pos)
                target[i] = value.decode("utf-8", "replace")
        elif chunk == b"PRNT":
            (count,) = struct.unpack_from("<I", buf, 1)
            children, pos = read_referents(buf, 5, count)
            parents, _ = read_referents(buf, pos, count)
            parent_of.update(zip(children, parents))
    if not class_of:
        raise ExportError("no instances found in the file")
    return class_of, name_of, source_of, parent_of


def safe(name):
    """Turns an instance name into a file name that cannot leave its folder."""
    cleaned = "".join("_" if (c in BAD_CHARS or ord(c) < 32) else c for c in name).rstrip(". ")
    if not cleaned:
        return "_"
    if cleaned.split(".")[0].upper() in RESERVED:  # names Windows keeps for devices
        cleaned = "_" + cleaned
    return cleaned


def export(place, out_dir):
    class_of, name_of, source_of, parent_of = read_place(place)
    out_dir = os.path.abspath(out_dir)
    marker = os.path.join(out_dir, MARKER)
    if os.path.isdir(out_dir) and os.listdir(out_dir) and not os.path.exists(marker):
        raise ExportError("%s already has files that this tool did not make; choose an empty folder" % out_dir)
    os.makedirs(out_dir, exist_ok=True)
    with open(marker, "w", encoding="utf-8") as f:
        f.write("Made by tools/export_scripts.py. Everything in this folder is rewritten on every save.\n")

    def folder_parts(i):
        parts = []
        i = parent_of.get(i, -1)
        while i in class_of and len(parts) < 200:
            parts.append(safe(name_of.get(i, class_of[i])))
            i = parent_of.get(i, -1)
        return parts[::-1]

    written = set()
    for i in sorted(source_of):
        suffix = SUFFIX.get(class_of.get(i))
        if suffix is None:
            continue
        folder = os.path.join(out_dir, *folder_parts(i))
        base = safe(name_of.get(i, class_of[i]))
        path = os.path.join(folder, base + suffix)
        n = 2
        while os.path.normcase(path) in written:  # two scripts with the same name in one place
            path = os.path.join(folder, "%s~%d%s" % (base, n, suffix))
            n += 1
        written.add(os.path.normcase(path))
        os.makedirs(folder, exist_ok=True)
        text = source_of[i].replace("\r\n", "\n")
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)

    removed = 0
    for root, dirs, files in os.walk(out_dir, topdown=False):
        for name in files:
            full = os.path.join(root, name)
            if name.endswith(".luau") and os.path.normcase(full) not in written:
                os.remove(full)
                removed += 1
        if root != out_dir and not os.listdir(root):
            os.rmdir(root)
    return len(written), removed


def main(argv):
    if len(argv) != 3:
        print("Usage: py -I tools/export_scripts.py <place.rbxl> <output folder>")
        return 2
    try:
        count, removed = export(argv[1], argv[2])
    except ExportError as e:
        print("EXPORT FAILED: %s" % e)
        return 1
    except (OSError, struct.error, IndexError) as e:
        print("EXPORT FAILED: could not read the place file (%s: %s)" % (type(e).__name__, e))
        return 1
    print("EXPORTED %d scripts to %s (%d old files removed)" % (count, argv[2], removed))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
