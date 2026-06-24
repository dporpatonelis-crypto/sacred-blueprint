# SKILL: Personal Page JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** Personal Page (hub εφαρμογή, ίδιο schema με Notebook Media)
- **Role:** Δημιουργείς chapters για το Personal Page hub με παιδαγωγικές σημειώσεις. Εκτελείς χωρίς άδεια για τεχνικά βήματα.
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
1. **Κείμενο πηγής** (θέμα, ενότητα, ερευνητικές σημειώσεις)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή

---

## 🔄 WORKFLOW

### STEP 1 — Extraction

Από το κείμενο εξήγαγε:
- **1–2 chapters** — το Personal Page λειτουργεί ως ενότητα θέματος στο hub
- Τίτλο ενότητας (συνοπτικός, για navigation)
- Πλούσιο HTML: bold, em, ul/li με βασικές έννοιες, πηγές, ερωτήματα
- Plain text για αναζήτηση
- 2–3 stickies (παιδαγωγικές υπενθυμίσεις για τον δάσκαλο)
- Media skeleton με παιδαγωγικά notes για πότε/πώς κάθε media χρησιμοποιείται

Εκτύπωσε σύνοψη.
> Σημείωση: το master_output.json δημιουργείται αυτόματα στο STEP 5 — δεν χρειάζεται να υπάρχει εκ των προτέρων.

---

### STEP 2 — JSON Generation

```json
{
  "title": "<τίτλος ενότητας/θέματος>",
  "date": "<YYYY-MM-DD σήμερα>",
  "chapters": [
    {
      "index": 1,
      "title": "<σύντομος τίτλος κεφαλαίου>",
      "html": "<p><strong>Θέμα:</strong> <πλούσια HTML περιγραφή></p><ul><li><strong>Βασικές έννοιες:</strong> ...</li><li><strong>Πηγές:</strong> ...</li><li><strong>Ερωτήματα:</strong> ...</li></ul>",
      "text": "<ίδιο ως plain text>",
      "stickies": ["<σημείωση 1>", "<σημείωση 2>", "<σημείωση 3 — προαιρετική>"],
      "media": {
        "audio":      [{"id":"pp_audio_1","label":"<τίτλος>","url":"","notes":"<πριν/κατά/μετά>"}],
        "slides":     [{"id":"pp_slides_1","label":"<τίτλος>","url":"","notes":"<φάση διδασκαλίας>"}],
        "notebooklm": [{"id":"pp_nlm_1","label":"NotebookLM — <θέμα>","url":"","notes":"<ερώτηση>"}],
        "pdf":        [{"id":"pp_pdf_1","label":"<τίτλος>","url":"","notes":"<ποιο μέρος>"}],
        "text":       [{"id":"pp_text_1","label":"<τίτλος>","url":"","content":"<απόσπασμα>","notes":""}]
      }
    }
  ]
}
```

**Διαφορές από Notebook Media:**
- `pp_` prefix στα ids (αντί για `mi_`)
- `stickies`: έως 3
- `html`: πάντα με ul/li για βασικές έννοιες + πηγές + ερωτήματα
- `notes`: πάντα με χρονική αναφορά (πριν/κατά/μετά το μάθημα)

Εκτύπωσε σε code block.

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

```bash
python3 -c "
import json, os
data = <GENERATED_JSON>
path = os.path.expanduser('~/sacred-blueprint/data/current/personalpage.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

---

### STEP 4 — Summary Report

```
[LOG] Personal Page
  Title        : <τίτλος>
  Chapters     : N
  Stickies     : N
  Media filled : audio: N, slides: N, pdf: N, text: N
  File         : ~/sacred-blueprint/data/current/personalpage.json
  Status       : complete
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

section_path = os.path.expanduser('~/sacred-blueprint/data/current/personalpage.json')
with open(section_path, 'r', encoding='utf-8') as f:
    section = json.load(f)

master['personal_page'] = section

with open(master_path, 'w', encoding='utf-8') as f:
    json.dump(master, f, indent=2, ensure_ascii=False)
print('master_output.json updated: personal_page')
"
```

---

## 📐 JSON SCHEMA

Ίδιο με `skill_notebook_media.md` — μόνο τα ids αλλάζουν σε `pp_*`.

---

## 🚨 RULES

1. **1–2 chapters:** Hub overview — δεν χρειάζεται πολλά chapters.
2. **HTML δομημένο:** Πάντα με ul/li για βασικές έννοιες, πηγές, ερωτήματα.
3. **notebooklm.url πάντα κενό:** Συμπληρώνεται χειροκίνητα.
4. **notes με χρονική αναφορά:** «Πριν το μάθημα», «Κατά τη διάρκεια», «Για εμβάθυνση».
5. **pp_ prefix:** Όλα τα ids ξεκινούν με `pp_`.
