#!/bin/bash
# ============================================================
# sync_github.sh — Commit και push με πλήρες error reporting
# ============================================================

BASE="$(pwd)"
MSG="${1:-lesson: update $(date +%Y-%m-%d)}"

cd "$BASE" || exit 1

if [ ! -d .git ]; then
  echo "⚠ Δεν είναι git repository. Αρχικοποίηση..."
  git init && git branch -M main
  echo "✓ Git repo έτοιμο."
  echo "  Πρόσθεσε remote: git remote add origin git@github.com:USERNAME/sacred-blueprint.git"
  exit 0
fi

echo "═══════════════════════════════════════════════════"
echo "      🔄 GitHub Sync — Auto-Detection Mode        "
echo "═══════════════════════════════════════════════════"
echo ""

echo "🔍 Scanning /lessons/ for active lessons..."
NEW_LESSONS=()

for dir in lessons/*/; do
   if [[ -d "$dir" ]] && [ -n "$(ls "$dir"/*_output.json 2>/dev/null)" ]; then
     NEW_LESSONS+=("$dir")
     echo "   ✓ Found: $(basename "$dir")"
   fi
done

echo ""

git add \
  config/ \
  skills/prompts/ \
  lessons/*/meta.json \
  lessons/*/master_output.json \
  lessons/*/*_output.json \
  lessons/index.html \
  workflows/ \
  scripts/ \
  orchestrator/ \
  README.md \
  data/current/ \
  2>/dev/null || true

if git diff --cached --quiet; then
  echo "ⓘ Καμία αλλαγή για commit."
  exit 0
fi

echo "✅ Committing changes..."
if ! git commit -m "$MSG"; then
  echo "✗ Commit failed — έλεγξε .gitignore ή permissions"
  exit 1
fi
echo "   → Commit: $MSG"
echo ""

# ── PULL πρώτα, για να αποφύγουμε non-fast-forward rejection ──
echo "🔄 Έλεγχος για αλλαγές στο remote (πιθανές από GitHub Action)..."
git fetch origin main 2>&1

BEHIND=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo "0")
if [ "$BEHIND" -gt 0 ]; then
  echo "  ⚠ Το remote έχει $BEHIND νέα commits (πιθανόν από Actions)."
  echo "  Κάνω pull --rebase..."
  if ! git pull --rebase origin main; then
    echo "  ✗ Rebase conflict — χρειάζεται χειροκίνητη επίλυση:"
    echo "     git status"
    echo "     # διόρθωσε conflicts"
    echo "     git rebase --continue"
    exit 1
  fi
  echo "  ✓ Rebase ολοκληρώθηκε."
fi
echo ""

# ── PUSH με πλήρες error output (όχι κρυμμένο) ──
echo "☁️  Push στο GitHub..."
PUSH_OUTPUT=$(git push origin main 2>&1)
PUSH_STATUS=$?

if [ $PUSH_STATUS -eq 0 ]; then
  echo ""
  echo "═══════════════════════════════════════════════════"
  echo "      🎉 GITHUB SYNC SUCCESSFUL!                    "
  echo "═══════════════════════════════════════════════════"
  echo ""
  echo "✓ ${#NEW_LESSONS[@]} lesson(s) tracked"
  echo "🌐 Remote: origin/main"
  exit 0
else
  echo ""
  echo "✗ Push απέτυχε. Πλήρες error:"
  echo "──────────────────────────────────────────"
  echo "$PUSH_OUTPUT"
  echo "──────────────────────────────────────────"
  echo ""
  echo "Local commit έγινε επιτυχώς — μόνο το push απέτυχε."
  echo "Χειροκίνητο retry: git push origin main"
  exit 1
fi
