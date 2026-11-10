"""Checks that every genre in genres.txt has a complete profile in genre_guide.md.

Usage (from the template folder):  py -I setup/check_genres.py
Prints "GENRES OK: <n> genres, each with a full profile", or lists what is missing (exit code 1).
Run it after adding or renaming a genre.
"""
import io
import os
import sys

FIELDS = ["Traits", "Loop", "Must have", "Progress", "With friends", "Keep it", "Prove"]
TRAITS = {"Feel", "Several players", "No currency", "Building", "None"}


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    genres = []
    for line in io.open(os.path.join(here, "genres.txt"), encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#"):
            genres.append(line.split("|")[0].strip())

    profiles, name = {}, None
    for line in io.open(os.path.join(here, "genre_guide.md"), encoding="utf-8"):
        line = line.rstrip("\n")
        if line.startswith("## "):
            name = line[3:].strip()
            profiles[name] = {}
        elif name and ":" in line:
            key, value = line.split(":", 1)
            if key in FIELDS:
                profiles[name][key] = value.strip()

    problems = []
    for genre in genres:
        profile = profiles.get(genre)
        if profile is None:
            problems.append("%s: no profile in genre_guide.md" % genre)
            continue
        for field in FIELDS:
            if not profile.get(field):
                problems.append("%s: the '%s' line is missing or empty" % (genre, field))
        traits = [t.strip() for t in profile.get("Traits", "").split(",") if t.strip()]
        for trait in traits:
            if trait not in TRAITS:
                problems.append("%s: unknown trait '%s'" % (genre, trait))
        if "None" in traits and len(traits) > 1:
            problems.append("%s: 'None' can't be mixed with other traits" % genre)
        if len([m for m in profile.get("Must have", "").split(";") if m.strip()]) < 4:
            problems.append("%s: fewer than 4 must-haves" % genre)
    for name in profiles:
        if name not in genres:
            problems.append("%s: has a profile but is not in genres.txt" % name)
    if len(set(genres)) != len(genres):
        problems.append("genres.txt lists a genre twice")

    if problems:
        print("GENRE PROBLEMS (%d):" % len(problems))
        for p in problems:
            print("  " + p)
        return 1
    print("GENRES OK: %d genres, each with a full profile" % len(genres))
    return 0


if __name__ == "__main__":
    sys.exit(main())
