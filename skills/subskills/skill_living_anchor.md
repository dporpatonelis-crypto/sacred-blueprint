# SKILL: Living Anchor JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** Living Anchor (layered text annotation, JSON export)
- **Role:** Δημιουργείς anchors με τριεπίπεδη ανάλυση (literal → structural → critical) και αιτιακές συνδέσεις. Εκτελείς χωρίς άδεια για τεχνικά βήματα.
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
1. **Κείμενο πηγής** (απόσπασμα, θέμα, σημειώσεις)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή

---

## 🔄 WORKFLOW

### STEP 1 — Extraction

Από το κείμενο εξήγαγε **3–4 φράσεις-κλειδιά** (anchors).

Για κάθε anchor:
- **Phrase:** Η ακριβής φράση ή έννοια από το κείμενο
- **Literal layer:** Τι λέει κυριολεκτικά (τι, ποιος, πότε)
- **Structural layer:** Πώς συνδέεται με τη δομή του θέματος
- **Critical layer:** Ποια η σημασία, ποια αντίθεση ή παράδοξο εγείρει
- **Cause:** Τι προκάλεσε αυτή τη φράση/κατάσταση
- **Consequence:** Τι προκάλεσε με τη σειρά της

Εκτύπωσε σύνοψη.
> Σημείωση: το master_output.json δημιουργείται αυτόματα στο STEP 5 — δεν χρειάζεται να υπάρχει εκ των προτέρων.

---

### STEP 2 — JSON Generation

```json
{
  "metadata": {
    "title": "<τίτλος μαθήματος>",
    "source": "<πηγή κειμένου>",
    "date": "<YYYY-MM-DD σήμερα>"
  },
  "anchors": [
    {
      "id": "<slug π.χ. 'homoousion'>",
      "phrase": "<φράση-κλειδί>",
      "layers": {
        "literal": "<τι λέει κυριολεκτικά>",
        "structural": "<πώς λειτουργεί στο κείμενο/θέμα>",
        "critical": "<γιατί έχει σημασία — αντίθεση, παράδοξο, σύνδεση με παρόν>"
      },
      "causality": {
        "cause": "<τι το προκάλεσε>",
        "consequence": "<τι προκάλεσε>"
      }
    }
  ]
}
```

Εκτύπωσε σε code block.

---

### STEP 3 — Write to Workspace

```bash
python3 -c "
import json, os
data = <GENERATED_JSON>
path = os.path.expanduser('~/sacred-blueprint/data/current/anchor.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

---

### STEP 4 — Summary Report

```
[LOG] Living Anchor
  Title        : <τίτλος>
  Source       : <πηγή>
  Anchors      : N
  Layers       : literal / structural / critical (όλα συμπληρωμένα)
  File         : ~/sacred-blueprint/data/current/anchor.json
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

section_path = os.path.expanduser('~/sacred-blueprint/data/current/anchor.json')
with open(section_path, 'r', encoding='utf-8') as f:
    section = json.load(f)

master['anchor'] = section

with open(master_path, 'w', encoding='utf-8') as f:
    json.dump(master, f, indent=2, ensure_ascii=False)
print('master_output.json updated: anchor')
"
```

---

## 📐 JSON SCHEMA

```json
{
  "metadata": {"title":"string","source":"string","date":"YYYY-MM-DD"},
  "anchors": [
    {
      "id": "string (slug, lowercase, no spaces)",
      "phrase": "string",
      "layers": {"literal":"string","structural":"string","critical":"string"},
      "causality": {"cause":"string","consequence":"string"}
    }
  ]
}
```

---

## 🚨 RULES

1. **3–4 anchors:** Ελάχιστο 3, μέγιστο 4 — ποιότητα πάνω από ποσότητα.
2. **Και τα τρία layers υποχρεωτικά:** Κανένα κενό — το `critical` είναι το πιο σημαντικό.
3. **Slug ids:** Lowercase, χωρίς κενά/τόνους (π.χ. `"homoousion"`, `"periagoge"`).
4. **Causality:** Και τα δύο πεδία πρέπει να είναι συγκεκριμένα — όχι γενικόλογα.
5. **Μόνο από πηγή:** Οι anchors επιλέγονται από το κείμενο, δεν επινοούνται.
