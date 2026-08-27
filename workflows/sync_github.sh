#!/bin/bash
# ============================================================
# sync_github.sh — Commit/push του data/current/ και προαιρετικά ενός lesson folder
# ============================================================

BASE="$(pwd)"
MSG="${1:-lesson: update $(date +%Y-%m-%d)}"
LESSON_DIR="${2:-}"
LESSON_DIR="${LESSON_DIR%/}"

cd "$BASE" || exit 1

if [ ! -d .git ]; then
  echo "⚠ Δεν είναι git repository. Αρχικοποίηση..."
  git init && git branch -M main
  echo "✓ Git repo έτοιμο."
  echo "  Πρόσθεσε remote: git remote add origin git@github.com:USERNAME/sacred-blueprint.git"
  exit 0
fi

echo "═══════════════════════════════════════════════════"
echo "      🔄 GitHub Sync — current + active lesson    "
echo "═══════════════════════════════════════════════════"
echo ""

SYNC_PATHS=("data/current/")

if [ -n "$LESSON_DIR" ]; then
  case "$LESSON_DIR" in
    lessons/*) ;;
    *)
      echo "✗ Ο φάκελος μαθήματος πρέπει να βρίσκεται μέσα στο lessons/: $LESSON_DIR"
      exit 1
      ;;
  esac
  case "/$LESSON_DIR/" in
    */../*|*/./*)
      echo "✗ Μη ασφαλής διαδρομή μαθήματος: $LESSON_DIR"
      exit 1
      ;;
  esac
fi

echo "🔄 Refresh: origin/main"
if ! git fetch origin main; then
  echo "✗ Δεν ήταν δυνατή η ανάγνωση του τρέχοντος origin/main."
  exit 1
fi

echo "🔧 Staging: data/current/"
git add data/current/

# Το lesson folder είναι προαιρετικό. Αν δεν δοθεί ή δεν υπάρχει, η τωρινή
# λειτουργία του data/current συνεχίζει χωρίς διακοπή.
if [ -n "$LESSON_DIR" ] && [ -d "$LESSON_DIR" ]; then
  SYNC_PATHS+=("$LESSON_DIR")
  echo "🔧 Staging: $LESSON_DIR"
  git add "$LESSON_DIR"
elif [ -n "$LESSON_DIR" ]; then
  echo "⚠ Ο φάκελος μαθήματος δεν βρέθηκε — συνεχίζω μόνο με data/current/: $LESSON_DIR"
fi

if [ -f "lessons/index.html" ]; then
  SYNC_PATHS+=("lessons/index.html")
  echo "🔧 Staging: lessons/index.html"
  git add lessons/index.html
fi

if git diff --cached --quiet -- "${SYNC_PATHS[@]}"; then
  echo "ⓘ Δεν υπάρχουν νέες αλλαγές στα δεδομένα δημοσίευσης για commit."
else
  echo "✅ Committing current data και ενεργό lesson..."
  git commit --only -m "$MSG" -- "${SYNC_PATHS[@]}" || {
    echo "✗ Το commit απέτυχε."
    exit 1
  }
fi

# Η συνηθισμένη περίπτωση: το local HEAD περιέχει ήδη το origin/main και το
# push είναι fast-forward.
if git merge-base --is-ancestor origin/main HEAD; then
  if git push origin main; then
    echo ""
    echo "═══════════════════════════════════════════════════"
    echo "      🎉 DATA/CURRENT SYNC SUCCESSFUL!             "
    echo "═══════════════════════════════════════════════════"
    echo "🌐 Remote: origin/main"
    exit 0
  fi

  echo "⚠ Το origin/main μετακινήθηκε κατά το push. Ξανατρέξε το publish για ασφαλή επανέλεγχο."
  exit 1
fi

# Αν το local main έχει αποκλίνει (π.χ. έγινε προηγουμένως focused remote
# cleanup), δεν συγχωνεύουμε, δεν κάνουμε rebase και δεν ανεβάζουμε παλιές
# διαγραφείσες βιβλιοθήκες. Χτίζουμε ένα μικρό commit πάνω στο φρέσκο
# origin/main μέσα σε προσωρινό καθαρό worktree, με τα ρητά publication paths.
echo "⚠ Το local main έχει αποκλίνει από το origin/main."
echo "  → Δημοσίευση των scoped lesson data πάνω στο τρέχον remote head."

SYNC_ROOT=$(mktemp -d /tmp/sacred-blueprint-sync.XXXXXX) || {
  echo "✗ Δεν δημιουργήθηκε προσωρινός φάκελος sync."
  exit 1
}
SYNC_WORKTREE="$SYNC_ROOT/worktree"

cleanup_sync_worktree() {
  cd "$BASE" >/dev/null 2>&1 || true
  if [ -d "$SYNC_WORKTREE" ]; then
    git -C "$BASE" worktree remove "$SYNC_WORKTREE" >/dev/null 2>&1 || true
  fi
  rmdir "$SYNC_ROOT" >/dev/null 2>&1 || true
}

if ! git worktree add --detach "$SYNC_WORKTREE" origin/main; then
  cleanup_sync_worktree
  echo "✗ Δεν δημιουργήθηκε το προσωρινό worktree."
  exit 1
fi

mkdir -p "$SYNC_WORKTREE/data/current"
if ! rsync -a --delete --exclude '.DS_Store' "$BASE/data/current/" "$SYNC_WORKTREE/data/current/"; then
  cleanup_sync_worktree
  echo "✗ Απέτυχε η προετοιμασία του data/current/."
  exit 1
fi

REMOTE_SYNC_PATHS=("data/current/")

if [ -n "$LESSON_DIR" ] && [ -d "$BASE/$LESSON_DIR" ]; then
  mkdir -p "$SYNC_WORKTREE/$LESSON_DIR"
  if ! rsync -a --delete --exclude '.DS_Store' "$BASE/$LESSON_DIR/" "$SYNC_WORKTREE/$LESSON_DIR/"; then
    cleanup_sync_worktree
    echo "✗ Απέτυχε η προετοιμασία του $LESSON_DIR."
    exit 1
  fi
  REMOTE_SYNC_PATHS+=("$LESSON_DIR")
fi

if [ -f "$BASE/lessons/index.html" ]; then
  mkdir -p "$SYNC_WORKTREE/lessons"
  cp "$BASE/lessons/index.html" "$SYNC_WORKTREE/lessons/index.html"
  REMOTE_SYNC_PATHS+=("lessons/index.html")
fi

cd "$SYNC_WORKTREE" || {
  cleanup_sync_worktree
  exit 1
}
git add -- "${REMOTE_SYNC_PATHS[@]}"

if git diff --cached --quiet -- "${REMOTE_SYNC_PATHS[@]}"; then
  echo "ⓘ Το remote περιέχει ήδη τα ίδια publication data."
  cleanup_sync_worktree
  exit 0
fi

git config user.name "Sacred Blueprint Publisher"
git config user.email "publisher@sacred-blueprint.local"
if ! git commit -m "$MSG" -- "${REMOTE_SYNC_PATHS[@]}"; then
  cleanup_sync_worktree
  echo "✗ Απέτυχε το scoped remote-base commit."
  exit 1
fi

if git push origin HEAD:main; then
  echo ""
  echo "═══════════════════════════════════════════════════"
  echo "      🎉 SCOPED REMOTE-BASE SYNC SUCCESSFUL!       "
  echo "═══════════════════════════════════════════════════"
  echo "🌐 Remote: origin/main"
  cleanup_sync_worktree
  exit 0
fi

cleanup_sync_worktree
echo "⚠ Το origin/main μετακινήθηκε κατά το scoped push. Ξανατρέξε το publish για ασφαλή επανέλεγχο."
exit 1
