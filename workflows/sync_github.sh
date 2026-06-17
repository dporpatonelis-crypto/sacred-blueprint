#!/bin/bash
BASE="$(pwd)"
MSG="${1:-lesson: update $(date +%Y-%m-%d)}"
cd "$BASE" || exit 1
if [ ! -d .git ]; then
  echo "⚠ Δεν είναι git repository. Αρχικοποίηση..."
  git init && git branch -M main
  echo "✓ Git repo έτοιμο. Πρόσθεσε remote: git remote add origin git@github.com:USERNAME/sacred-blueprint.git"
  exit 0
fi
git add config/ skills/prompts/ lessons/*/meta.json lessons/*/master_output.json lessons/*/*_output.json workflows/ scripts/ orchestrator/ README.md 2>/dev/null
if git diff --cached --quiet; then
  echo "ⓘ  Τίποτα νέο."
else
  git commit -m "$MSG" && echo "✓ Commit: $MSG"
fi
git push origin main 2>/dev/null && echo "✓ GitHub sync" || echo "✗ Push απέτυχε — έλεγξε το remote"
