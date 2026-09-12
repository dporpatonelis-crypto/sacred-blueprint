#!/usr/bin/env python3
"""Build a History Explorer 3D payload without altering the protected scene."""

import json
import sys
from pathlib import Path

from history3d_contract import build_scenario, load_json, write_json


if len(sys.argv) != 4:
    raise SystemExit(
        "usage: build_history3d_from_template.py TEMPLATE CONTENT OUTPUT"
    )

template_path, content_path, output_path = map(Path, sys.argv[1:])

try:
    template = load_json(template_path)
    content = load_json(content_path)
    result = build_scenario(template, content)
except (OSError, json.JSONDecodeError, ValueError) as error:
    raise SystemExit(f"History3D template error: {error}") from error

write_json(output_path, result)
print(f"Written: {output_path}")
