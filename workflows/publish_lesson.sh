#!/bin/bash
# ============================================================
# publish_lesson.sh — Πλήρης αυτοματοποίηση
# Χρήση: bash workflows/publish_lesson.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/
#        bash workflows/publish_lesson.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/ --skip-transform
# ============================================================

BASE="$(pwd)"
LESSON_DIR="${1:?Χρήση: bash workflows/publish_lesson.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/}"
MASTER="$LESSON_DIR/master_output.json"
ROUTING="$BASE/config/routing.json"
ERRORS=0

SKIP_TRANSFORM=false
for arg in "${@:2}"; do
  case $arg in
    --skip-transform) SKIP_TRANSFORM=true ;;
  esac
done

echo "╔══════════════════════════════════════════════╗"
echo "║   🚀 Publish Lesson — Πλήρης Αυτοματοποίηση ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── 1. Έλεγχος αρχείων ───────────────────────────────────
if [ ! -f "$MASTER" ]; then
  echo "✗ master_output.json δεν βρέθηκε: $MASTER"
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "✗ jq δεν βρέθηκε — brew install jq"
  exit 1
fi

TOPIC=$(jq -r '.title // "Μάθημα"' "$MASTER" 2>/dev/null || echo "Μάθημα")
echo "📚 Μάθημα: $TOPIC"
echo "📁 Φάκελος: $LESSON_DIR"
echo ""

# ── 2. Transform (προαιρετικό) ───────────────────────────
if [ "$SKIP_TRANSFORM" = true ]; then
  echo "⏭️  Βήμα 1/4: Παράλειψη μετασχηματισμού (--skip-transform)"
else
  echo "🤖 Βήμα 1/4: Μετασχηματισμός για τις εφαρμογές..."

  APPS=$(jq -r '.lesson_types.theological_concept.apps[]' "$ROUTING" 2>/dev/null || echo "")
  if [ -z "$APPS" ]; then
    echo "  ⚠ Δεν βρέθηκαν εφαρμογές στο routing.json — παράλειψη"
    SKIP_TRANSFORM=true
  else
    echo "  Εφαρμογές: $(echo $APPS | tr '\n' ' ')"
    PROMPT="Έχω ένα master_output.json. Θέλω να εξάγεις τα τμήματα για τις εφαρμογές: $APPS.

Master JSON:
$(cat "$MASTER")

Απάντησε ΜΟΝΟ με JSON. Τα κλειδιά να είναι τα ονόματα των εφαρμογών."

    echo "  📡 Καλώ το Qwen..."
    RESPONSE=$(echo "$PROMPT" | ollama run qwen3.5:9b-mlx 2>&1) || {
      echo "  ⚠ Qwen απέτυχε — συνεχίζω χωρίς transform"
      SKIP_TRANSFORM=true
    }

    if [ "$SKIP_TRANSFORM" = false ]; then
      CLEANED=$(echo "$RESPONSE" | python3 -c "
import sys, json
text = sys.stdin.read()
start = text.find('{')
end   = text.rfind('}')
if start >= 0 and end >= 0:
    candidate = text[start:end+1]
    try:
        json.loads(candidate)
        print(candidate)
    except:
        pass
" 2>/dev/null)

      if [ -n "$CLEANED" ] && echo "$CLEANED" | jq empty 2>/dev/null; then
        echo "$CLEANED" > "$LESSON_DIR/transformed.json"
        jq -s '.[0] * .[1]' "$MASTER" "$LESSON_DIR/transformed.json" > /tmp/merged.json \
          && mv /tmp/merged.json "$MASTER" \
          && echo "  ✅ Transform ολοκληρώθηκε + merged στο master."
      else
        echo "  ⚠ Qwen δεν επέστρεψε έγκυρο JSON — συνεχίζω με master as-is."
        echo "$RESPONSE" > "$LESSON_DIR/transform_raw.txt"
      fi
    fi
  fi
fi
echo ""

# ── 3. Distribute → data/current/ ────────────────────────
echo "📤 Βήμα 2/4: Εξαγωγή → data/current/..."
if bash workflows/distribute.sh "$LESSON_DIR"; then
  echo "  ✅ Διανομή ολοκληρώθηκε."
else
  echo "  ✗ Distribute απέτυχε."
  ERRORS=$((ERRORS+1))
fi
echo ""

# ── 4. Dashboard ─────────────────────────────────────────
echo "📊 Βήμα 3/4: Dashboard..."
if bash workflows/generate_dashboard.sh; then
  echo "  ✅ Dashboard ενημερώθηκε."
else
  echo "  ✗ Dashboard απέτυχε."
  ERRORS=$((ERRORS+1))
fi
echo ""

# ── 5. GitHub push ────────────────────────────────────────
echo "☁️  Βήμα 4/4: GitHub push..."
COMMIT_MSG="lesson: $TOPIC ($(date +%Y-%m-%d))"
if bash workflows/sync_github.sh "$COMMIT_MSG"; then
  echo "  ✅ Push ολοκληρώθηκε — GitHub Action ξεκίνησε."
else
  echo "  ✗ Push απέτυχε — τα αρχεία αποθηκεύτηκαν τοπικά."
  echo "  Χειροκίνητο push: git push origin main"
  ERRORS=$((ERRORS+1))
fi
echo ""

# ── 6. Τελικό μήνυμα ─────────────────────────────────────
echo "══════════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
  echo "✅ Ολοκληρώθηκε χωρίς σφάλματα!"
else
  echo "⚠ Ολοκληρώθηκε με $ERRORS σφάλμα/τα — έλεγξε παραπάνω."
fi
echo ""
echo "📚 Βιβλιοθήκη : $LESSON_DIR"
echo "📡 Ενεργό     : data/current/"
echo "📖 Dashboard  : open $BASE/lessons/index.html"
echo "══════════════════════════════════════════════"
