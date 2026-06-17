#!/bin/bash
# ============================================================
# publish_lesson.sh — Πλήρης αυτοματοποίηση
# Χρήση: bash workflows/publish_lesson.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/
#        bash workflows/publish_lesson.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/ --skip-transform
# ============================================================

set -e

LESSON_DIR="${1:?Χρήση: bash workflows/publish_lesson.sh lessons/ΟΝΟΜΑ_ΦΑΚΕΛΟΥ/}"
BASE="$(pwd)"
MASTER="$LESSON_DIR/master_output.json"
ROUTING="$BASE/config/routing.json"

# Επιλογές
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

# ── 1. Έλεγχοι ──────────────────────────────────────────
if [ ! -f "$MASTER" ]; then
  echo "✗ master_output.json δεν βρέθηκε: $MASTER"
  exit 1
fi

TOPIC=$(jq -r '.title' "$MASTER" 2>/dev/null || echo "Μάθημα")
echo "📚 Μάθημα: $TOPIC"
echo "📁 Φάκελος: $LESSON_DIR"
echo ""

# ── 2. Validate ──────────────────────────────────────────
echo "🔍 Βήμα 1/4: Έλεγχος πληρότητας..."
REQUIRED_KEYS=("title" "subtitle" "description" "date" "era" "location" "coordinates")
MISSING=0
for key in "${REQUIRED_KEYS[@]}"; do
  if ! jq -e ".$key" "$MASTER" >/dev/null 2>&1; then
    echo "  ✗ ΛΕΙΠΕΙ: $key"
    MISSING=$((MISSING+1))
  fi
done

if [ $MISSING -eq 0 ]; then
  echo "  ✅ Το master_output.json είναι πλήρες."
else
  echo "  ⚠ Λείπουν $MISSING πεδία. Συμπλήρωσέ τα."
  read -p "  Θες να συνεχίσεις; (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "  ❌ Ακυρώθηκε."
    exit 1
  fi
fi
echo ""

# ── 3. Transform (μόνο αν ΔΕΝ έχουμε --skip-transform) ──
if [ "$SKIP_TRANSFORM" = true ]; then
  echo "⏭️  Βήμα 2/4: Παράλειψη μετασχηματισμού (--skip-transform)"
else
  echo "🤖 Βήμα 2/4: Μετασχηματισμός για τις εφαρμογές..."

  # Διαβάζουμε ποιες apps χρειάζονται
  APPS=$(jq -r '.lesson_types.theological_concept.apps[]' "$ROUTING" 2>/dev/null)

  if [ -z "$APPS" ]; then
    echo "  ⚠ Δεν βρέθηκαν εφαρμογές στο routing.json"
    APPS="living_anchor notebook"
  fi

  echo "  Εφαρμογές: $(echo $APPS | tr '\n' ' ')"

  # Δημιουργία prompt
  PROMPT="Έχω ένα master_output.json. Θέλω να εξάγεις τα τμήματα για τις εφαρμογές: $APPS.

Master JSON:
$(cat "$MASTER")

Mapping:
- living_anchor → personal_page
- investigation_board → investigation_board
- notebook → notebook
- mind_palace_debate → mind_palace
- timeline_explorer → timeline_item
- history_explorer_ue → history3d
- unreal_scenario → unreal_scenario
- personal_page → personal_page

Απάντησε ΜΟΝΟ με JSON. Τα κλειδιά να είναι τα ονόματα των εφαρμογών."

  echo "  📡 Καλώ το Qwen..."
  RESPONSE=$(echo "$PROMPT" | ollama run qwen3.5:9b-mlx 2>&1)

  # Καθαρισμός
  CLEANED=$(echo "$RESPONSE" | sed -n '/^{/,/^}/p' | sed '/^```/d')

  if echo "$CLEANED" | jq empty 2>/dev/null; then
    echo "$CLEANED" > "$LESSON_DIR/transformed.json"
    echo "  ✅ Το Qwen ολοκλήρωσε τον μετασχηματισμό."

    echo "$CLEANED" | jq -r 'keys[]' 2>/dev/null | while read -r app; do
      echo "$CLEANED" | jq ".\"$app\"" > "$LESSON_DIR/${app}_output.json"
      echo "    → ${app}_output.json"
    done
  else
    echo "  ⚠ Το Qwen δεν επέστρεψε έγκυρο JSON."
    echo "$RESPONSE" > "$LESSON_DIR/transform_raw.txt"
    echo "  → Θα χρησιμοποιήσω το master_output.json απευθείας (τα sections υπάρχουν ήδη)."
  fi
fi
echo ""

# ── 4. Distribute ──────────────────────────────────────────
echo "📤 Βήμα 3/4: Διανομή στις εφαρμογές..."
bash workflows/distribute.sh "$LESSON_DIR" 2>&1 | tee /tmp/distribute.log
echo "  ✅ Διανομή ολοκληρώθηκε."
echo ""

# ── 5. Dashboard + GitHub ──────────────────────────────────
echo "📊 Βήμα 4/4: Dashboard + GitHub..."
bash workflows/generate_dashboard.sh 2>&1 | tee /tmp/dashboard.log
COMMIT_MSG="lesson: $TOPIC ($(date +%Y-%m-%d))"
bash workflows/sync_github.sh "$COMMIT_MSG" 2>&1 | tee /tmp/github.log
echo "  ✅ Ολοκληρώθηκε."
echo ""

# ── 6. Τελικό μήνυμα ──────────────────────────────────────
echo "══════════════════════════════════════════════"
echo "✅ Ολοκληρώθηκε!"
echo ""
echo "📖 Δες το dashboard:"
echo "  open $BASE/lessons/index.html"
echo ""
echo "📂 Φάκελος μαθήματος:"
echo "  $LESSON_DIR"
echo "══════════════════════════════════════════════"
