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
echo "🔍 Βήμα 1/5: Έλεγχος πληρότητας..."
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
  echo "  ⚠ Λείπουν $MISSING πεδία."
  read -p "  Θες να συνεχίσεις; (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "  ❌ Ακυρώθηκε."
    exit 1
  fi
fi
echo ""

# ── 3. Transform ──────────────────────────────────────────
if [ "$SKIP_TRANSFORM" = true ]; then
  echo "⏭️  Βήμα 2/5: Παράλειψη μετασχηματισμού (--skip-transform)"
else
  echo "🤖 Βήμα 2/5: Μετασχηματισμός για τις εφαρμογές..."
  APPS=$(jq -r '.lesson_types.theological_concept.apps[]' "$ROUTING" 2>/dev/null)
  if [ -z "$APPS" ]; then
    echo "  ⚠ Δεν βρέθηκαν εφαρμογές στο routing.json"
    APPS="living_anchor notebook"
  fi
  echo "  Εφαρμογές: $(echo $APPS | tr '\n' ' ')"
  PROMPT="Έχω ένα master_output.json. Θέλω να εξάγεις τα τμήματα για τις εφαρμογές: $APPS.

Master JSON:
$(cat "$MASTER")

Απάντησε ΜΟΝΟ με JSON. Τα κλειδιά να είναι τα ονόματα των εφαρμογών."

  echo "  📡 Καλώ το Qwen..."
  RESPONSE=$(echo "$PROMPT" | ollama run qwen3.5:9b-mlx 2>&1)
  CLEANED=$(echo "$RESPONSE" | sed -n '/^{/,/^}/p' | sed '/^```/d')

  if echo "$CLEANED" | jq empty 2>/dev/null; then
    echo "$CLEANED" > "$LESSON_DIR/transformed.json"
    echo "  ✅ Μετασχηματισμός ολοκληρώθηκε."
    # Merge transformed sections back into master για να τα βρει το distribute
    jq -s '.[0] * .[1]' "$MASTER" "$LESSON_DIR/transformed.json" > /tmp/merged.json
    mv /tmp/merged.json "$MASTER"
    echo "  ✅ Sections merged στο master_output.json"
  else
    echo "  ⚠ Το Qwen δεν επέστρεψε έγκυρο JSON — συνεχίζω με --skip-transform λογική."
    echo "$RESPONSE" > "$LESSON_DIR/transform_raw.txt"
  fi
fi
echo ""

# ── 4. Distribute → data/current/ ────────────────────────
# Νέο βήμα: εξάγει sections από master και γεμίζει data/current/
# Αυτό τροφοδοτεί το GitHub Action που διανέμει στα apps
echo "📤 Βήμα 3/5: Εξαγωγή → data/current/..."
bash workflows/distribute.sh "$LESSON_DIR"
echo ""

# ── 5. Dashboard ──────────────────────────────────────────
echo "📊 Βήμα 4/5: Dashboard..."
bash workflows/generate_dashboard.sh 2>&1 | tee /tmp/dashboard.log
echo "  ✅ Dashboard ενημερώθηκε."
echo ""

# ── 6. GitHub push ────────────────────────────────────────
# Κάνει commit ΚΑΙ τον φάκελο μαθήματος (βιβλιοθήκη)
# ΚΑΙ το data/current/ (trigger για Actions)
echo "☁️  Βήμα 5/5: GitHub push..."
COMMIT_MSG="lesson: $TOPIC ($(date +%Y-%m-%d))"
git add "$LESSON_DIR/"
git add data/current/
git add lessons/index.html 2>/dev/null || true
git commit -m "$COMMIT_MSG"
git push
echo "  ✅ Push ολοκληρώθηκε — GitHub Action ξεκίνησε."
echo ""

# ── 7. Τελικό μήνυμα ──────────────────────────────────────
echo "══════════════════════════════════════════════"
echo "✅ Ολοκληρώθηκε!"
echo ""
echo "📚 Βιβλιοθήκη:  $LESSON_DIR"
echo "📡 Ενεργό:      data/current/ (→ apps μέσω GitHub Action)"
echo ""
echo "📖 Dashboard:"
echo "   open $BASE/lessons/index.html"
echo "══════════════════════════════════════════════"
