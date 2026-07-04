#!/bin/bash
# ============================================================
# sync_github.sh — Commit και push (MONI MEGA LYSI)
# Αποκλειστικό σενάριο για το sacred-blueprint repo
# Πλήρης αυτοματοποίηση με auto-detection of new lessons in /lessons/
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

# ── STEP 1: Find all lesson folders that have *_output.json files ─────────────────
echo "🔍 Scanning /lessons/ for active lessons..."
NEW_LESSONS=()

for dir in lessons/*/; do
   if [[ -d "$dir" ]] && [ -n "$(ls "$dir"/*_output.json 2>/dev/null)" ]; then
     NEW_LESSONS+=("$dir")
     echo "   ✓ Found: $(basename "$dir")"
   fi
done

echo ""
if [ ${#NEW_LESSONS[@]} -eq 0 ]; then
  echo "⚠ No new lesson folders detected with output files."
else
  echo "🔧 Preparing Git add..."
  
   # Add all discovered lesson folders to git
  for dir in "${NEW_LESSONS[@]}"; do
    basename_dir=$(basename "$dir")
    
     # Add ALL files from the lesson directory
    git add "$dir"/*.json "$dir"/*_output.json "$dir"/master_output.json "$dir"/meta.json 2>/dev/null || true
    echo "   → Added: $basename_dir/"
  done
  
   # Also add index.html for dashboard updates  
  if [ -f "lessons/index.html" ]; then
    git add lessons/index.html 2>/dev/null || true
    echo "   → Added: lessons/index.html"
  fi
  
  echo ""
  echo "📦 Additional config & data files..."
  
   # Add supporting files  
  git add \
    config/ \
    skills/prompts/ \
    workflows/ \
    scripts/ \
    orchestrator/ \
    README.md \
    data/current/ \
     2>/dev/null || true
  
  echo ""
  if git diff --cached --quiet; then
    echo "ⓘ No changes to commit. All files already tracked."
    exit 0
  else
    echo ""
    echo "✅ Committing changes..."
    git commit -m "$MSG" && echo "   → Commit: $MSG" || {
      echo "   ✗ Commit failed — check .gitignore or permissions"
      exit 1
     }

    if git push origin main &>/dev/null; then
      echo ""
      echo "═══════════════════════════════════════════════════"
      echo "      🎉 GITHUB SYNC SUCCESSFUL!                      "
      echo "═══════════════════════════════════════════════════"
      echo ""
      echo "✓ ${#NEW_LESSONS[@]} lesson(s) published to GitHub"
      echo "🌐 Remote: origin/main"
      exit 0
    else
      echo ""
      echo "⚠ Push failed — check network/remote configuration"
      echo "  Local commit successful."
      exit 1
    fi
  fi
fi
