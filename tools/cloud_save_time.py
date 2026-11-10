"""Shows when a Roblox place was last saved to the cloud (used by the save-game skill).

Usage (from the project folder):  py -I tools/cloud_save_time.py <place id>

Prints "UPDATED <UTC time> (<n> seconds ago)", or "CHECK FAILED: <reason>" and exit code 1.
Then prints "STUDIO SAID: <time> <message>" with what Studio's own log said about the last
Save to Roblox, if it finds one. Studio skips the upload when nothing has changed since the last
save and logs "No changes to the place detected. Did not save."; the UPDATED time then stays old.
Sends only the place id to Roblox. Reads Studio's log files on this PC. No login and no add-ons needed.
"""
import glob
import json
import os
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone


def last_studio_save():
    """Returns the newest 'what happened to the save' line from Studio's logs, or None."""
    folder = os.path.join(os.environ.get("LOCALAPPDATA", ""), "Roblox", "logs")
    logs = sorted(glob.glob(os.path.join(folder, "*Studio*.log")), key=os.path.getmtime, reverse=True)[:5]
    best = None
    for path in logs:
        try:
            with open(path, encoding="utf-8", errors="replace") as f:
                for line in f:
                    if "[FLog::CreatorOutput]" in line or "[FLog::StudioKeyEvents] publish request" in line:
                        stamp = line[:19]
                        if best is None or stamp >= best[0]:  # >= so the result line wins over its request line
                            best = (stamp, line.split("] ", 1)[-1].strip()[:160])
        except OSError:
            continue
    return best


def main(argv):
    if len(argv) != 2 or not argv[1].isdigit():
        print("Usage: py -I tools/cloud_save_time.py <place id>")
        return 2
    url = "https://economy.roblox.com/v2/assets/%s/details" % argv[1]
    try:
        request = urllib.request.Request(url, headers={"User-Agent": "save-check"})
        with urllib.request.urlopen(request, timeout=20) as reply:
            updated = json.load(reply)["Updated"]
    except urllib.error.HTTPError as e:
        print("CHECK FAILED: Roblox answered %d (a private place can do this)" % e.code)
        return 1
    except (urllib.error.URLError, OSError, KeyError, ValueError) as e:
        print("CHECK FAILED: %s: %s" % (type(e).__name__, e))
        return 1
    # e.g. 2026-01-05T13:42:10.123Z: keep the whole seconds, which every Python version can read
    stamp = datetime.strptime(updated[:19], "%Y-%m-%dT%H:%M:%S").replace(tzinfo=timezone.utc)
    age = int((datetime.now(timezone.utc) - stamp).total_seconds())
    print("UPDATED %s UTC (%d seconds ago)" % (stamp.strftime("%Y-%m-%d %H:%M:%S"), age))
    said = last_studio_save()
    if said:
        print("STUDIO SAID: %s UTC %s" % (said[0].replace("T", " "), said[1]))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
