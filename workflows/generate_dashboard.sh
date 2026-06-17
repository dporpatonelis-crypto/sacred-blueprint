#!/bin/bash
BASE="$(pwd)"
OUT="$BASE/lessons/index.html"
if ! command -v jq &>/dev/null; then echo "✗ jq — brew install jq" && exit 1; fi
LESSONS_JSON="["
FIRST=true
for meta in "$BASE/lessons"/*/meta.json; do
  [ -f "$meta" ] || continue
  ENTRY=$(jq -c --arg dir "$(dirname "$meta")" '. + {dir: $dir}' "$meta" 2>/dev/null)
  [ -z "$ENTRY" ] && continue
  if [ "$FIRST" = true ]; then LESSONS_JSON="$LESSONS_JSON$ENTRY"; FIRST=false; else LESSONS_JSON="$LESSONS_JSON,$ENTRY"; fi
done
LESSONS_JSON="$LESSONS_JSON]"
cat > "$OUT" << HTMLEOF
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Sacred Blueprint — Dashboard</title><style>
body{background:#f5f0e8;color:#2c2416;font-family:Georgia,serif;padding:2rem;}
h1{font-size:1.8rem;border-bottom:1px solid #d4c9a8;padding-bottom:0.5rem;}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:1rem;margin-top:1.5rem;}
.card{background:#fffdf7;border:1px solid #d4c9a8;border-radius:8px;padding:1rem;}
.card .topic{font-weight:bold;font-size:1.1rem;}
.card .type{font-size:0.8rem;color:#7a6e58;text-transform:uppercase;letter-spacing:0.05em;}
.card .status{font-size:0.75rem;padding:0.2rem 0.6rem;border-radius:12px;background:#e8e0cc;}
.status.distributed{background:#d4e8d4;color:#2d6640;}
</style></head>
<body><h1>Sacred Blueprint — Lessons</h1><div class="grid" id="grid"></div>
<script>
const lessons = $LESSONS_JSON;
const grid = document.getElementById('grid');
if (!lessons.length) grid.innerHTML = '<p>Δεν βρέθηκαν μαθήματα.</p>';
else {
  grid.innerHTML = lessons.map(l => \`
    <div class="card">
      <div class="type">\${l.lesson_type || ''}</div>
      <div class="topic">\${l.topic || '—'}</div>
      <div style="margin-top:0.5rem;display:flex;justify-content:space-between;align-items:center;">
        <span style="font-size:0.75rem;color:#7a6e58;">\${l.created ? new Date(l.created).toLocaleDateString('el') : ''}</span>
        <span class="status \${l.status || 'draft'}">\${l.status || 'draft'}</span>
      </div>
    </div>
  \`).join('');
}
</script></body></html>
HTMLEOF
echo "✓ Dashboard: $OUT"
