#!/bin/bash
# ============================================================
# cleanup_catalog.sh — Αφαιρεί orphan entries από
# catalog.json / manifest.json / index.json
# σε όλους τους τοπικούς φακέλους εφαρμογών.
#
# Χρήση: bash workflows/cleanup_catalog.sh
# ============================================================

APPS_DIR="$HOME/apps"   # ← άλλαξε αν χρειάζεται

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
SKIP='\033[0;90m'
NC='\033[0m'

ok()   { echo -e "${GREEN}  ✅ $1${NC}"; }
skip() { echo -e "${SKIP}  ⏭  $1${NC}"; }
warn() { echo -e "${YELLOW}  ⚠  $1${NC}"; }

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Cleanup: Orphan entries σε catalogs   ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── 1. Map-Timeline → catalog.json ───────────────────────────
echo "🗺️  Map-Timeline"
CATALOG="$APPS_DIR/Map-Timeline/catalog.json"
DATA_DIR="$APPS_DIR/Map-Timeline/data"

if [ -f "$CATALOG" ]; then
  python3 - "$CATALOG" "$DATA_DIR" << 'PYEOF'
import json, os, sys

catalog_path = sys.argv[1]
data_dir     = sys.argv[2]

catalog = json.load(open(catalog_path, "r", encoding="utf-8"))
before  = len(catalog.get("scenarios", []))
kept    = []

for s in catalog.get("scenarios", []):
    file_path = os.path.join(data_dir, s.get("id","") + ".json")
    if not s.get("dataFile"):
        file_path = os.path.join(data_dir, os.path.basename(s.get("dataFile", s["id"]+".json")))
    if os.path.exists(file_path):
        kept.append(s)
    else:
        print(f"  ✗ Orphan removed: {s.get('id')} → {file_path}")

catalog["scenarios"] = kept
json.dump(catalog, open(catalog_path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
removed = before - len(kept)
print(f"  Entries: {before} → {len(kept)} ({removed} αφαιρέθηκαν)")
PYEOF
  ok "catalog.json ελέγχθηκε"
else
  skip "catalog.json δεν βρέθηκε ($CATALOG)"
fi
echo ""

# ── 2. mind-palace-cases → catalog.json ──────────────────────
echo "🧠  mind-palace-cases"
CATALOG="$APPS_DIR/mind-palace-cases/catalog.json"
CASES_DIR="$APPS_DIR/mind-palace-cases/cases"

if [ -f "$CATALOG" ]; then
  python3 - "$CATALOG" "$CASES_DIR" << 'PYEOF'
import json, os, sys

catalog_path = sys.argv[1]
cases_dir    = sys.argv[2]

catalog = json.load(open(catalog_path, "r", encoding="utf-8"))
before  = len(catalog.get("scenarios", []))
kept    = []

for s in catalog.get("scenarios", []):
    scenario_file = s.get("scenarioFile", f"cases/{s.get('id','')}.json")
    file_path = os.path.join(os.path.dirname(catalog_path), scenario_file)
    if os.path.exists(file_path):
        kept.append(s)
    else:
        print(f"  ✗ Orphan removed: {s.get('id')} → {file_path}")

catalog["scenarios"] = kept
json.dump(catalog, open(catalog_path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
removed = before - len(kept)
print(f"  Entries: {before} → {len(kept)} ({removed} αφαιρέθηκαν)")
PYEOF
  ok "catalog.json ελέγχθηκε"
else
  skip "catalog.json δεν βρέθηκε ($CATALOG)"
fi
echo ""

# ── 3. history-explorer-3d → manifest.json ───────────────────
echo "🏛️  history-explorer-3d"
MANIFEST="$APPS_DIR/history-explorer-3d/public/data/manifest.json"
DATA_DIR="$APPS_DIR/history-explorer-3d/public/data"

if [ -f "$MANIFEST" ]; then
  python3 - "$MANIFEST" "$DATA_DIR" << 'PYEOF'
import json, os, sys

manifest_path = sys.argv[1]
data_dir      = sys.argv[2]

manifest = json.load(open(manifest_path, "r", encoding="utf-8"))
before   = len(manifest.get("scenarios", []))
kept     = []

for s in manifest.get("scenarios", []):
    file_path = os.path.join(data_dir, s.get("file",""))
    if os.path.exists(file_path):
        kept.append(s)
    else:
        print(f"  ✗ Orphan removed: {s.get('file')} → {file_path}")

manifest["scenarios"] = kept
json.dump(manifest, open(manifest_path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
removed = before - len(kept)
print(f"  Entries: {before} → {len(kept)} ({removed} αφαιρέθηκαν)")
PYEOF
  ok "manifest.json ελέγχθηκε"
else
  skip "manifest.json δεν βρέθηκε ($MANIFEST)"
fi
echo ""

# ── 4. personal-page → index.json ────────────────────────────
echo "🌐  personal-page"
INDEX="$APPS_DIR/personal-page/public/data/lessons/index.json"
LESSONS_DIR="$APPS_DIR/personal-page/public/data/lessons"

if [ -f "$INDEX" ]; then
  python3 - "$INDEX" "$LESSONS_DIR" << 'PYEOF'
import json, os, sys

index_path  = sys.argv[1]
lessons_dir = sys.argv[2]

index  = json.load(open(index_path, "r", encoding="utf-8"))
before = len(index)
kept   = []

for filename in index:
    file_path = os.path.join(lessons_dir, filename)
    if os.path.exists(file_path):
        kept.append(filename)
    else:
        print(f"  ✗ Orphan removed: {filename} → {file_path}")

json.dump(kept, open(index_path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
removed = before - len(kept)
print(f"  Entries: {before} → {len(kept)} ({removed} αφαιρέθηκαν)")
PYEOF
  ok "index.json ελέγχθηκε"
else
  skip "index.json δεν βρέθηκε ($INDEX)"
fi
echo ""

echo "══════════════════════════════════════════"
echo "✅ Cleanup ολοκληρώθηκε"
echo "   Επόμενο βήμα αν θες να ανεβάσεις:"
echo "   bash workflows/sync_apps_to_github.sh"
echo "══════════════════════════════════════════"
echo ""
