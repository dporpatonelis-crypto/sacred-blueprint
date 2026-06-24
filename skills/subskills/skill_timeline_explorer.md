# SKILL: Timeline Explorer JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** Timeline Explorer (Leaflet.js, standalone HTML, localStorage, UE broadcast)
- **Role:** Μετατρέπεις κείμενο ή υπάρχον JSON σε εγγραφή Timeline Explorer. Εκτελείς χωρίς να ζητάς άδεια για κάθε βήμα.
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
1. **Κείμενο πηγής** (θέμα, χρονολογία, γεγονός)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή — δήλωσε την πηγή (π.χ. `anchor`, `investigation`)

---

## 🔄 WORKFLOW

### STEP 1 — Εξαγωγή χρονικών/γεωγραφικών δεδομένων

Από το κείμενο ή JSON εξήγαγε:
- Χρονολογία ή εύρος (π.χ. `"726–843 μ.Χ."`)
- Τίτλο γεγονότος (σύντομος, max 8 λέξεις)
- Σύντομη περιγραφή (1 πρόταση)
- Τοποθεσία (πόλη, περιοχή, μοναστήρι)
- Συντεταγμένες lat/lng (χρησιμοποίησε γνωστές τιμές για ιστορικούς τόπους· αν αγνοείς, βάλε 0)
- Zoom (5=ήπειρος, 7=χώρα, 10=πόλη, 13=μνημείο)
- URL εικόνας (κενό αν δεν υπάρχει)
- URL Google Slides (κενό αν δεν υπάρχει)

Εκτύπωσε σύνοψη εξαγόμενων πριν προχωρήσεις.
> Σημείωση: το master_output.json δημιουργείται αυτόματα στο STEP 5 — δεν χρειάζεται να υπάρχει εκ των προτέρων.

---

### STEP 2 — JSON Generation

Δημιούργησε **έναν** Timeline entry. Χρησιμοποίησε `Date.now()` ως id (ή αριθμό timestamp που παράγεις εσύ):

```json
[
  {
    "id": 1773388754927,
    "year": "<χρονολογία ή εύρος>",
    "title": "<τίτλος>",
    "desc": "<1 πρόταση>",
    "img": "<URL εικόνας ή κενό>",
    "location": "<τοποθεσία>",
    "lat": 0,
    "lng": 0,
    "zoom": 7,
    "slides": "<Google Slides URL ή κενό>"
  }
]
```

> Το JSON είναι **array** (ξεκινάει με `[`), ακόμα κι αν έχει μία εγγραφή.

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
path = os.path.expanduser('~/sacred-blueprint/data/current/timeline.json')
if os.path.exists(path):
    with open(path, 'r', encoding='utf-8') as f:
        existing = json.load(f)
    existing.extend(data)
    data = existing
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written. Total entries:', len(data))
"
```

---

### STEP 4 — Summary Report

```
[LOG] Timeline Explorer
  Entry title  : <τίτλος>
  Year         : <χρονολογία>
  Location     : <τοποθεσία> (lat, lng)
  Media        : img=<ok/empty> slides=<ok/empty>
  File         : ~/sacred-blueprint/data/current/timeline.json
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

section_path = os.path.expanduser('~/sacred-blueprint/data/current/timeline.json')
with open(section_path, 'r', encoding='utf-8') as f:
    section = json.load(f)

master['timeline_item'] = section

with open(master_path, 'w', encoding='utf-8') as f:
    json.dump(master, f, indent=2, ensure_ascii=False)
print('master_output.json updated: timeline_item')
"
```

---

## 📐 JSON SCHEMA

```json
[
  {
    "id": 1773388754927,
    "year": "string",
    "title": "string",
    "desc": "string",
    "img": "string (URL ή κενό)",
    "location": "string",
    "lat": 0,
    "lng": 0,
    "zoom": 7,
    "slides": "string (URL ή κενό)"
  }
]
```

**Γνωστές συντεταγμένες για συχνά θέματα:**

| Τόπος | lat | lng | zoom |
|---|---|---|---|
| Κωνσταντινούπολη | 41.008 | 28.978 | 12 |
| Θεσσαλονίκη | 40.640 | 22.944 | 12 |
| Ιεροσόλυμα | 31.768 | 35.213 | 13 |
| Καισάρεια Καππαδοκίας | 38.723 | 35.487 | 10 |
| Αλεξάνδρεια | 31.200 | 29.918 | 12 |
| Αντιόχεια | 36.201 | 36.160 | 11 |
| Νίκαια | 40.430 | 29.720 | 12 |
| Χαλκηδόνα | 40.992 | 29.030 | 12 |
| Αθήνα | 37.975 | 23.735 | 12 |
| Ρώμη | 41.902 | 12.496 | 12 |

---

## 🚨 RULES

1. **Array πάντα:** Το output είναι `[...]` ακόμα κι αν έχει 1 εγγραφή.
2. **Append, όχι overwrite:** Αν υπάρχει timeline.json, πρόσθεσε — μην αντικαταστήσεις.
3. **Μοναδικό id:** Χρησιμοποίησε timestamp-style αριθμό.
4. **Κενά fields:** `img` και `slides` παραμένουν κενά strings `""` αν δεν υπάρχουν URLs — ποτέ `null`.
5. **Zoom λογικό:** Μην βάλεις zoom > 14 ή < 4.
