#!/usr/bin/env python3
"""Sync a validated History Explorer 3D scene into a lesson master JSON."""

import json
import sys
from pathlib import Path

from history3d_contract import load_json, validate_full_scenario, write_json


if len(sys.argv) != 4:
    raise SystemExit(
        "usage: sync_history3d_to_master.py TEMPLATE HISTORY MASTER"
    )

template_path, history_path, master_path = map(Path, sys.argv[1:])

try:
    template = load_json(template_path)
    history = load_json(history_path)
    master = load_json(master_path)
    validate_full_scenario(history, template)
except (OSError, json.JSONDecodeError, ValueError) as error:
    raise SystemExit(f"Refusing History3D sync: {error}") from error

if not isinstance(master, dict):
    raise SystemExit("Refusing History3D sync: master_output.json must be an object")

master["history3d"] = history
write_json(master_path, master)
print(f"Synced protected History3D scene to: {master_path}")
