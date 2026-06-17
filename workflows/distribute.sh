#!/bin/bash
# ============================================================
# distribute.sh — Διαβάζει το master_output.json
# και βγάζει outputs για ΟΛΑ τα κλειδιά που υπάρχουν
# Χρήση: bash workflows/distribute.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/
# ============================================================

set -e

LESSON_DIR="${1:?Χρήση: bash workflows/distribute.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/}"
BASE="$(pwd)"
MASTER="$LESSON_DIR/master_output.json"
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

TOPIC=$(jq -r '.title' "$MASTER" 2>/dev/null || echo "Untitled")

echo "╔══════════════════════════════════════╗" | tee "$LOG"
echo "║   Sacred Blueprint — Distribute     ║" | tee -a "$LOG"
echo "╚══════════════════════════════════════╝" | tee -a "$LOG"
echo "Θέμα: $TOPIC" | tee -a "$LOG"
echo "" | tee -a "$LOG"

# ── Λίστα κλειδιών που ΔΕΝ θέλουμε να εξάγουμε ──────────
EXCLUDED="title|subtitle|description|date|era|location|coordinates|_comment|_version"

# ── Διάβασμα όλων των κλειδιών ──────────────────────────
KEYS=$(jq -r "keys[]" "$MASTER" 2>/dev/null | grep -vE "^($EXCLUDED)$")

if [ -z "$KEYS" ]; then
  echo "⚠ Δεν βρέθηκαν κλειδιά εφαρμογών" | tee -a "$LOG"
  echo "  → Τα κλειδιά πρέπει να είναι: timeline_item, investigation_board, κ.λπ." | tee -a "$LOG"
  exit 1
fi

echo "Βρέθηκαν κλειδιά:" | tee -a "$LOG"
echo "$KEYS" | sed 's/^/  - /' | tee -a "$LOG"
echo "" | tee -a "$LOG"

# ── Εξαγωγή για κάθε κλειδί ────────────────────────────
SUCCESS=0
TOTAL=0

for KEY in $KEYS; do
  TOTAL=$((TOTAL + 1))
  
  SECTION=$(jq ".\"$KEY\"" "$MASTER" 2>/dev/null)

  if [ -z "$SECTION" ] || [ "$SECTION" = "null" ]; then
    echo "  ⚠ Το κλειδί '$KEY' είναι κενό" | tee -a "$LOG"
    continue
  fi

  OUTPUT_FILE="$LESSON_DIR/${KEY}_output.json"
  echo "$SECTION" > "$OUTPUT_FILE"
  echo "  ✓ ${KEY}_output.json" | tee -a "$LOG"
  SUCCESS=$((SUCCESS + 1))
done

# ── Σύνοψη ───────────────────────────────────────────────
echo "" | tee -a "$LOG"
echo "══════════════════════════════════════════" | tee -a "$LOG"
echo "✓ Τοπική Διανομή: $SUCCESS/$TOTAL κλειδιά" | tee -a "$LOG"
echo "Λεπτομέρειες: $LOG" | tee -a "$LOG"#!/bin/bash
# ============================================================
# distribute.sh — Διαβάζει το master_output.json και βγάζει outputs
# για ΟΛΑ τα κλειδιά που υπάρχουν (χωρίς routing.json)
# Χρήση: bash workflows/distribute.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/
# ============================================================

set -e

LESSON_DIR="${1:?Χρήση: bash workflows/distribute.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/}"
BASE="$(pwd)"
MASTER="$LESSON_DIR/master_output.json"
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

TOPIC=$(jq -r '.title' "$MASTER" 2>/dev/null || echo "Untitled")

echo "╔══════════════════════════════════════╗" | tee "$LOG"
echo "║   Sacred Blueprint — Distribute     ║" | tee -a "$LOG"
echo "╚══════════════════════════════════════╝" | tee -a "$LOG"
echo "Θέμα: $TOPIC" | tee -a "$LOG"
echo "" | tee -a "$LOG"

# ── Διάβασμα όλων των κλειδιών κορυφαίου επιπέδου ──────
# Εξαιρούμε τα "_comment", "_version" και βασικά πεδία (title, subtitle, κ.λπ.)
EXCLUDED_KEYS='"_comment"|"_version"|"title"|"subtitle"|"description"|"date"|"era"|"location"|"coordinates"'

KEYS=$(jq -r "keys[] | select(. | test(\"$EXCLUDED_KEYS\") | not)" "$MASTER" 2>/dev/null)

if [ -z "$KEYS" ]; then
  echo "⚠ Δεν βρέθηκαν κλειδιά εφαρμογών στο master_output.json" | tee -a "$LOG"
  echo "  → Τα κλειδιά πρέπει να είναι: timeline_item, investigation_board, notebook, κ.λπ." | tee -a "$LOG"
  exit 1
fi

echo "Βρέθηκαν κλειδιά:" | tee -a "$LOG"
echo "$KEYS" | sed 's/^/  - /' | tee -a "$LOG"
echo "" | tee -a "$LOG"

# ── Εξαγωγή για κάθε κλειδί ────────────────────────────
SUCCESS=0
TOTAL=0

for KEY in $KEYS; do
  TOTAL=$((TOTAL + 1))
  
  # Εξαγωγή του τμήματος
  SECTION=$(jq ".\"$KEY\"" "$MASTER" 2>/dev/null)

  if [ -z "$SECTION" ] || [ "$SECTION" = "null" ]; then
    echo "  ⚠ Το κλειδί '$KEY' είναι κενό" | tee -a "$LOG"
    continue
  fi

  # Αποθήκευση με όμορφο όνομα
  OUTPUT_FILE="$LESSON_DIR/${KEY}_output.json"
  echo "$SECTION" > "$OUTPUT_FILE"
  echo "  ✓ ${KEY}_output.json" | tee -a "$LOG"
  SUCCESS=$((SUCCESS + 1))
done

# ── Σύνοψη ───────────────────────────────────────────────
echo "" | tee -a "$LOG"
echo "══════════════════════════════════════════" | tee -a "$LOG"
echo "✓ Τοπική Διανομή: $SUCCESS/$TOTAL κλειδιά εξήχθησαν" | tee -a "$LOG"
echo "Λεπτομέρειες: $LOG" | tee -a "$LOG"
