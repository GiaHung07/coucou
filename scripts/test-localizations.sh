#!/usr/bin/env bash
# Every language the string catalog carries must be declared to the OS, or the
# Mac app will not offer it. Guards the plist and both XcodeGen targets against
# drifting behind NotchBuddy/Resources/Localizable.xcstrings.
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
import json, re, sys

catalog = json.load(open("NotchBuddy/Resources/Localizable.xcstrings", encoding="utf-8"))
langs = set()
for entry in catalog.get("strings", {}).values():
    langs.update((entry.get("localizations") or {}).keys())
if not langs:
    sys.exit("no localizations found in the catalog")

yml = open("NotchBuddy/project.yml", encoding="utf-8").read()
arrays = [
    set(re.findall(r"-[ \t]+(\S+)", block))
    for block in re.findall(r"CFBundleLocalizations:\n((?:[ \t]+-[^\n]*\n)+)", yml)
]
if not arrays:
    sys.exit("project.yml has no CFBundleLocalizations")
for declared in arrays:
    missing = langs - declared
    if missing:
        sys.exit(f"project.yml CFBundleLocalizations is missing: {sorted(missing)}")

plist = open("NotchBuddy/Resources/Info.plist", encoding="utf-8").read()
block = re.search(r"CFBundleLocalizations[\s\S]*?<array>([\s\S]*?)</array>", plist)
if not block:
    sys.exit("Info.plist has no CFBundleLocalizations")
declared = set(re.findall(r"<string>([^<]+)</string>", block.group(1)))
missing = langs - declared
if missing:
    sys.exit(f"Info.plist CFBundleLocalizations is missing: {sorted(missing)}")

print(f"CFBundleLocalizations declares all {len(langs)} catalog languages: {sorted(langs)}")
PY
