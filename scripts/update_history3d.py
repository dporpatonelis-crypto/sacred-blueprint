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

with open(src_path, "r", encoding="utf-8") as handle:
    src = json.load(handle)
with open(template_path, "r", encoding="utf-8") as handle:
    template = json.load(handle)

required_keys = {"characters", "dialogs", "facts", "screens", "props"}
optional_keys = {"interactive", "character_interactives", "completion", "quiz"}
missing_keys = required_keys - set(src)
unexpected_keys = set(src) - required_keys - optional_keys
if missing_keys:
    raise SystemExit(
        "History3D publish blocked: missing top-level keys: "
        + ", ".join(sorted(missing_keys))
    )
if unexpected_keys:
    raise SystemExit(
        "History3D publish blocked: unexpected top-level keys: "
        + ", ".join(sorted(unexpected_keys))
    )

if src.get("characters") != template.get("characters"):
    raise SystemExit("History3D publish blocked: characters/models differ from templates/history3d/default.json")
if src.get("props") != template.get("props"):
    raise SystemExit("History3D publish blocked: props differ from templates/history3d/default.json")

allowed_ids = {character["id"] for character in template["characters"]}
allowed_prop_ids = {prop["id"] for prop in template.get("props", [])}
if not isinstance(src["dialogs"], list) or not isinstance(src["facts"], list) or not isinstance(src["screens"], dict):
    raise SystemExit("History3D publish blocked: dialogs/facts/screens have the wrong types")
for index, dialog in enumerate(src["dialogs"]):
    if (
        set(dialog) != {"character_id", "question", "answer"}
        or dialog["character_id"] not in allowed_ids
        or not isinstance(dialog["question"], str)
        or not dialog["question"].strip()
        or not isinstance(dialog["answer"], str)
        or not dialog["answer"].strip()
    ):
        raise SystemExit(f"History3D publish blocked: invalid dialogs[{index}]")
for index, fact in enumerate(src["facts"]):
    if (
        set(fact) != {"character_id", "fact"}
        or fact["character_id"] not in allowed_ids
        or not isinstance(fact["fact"], str)
        or not fact["fact"].strip()
    ):
        raise SystemExit(f"History3D publish blocked: invalid facts[{index}]")
if set(src["screens"]) != {"left_image_url", "right_image_url", "left_label", "right_label"}:
    raise SystemExit("History3D publish blocked: screens contain unsupported fields")

def nonempty_string(value):
    return isinstance(value, str) and bool(value.strip())

def valid_media_url(value):
    return nonempty_string(value) and value.strip().startswith(("http://", "https://", "/"))

def validate_interactive(media, path):
    if not isinstance(media, dict):
        raise SystemExit(f"History3D publish blocked: {path} must be an object")
    unexpected = set(media) - {"video_url", "target_screen", "label"}
    if unexpected or not valid_media_url(media.get("video_url")):
        raise SystemExit(f"History3D publish blocked: invalid {path}")
    if "target_screen" in media and media["target_screen"] not in {"left", "right"}:
        raise SystemExit(f"History3D publish blocked: invalid {path}.target_screen")
    if "label" in media and not isinstance(media["label"], str):
        raise SystemExit(f"History3D publish blocked: invalid {path}.label")

if "interactive" in src:
    validate_interactive(src["interactive"], "interactive")

if "character_interactives" in src:
    character_interactives = src["character_interactives"]
    if not isinstance(character_interactives, dict):
        raise SystemExit("History3D publish blocked: character_interactives must be an object")
    for character_id, media in character_interactives.items():
        if character_id not in allowed_ids:
            raise SystemExit(
                f"History3D publish blocked: unknown character_interactives id: {character_id}"
            )
        validate_interactive(media, f"character_interactives[{character_id!r}]")

if "completion" in src:
    completion = src["completion"]
    if not isinstance(completion, dict) or set(completion) - {
        "required_character_ids",
        "reward_interactive",
    }:
        raise SystemExit("History3D publish blocked: invalid completion fields")
    required_ids = completion.get("required_character_ids")
    if (
        not isinstance(required_ids, list)
        or not required_ids
        or any(character_id not in allowed_ids for character_id in required_ids)
    ):
        raise SystemExit("History3D publish blocked: invalid completion.required_character_ids")
    if "reward_interactive" in completion:
        validate_interactive(
            completion["reward_interactive"],
            "completion.reward_interactive",
        )

if "quiz" in src:
    quiz = src["quiz"]
    if not isinstance(quiz, dict):
        raise SystemExit("History3D publish blocked: quiz must be an object")
    questions = quiz.get("questions")
    if (
        not nonempty_string(quiz.get("id"))
        or not nonempty_string(quiz.get("host_prop_id"))
        or quiz["host_prop_id"] not in allowed_prop_ids
        or not nonempty_string(quiz.get("reward_text"))
        or not isinstance(questions, list)
        or not questions
    ):
        raise SystemExit("History3D publish blocked: invalid quiz")
    pass_score = quiz.get("pass_score")
    if (
        isinstance(pass_score, bool)
        or not isinstance(pass_score, int)
        or not 1 <= pass_score <= len(questions)
    ):
        raise SystemExit("History3D publish blocked: invalid quiz.pass_score")
    if "reward_audio_url" in quiz and not valid_media_url(quiz["reward_audio_url"]):
        raise SystemExit("History3D publish blocked: invalid quiz.reward_audio_url")
    if "reward_interactive" in quiz:
        validate_interactive(quiz["reward_interactive"], "quiz.reward_interactive")
    for index, question in enumerate(questions):
        if not isinstance(question, dict):
            raise SystemExit(f"History3D publish blocked: invalid quiz.questions[{index}]")
        options = question.get("options")
        correct_index = question.get("correct_index")
        if (
            not nonempty_string(question.get("id"))
            or not nonempty_string(question.get("prompt"))
            or not isinstance(options, list)
            or len(options) < 2
            or any(not nonempty_string(option) for option in options)
            or isinstance(correct_index, bool)
            or not isinstance(correct_index, int)
            or not 0 <= correct_index < len(options)
        ):
            raise SystemExit(f"History3D publish blocked: invalid quiz.questions[{index}]")
        if "audio_url" in question and not valid_media_url(question["audio_url"]):
            raise SystemExit(
                f"History3D publish blocked: invalid quiz.questions[{index}].audio_url"
            )

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
}
for key in ("interactive", "character_interactives", "completion", "quiz"):
    if key in src:
        result[key] = src[key]
result["props"] = src.get("props", [])

with open(os.path.join(out_dir, lesson_id+".json"), "w", encoding="utf-8") as handle:
    json.dump(result, handle, indent=2, ensure_ascii=False)
    handle.write("\n")
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

with open(manifest_path, "w", encoding="utf-8") as handle:
    json.dump(manifest, handle, indent=2, ensure_ascii=False)
    handle.write("\n")
print("manifest.json written.")
