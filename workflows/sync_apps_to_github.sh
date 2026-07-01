#!/bin/bash
# ============================================================
# sync_apps_to_github.sh — Sync όλων των τοπικών app φακέλων
# στα αντίστοιχα GitHub repos τους.
#
# Χρήση: bash workflows/sync_apps_to_github.sh
#        bash workflows/sync_apps_to_github.sh "custom commit message"
# ============================================================

APPS_DIR="$HOME/apps"   # ← άλλαξε αν χρειάζεται
MSG="${1:-sync: local update $(date +%Y-%m-%d_%H:%M)}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
SKIP='\033[0;90m'
NC='\033[0m'

ok()   { echo -e "${GREEN}  ✅ $1${NC}"; }
skip() { echo -e "${SKIP}  ⏭  $1${NC}"; }
warn() { echo -e "${YELLOW}  ⚠  $1${NC}"; }
err()  { echo -e "${RED}  ✗ $1${NC}"; }

# Λίστα εφαρμογών προς sync
APPS=(
  "Map-Timeline"
  "idea-weaver-board"
  "history-explorer-3d"
  "mind-palace-cases"
  "personal-page"
)

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Sync: ~/apps/*  →  GitHub repos        ║"
echo "╚══════════════════════════════════════════╝"
echo ""

TOTAL=0
SUCCESS=0
SKIPPED=0
FAILED=0

for APP in "${APPS[@]}"; do
  TOTAL=$((TOTAL+1))
  DIR="$APPS_DIR/$APP"

  echo "📦 $APP"

  if [ ! -d "$DIR" ]; then
    skip "Φάκελος δεν βρέθηκε: $DIR"
    SKIPPED=$((SKIPPED+1))
    echo ""
    continue
  fi

  if [ ! -d "$DIR/.git" ]; then
    err "Δεν είναι git repository: $DIR"
    FAILED=$((FAILED+1))
    echo ""
    continue
  fi

  cd "$DIR" || { err "Αδύνατη πρόσβαση"; FAILED=$((FAILED+1)); continue; }

  git add -A

  if git diff --cached --quiet; then
    skip "Καμία αλλαγή"
    SKIPPED=$((SKIPPED+1))
    echo ""
    continue
  fi

  if git commit -m "$MSG" >/dev/null 2>&1; then
    if git push origin main 2>&1 | grep -qE "(rejected|error|fatal)"; then
      err "Push απέτυχε — πιθανό conflict, χρειάζεται git pull"
      FAILED=$((FAILED+1))
    else
      ok "Commit + push ολοκληρώθηκε"
      SUCCESS=$((SUCCESS+1))
    fi
  else
    err "Commit απέτυχε"
    FAILED=$((FAILED+1))
  fi

  echo ""
done

echo "══════════════════════════════════════════"
echo "✅ Επιτυχία : $SUCCESS/$TOTAL"
echo "⏭  Παράλειψη: $SKIPPED/$TOTAL"
if [ $FAILED -gt 0 ]; then
  echo -e "${RED}✗ Αποτυχία  : $FAILED/$TOTAL${NC}"
fi
echo "══════════════════════════════════════════"
echo ""
