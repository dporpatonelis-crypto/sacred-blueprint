#!/bin/bash
set -e
BASE="$(pwd)"
echo "╔══════════════════════════════════════╗"
echo "║   Sacred Blueprint — Local Setup    ║"
echo "╚══════════════════════════════════════╝"
echo "Workspace: $BASE"

mkdir -p skills/prompts/{startup,investigation,synthesis} skills/scripts skills/patterns lessons/_templates workflows config orchestrator scripts logs apps/data

cat > config/routing.json << 'JSON'
{
  "_meta": { "version": "2.0", "description": "Local-first routing", "last_updated": "2026-06-17" },
  "defaults": { "output_dir": "lessons", "local_model": "qwen3.5-9b-mlx", "orchestrator_html": "orchestrator/index.html", "master_template": "orchestrator/master_template.json" },
  "lesson_types": {
    "patristic_text_analysis": { "description": "Βαθιά ανάλυση πατερικού κειμένου", "stages": ["startup","investigation","synthesis"], "apps": { "startup": ["living_anchor"], "investigation": ["investigation_board","interactive_book"], "synthesis": ["mind_palace_debate"] }, "prompt_templates": { "startup": "skills/prompts/startup/patristic.md", "investigation": "skills/prompts/investigation/patristic.md", "synthesis": "skills/prompts/synthesis/debate.md" }, "media_tags": ["patristic","greek_fathers","theology"] },
    "historical_event": { "description": "Βυζαντινό ιστορικό γεγονός", "stages": ["startup","investigation"], "apps": { "startup": ["living_anchor"], "investigation": ["timeline_explorer","investigation_board","history_explorer_ue"] }, "prompt_templates": { "startup": "skills/prompts/startup/historical.md", "investigation": "skills/prompts/investigation/historical.md" }, "media_tags": ["byzantine","history","3d_assets"] },
    "theological_concept": { "description": "Αφηρημένη θεολογική έννοια", "stages": ["startup","synthesis"], "apps": { "startup": ["living_anchor","interactive_book"], "synthesis": ["mind_palace_debate"] }, "prompt_templates": { "startup": "skills/prompts/startup/concept.md", "synthesis": "skills/prompts/synthesis/debate.md" }, "media_tags": ["theology","concept","debate"] },
    "3d_exploration": { "description": "Χωρική ιστορική εξερεύνηση", "stages": ["startup","investigation"], "apps": { "startup": ["living_anchor"], "investigation": ["history_explorer_ue","timeline_explorer"] }, "prompt_templates": { "startup": "skills/prompts/startup/historical.md", "investigation": "skills/prompts/investigation/3d_exploration.md" }, "media_tags": ["3d","exploration","unreal"] },
    "quick_concept_overview": { "description": "Σύντομη εισαγωγή έννοιας", "stages": ["startup"], "apps": { "startup": ["living_anchor","interactive_book"] }, "prompt_templates": { "startup": "skills/prompts/startup/quick_overview.md" }, "media_tags": ["introduction","overview"] }
  },
  "stages": { "startup": { "label": "Startup & Analysis", "primary_app": "living_anchor" }, "investigation": { "label": "Investigation & Exploration", "primary_app": "investigation_board" }, "synthesis": { "label": "Synthesis & Conclusion", "primary_app": "mind_palace_debate" } },
  "local_paths": { "scripts": "scripts/", "workflows": "workflows/", "skills": "skills/", "config": "config/", "orchestrator": "orchestrator/", "lessons": "lessons/", "logs": "logs/" }
}
JSON

cat > orchestrator/master_template.json << 'JSON'
{ "_comment": "Master Template", "_version": "1.0", "title": "", "subtitle": "", "description": "", "date": "", "era": "", "location": "", "coordinates": { "lat": 0, "lng": 0, "zoom": 7 }, "timeline_item": {}, "investigation_board": {}, "history3d": {}, "mind_palace": {}, "unreal_scenario": {}, "notebook": {}, "personal_page": {} }
JSON

echo "✓ Όλα έτοιμα"
