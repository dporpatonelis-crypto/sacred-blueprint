#!/bin/bash
# ============================================================
# distribute.sh — Διαβάζει το master_output.json
# και βγάζει outputs για ΟΛΑ τα κλειδιά που υπάρχουν.
# Γράφει:
#   1. lessons/<ΦΑΚΕΛΟΣ>/<key>_output.json  (βιβλιοθήκη)
#   2. data/current/<key>.json              (ενεργό μάθημα → GitHub Action)
# Χρήση: bash workflows/distribute.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/
# ============================================================

set -e

LESSON_DIR="${1:?Χρήση: bash workflows/distribute.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/}"
BASE="$(pwd)"
MASTER="$LESSON_DIR/master_output.json"
CURRENT="$BASE/data/current"
mkdir -p "$BASE/logs"
LOG="$BASE/logs/distribute_$(date +%Y%m%d_%H%M%S).log"

# ── Έλεγχοι ──────────────────────────────────────────────
if ! command -v jq &>/dev/null; then
  echo "✗ jq δεν βρέθηκε — brew install jq"
  exit 1
fi

if [ ! -f "$MASTER" ]; then
  echo "✗ master_output.json δεν βρέθηκε: $MASTER"
  exit 1
fi

mkdir -p "$CURRENT"
mkdir -p "$CURRENT/ue5"

TOPIC=$(jq -r '.title' "$MASTER" 2>/dev/null || echo "Untitled")
LESSON_ID=$(basename "$LESSON_DIR")

echo "╔══════════════════════════════════════╗" | tee "$LOG"
echo "║   Sacred Blueprint — Distribute     ║" | tee -a "$LOG"
echo "╚══════════════════════════════════════╝" | tee -a "$LOG"
echo "Θέμα:     $TOPIC" | tee -a "$LOG"
echo "Φάκελος:  $LESSON_DIR" | tee -a "$LOG"
echo "" | tee -a "$LOG"

# ── Κλειδιά που εξαιρούνται από εξαγωγή ─────────────────
EXCLUDED_KEYS="_comment|_version|title|subtitle|description|date|era|location|coordinates|media_enrichment_audit"

KEYS=$(jq -r 'keys[]' "$MASTER" 2>/dev/null | grep -vE "^($EXCLUDED_KEYS)$")

if [ -z "$KEYS" ]; then
  echo "⚠ Δεν βρέθηκαν κλειδιά εφαρμογών στο master_output.json" | tee -a "$LOG"
  echo "  → Αναμενόμενα: timeline_item, investigation_board, notebook, κ.λπ." | tee -a "$LOG"
  exit 1
fi

echo "Βρέθηκαν κλειδιά:" | tee -a "$LOG"
echo "$KEYS" | sed 's/^/  - /' | tee -a "$LOG"
echo "" | tee -a "$LOG"

# ── Εξαγωγή για κάθε κλειδί ─────────────────────────────
SUCCESS=0
TOTAL=0

for KEY in $KEYS; do
  TOTAL=$((TOTAL + 1))

  SECTION=$(jq ".\"$KEY\"" "$MASTER" 2>/dev/null)

  if [ -z "$SECTION" ] || [ "$SECTION" = "null" ]; then
    echo "  ⚠ Το κλειδί '$KEY' είναι κενό — παραλείπεται" | tee -a "$LOG"
    continue
  fi

  # 1. Βιβλιοθήκη: μέσα στον φάκελο του μαθήματος
  echo "$SECTION" > "$LESSON_DIR/${KEY}_output.json"

  # 2. data/current/: αντιστοίχιση master key → app file
  # Ονόματα συγχρονισμένα με το orchestrator APPS array
  if [ "$KEY" = "unreal_scenario" ]; then
    SCENARIO_ID=$(echo "$SECTION" | jq -r '.id // "scenario"' 2>/dev/null)
    mkdir -p "$CURRENT/ue5/$SCENARIO_ID"
    echo "$SECTION" > "$CURRENT/ue5/$SCENARIO_ID/scenario.json"
    ASSETS=$(jq '.unreal_assets // {}' "$MASTER" 2>/dev/null)
    echo "$ASSETS" > "$CURRENT/ue5/$SCENARIO_ID/assets.json"
    MANIFEST=$(jq '.unreal_manifest // {}' "$MASTER" 2>/dev/null)
    echo "$MANIFEST" > "$CURRENT/ue5/$SCENARIO_ID/manifest_entry.json"
    echo "  ✓ unreal_scenario  →  data/current/ue5/$SCENARIO_ID/ (3 αρχεία)" | tee -a "$LOG"
  else
    # master_output key   → data/current/ filename
    # (orchestrator app id στο σχόλιο για αναφορά)
    case "$KEY" in
      timeline_item)       CURRENT_FILE="timeline.json"     ;;  # id: timeline
      investigation_board) CURRENT_FILE="investigation.json" ;; # id: investigation
      history3d)           CURRENT_FILE="history3d.json"    ;;  # id: history3d
      mind_palace)         CURRENT_FILE="mindpalace.json"   ;;  # id: mindpalace
      anchor)              CURRENT_FILE="anchor.json"       ;;  # id: anchor
      books)               CURRENT_FILE="books.json"        ;;  # id: books
      notebook)            CURRENT_FILE="notebook.json"     ;;  # id: notebook
      personal_page)       CURRENT_FILE="personalpage.json" ;;  # id: personalpage
      media)               CURRENT_FILE="media.json"        ;;
      *)                   CURRENT_FILE="${KEY}.json"        ;;
    esac

    echo "$SECTION" > "$CURRENT/$CURRENT_FILE"
    echo "  ✓ ${KEY}_output.json  →  data/current/$CURRENT_FILE" | tee -a "$LOG"
  fi

  SUCCESS=$((SUCCESS + 1))
done

# ── active_lesson.json ────────────────────────────────────
cat > "$CURRENT/active_lesson.json" << EOF
{
  "lesson_id":  "$LESSON_ID",
  "title":      "$TOPIC",
  "source":     "$LESSON_DIR/master_output.json",
  "activated":  "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
echo "" | tee -a "$LOG"
echo "  ✓ active_lesson.json → $LESSON_ID" | tee -a "$LOG"

# ── Σύνοψη ───────────────────────────────────────────────
echo "" | tee -a "$LOG"
echo "══════════════════════════════════════════" | tee -a "$LOG"
echo "✓ Βιβλιοθήκη:  $SUCCESS/$TOTAL κλειδιά → $LESSON_DIR" | tee -a "$LOG"
echo "✓ Ενεργό:      $SUCCESS/$TOTAL αρχεία  → data/current/" | tee -a "$LOG"
echo "Log: $LOG" | tee -a "$LOG"
