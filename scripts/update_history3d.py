#!/usr/bin/env python3
import json, os, sys

lesson_id = sys.argv[1]
title     = sys.argv[2]
today     = sys.argv[3]

# Source data is in sacred-blueprint (where workflow runs)
src_path = os.environ.get("GITHUB_WORKSPACE", ".") + "/data/current/history3d.json"
template_path = os.environ.get("GITHUB_WORKSPACE", ".") + "/templates/history3d/default.json"
# Output goes to the cloned repo
out_dir  = "/tmp/history-explorer-3d/public/data"
os.makedirs(out_dir, exist_ok=True)

src = json.load(open(src_path, "r", encoding="utf-8"))
template = json.load(open(template_path, "r", encoding="utf-8"))

if src.get("characters") != template.get("characters"):
    raise SystemExit("History3D publish blocked: characters/models differ from templates/history3d/default.json")
if src.get("props") != template.get("props"):
    raise SystemExit("History3D publish blocked: props differ from templates/history3d/default.json")
if set(src) != {"characters", "dialogs", "facts", "screens", "props"}:
    raise SystemExit("History3D publish blocked: unexpected top-level keys")
allowed_ids = {character["id"] for character in template["characters"]}
if not isinstance(src["dialogs"], list) or not isinstance(src["facts"], list) or not isinstance(src["screens"], dict):
    raise SystemExit("History3D publish blocked: dialogs/facts/screens have the wrong types")
for index, dialog in enumerate(src["dialogs"]):
    if set(dialog) != {"character_id", "question", "answer"} or dialog["character_id"] not in allowed_ids:
        raise SystemExit(f"History3D publish blocked: invalid dialogs[{index}]")
for index, fact in enumerate(src["facts"]):
    if set(fact) != {"character_id", "fact"} or fact["character_id"] not in allowed_ids:
        raise SystemExit(f"History3D publish blocked: invalid facts[{index}]")
if set(src["screens"]) != {"left_image_url", "right_image_url", "left_label", "right_label"}:
    raise SystemExit("History3D publish blocked: screens contain unsupported fields")

def xchar(c):
    # Canonical History Explorer records already contain the full protected
    # scene entry. Keep every fixed field intact; retain a small fallback for
    # legacy lessons that only supplied the old character subset.
    return dict(c) if c.get("glbModel") else {
        "id": c.get("id", "char_1"), "name": c.get("name", ""),
        "position_x": c.get("position_x", 0), "position_y": c.get("position_y", 0.05),
        "position_z": c.get("position_z", 0), "rotation": c.get("rotation", 0),
        "color": c.get("color", ""), "robeColor": c.get("robeColor", ""),
        "description": c.get("description", c.get("role", "")),
        "glbModel": "/models/" + c.get("name", "Char").replace(" ", "") + ".glb"
    }

def xdialog(d):
    return {
        "character_id": d.get("character_id",""),
        "question": d.get("question", d.get("trigger", "")),
        "answer": d.get("answer", d.get("text", ""))
    }

def xfact(f, chars):
    if "character_id" in f and "fact" in f:
        return {"character_id": f["character_id"], "fact": f["fact"]}
    cid = chars[0]["id"] if chars else "char_1"
    txt = f.get("title", "") + ": " + f.get("content", "")
    if f.get("era"):
        txt += " (" + f["era"] + ")"
    return {"character_id": cid, "fact": txt}

def xscreens(s):
    return {
        "left_image_url":  s.get("left_image_url",""),
        "right_image_url": s.get("right_image_url",""),
        "left_label":  s.get("left_label", s.get("title","")),
        "right_label": s.get("right_label","")
    }

chars  = [xchar(c) for c in src.get("characters", [])]
result = {
    "characters": chars,
    "dialogs":    [xdialog(d) for d in src.get("dialogs", [])],
    "facts":      [xfact(f, chars) for f in src.get("facts", [])],
    "screens":    xscreens(src.get("screens", {})),
    "props":      src.get("props", [])
}
json.dump(result, open(os.path.join(out_dir, lesson_id+".json"), "w", encoding="utf-8"), indent=2, ensure_ascii=False)
print(f"  -> public/data/{lesson_id}.json (transformed)")

manifest_path = os.path.join(out_dir, "manifest.json")
try:
    manifest = json.load(open(manifest_path, "r", encoding="utf-8"))
except:
    manifest = {"scenarios": []}
if "scenarios" not in manifest:
    manifest["scenarios"] = []

entry = {"file": lesson_id+".json", "title": title,
         "description": f"Μάθημα: {title} ({today})", "thumbnail": ""}
existing = next((s for s in manifest["scenarios"] if s.get("file") == lesson_id+".json"), None)
if existing:
    manifest["scenarios"][manifest["scenarios"].index(existing)] = entry
else:
    manifest["scenarios"].append(entry)
    print(f"  + Added to manifest: {lesson_id}")

json.dump(manifest, open(manifest_path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
print("manifest.json written.")
