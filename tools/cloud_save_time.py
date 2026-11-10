"""Shows when a Roblox place was last saved to the cloud (used by the save-game skill).

Usage (from the project folder):  py -I tools/cloud_save_time.py <place id>

Prints "UPDATED <UTC time> (<n> seconds ago)", or "CHECK FAILED: <reason>" and exit code 1.
Sends only the place id to Roblox. No login and no add-ons needed.
"""
import json
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone


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
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
