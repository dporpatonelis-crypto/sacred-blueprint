#!/usr/bin/env python3
import json, os, sys

case_id     = sys.argv[1]
title       = sys.argv[2]
lesson_type = sys.argv[3]
today       = sys.argv[4]

catalog_path = "/tmp/mind-palace-cases/catalog.json"
try:
    catalog = json.load(open(catalog_path, "r", encoding="utf-8"))
except:
    catalog = {"scenarios": []}
if "scenarios" not in catalog:
    catalog["scenarios"] = []

entry = {
    "id": case_id, "title": title, "type": lesson_type,
    "status": "complete", "scenarioFile": f"cases/{case_id}.json", "updatedAt": today
}
existing = next((s for s in catalog["scenarios"] if s["id"] == case_id), None)
if existing:
    catalog["scenarios"][catalog["scenarios"].index(existing)] = entry
    print(f"  ~ Updated: {case_id}")
else:
    catalog["scenarios"].append(entry)
    print(f"  + Added: {case_id}")

json.dump(catalog, open(catalog_path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
print("catalog.json written.")
