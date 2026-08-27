#!/usr/bin/env python3
"""Validate canonical Light Up Legacy lesson JSON (plus legacy snapshots)."""

from __future__ import annotations

import sys
from pathlib import Path

from build_sculpture_from_template import (
    CATEGORIES,
    REGIONS,
    REGION_LABELS,
    doc_score,
    ensure_template,
    fail,
    load_json,
)


CANONICAL_TEMPLATE_KEYS = {"id", "type", "title"}
CANONICAL_INSTANCE_KEYS = {"lesson_id", "interaction", "default_focus", "title"}
CANONICAL_REGION_KEYS = {"title", "concept", "prompt"}
CANONICAL_CONTRIBUTION_KEYS = {"id", "region", "label", "prompt"}


def require_non_empty_string(value: object, field: str) -> None:
    if not isinstance(value, str) or not value.strip():
        fail(f"{field} must be a non-empty string")


def is_canonical_lesson(payload: object) -> bool:
    if not isinstance(payload, dict):
        return False
    definition = payload.get("template")
    return isinstance(definition, dict) and set(definition) == CANONICAL_TEMPLATE_KEYS


def validate_canonical_lesson(payload: dict) -> None:
    expected_top_level = {"template", "instance", "regions", "contributions", "assets"}
    if set(payload) != expected_top_level:
        fail("canonical lesson must contain only template, instance, regions, contributions and assets")

    definition = payload["template"]
    if not isinstance(definition, dict) or set(definition) != CANONICAL_TEMPLATE_KEYS:
        fail("template must contain exactly id, type and title")
    for key in ("id", "type", "title"):
        require_non_empty_string(definition.get(key), f"template.{key}")

    instance = payload["instance"]
    if not isinstance(instance, dict) or set(instance) != CANONICAL_INSTANCE_KEYS:
        fail("instance must contain exactly lesson_id, interaction, default_focus and title")
    for key in ("lesson_id", "interaction", "default_focus", "title"):
        require_non_empty_string(instance.get(key), f"instance.{key}")

    regions = payload["regions"]
    if not isinstance(regions, dict) or len(regions) < 3:
        fail("regions must be an object with at least three semantic regions")
    for key, region in regions.items():
        require_non_empty_string(key, "regions key")
        if not isinstance(region, dict) or set(region) != CANONICAL_REGION_KEYS:
            fail(f"regions.{key} must contain exactly title, concept and prompt")
        for field in ("title", "concept", "prompt"):
            require_non_empty_string(region.get(field), f"regions.{key}.{field}")

    contributions = payload["contributions"]
    if not isinstance(contributions, list) or len(contributions) < 3:
        fail("contributions must be an array with at least three entries")
    contribution_ids = set()
    for index, item in enumerate(contributions):
        if not isinstance(item, dict) or set(item) != CANONICAL_CONTRIBUTION_KEYS:
            fail(f"contributions[{index}] must contain exactly id, region, label and prompt")
        for field in ("id", "region", "label", "prompt"):
            require_non_empty_string(item.get(field), f"contributions[{index}].{field}")
        if item["id"] in contribution_ids:
            fail(f"contributions[{index}].id is duplicated")
        contribution_ids.add(item["id"])
        if item["region"] not in regions:
            fail(f"contributions[{index}].region references an unknown semantic region")

    if payload["assets"] != []:
        fail("assets must remain []; models are fixed in the local Light Up Legacy app")


def validate_legacy_snapshot(template: dict, payload: dict) -> None:
    ensure_template(template)
    if not isinstance(payload, dict) or set(payload) != {"template", "instance", "regions", "contributions", "assets"}:
        fail("snapshot must contain only template, instance, regions, contributions and assets")
    if payload["template"] != template["template"]:
        fail("template definition is protected")
    if payload["instance"] != template["instance"]:
        fail("instance metadata is protected")
    if payload["assets"] != []:
        fail("assets must remain []")

    contributions = payload["contributions"]
    if not isinstance(contributions, list):
        fail("contributions must be an array")
    derived = {
        key: {
            "name": REGION_LABELS[key][0],
            "contributions": 0,
            "docStrength": 0,
            "category": None,
            "label": REGION_LABELS[key][1],
        }
        for key in REGIONS
    }
    for index, item in enumerate(contributions):
        if not isinstance(item, dict) or set(item) != {"id", "region", "text", "source", "category", "docScore", "timestamp"}:
            fail(f"contributions[{index}] has an unexpected shape")
        if item["region"] not in REGIONS or item["category"] not in CATEGORIES:
            fail(f"contributions[{index}] has an invalid region/category")
        if not isinstance(item["text"], str) or not item["text"].strip() or not isinstance(item["source"], str):
            fail(f"contributions[{index}] text/source is invalid")
        expected_score = doc_score(item["source"])
        if item["docScore"] != expected_score:
            fail(f"contributions[{index}].docScore does not match the app formula")
        region = derived[item["region"]]
        region["contributions"] += 1
        region["docStrength"] = round(region["docStrength"] + expected_score, 10)
        region["category"] = item["category"]
    if payload["regions"] != derived:
        fail("regions must be derived from contributions and keep fixed names/labels")


def validate(template: dict, payload: dict) -> str:
    if is_canonical_lesson(payload):
        validate_canonical_lesson(payload)
        return "canonical lesson"
    validate_legacy_snapshot(template, payload)
    return "legacy snapshot"


def main() -> None:
    if len(sys.argv) != 3:
        fail("usage: validate_sculpture.py TEMPLATE SNAPSHOT")

    template_path, payload_path = map(Path, sys.argv[1:])
    template = load_json(template_path)
    payload = load_json(payload_path)
    contract = validate(template, payload)
    print(f"Valid: {payload_path} ({contract}, {len(payload['contributions'])} contributions)")


if __name__ == "__main__":
    main()
