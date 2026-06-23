#!/bin/bash
# ============================================================
# sync_github.sh — Commit και push στο sacred-blueprint repo
# Περιλαμβάνει: βιβλιοθήκη μαθημάτων + data/current/
# Χρήση: bash workflows/sync_github.sh "commit message"
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

git add \
  config/ \
  skills/prompts/ \
  lessons/*/meta.json \
  lessons/*/master_output.json \
  lessons/*/*_output.json \
  workflows/ \
  scripts/ \
  orchestrator/ \
  README.md \
  data/current/ \
  2>/dev/null || true

if git diff --cached --quiet; then
  echo "ⓘ  Τίποτα νέο για commit."
else
  git commit -m "$MSG" && echo "✓ Commit: $MSG"
fi

git push origin main 2>/dev/null && echo "✓ GitHub sync ολοκληρώθηκε" || echo "✗ Push απέτυχε — έλεγξε το remote"
