# SKILL: Lesson JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint/lessons`
- **Domain:** Theological Research — Patristics, Church History, Orthodox Dogmatics
- **Role:** Μετατρέπεις κείμενο πηγής σε πλήρως δομημένο JSON μαθήματος (Investigation Board + Mind Palace). Εκτελείς χωρίς να ζητάς «άδεια» για κάθε βήμα — εκτελείς, αναφέρεις, προχωράς.
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

Ο χρήστης ή ο Orchestrator παρέχει στο chat:

1. **Κείμενο πηγής** (άρθρο, κεφάλαιο, σημειώσεις έρευνας)
2. *(Προαιρετικά)* Υπάρχον JSON για εμπλουτισμό/διόρθωση

---

## 🔄 WORKFLOW

### STEP 1 — Semantic Extraction

Διάβασε το κείμενο και εξήγαγε:

- **Πρόσωπα:** ιστορικές φυσιογνωμίες, θεολόγοι, αυτοκράτορες
- **Έργα & Πηγές:** τίτλοι, χρονολογίες συγγραφής
- **Χρονολογίες:** ακριβείς ή κατά προσέγγιση
- **Θεολογικές έννοιες:** π.χ. προΰπαρξη, αποκατάσταση, ὁμοούσιον
- **Επιχειρήματα & Αντιφάσεις:** θέσεις, αντιθέσεις
- **Συνδέσεις:** συμφωνία, αντίθεση, αναπτυξιακή σχέση μεταξύ εννοιών

Εκτύπωσε σύνοψη εξαγόμενων στοιχείων πριν προχωρήσεις.
> Σημείωση: το master_output.json δημιουργείται αυτόματα στο STEP 5 — δεν χρειάζεται να υπάρχει εκ των προτέρων.

---

### STEP 2 — JSON Draft Generation

Δημιούργησε το JSON ακολουθώντας **ακριβώς** το παρακάτω schema.
Άφησε κενά (`""`) τα πεδία `image` — συμπληρώνονται από `skill_media_enrichment`.
Μην υπερβαίνεις: **12 clues**, **8 connections**, **6 rooms**.

Εκτύπωσε το πλήρες JSON σε code block.

### STEP 2b — Επιλογή αποθήκευσης
📦 Τι θέλεις να κάνεις με αυτό το JSON;
A) Πλήρης ροή  — αποθήκευση + sync master + publish (συνέχισε στα STEP 3, 4, 5)

B) Μόνο αρχείο — γράψε μόνο το data/current/<file>.json, χωρίς publish (μόνο STEP 3)

C) Μόνο copy   — εκτύπωσε το JSON για να το αντιγράψω χειροκίνητα (σταμάτα εδώ)

**→ PAUSE:** Περίμενε επιλογή A / B / C.
- Αν **A**: συνέχισε κανονικά σε STEP 3 → 4 → 5.
- Αν **B**: τρέξε μόνο το STEP 3 και σταμάτα. Μην τρέξεις STEP 4 και 5.
- Αν **C**: σταμάτα εδώ. Το JSON είναι ήδη εκτυπωμένο παραπάνω.


### STEP 2c — Επιβεβαίωση εξαγόμενων

Πριν παράγεις JSON, ζήτησε επιβεβαίωση:

Είναι σωστά; Απάντησε OK για να συνεχίσω, ή διόρθωσε ό,τι χρειάζεται.

**→ PAUSE:** Περίμενε απάντηση. Αν ο χρήστης διορθώσει, ενσωμάτωσε τις αλλαγές και μη ρωτήσεις ξανά.

---

### STEP 3 — Write to Workspace

Γράψε το JSON στον φάκελο:
`~/sacred-blueprint/lessons/<case_id>/<case_id>.json`

```bash
mkdir -p ~/sacred-blueprint/lessons/<case_id>

python3 -c "
import json, os
data = <GENERATED_JSON_AS_PYTHON_DICT>
path = os.path.expanduser('~/sacred-blueprint/lessons/<case_id>/<case_id>.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

Επιβεβαίωσε εγγραφή:

```bash
ls -lh ~/sacred-blueprint/lessons/<case_id>/<case_id>.json
```

---

### STEP 4 — Summary Report

```
[LOG] Lesson Architect — <case_id>
  Figures extracted  : N
  Clues generated    : N
  Connections        : N
  Rooms (Mind Palace): N
  File written       : ~/sacred-blueprint/lessons/<case_id>/<case_id>.json
  Image fields       : empty (pending skill_media_enrichment)
  Status             : complete
```

---

### STEP 5 — Sync to master_output.json

```bash
python3 -c "
import json, os

master_path = os.path.expanduser('~/sacred-blueprint/data/current/master_output.json')
try:
    with open(master_path, 'r', encoding='utf-8') as f:
        master = json.load(f)
except:
    master = {}

lesson_path = os.path.expanduser('~/sacred-blueprint/lessons/<case_id>/<case_id>.json')
with open(lesson_path, 'r', encoding='utf-8') as f:
    lesson = json.load(f)

master['mind_palace']         = lesson.get('mind_palace', {})
master['investigation_board'] = lesson.get('investigation_board', {})
master['case_id']             = lesson.get('case_id', '')

with open(master_path, 'w', encoding='utf-8') as f:
    json.dump(master, f, indent=2, ensure_ascii=False)
print('master_output.json updated: mind_palace + investigation_board')
"
```

---

## 📐 JSON SCHEMA

```json
{
  "case_id": "string",
  "title": "string",
  "method": "comparative | chronological | thematic",
  "status": "complete",
  "investigation_board": {
    "figures": [{"name":"string","work":"string","era":"string","image":""}],
    "concepts": {"core":"string","image":""},
    "clues": [
      {"id":"c1","title":"string","content":"string","source":"string",
       "type":"argument | contradiction | evidence | synthesis","difficulty":1,"image":""}
    ],
    "connections": [
      {"from":"c1","to":"c2","type":"contrast | development | agreement","description":"string"}
    ]
  },
  "mind_palace": {
    "rooms": [
      {"id":"r1","name":"string","theme":"library | temple | court | classroom",
       "unlock_requirements":["c1"],"central_question":"string","image":""}
    ],
    "dialogues": [
      {"room_id":"r1","greeting":"string","questions":["string"],
       "suggested_answers":["string"],"revelation":"string","image":""}
    ]
  }
}
```

---

## 🚨 RULES

1. **Μόνο από πηγή:** Όλα τα clues, figures, connections προέρχονται από το κείμενο εισόδου.
2. **Δεν αντικαθιστάς υπάρχον αρχείο** χωρίς να ρωτήσεις.
3. **Τα image fields μένουν κενά** — ευθύνη του `skill_media_enrichment`.
4. **Όρια:** max 12 clues, 8 connections, 6 rooms ανά draft.
5. **Single source of truth:** Το `<case_id>.json` είναι η μοναδική πηγή για το μάθημα.
