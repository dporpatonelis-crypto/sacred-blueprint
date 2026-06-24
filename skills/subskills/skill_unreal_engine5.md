# SKILL: Unreal Engine 5 Scenario Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** Unreal Engine 5 — C++ only (no Blueprints), dialogue system (`ScenarioManager`, `DialogueController`, `AssetResolver`), JSON-driven content από GitHub: `dporpatonelis-crypto/sheetunreal`
- **Role:** Δημιουργείς **3 αρχεία** για κάθε UE5 scenario: `scenario.json`, `assets.json`, `manifest_entry.json`. Εκτελείς χωρίς άδεια για τεχνικά βήματα.
## 📋 ΠΡΟΑΠΑΙΤΟΥΜΕΝΑ — Διάβασε πριν ξεκινήσεις

**Δεν ρωτάς για master_output.json πριν ξεκινήσεις.** Το παράγεις εσύ στο STEP 5.

**Το μάθημα πρέπει να έχει ήδη δημιουργηθεί** με:
```bash
bash workflows/new_lesson.sh "Τίτλος Μαθήματος" lesson_type
```
Αυτό δημιουργεί τον φάκελο `lessons/YYYYMMDD_HHMMSS_<slug>/` με `meta.json` μέσα.

**Έγκυροι τύποι μαθήματος:**
`patristic_text_analysis` | `historical_event` | `theological_concept` | `3d_exploration` | `quick_concept_overview`

**Το meta.json που δημιουργείται έχει αυτή τη δομή:**
```json
{
  "topic": "Τίτλος Μαθήματος",
  "lesson_type": "theological_concept",
  "stages": [],
  "status": "draft",
  "created": "2026-06-24T10:00:00Z",
  "updated": "2026-06-24T10:00:00Z"
}
```

**Μετά το STEP 5** (sync to master_output.json), το μάθημα δημοσιεύεται με:
```bash
bash workflows/publish_lesson.sh lessons/YYYYMMDD_HHMMSS_<slug>/ --skip-transform
```

**Ροή εργασίας:**
1. `new_lesson.sh` → δημιουργεί φάκελο + meta.json
2. Τρέχεις skill(s) → παράγουν JSON + ενημερώνουν master_output.json
3. `publish_lesson.sh` → διανέμει στα apps + push στο GitHub

---

## 📥 INPUT

Ένα από τα δύο:
1. **Κείμενο πηγής** (θέμα, ιστορικό υλικό, διάλογοι πηγής)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή

---

## 🔄 WORKFLOW

### STEP 1 — Extraction

Από το κείμενο εξήγαγε:
- **scenario id** (slug, π.χ. `"basil-trinitology"`)
- **2 χαρακτήρες** (με display name, short name, χρώμα)
- **3 acts**: `act_intro` (cinematic) → `act_main` (dialogue) → `act_outro` (cinematic)
- **2–3 dialogues ανά act** με speaker, text, animation, camera angle
- **Player choices** στο τέλος κάθε act (radial menu, 2 επιλογές)
- Audio URL placeholders: `{{audio_char1_01}}` κ.λπ.

Εκτύπωσε σύνοψη.
> Σημείωση: το master_output.json δημιουργείται αυτόματα στο STEP 5 — δεν χρειάζεται να υπάρχει εκ των προτέρων.

---

### STEP 2 — scenario.json Generation

```json
{
  "id": "<slug>",
  "version": "1.0",
  "title": "<τίτλος σεναρίου>",
  "subtitle": "<υπότιτλος>",
  "characters": {
    "char1": {"displayName":"<πλήρες όνομα>","shortName":"<σύντομο>","color":"#1a4a8b"},
    "char2": {"displayName":"<πλήρες όνομα>","shortName":"<σύντομο>","color":"#8b1a1a"}
  },
  "acts": [
    {
      "id": "act_intro", "title": "<τίτλος>", "type": "cinematic",
      "dialogues": [
        {"id":"d_01","speaker":"char1","text":"<ρήση>","audioUrl":"{{audio_char1_01}}",
         "animation":"gesture_welcome","camera":"medium_char1","subtitle":true},
        {"id":"d_02","speaker":"char2","text":"<ρήση>","audioUrl":"{{audio_char2_01}}",
         "animation":"gesture_think","camera":"medium_char2","subtitle":true}
      ],
      "playerChoice": {
        "prompt":"<ερώτηση>","displayStyle":"radial_menu",
        "choices":[{"id":"c1","label":"<επιλογή 1>","nextAct":"act_main"},
                   {"id":"c2","label":"<επιλογή 2>","nextAct":"act_main"}]
      }
    },
    {
      "id": "act_main", "title": "<τίτλος>", "type": "dialogue",
      "dialogues": [
        {"id":"d_03","speaker":"char1","text":"<ρήση>","audioUrl":"{{audio_char1_02}}",
         "animation":"gesture_explain","camera":"wide_both","subtitle":true},
        {"id":"d_04","speaker":"char2","text":"<ρήση>","audioUrl":"{{audio_char2_02}}",
         "animation":"gesture_argue","camera":"medium_char2","subtitle":true},
        {"id":"d_05","speaker":"char1","text":"<ρήση>","audioUrl":"{{audio_char1_03}}",
         "animation":"gesture_conclude","camera":"close_char1","subtitle":true}
      ],
      "playerChoice": {
        "prompt":"<ερώτηση>","displayStyle":"radial_menu",
        "choices":[{"id":"c3","label":"<επιλογή 1>","nextAct":"act_outro"},
                   {"id":"c4","label":"<επιλογή 2>","nextAct":"act_outro"}]
      }
    },
    {
      "id": "act_outro", "title": "<τίτλος>", "type": "cinematic",
      "dialogues": [
        {"id":"d_06","speaker":"char1","text":"<κλείσιμο>","audioUrl":"{{audio_char1_04}}",
         "animation":"gesture_bow","camera":"wide_both","subtitle":true}
      ],
      "playerChoice": null
    }
  ]
}
```

**Animations:** `gesture_welcome`, `gesture_think`, `gesture_explain`, `gesture_argue`, `gesture_conclude`, `gesture_bow`, `idle`

**Camera angles:** `medium_char1`, `medium_char2`, `wide_both`, `close_char1`, `close_char2`, `overhead`

---

### STEP 3 — assets.json Generation

Εξήγαγε όλα τα `{{audio_*}}` placeholders αυτόματα:

```json
{
  "_comment": "Assets για <scenario_id>",
  "assets": {
    "audio_char1_01": {"type":"audio","label":"<char1> — <act>","url":"","speaker":"char1","dialogueId":"d_01"},
    "audio_char2_01": {"type":"audio","label":"<char2> — <act>","url":"","speaker":"char2","dialogueId":"d_02"}
  }
}
```

---

### STEP 4 — manifest_entry.json Generation

```json
{
  "id": "<scenario_id>",
  "title": "<τίτλος>",
  "subtitle": "<υπότιτλος>",
  "description": "<υπότιτλος>",
  "thumbnail": "<scenario_id>/thumbnail.jpg",
  "scenarioFile": "scenarios/<scenario_id>/scenario.json",
  "sublevel": "/Game/Maps/Sublevels/SL_<scenario_id>",
  "assetsUrl": "https://raw.githubusercontent.com/dporpatonelis-crypto/sheetunreal/refs/heads/main/scenarios/<scenario_id>/assets.json",
  "characters": ["char1", "char2"],
  "themes": [],
  "estimatedDuration": 15,
  "difficulty": "intermediate",
  "environment": "ancient_library",
  "status": "draft"
}
```

---

### STEP 5 — Write All 3 Files to Workspace

```bash
mkdir -p ~/sacred-blueprint/data/current/ue5/<scenario_id>

python3 -c "
import json, os

scenario_id = '<scenario_id>'
base = os.path.expanduser(f'~/sacred-blueprint/data/current/ue5/{scenario_id}')
os.makedirs(base, exist_ok=True)

scenario = <SCENARIO_JSON>
assets   = <ASSETS_JSON>
manifest = <MANIFEST_JSON>

with open(f'{base}/scenario.json',       'w', encoding='utf-8') as f: json.dump(scenario, f, indent=2, ensure_ascii=False)
with open(f'{base}/assets.json',         'w', encoding='utf-8') as f: json.dump(assets,   f, indent=2, ensure_ascii=False)
with open(f'{base}/manifest_entry.json', 'w', encoding='utf-8') as f: json.dump(manifest, f, indent=2, ensure_ascii=False)

print('Written 3 files to', base)
"
```

---

### STEP 6 — Summary Report

```
[LOG] Unreal Engine 5 Scenario
  Scenario ID  : <id>
  Characters   : char1=<name>, char2=<name>
  Acts         : 3 (intro / main / outro)
  Dialogues    : N total
  Audio slots  : N (assets.json — URLs κενά)
  Files written:
    data/current/ue5/<id>/scenario.json
    data/current/ue5/<id>/assets.json
    data/current/ue5/<id>/manifest_entry.json
  Status       : draft
```

---

### STEP 7 — Sync to master_output.json

```bash
python3 -c "
import json, os

master_path = os.path.expanduser('~/sacred-blueprint/data/current/master_output.json')
try:
    with open(master_path, 'r', encoding='utf-8') as f:
        master = json.load(f)
except:
    master = {}

scenario_id = '<scenario_id>'
base = os.path.expanduser(f'~/sacred-blueprint/data/current/ue5/{scenario_id}')

with open(f'{base}/scenario.json', 'r', encoding='utf-8') as f:
    master['unreal_scenario'] = json.load(f)
with open(f'{base}/assets.json', 'r', encoding='utf-8') as f:
    master['unreal_assets'] = json.load(f)
with open(f'{base}/manifest_entry.json', 'r', encoding='utf-8') as f:
    master['unreal_manifest'] = json.load(f)

with open(master_path, 'w', encoding='utf-8') as f:
    json.dump(master, f, indent=2, ensure_ascii=False)
print('master_output.json updated: unreal_scenario + unreal_assets + unreal_manifest')
"
```

---

## 📐 JSON SCHEMAS (σύνοψη)

**scenario.json** — `{"id","version","title","subtitle","characters":{},"acts":[]}`

**assets.json** — `{"_comment","assets":{"audio_*":{"type","label","url","speaker","dialogueId"}}}`

**manifest_entry.json** — `{"id","title","subtitle","description","thumbnail","scenarioFile","sublevel","assetsUrl","characters":[],"themes":[],"estimatedDuration","difficulty","environment","status"}`

---

## 🚨 RULES

1. **Πάντα 3 αρχεία:** scenario + assets + manifest. Ποτέ μόνο ένα.
2. **C++ only:** Τα dialogues και choices αντικατοπτρίζουν τη λογική του `DialogueController`.
3. **Audio placeholders:** `{{audio_char1_01}}` — πάντα double curly braces, lowercase.
4. **Assets auto-extracted:** Κάθε placeholder στο scenario γίνεται entry στο assets.json.
5. **manifest status="draft":** Πάντα draft — ο χρήστης το αλλάζει σε "active" μετά το testing.
6. **Ακριβώς 2 characters:** `char1` και `char2` — τα C++ components το περιμένουν.
7. **playerChoice = null** στο act_outro.
