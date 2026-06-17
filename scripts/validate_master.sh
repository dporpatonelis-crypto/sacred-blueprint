#!/bin/bash
# ============================================================
# validate_master.sh — Ελέγχει την πληρότητα ενός master JSON
# Χρήση: bash scripts/validate_master.sh lessons/SLUG/master_output.json
# ============================================================

set -e

TARGET="${1:?Χρήση: bash scripts/validate_master.sh lessons/SLUG/master_output.json}"
BASE="$(pwd)"
TEMPLATE="$BASE/orchestrator/master_template.json"
LOG="$BASE/logs/validate_$(date +%Y%m%d_%H%M%S).log"

if [ ! -f "$TEMPLATE" ]; then
  echo "✗ Το master_template.json δεν βρέθηκε: $TEMPLATE"
  exit 1
fi

if [ ! -f "$TARGET" ]; then
  echo "✗ Το αρχείο $TARGET δεν βρέθηκε"
  exit 1
fi

# Έλεγχος jq
if ! command -v jq &>/dev/null; then
  echo "✗ jq δεν βρέθηκε — brew install jq"
  exit 1
fi

echo "╔══════════════════════════════════════╗" | tee "$LOG"
echo "║   validate_master.sh — Έλεγχος     ║" | tee -a "$LOG"
echo "╚══════════════════════════════════════╝" | tee -a "$LOG"
echo "Έλεγχος: $TARGET" | tee -a "$LOG"
echo "Πρότυπο: $TEMPLATE" | tee -a "$LOG"
echo "" | tee -a "$LOG"

# 1. Βασική δομή: ελέγχουμε αν τα κλειδιά του template υπάρχουν στο target
# Παίρνουμε τα κλειδιά κορυφαίου επιπέδου από το template (πλην σχολίων)
TEMPLATE_KEYS=$(jq -r 'keys[]' "$TEMPLATE" | grep -v '^_')
TARGET_KEYS=$(jq -r 'keys[]' "$TARGET" 2>/dev/null || echo "")

MISSING=0
EXTRA=0

echo "🔍 Έλεγχος κλειδιών κορυφαίου επιπέδου:" | tee -a "$LOG"
for key in $TEMPLATE_KEYS; do
  if echo "$TARGET_KEYS" | grep -qx "$key"; then
    echo "  ✓ $key" | tee -a "$LOG"
  else
    echo "  ✗ ΛΕΙΠΕΙ: $key" | tee -a "$LOG"
    MISSING=$((MISSING+1))
  fi
done

# Έλεγχος για επιπλέον κλειδιά (προαιρετικά)
for key in $TARGET_KEYS; do
  if ! echo "$TEMPLATE_KEYS" | grep -qx "$key"; then
    echo "  ⚠ ΠΛΕΟΝΑΖΟΝ: $key" | tee -a "$LOG"
    EXTRA=$((EXTRA+1))
  fi
done

echo "" | tee -a "$LOG"
echo "📊 Αποτελέσματα:" | tee -a "$LOG"
echo "  Λείποντα: $MISSING" | tee -a "$LOG"
echo "  Πλεονάζοντα: $EXTRA" | tee -a "$LOG"

if [ $MISSING -eq 0 ]; then
  echo "✅ Όλα τα βασικά κλειδιά υπάρχουν." | tee -a "$LOG"
else
  echo "⚠ Λείπουν $MISSING κλειδιά. Συμπλήρωσέ τα πριν το distribute." | tee -a "$LOG"
fi

# 2. Προαιρετικά: έλεγχος τύπου για μερικά πεδία (π.χ. coordinates)
echo "" | tee -a "$LOG"
echo "🔍 Έλεγχος τύπων (βασικά πεδία):" | tee -a "$LOG"

# Έλεγχος ότι το coordinates είναι object με lat, lng, zoom
if jq -e '.coordinates | has("lat") and has("lng") and has("zoom")' "$TARGET" >/dev/null 2>&1; then
  echo "  ✓ coordinates: lat/lng/zoom υπάρχουν" | tee -a "$LOG"
else
  echo "  ✗ coordinates: λείπει lat ή lng ή zoom (ή δεν είναι object)" | tee -a "$LOG"
fi

# Έλεγχος ότι timeline_item είναι object
if jq -e '.timeline_item | type == "object"' "$TARGET" >/dev/null 2>&1; then
  echo "  ✓ timeline_item: object" | tee -a "$LOG"
else
  echo "  ✗ timeline_item: δεν είναι object" | tee -a "$LOG"
fi

echo "" | tee -a "$LOG"
echo "Λεπτομέρειες: $LOG" | tee -a "$LOG"

# Εξαγωγή κωδικού εξόδου: 0 αν όλα καλά, 1 αν λείπουν κλειδιά
if [ $MISSING -eq 0 ]; then
  exit 0
else
  exit 1
fi
