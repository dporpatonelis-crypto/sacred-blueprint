# SKILL: History Explorer 3D JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** History Explorer 3D (React Three Fiber, curved screens, NPC models, Firebase Storage)
- **Role:** Δημιουργείς JSON με characters, dialogs, facts και screens για το 3D περιβάλλον. Εκτελείς χωρίς άδεια για τεχνικά βήματα.
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
1. **Κείμενο πηγής** (ιστορικό θέμα με πρόσωπα και γεγονότα)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή

---

## 🔄 WORKFLOW

### STEP 1 — Extraction

Από το κείμενο εξήγαγε:
- **2 χαρακτήρες** (ιστορικά πρόσωπα που θα είναι NPCs στο 3D περιβάλλον)
- **2 διαλόγους** (ένας ανά χαρακτήρα) με trigger, κείμενο, επιλογές απάντησης
- **3 facts** (συνοπτικά ιστορικά στοιχεία για τα panels)
- **Background** (επιλογή: `bg-agora.jpg` | `bg-library.jpg` | `bg-temple.jpg` | `bg-palace.jpg`)

Εκτύπωσε σύνοψη.
> Σημείωση: το master_output.json δημιουργείται αυτόματα στο STEP 5 — δεν χρειάζεται να υπάρχει εκ των προτέρων.

### STEP 1b — Επιβεβαίωση εξαγόμενων

Πριν παράγεις JSON, εκτύπωσε τα εξαγόμενα στοιχεία σε ανθρώπινη μορφή και ζήτησε επιβεβαίωση:
📋 Εξαγόμενα στοιχεία — επιβεβαίωσε πριν συνεχίσω:
Πρόσωπα     : <λίστα>

Χρονολογίες : <λίστα>

Τοποθεσίες  : <λίστα>

Βασικές έννοιες : <λίστα>

Τίτλος      : <τίτλος που θα χρησιμοποιηθεί>
Είναι σωστά; Απάντησε OK για να συνεχίσω, ή διόρθωσε ό,τι χρειάζεται.

**→ PAUSE:** Περίμενε απάντηση. Αν ο χρήστης διορθώσει, ενσωμάτωσε τις αλλαγές και μη ρωτήσεις ξανά.

---

### STEP 2 — JSON Generation

```json
{
  "characters": [
    {
      "id": "char_1",
      "name": "<Όνομα χαρακτήρα>",
      "role": "<ρόλος/τίτλος>",
      "description": "<σύντομη βιογραφία, 1-2 προτάσεις>",
      "position_x": 0, "position_y": 0, "position_z": 0, "rotation": 0
    },
    {
      "id": "char_2",
      "name": "<Όνομα χαρακτήρα>",
      "role": "<ρόλος/τίτλος>",
      "description": "<σύντομη βιογραφία>",
      "position_x": 3, "position_y": 0, "position_z": 0, "rotation": 180
    }
  ],
  "dialogs": [
    {
      "character_id": "char_1",
      "trigger": "<τι κάνει ο μαθητής για να ξεκινήσει τον διάλογο>",
      "text": "<ρήση του χαρακτήρα, 2-3 προτάσεις>",
      "response_options": ["<επιλογή 1>", "<επιλογή 2>"]
    },
    {
      "character_id": "char_2",
      "trigger": "<trigger για char_2>",
      "text": "<ρήση char_2>",
      "response_options": ["<επιλογή 1>", "<επιλογή 2>"]
    }
  ],
  "facts": [
    {"id": "fact_1", "title": "<τίτλος>", "content": "<2-3 προτάσεις>", "era": "<χρονική περίοδος>"},
    {"id": "fact_2", "title": "<τίτλος>", "content": "<περιεχόμενο>", "era": "<εποχή>"},
    {"id": "fact_3", "title": "<τίτλος>", "content": "<περιεχόμενο>", "era": "<εποχή>"}
  ],
  "screens": {
    "title": "<τίτλος σκηνής>",
    "background": "bg-agora.jpg"
  }
}
```

**Επιλογή background:**
- `bg-agora.jpg` → Αρχαία Αγορά (φιλοσοφία, δημοκρατία, αρχαιότητα)
- `bg-library.jpg` → Βιβλιοθήκη (θεολογία, Πατέρες, κείμενα)
- `bg-temple.jpg` → Ναός (λειτουργία, εικόνες, Βυζάντιο)
- `bg-palace.jpg` → Παλάτι (αυτοκράτορες, πολιτική ιστορία)

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

---

### STEP 3 — Write to Workspace

```bash
python3 -c "
import json, os
data = <GENERATED_JSON>
path = os.path.expanduser('~/sacred-blueprint/data/current/history3d.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

---

### STEP 4 — Summary Report

```
[LOG] History Explorer 3D
  Characters   : N
  Dialogs      : N
  Facts        : N
  Background   : <bg-*.jpg>
  File         : ~/sacred-blueprint/data/current/history3d.json
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

section_path = os.path.expanduser('~/sacred-blueprint/data/current/history3d.json')
with open(section_path, 'r', encoding='utf-8') as f:
    section = json.load(f)

master['history3d'] = section

with open(master_path, 'w', encoding='utf-8') as f:
    json.dump(master, f, indent=2, ensure_ascii=False)
print('master_output.json updated: history3d')
"
```

---

## 📐 JSON SCHEMA

```json
{
  "characters": [
    {"id":"string","name":"string","role":"string","description":"string",
     "position_x":0,"position_y":0,"position_z":0,"rotation":0}
  ],
  "dialogs": [
    {"character_id":"string","trigger":"string","text":"string",
     "response_options":["string","string"]}
  ],
  "facts": [
    {"id":"string","title":"string","content":"string","era":"string"}
  ],
  "screens": {"title":"string","background":"bg-agora.jpg"}
}
```

---

## 🚨 RULES

1. **Ακριβώς 2 characters:** Δεν λιγότερο, δεν περισσότερο.
2. **character_id στα dialogs:** Πρέπει να ταιριάζει με `char_1` / `char_2`.
3. **Positions:** Οι χαρακτήρες δεν στέκονται στο ίδιο σημείο — `position_x` να διαφέρει.
4. **Facts max 3:** Συνοπτικά, εκπαιδευτικά, χωρίς Wikipedia-style μήκος.
5. **Background επιλογή:** Ταίριαξε με τη θεματική του μαθήματος.
6. **Μόνο από πηγή:** Οι ρήσεις των χαρακτήρων αντικατοπτρίζουν πραγματικές θέσεις τους.
