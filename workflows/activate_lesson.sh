#!/bin/bash
# ============================================================
# activate_lesson.sh — Ενεργοποίηση παλιού μαθήματος από βιβλιοθήκη
# Χρήση: bash workflows/activate_lesson.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/
#
# Αντιγράφει τα JSON ενός παλιού μαθήματος στο data/current/
# και κάνει push — το GitHub Action διανέμει αυτόματα στα apps.
# ============================================================

set -e

LESSON_DIR="${1:-}"

# Αν δεν δοθεί φάκελος, εμφάνισε λίστα
if [ -z "$LESSON_DIR" ]; then
  echo "Χρήση: bash workflows/activate_lesson.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/"
  echo ""
  echo "Διαθέσιμα μαθήματα (νεότερα πρώτα):"
  ls lessons/ 2>/dev/null | sort -r | head -20 | sed 's/^/  /'
  exit 0
fi

if [ ! -d "$LESSON_DIR" ]; then
  echo "✗ Φάκελος δεν βρέθηκε: $LESSON_DIR"
  echo ""
  echo "Διαθέσιμα μαθήματα:"
  ls lessons/ 2>/dev/null | sort -r | head -20 | sed 's/^/  /'
  exit 1
fi

if [ ! -f "$LESSON_DIR/master_output.json" ]; then
  echo "✗ master_output.json δεν βρέθηκε στο $LESSON_DIR"
  exit 1
fi

TITLE=$(jq -r '.title // "Μάθημα"' "$LESSON_DIR/master_output.json" 2>/dev/null)

echo "🔄 Ενεργοποίηση: $TITLE"
echo "   Φάκελος: $LESSON_DIR"
echo ""

# Τρέξε distribute για αυτό το μάθημα
bash workflows/distribute.sh "$LESSON_DIR"

# Commit + push → trigger GitHub Action
COMMIT_MSG="activate: $TITLE ($(date +%Y-%m-%d))"

git add data/current/
if git diff --cached --quiet; then
  echo ""
  echo "ⓘ  Το μάθημα ήταν ήδη ενεργό — κανένα νέο αρχείο."
else
  git commit -m "$COMMIT_MSG"
  git push origin main 2>/dev/null && echo "✓ Push ολοκληρώθηκε" || echo "✗ Push απέτυχε"
fi

echo ""
echo "✅ Ενεργό μάθημα: $TITLE"
echo "   Τα apps θα ενημερωθούν σε λίγα λεπτά μέσω GitHub Actions."
