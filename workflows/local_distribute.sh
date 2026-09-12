#!/bin/bash
# ============================================================
# local_distribute.sh — Τοπική διανομή σε app φακέλους
# Χρήση: bash workflows/local_distribute.sh
#
# Αντιγράφει από data/current/ στους τοπικούς φακέλους
# των εφαρμογών. Δεν χρειάζεται internet.
# ============================================================

set -e

BASE="$(pwd)"
CURRENT="$BASE/data/current"
APPS_DIR="$HOME/apps"   # ← άλλαξε αν οι εφαρμογές είναι αλλού

# Χρώματα για output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
SKIP='\033[0;90m'
NC='\033[0m'

ok()   { echo -e "${GREEN}  ✅ $1${NC}"; }
skip() { echo -e "${SKIP}  ⏭  $1${NC}"; }
warn() { echo -e "${YELLOW}  ⚠  $1${NC}"; }

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Sacred Blueprint — Local Distribute   ║"
echo "╚══════════════════════════════════════════╝"
echo ""

if [ ! -f "$CURRENT/active_lesson.json" ]; then
  echo "✗ data/current/active_lesson.json δεν βρέθηκε."
  echo "  Τρέξε πρώτα: bash workflows/distribute.sh lessons/ΦΑΚΕΛΟΣ/"
  exit 1
fi

LESSON_ID=$(jq -r '.lesson_id // "lesson"' "$CURRENT/active_lesson.json" 2>/dev/null || echo "lesson")
TITLE=$(jq -r '.title // "Μάθημα"' "$CURRENT/active_lesson.json" 2>/dev/null || echo "Μάθημα")
TODAY=$(date +%Y-%m-%d)

echo "📚 Μάθημα : $TITLE"
echo "🔑 ID     : $LESSON_ID"
echo ""

# ── 1. Timeline → Map-Timeline ───────────────────────────────
DEST="$APPS_DIR/Map-Timeline"
if [ -f "$CURRENT/timeline.json" ]; then
  if [ -d "$DEST" ]; then
    mkdir -p "$DEST/data"
    cp "$CURRENT/timeline.json"      "$DEST/data/${LESSON_ID}.json"
    cp "$CURRENT/active_lesson.json" "$DEST/active_lesson.json"
    # Ενημέρωση catalog.json
    python3 - "$LESSON_ID" "$TITLE" "$TODAY" "$DEST/catalog.json" << 'PYEOF'
import json, sys
lesson_id, title, today, path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
try:
    cat = json.load(open(path, "r", encoding="utf-8"))
except:
    cat = {"scenarios": []}
cat.setdefault("scenarios", [])
entry = {"id": lesson_id, "title": title, "type": "timeline",
         "status": "complete", "dataFile": f"data/{lesson_id}.json", "updatedAt": today}
ex = next((s for s in cat["scenarios"] if s["id"] == lesson_id), None)
if ex:
    cat["scenarios"][cat["scenarios"].index(ex)] = entry
else:
    cat["scenarios"].append(entry)
json.dump(cat, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
print(f"catalog.json: {lesson_id}")
PYEOF
    ok "Map-Timeline → data/${LESSON_ID}.json + catalog.json"
  else
    skip "Map-Timeline: φάκελος δεν βρέθηκε ($DEST)"
  fi
else
  skip "timeline.json: δεν υπάρχει στο data/current/"
fi

# ── 2. Investigation → idea-weaver-board ─────────────────────
DEST="$APPS_DIR/idea-weaver-board"
if [ -f "$CURRENT/investigation.json" ]; then
  if [ -d "$DEST" ]; then
    mkdir -p "$DEST/src/data/library"
    cp "$CURRENT/investigation.json" "$DEST/src/data/library/${LESSON_ID}.json"
    ok "idea-weaver-board → src/data/library/${LESSON_ID}.json"
  else
    skip "idea-weaver-board: φάκελος δεν βρέθηκε ($DEST)"
  fi
else
  skip "investigation.json: δεν υπάρχει στο data/current/"
fi

# ── 3. History 3D → history-explorer-3d ─────────────────────
DEST="$APPS_DIR/history-explorer-3d"
if [ -f "$CURRENT/history3d.json" ]; then
  if [ -d "$DEST" ]; then
    # Use the same lossless validator/publisher as the GitHub Action.
    python3 "$BASE/scripts/update_history3d.py" \
      "$LESSON_ID" "$TITLE" "$TODAY" \
      "$CURRENT/history3d.json" "$DEST/public/data" \
      "$BASE/templates/history3d/default.json"
    ok "history-explorer-3d → public/data/${LESSON_ID}.json (validated, lossless) + manifest.json"
  else
    skip "history-explorer-3d: φάκελος δεν βρέθηκε ($DEST)"
  fi
else
  skip "history3d.json: δεν υπάρχει στο data/current/"
fi

# ── 4. Mind Palace → mind-palace-cases ───────────────────────
DEST="$APPS_DIR/mind-palace-cases"
if [ -f "$CURRENT/mindpalace.json" ]; then
  if [ -d "$DEST" ]; then
    CASE_ID=$(jq -r '.case_id // "'$LESSON_ID'"' "$CURRENT/mindpalace.json" 2>/dev/null || echo "$LESSON_ID")
    CASE_TITLE=$(jq -r '.title // "'$TITLE'"' "$CURRENT/mindpalace.json" 2>/dev/null || echo "$TITLE")
    LESSON_TYPE=$(jq -r '.method // "theological_concept"' "$CURRENT/mindpalace.json" 2>/dev/null || echo "theological_concept")
    mkdir -p "$DEST/cases"
    cp "$CURRENT/mindpalace.json"    "$DEST/cases/${CASE_ID}.json"
    cp "$CURRENT/active_lesson.json" "$DEST/active_lesson.json"
    python3 - "$CASE_ID" "$CASE_TITLE" "$LESSON_TYPE" "$TODAY" "$DEST/catalog.json" << 'PYEOF'
import json, sys
case_id, title, ltype, today, path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
try:
    cat = json.load(open(path, "r", encoding="utf-8"))
except:
    cat = {"scenarios": []}
cat.setdefault("scenarios", [])
entry = {"id": case_id, "title": title, "type": ltype,
         "status": "complete", "scenarioFile": f"cases/{case_id}.json", "updatedAt": today}
ex = next((s for s in cat["scenarios"] if s["id"] == case_id), None)
if ex:
    cat["scenarios"][cat["scenarios"].index(ex)] = entry
else:
    cat["scenarios"].append(entry)
json.dump(cat, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
print(f"catalog.json: {case_id}")
PYEOF
    ok "mind-palace-cases → cases/${CASE_ID}.json + catalog.json"
  else
    skip "mind-palace-cases: φάκελος δεν βρέθηκε ($DEST)"
  fi
else
  skip "mindpalace.json: δεν υπάρχει στο data/current/"
fi

# ── 5. Personal Page → personal-page ─────────────────────────
DEST="$APPS_DIR/personal-page"
if [ -f "$CURRENT/personalpage.json" ] || [ -f "$CURRENT/notebook.json" ]; then
  if [ -d "$DEST" ]; then
    mkdir -p "$DEST/public/data/lessons"
    if [ -f "$CURRENT/personalpage.json" ]; then
      SOURCE="$CURRENT/personalpage.json"
    else
      SOURCE="$CURRENT/notebook.json"
    fi
    cp "$SOURCE" "$DEST/public/data/lessons/${LESSON_ID}.json"
    python3 - "$LESSON_ID" "$DEST/public/data/lessons/index.json" << 'PYEOF'
import json, sys
lesson_id, path = sys.argv[1], sys.argv[2]
lesson_file = lesson_id + ".json"
try:
    index = json.load(open(path, "r", encoding="utf-8"))
    if not isinstance(index, list): index = []
except:
    index = []
if lesson_file not in index:
    index.append(lesson_file)
json.dump(index, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
print(f"index.json: {lesson_file}")
PYEOF
    ok "personal-page → public/data/lessons/${LESSON_ID}.json + index.json"
  else
    skip "personal-page: φάκελος δεν βρέθηκε ($DEST)"
  fi
else
  skip "personalpage.json / notebook.json: δεν υπάρχουν στο data/current/"
fi

# ── Σύνοψη ───────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════"
echo "✅ Τοπική διανομή ολοκληρώθηκε"
echo "   Μάθημα: $TITLE"
echo "   Apps  : $APPS_DIR"
echo "══════════════════════════════════════════"
echo ""
