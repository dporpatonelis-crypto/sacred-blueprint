#!/usr/bin/env python3
"""Build a History Explorer 3D payload without altering the protected scene."""

import json
import sys
from copy import deepcopy
from pathlib import Path


def load_json(path: Path):
    with path.open(encoding="utf-8") as source:
        return json.load(source)


def fail(message: str):
    raise SystemExit(f"History3D template error: {message}")


if len(sys.argv) != 4:
    fail("usage: build_history3d_from_template.py TEMPLATE CONTENT OUTPUT")

template_path, content_path, output_path = map(Path, sys.argv[1:])
template = load_json(template_path)
content = load_json(content_path)

characters = template.get("characters")
if not isinstance(characters, list) or not characters:
    fail("template.characters must be a non-empty array")

protected_fields = {"id", "name", "position_x", "position_y", "position_z", "rotation", "color", "robeColor", "description", "glbModel"}
for character in characters:
    if not protected_fields.issubset(character):
        fail("every template character must include all protected scene fields")

allowed_ids = {character["id"] for character in characters}
dialogs = content.get("dialogs", [])
facts = content.get("facts", [])
screens = content.get("screens", {})

if not isinstance(dialogs, list) or not isinstance(facts, list) or not isinstance(screens, dict):
    fail("content must contain dialogs[], facts[], and screens{}")

for dialog in dialogs:
    if set(dialog) != {"character_id", "question", "answer"}:
        fail("each dialog must contain only character_id, question, answer")
    if dialog["character_id"] not in allowed_ids:
        fail(f"dialog references unknown template character: {dialog['character_id']}")

for fact in facts:
    if set(fact) != {"character_id", "fact"}:
        fail("each fact must contain only character_id and fact")
    if fact["character_id"] not in allowed_ids:
        fail(f"fact references unknown template character: {fact['character_id']}")

required_screen_fields = {"left_image_url", "right_image_url", "left_label", "right_label"}
if not required_screen_fields.issubset(screens):
    fail("screens must include left/right image URLs and labels")

result = deepcopy(template)
result["dialogs"] = dialogs
result["facts"] = facts
result["screens"] = {key: screens[key] for key in required_screen_fields}

output_path.parent.mkdir(parents=True, exist_ok=True)
with output_path.open("w", encoding="utf-8") as destination:
    json.dump(result, destination, ensure_ascii=False, indent=2)
    destination.write("\n")

print(f"Written: {output_path}")
