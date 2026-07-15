#!/usr/bin/env python3
"""Sync a validated History Explorer 3D scene into a lesson master JSON."""

import json
import sys
from pathlib import Path


def load(path: Path):
    with path.open(encoding="utf-8") as source:
        return json.load(source)


if len(sys.argv) != 4:
    raise SystemExit("usage: sync_history3d_to_master.py TEMPLATE HISTORY MASTER")

template_path, history_path, master_path = map(Path, sys.argv[1:])
template = load(template_path)
history = load(history_path)
master = load(master_path)

if history.get("characters") != template.get("characters"):
    raise SystemExit("Refusing sync: protected History3D characters differ from the template.")

for key in ("dialogs", "facts", "screens"):
    if key not in history:
        raise SystemExit(f"Refusing sync: missing history3d.{key}")

master["history3d"] = history
with master_path.open("w", encoding="utf-8") as destination:
    json.dump(master, destination, ensure_ascii=False, indent=2)
    destination.write("\n")

print(f"Synced protected History3D scene to: {master_path}")
