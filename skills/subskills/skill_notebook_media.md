# SKILL: Notebook Media JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** Notebook Media (Samsung tablet/S Pen, handwriting fonts, chapter tabs, JSON import/export)
- **Role:** Δημιουργείς chapters με πλούσιο εκπαιδευτικό περιεχόμενο και πλήρη media skeleton. Εκτελείς χωρίς άδεια για τεχνικά βήματα.
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
1. **Κείμενο πηγής** (θέμα, σημειώσεις, απόσπασμα)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή

---

## 🔄 WORKFLOW

### STEP 1 — Extraction

Από το κείμενο εξήγαγε:
- **1–2 chapters** (ένα κεφάλαιο ανά μεγάλη θεματική ενότητα)
- Τίτλο notebook και κάθε chapter
- Εκπαιδευτικό περιεχόμενο ως HTML (bold, em, ul/li επιτρέπονται)
- Plain text έκδοση για αναζήτηση
- 2 stickies (σύντομες σημειώσεις για τον δάσκαλο)
- Media skeleton: audio, slides, notebooklm, pdf, text

Εκτύπωσε σύνοψη.
> Σημείωση: το master_output.json δημιουργείται αυτόματα στο STEP 5 — δεν χρειάζεται να υπάρχει εκ των προτέρων.

---

### STEP 2 — JSON Generation

```json
{
  "title": "<τίτλος notebook>",
  "date": "<YYYY-MM-DD σήμερα>",
  "chapters": [
    {
      "index": 1,
      "title": "<τίτλος κεφαλαίου>",
      "html": "<p><strong>Θέμα:</strong> <περιγραφή></p>",
      "text": "<ίδιο ως plain text>",
      "stickies": ["<σημείωση 1>", "<σημείωση 2>"],
      "media": {
        "audio":      [{"id":"mi_audio_1","label":"<τίτλος>","url":"","notes":"<πότε>"}],
        "slides":     [{"id":"mi_slides_1","label":"<τίτλος>","url":"","notes":"<πότε>"}],
        "notebooklm": [{"id":"mi_nlm_1","label":"NotebookLM — <θέμα>","url":"","notes":"<ερώτηση>"}],
        "pdf":        [{"id":"mi_pdf_1","label":"<τίτλος>","url":"","notes":"<σελίδες>"}],
        "text":       [{"id":"mi_text_1","label":"<τίτλος>","url":"","content":"<απόσπασμα>","notes":""}]
      }
    }
  ]
}
```

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
path = os.path.expanduser('~/sacred-blueprint/data/current/notebook.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

---

### STEP 4 — Summary Report

```
[LOG] Notebook Media
  Title        : <τίτλος>
  Chapters     : N
  Media filled : audio: N, slides: N, notebooklm: N, pdf: N, text: N
  File         : ~/sacred-blueprint/data/current/notebook.json
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

section_path = os.path.expanduser('~/sacred-blueprint/data/current/notebook.json')
with open(section_path, 'r', encoding='utf-8') as f:
    section = json.load(f)

master['notebook'] = section

with open(master_path, 'w', encoding='utf-8') as f:
    json.dump(master, f, indent=2, ensure_ascii=False)
print('master_output.json updated: notebook')
"
```

---

## 📐 JSON SCHEMA

```json
{
  "title": "string",
  "date": "YYYY-MM-DD",
  "chapters": [
    {
      "index": 1,
      "title": "string",
      "html": "string (HTML)",
      "text": "string (plain)",
      "stickies": ["string", "string"],
      "media": {
        "audio":       [{"id":"string","label":"string","url":"string","notes":"string"}],
        "slides":      [{"id":"string","label":"string","url":"string","notes":"string"}],
        "notebooklm":  [{"id":"string","label":"string","url":"","notes":"string"}],
        "pdf":         [{"id":"string","label":"string","url":"string","notes":"string"}],
        "text":        [{"id":"string","label":"string","url":"","content":"string","notes":"string"}]
      }
    }
  ]
}
```

---

## 🚨 RULES

1. **1–2 chapters:** Δεν υπερβαίνεις τα 2 ανά κλήση.
2. **HTML πάντα valid:** Μόνο `<p>`, `<strong>`, `<em>`, `<ul>`, `<li>`.
3. **notebooklm.url πάντα κενό:** Συμπληρώνεται χειροκίνητα.
4. **notes υποχρεωτικά:** Κάθε media item έχει notes που εξηγούν πότε/πώς χρησιμοποιείται.
5. **ids μοναδικά:** `mi_audio_1`, `mi_slides_1` — αν 2 chapters, συνέχισε αρίθμηση.
6. **Κενά URLs ΟΚ:** Καλύτερο κενό string από εφευρημένο URL.
