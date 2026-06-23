# SKILL: Investigation Board JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** Investigation Board (Lovable/Vercel, Google Sheets sync, GitHub → Vercel pipeline)
- **Role:** Δημιουργείς clues για το Investigation Board από κείμενο ή υπάρχον JSON. Εκτελείς χωρίς άδεια για τεχνικά βήματα.

---

## 📥 INPUT

Ένα από τα δύο:
1. **Κείμενο πηγής** (θέμα, γεγονός, ιστορικό υλικό)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή

---

## 🔄 WORKFLOW

### STEP 1 — Semantic Extraction

Από το κείμενο εξήγαγε:
- Κεντρικό θέμα (1 πρόταση)
- Ενδείξεις (clues): αποδείξεις, υπόπτους, σημειώσεις, αντιφάσεις
- Τύπος κάθε clue: `evidence` | `suspect` | `note`
- Βαρύτητα κάθε clue για την έρευνα

Στόχος: **5–7 clues** με ποικιλία types.

Εκτύπωσε σύνοψη.

---

### STEP 2 — JSON Generation

```json
{
  "topic": "<κεντρικό θέμα ερεύνης>",
  "clues": [
    {
      "title": "<σύντομος τίτλος>",
      "description": "<αναλυτική περιγραφή clue, 2-3 προτάσεις>",
      "type": "evidence | suspect | note"
    }
  ]
}
```

Κατανομή types: τουλάχιστον 2 `evidence`, 1 `suspect`, 2 `note`.

Εκτύπωσε σε code block.

---

### STEP 3 — Write to Workspace

```bash
python3 -c "
import json, os
data = <GENERATED_JSON>
path = os.path.expanduser('~/sacred-blueprint/data/current/investigation.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

---

### STEP 4 — Summary Report

```
[LOG] Investigation Board
  Topic        : <θέμα>
  Clues        : N (evidence: N, suspect: N, note: N)
  File         : ~/sacred-blueprint/data/current/investigation.json
  Status       : complete
```

---

## 📐 JSON SCHEMA

```json
{
  "topic": "string",
  "clues": [
    {
      "title": "string",
      "description": "string",
      "type": "evidence | suspect | note"
    }
  ]
}
```

---

## 🚨 RULES

1. **5–7 clues:** Ελάχιστο 5, μέγιστο 7.
2. **Ποικιλία types:** Τουλάχιστον ένας από κάθε type.
3. **Descriptions:** Κάθε description 2–3 προτάσεις — αρκετά αναλυτικό για τον μαθητή.
4. **Μόνο από πηγή:** Δεν επινοείς clues που δεν τεκμηριώνονται στο κείμενο.
5. **Overwrite ΟΚ:** Το investigation.json αντικαθίσταται κάθε φορά (δεν accumulates όπως το timeline).
