#!/usr/bin/env python3
import json, os, sys

lesson_id  = sys.argv[1]
index_path = os.environ.get("INDEX_PATH", "/tmp/personal-page/public/data/lessons/index.json")
lesson_file = lesson_id + ".json"

os.makedirs(os.path.dirname(index_path), exist_ok=True)

try:
    index = json.load(open(index_path, "r", encoding="utf-8"))
    if not isinstance(index, list):
        index = []
except:
    index = []

if lesson_file not in index:
    index.append(lesson_file)
    print(f"  + Added to index: {lesson_file}")
else:
    print(f"  ~ Already in index: {lesson_file}")

json.dump(index, open(index_path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
print("index.json written.")
