#!/bin/bash
# ============================================================
# draft_from_text.sh — Δημιουργεί draft master_output.json από κείμενο
# Χρήση: bash scripts/draft_from_text.sh "Θέμα" lesson_type
# ============================================================

set -e

TOPIC="${1:?Χρήση: bash scripts/draft_from_text.sh \"Θέμα\" lesson_type}"
TYPE="${2:?Χρήση: bash scripts/draft_from_text.sh \"Θέμα\" lesson_type}"

BASE="$(pwd)"
OUTPUT_DIR="$BASE/lessons/draft_$(date +%Y%m%d_%H%M%S)"
OUTPUT_FILE="$OUTPUT_DIR/master_output.json"

mkdir -p "$OUTPUT_DIR"

echo "╔══════════════════════════════════════╗"
echo "║   draft_from_text.sh — Draft        ║"
echo "╚══════════════════════════════════════╝"
echo "Θέμα: $TOPIC"
echo "Τύπος μαθήματος: $TYPE"
echo "Έξοδος: $OUTPUT_FILE"
echo ""

# Δημιουργούμε ένα σύντομο prompt
PROMPT="Δημιούργησε ένα JSON για εκπαιδευτικό μάθημα με θέμα: $TOPIC.
Τύπος: $TYPE.
Δομή:
{
  \"title\": \"τίτλος\",
  \"subtitle\": \"υπότιτλος\",
  \"description\": \"περιγραφή\",
  \"date\": \"2026-06-17\",
  \"era\": \"ιστορική περίοδος\",
  \"location\": \"τόπος\",
  \"coordinates\": { \"lat\": 0, \"lng\": 0, \"zoom\": 7 },
  \"timeline_item\": { \"year\": \"έτος\", \"title\": \"γεγονός\", \"desc\": \"περιγραφή\" },
  \"investigation_board\": { \"topic\": \"θέμα\", \"clues\": [] },
  \"history3d\": { \"characters\": [], \"dialogs\": [], \"facts\": [], \"screens\": { \"title\": \"\", \"background\": \"\" } },
  \"mind_palace\": { \"case_id\": \"\", \"title\": \"\", \"method\": \"comparative\", \"status\": \"complete\", \"investigation_board\": { \"figures\": [], \"concepts\": { \"core\": \"\" }, \"clues\": [], \"connections\": [] }, \"mind_palace\": { \"rooms\": [], \"dialogues\": [] } },
  \"notebook\": { \"title\": \"\", \"date\": \"\", \"chapters\": [ { \"index\": 1, \"title\": \"\", \"html\": \"<p></p>\", \"text\": \"\", \"stickies\": [], \"media\": { \"audio\": [], \"slides\": [], \"notebooklm\": [], \"pdf\": [], \"text\": [] } } ] },
  \"personal_page\": { \"title\": \"\", \"chapters\": [] },
  \"unreal_scenario\": { \"id\": \"\", \"version\": \"1.0\", \"title\": \"\", \"subtitle\": \"\", \"characters\": {}, \"acts\": [] }
}
Συμπλήρωσε όλα τα πεδία. Μόνο JSON."

echo "📡 Καλώ το Ollama (qwen3.5:9b-mlx)..."
echo ""

# Στέλνουμε το prompt με echo (μη-διαδραστικά)
RESPONSE=$(echo "$PROMPT" | ollama run qwen3.5:9b-mlx 2>&1)

# Έλεγχος αν η απάντηση είναι κενή
if [ -z "$RESPONSE" ]; then
  echo "✗ Δεν έλαβα απάντηση από το Ollama"
  exit 1
fi

# Απομόνωση του JSON (αφαίρεση markdown fences)
CLEANED=$(echo "$RESPONSE" | sed -n '/^{/,/^}/p' | sed '/^```/d')

# Έλεγχος αν το CLEANED είναι έγκυρο JSON
if ! echo "$CLEANED" | jq empty 2>/dev/null; then
  echo "✗ Το Ollama δεν επέστρεψε έγκυρο JSON. Αποθηκεύω raw απάντηση."
  echo "$RESPONSE" > "$OUTPUT_DIR/ollama_raw.txt"
  echo "  → Raw: $OUTPUT_DIR/ollama_raw.txt"
  exit 1
fi

# Αποθήκευση του JSON
echo "$CLEANED" > "$OUTPUT_FILE"
echo "✓ Draft αποθηκεύτηκε: $OUTPUT_FILE"

echo ""
echo "🔍 Εκτέλεση validate_master.sh..."
bash "$BASE/scripts/validate_master.sh" "$OUTPUT_FILE" || echo "⚠ Υπάρχουν λειποντα κλειδιά."

echo ""
echo "✅ Ολοκληρώθηκε."
