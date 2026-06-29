#!/usr/bin/env python3
import json, os, sys

lesson_id = sys.argv[1]
title     = sys.argv[2]
today     = sys.argv[3]

catalog_path = "/tmp/Map-Timeline/catalog.json"
try:
    catalog = json.load(open(catalog_path, "r", encoding="utf-8"))
except:
    catalog = {"scenarios": []}
if "scenarios" not in catalog:
    catalog["scenarios"] = []

entry = {
    "id": lesson_id, "title": title, "type": "timeline",
    "status": "complete", "dataFile": f"data/{lesson_id}.json", "updatedAt": today
}
existing = next((s for s in catalog["scenarios"] if s["id"] == lesson_id), None)
if existing:
    catalog["scenarios"][catalog["scenarios"].index(existing)] = entry
    print(f"  ~ Updated: {lesson_id}")
else:
    catalog["scenarios"].append(entry)
    print(f"  + Added: {lesson_id}")

json.dump(catalog, open(catalog_path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
print("catalog.json written.")
