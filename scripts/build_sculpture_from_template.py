#!/usr/bin/env python3
"""Build the Interactive Sculpture snapshot from its protected template."""

from __future__ import annotations

import hashlib
import json
import sys
from copy import deepcopy
from pathlib import Path


REGIONS = ("base", "trunk", "arms", "head", "periphery", "core")
CATEGORIES = {"theological", "ethical", "historical", "philosophical"}
VISUAL_RULES = {
    "lighting": "intensity_per_contributions",
    "color": "category_mapping",
    "glow": "documentation_threshold",
    "inscriptions": "primary_source_text",
}
REGION_LABELS = {
    "base": ("Βάση", "Τα θεμέλια της έννοιας"),
    "trunk": ("Κορμός", "Το κύριο σώμα δεδομένων"),
    "arms": ("Χέρια", "Η δράση και η εφαρμογή"),
    "head": ("Κεφαλή", "Το ανώτερο νόημα (Θεολογία)"),
    "periphery": ("Περιφέρεια", "Το ιστορικό πλαίσιο"),
    "core": ("Εσωτ. Πυρήνας", "Η ουσία και η κινητήριος δύναμη"),
}


def fail(message: str):
    raise SystemExit(f"Interactive Sculpture template error: {message}")


def load_json(path: Path):
    try:
        with path.open(encoding="utf-8") as source:
            return json.load(source)
    except (OSError, json.JSONDecodeError) as error:
        fail(f"cannot read {path}: {error}")


def doc_score(source: str) -> float:
    """Exact formula used by public/game.html (short sources score 1)."""
    # JavaScript String.length counts UTF-16 code units, not Unicode code
    # points; matching it keeps Python builds identical for emoji/non-BMP text.
    js_length = len(source.encode("utf-16-le")) // 2
    return round(min(js_length / 10, 10), 10) if js_length > 5 else 1


def ensure_template(template: dict) -> None:
    if not isinstance(template, dict):
        fail("template must be an object")
    if set(template) != {"template", "instance", "regions", "contributions", "assets"}:
        fail("template must contain only template, instance, regions, contributions and assets")
    definition = template.get("template")
    if not isinstance(definition, dict) or set(definition) != {"version", "regions", "visualRules"}:
        fail("template.template has an unexpected shape")
    if definition.get("version") != "1.0" or definition.get("regions") != list(REGIONS):
        fail("the six region keys are protected")
    if definition.get("visualRules") != VISUAL_RULES:
        fail("template.visualRules are protected")
    instance = template.get("instance")
    if not isinstance(instance, dict) or set(instance) != {"class", "subject", "year", "createdAt"}:
        fail("template.instance must contain class, subject, year and createdAt")
    if not isinstance(template.get("assets"), list) or template["assets"]:
        fail("assets must be an empty array; 3D files are manual uploads")

    regions = template.get("regions")
    if not isinstance(regions, dict) or list(regions) != list(REGIONS):
        fail("template.regions must contain the six fixed region keys")
    for key in REGIONS:
        value = regions[key]
        if not isinstance(value, dict) or set(value) != {"name", "contributions", "docStrength", "category", "label"}:
            fail(f"region {key} has an unexpected shape")
        name, label = REGION_LABELS[key]
        if value["name"] != name or value["label"] != label:
            fail(f"region {key} name/label is protected")


def validate_overlay(content: dict) -> list[dict]:
    if not isinstance(content, dict) or set(content) != {"contributions"}:
        fail("content may change only contributions[]")
    contributions = content["contributions"]
    if not isinstance(contributions, list):
        fail("content.contributions must be an array")
    result = []
    for index, contribution in enumerate(contributions):
        if not isinstance(contribution, dict) or set(contribution) != {"region", "text", "source", "category"}:
            fail(f"contributions[{index}] must contain only region, text, source and category")
        region = contribution["region"]
        text = contribution["text"]
        source = contribution["source"]
        category = contribution["category"]
        if region not in REGIONS:
            fail(f"contributions[{index}] references unknown region {region!r}")
        if not isinstance(text, str) or not text.strip():
            fail(f"contributions[{index}].text must be a non-empty string")
        if not isinstance(source, str):
            fail(f"contributions[{index}].source must be a string")
        if category not in CATEGORIES:
            fail(f"contributions[{index}].category must be one of {sorted(CATEGORIES)}")
        result.append({"region": region, "text": text, "source": source, "category": category})
    return result


def stable_id(contribution: dict) -> int:
    raw = "|".join(contribution[field] for field in ("region", "text", "source", "category"))
    return int(hashlib.sha256(raw.encode("utf-8")).hexdigest()[:12], 16)


def build(template: dict, overlay: list[dict]) -> dict:
    result = deepcopy(template)
    original = template.get("contributions", [])
    if not isinstance(original, list):
        fail("template.contributions must be an array")
    original_by_content = {
        tuple(item.get(field) for field in ("region", "text", "source", "category")): item
        for item in original
        if isinstance(item, dict)
    }
    fallback_timestamp = result["instance"].get("createdAt")
    built = []
    for index, contribution in enumerate(overlay):
        key = tuple(contribution[field] for field in ("region", "text", "source", "category"))
        previous = original_by_content.get(key)
        if previous is None and index < len(original) and isinstance(original[index], dict):
            previous = original[index]
        built.append({
            "id": previous.get("id") if previous and isinstance(previous.get("id"), (int, float)) else stable_id(contribution),
            **contribution,
            "docScore": doc_score(contribution["source"]),
            "timestamp": previous.get("timestamp", fallback_timestamp) if previous else fallback_timestamp,
        })

    regions = {}
    for key in REGIONS:
        fixed = result["regions"][key]
        contributions = [item for item in built if item["region"] == key]
        regions[key] = {
            "name": fixed["name"],
            "contributions": len(contributions),
            "docStrength": round(sum(item["docScore"] for item in contributions), 10),
            "category": contributions[-1]["category"] if contributions else None,
            "label": fixed["label"],
        }
    result["regions"] = regions
    result["contributions"] = built
    result["assets"] = []
    return result


def main() -> None:
    if len(sys.argv) != 4:
        fail("usage: build_sculpture_from_template.py TEMPLATE CONTENT OUTPUT")

    template_path, content_path, output_path = map(Path, sys.argv[1:])
    template = load_json(template_path)
    content = load_json(content_path)
    ensure_template(template)
    overlay = validate_overlay(content)
    output = build(template, overlay)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8") as destination:
        json.dump(output, destination, ensure_ascii=False, indent=2)
        destination.write("\n")

    print(f"Written: {output_path} ({len(overlay)} contributions)")


if __name__ == "__main__":
    main()
