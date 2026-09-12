#!/usr/bin/env python3
"""Publish a validated History Explorer 3D scenario and update its manifest."""

import json
import os
import sys
from pathlib import Path

from history3d_contract import load_json, validate_full_scenario, write_json


if len(sys.argv) not in {4, 7}:
    raise SystemExit(
        "usage: update_history3d.py LESSON_ID TITLE TODAY "
        "[SOURCE OUTPUT_DIR TEMPLATE]"
    )

lesson_id, title, today = sys.argv[1:4]
workspace = Path(os.environ.get("GITHUB_WORKSPACE", ".")).resolve()

if len(sys.argv) == 7:
    src_path = Path(sys.argv[4])
    out_dir = Path(sys.argv[5])
    template_path = Path(sys.argv[6])
else:
    src_path = workspace / "data/current/history3d.json"
    out_dir = Path("/tmp/history-explorer-3d/public/data")
    template_path = workspace / "templates/history3d/default.json"

if (
    not lesson_id
    or lesson_id in {".", ".."}
    or "/" in lesson_id
    or "\\" in lesson_id
):
    raise SystemExit("History3D publish blocked: invalid lesson id")
if not title.strip():
    raise SystemExit("History3D publish blocked: title is empty")

try:
    src = load_json(src_path)
    template = load_json(template_path)
    validate_full_scenario(src, template)
except (OSError, json.JSONDecodeError, ValueError) as error:
    raise SystemExit(f"History3D publish blocked: {error}") from error

out_dir.mkdir(parents=True, exist_ok=True)
scenario_path = out_dir / f"{lesson_id}.json"
write_json(scenario_path, src)
print(f"  -> public/data/{lesson_id}.json (validated, lossless)")

manifest_path = out_dir / "manifest.json"
try:
    manifest = load_json(manifest_path)
except (OSError, json.JSONDecodeError):
    manifest = {"scenarios": []}

if not isinstance(manifest, dict):
    manifest = {"scenarios": []}
scenarios = manifest.setdefault("scenarios", [])
if not isinstance(scenarios, list):
    raise SystemExit("History3D publish blocked: manifest.scenarios must be an array")

entry = {
    "file": f"{lesson_id}.json",
    "title": title,
    "description": f"Μάθημα: {title} ({today})",
    "thumbnail": "",
}
existing_index = next(
    (
        index
        for index, scenario in enumerate(scenarios)
        if isinstance(scenario, dict)
        and scenario.get("file") == f"{lesson_id}.json"
    ),
    None,
)
if existing_index is None:
    scenarios.append(entry)
    print(f"  + Added to manifest: {lesson_id}")
else:
    scenarios[existing_index] = entry

write_json(manifest_path, manifest)
print("manifest.json written.")
