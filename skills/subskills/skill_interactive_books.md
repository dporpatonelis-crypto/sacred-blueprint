# SKILL: Interactive Books JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** Interactive Books (GitHub Pages, catalog.json, UE C++ integration)
- **Role:** Δημιουργείς σελίδες βιβλίου για το Interactive Books. Εκτελείς χωρίς άδεια για τεχνικά βήματα.
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
1. **Κείμενο πηγής** (θέμα, απόσπασμα, κεφάλαιο)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή

---

## 🔄 WORKFLOW

### STEP 1 — Extraction

Από το κείμενο εξήγαγε **3–4 σελίδες** με διαφορετικά types:
- `text` → κείμενο με παραγράφους
- `image` → εικόνα με λεζάντα
- `video` → YouTube embed
- `slides` → Google Slides embed
- `quiz` → ερώτηση με επιλογές

Εκτύπωσε σύνοψη.

---

### STEP 2 — JSON Generation

```json
{
  "pages": [
    {
      "number": 1,
      "type": "text",
      "title": "<τίτλος σελίδας>",
      "subtitle": "<υπότιτλος>",
      "content": ["<παράγραφος 1>", "<παράγραφος 2>"],
      "image": "",
      "videoId": "",
      "slidesUrl": ""
    }
  ]
}
```

**Κανόνες ανά type:**
- `text`: `content` array με 2-3 strings, υπόλοιπα κενά
- `image`: `image` με URL, `content` με λεζάντα
- `video`: `videoId` με YouTube ID μόνο (π.χ. `"dQw4w9WgXcQ"`)
- `slides`: `slidesUrl` με embed URL

Εκτύπωσε σε code block.

---

### STEP 3 — Write to Workspace

```bash
python3 -c "
import json, os
data = <GENERATED_JSON>
path = os.path.expanduser('~/sacred-blueprint/data/current/books.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

---

### STEP 4 — Summary Report

```
[LOG] Interactive Books
  Pages        : N
  Types        : text: N, image: N, video: N, slides: N
  Media URLs   : filled: N / empty: N
  File         : ~/sacred-blueprint/data/current/books.json
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

section_path = os.path.expanduser('~/sacred-blueprint/data/current/books.json')
with open(section_path, 'r', encoding='utf-8') as f:
    section = json.load(f)

master['books'] = section

with open(master_path, 'w', encoding='utf-8') as f:
    json.dump(master, f, indent=2, ensure_ascii=False)
print('master_output.json updated: books')
"
```

---

## 📐 JSON SCHEMA

```json
{
  "pages": [
    {
      "number": 1,
      "type": "text | image | video | slides | quiz",
      "title": "string",
      "subtitle": "string",
      "content": ["string"],
      "image": "string (URL ή κενό)",
      "videoId": "string (YouTube ID ή κενό)",
      "slidesUrl": "string (URL ή κενό)"
    }
  ]
}
```

---

## 🚨 RULES

1. **3–4 σελίδες:** Ελάχιστο 3, μέγιστο 4.
2. **Ποικιλία types:** Τουλάχιστον 2 διαφορετικοί types αν το υλικό το επιτρέπει.
3. **videoId = μόνο ID:** Όχι πλήρες URL.
4. **Κενά media ΟΚ:** Καλύτερο κενό string από λάθος URL.
5. **content πάντα array:** Ακόμα κι αν είναι 1 παράγραφος, να είναι `["string"]`.
