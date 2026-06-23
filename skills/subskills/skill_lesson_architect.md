# SKILL: Lesson JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint/lessons`
- **Domain:** Theological Research — Patristics, Church History, Orthodox Dogmatics
- **Role:** Μετατρέπεις κείμενο πηγής σε πλήρως δομημένο JSON μαθήματος (Investigation Board + Mind Palace). Εκτελείς χωρίς να ζητάς «άδεια» για κάθε βήμα — εκτελείς, αναφέρεις, προχωράς.

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
- **Επιχειρήματα & Αντιφάσεις:** θέσεις, αντιθέσεις, αντιπαραθέσεις
- **Συνδέσεις:** συμφωνία, αντίθεση, αναπτυξιακή σχέση μεταξύ εννοιών

Εκτύπωσε σύνοψη εξαγόμενων στοιχείων πριν προχωρήσεις.

---

### STEP 2 — JSON Draft Generation

Δημιούργησε το JSON ακολουθώντας **ακριβώς** το παρακάτω schema.
Άφησε κενά (`""`) τα πεδία `image` — συμπληρώνονται από `skill_media_enrichment`.
Μην υπερβαίνεις: **12 clues**, **8 connections**, **6 rooms**.

Εκτύπωσε το πλήρες JSON σε code block.

---

### STEP 3 — Write to Workspace

Γράψε το JSON στον φάκελο:
`~/sacred-blueprint/lessons/<case_id>/<case_id>.json`

Αν ο φάκελος δεν υπάρχει, δημιούργησέ τον:

```bash
mkdir -p ~/sacred-blueprint/lessons/<case_id>
```

Γράψε το αρχείο:

```bash
python3 -c "
import json
data = <GENERATED_JSON_AS_PYTHON_DICT>
with open(os.path.expanduser('~/sacred-blueprint/lessons/<case_id>/<case_id>.json'), 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

Εναλλακτικά, αν το Continue υποστηρίζει `write_file`, χρησιμοποίησέ το απευθείας.

Επιβεβαίωσε εγγραφή:

```bash
ls -lh ~/sacred-blueprint/lessons/<case_id>/<case_id>.json
```

---

### STEP 4 — Summary Report

Εκτύπωσε:

```
[LOG] Lesson Architect — <case_id>
  Figures extracted : N
  Clues generated   : N
  Connections       : N
  Rooms (Mind Palace): N
  File written      : ~/sacred-blueprint/lessons/<case_id>/<case_id>.json
  Image fields      : empty (pending skill_media_enrichment)
  Status            : complete
```

Ρώτησε αν ο χρήστης θέλει να καλέσει αμέσως το `@skill_media_enrichment`.

---

## 📐 JSON SCHEMA

```json
{
  "case_id": "string",
  "title": "string",
  "method": "comparative | chronological | thematic",
  "status": "complete",
  "investigation_board": {
    "figures": [
      {
        "name": "string",
        "work": "string",
        "era": "string",
        "image": ""
      }
    ],
    "concepts": {
      "core": "string (έννοιες χωρισμένες με ·)",
      "image": ""
    },
    "clues": [
      {
        "id": "c1",
        "title": "string",
        "content": "string",
        "source": "string",
        "type": "argument | contradiction | evidence | synthesis",
        "difficulty": 1,
        "image": ""
      }
    ],
    "connections": [
      {
        "from": "c1",
        "to": "c2",
        "type": "contrast | development | agreement",
        "description": "string"
      }
    ]
  },
  "mind_palace": {
    "rooms": [
      {
        "id": "r1",
        "name": "string",
        "theme": "library | temple | court | classroom",
        "unlock_requirements": ["c1"],
        "central_question": "string",
        "image": ""
      }
    ],
    "dialogues": [
      {
        "room_id": "r1",
        "greeting": "string (όνομα ομιλητή)",
        "questions": ["string"],
        "suggested_answers": ["string"],
        "revelation": "string",
        "image": ""
      }
    ]
  }
}
```

---

## 🚨 RULES

1. **Μόνο από πηγή:** Όλα τα clues, figures, connections προέρχονται αποκλειστικά από το κείμενο εισόδου. Δεν επινοείς.
2. **Δεν αντικαθιστάς υπάρχον αρχείο** χωρίς να ρωτήσεις (overwrite ή rename).
3. **Τα image fields μένουν κενά** — είναι ευθύνη του `skill_media_enrichment`.
4. **Όρια:** max 12 clues, 8 connections, 6 rooms ανά draft.
5. **Single source of truth:** Το `<case_id>.json` είναι η μοναδική πηγή για το μάθημα.
