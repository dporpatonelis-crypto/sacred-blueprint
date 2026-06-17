#!/bin/bash
BASE="$(pwd)"
TOPIC="${1:?Χρήση: bash workflows/new_lesson.sh \"Θέμα\" lesson_type}"
TYPE="${2:?Χρήση: bash workflows/new_lesson.sh \"Θέμα\" lesson_type}"
VALID_TYPES=("patristic_text_analysis" "historical_event" "theological_concept" "3d_exploration" "quick_concept_overview")
VALID=0
for t in "${VALID_TYPES[@]}"; do
  if [ "$t" = "$TYPE" ]; then VALID=1; break; fi
done
if [ $VALID -eq 0 ]; then
  echo "✗ Μη έγκυρος τύπος: $TYPE"
  echo "  Έγκυροι: ${VALID_TYPES[*]}"
  exit 1
fi
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
LESSON_DIR="$BASE/lessons/${TIMESTAMP}_${SLUG}"
mkdir -p "$LESSON_DIR/assets"
cat > "$LESSON_DIR/meta.json" << JSON
{
  "topic": "$TOPIC",
  "lesson_type": "$TYPE",
  "stages": [],
  "status": "draft",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSON
echo "✓ Φάκελος: $LESSON_DIR"
echo "✓ meta.json δημιουργήθηκε"
echo "Επόμενα βήματα:"
echo "  1. Άνοιξε το prompt: skills/prompts/startup/${TYPE}.md"
echo "  2. Συμπλήρωσε placeholders και στείλε στο Qwen/Orchestrator"
echo "  3. Αποθήκευσε το output ως: $LESSON_DIR/master_output.json"
echo "  4. Διανομή: bash workflows/distribute.sh $LESSON_DIR"
