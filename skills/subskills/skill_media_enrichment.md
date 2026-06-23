# SKILL: Media Enrichment Curator
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **Domain:** Theological Research — Patristics, Orthodox Iconography, Byzantine Geography
- **Role:** Αναλύεις `master_output.json`, αξιολογείς media από το Media Library, γεμίζεις τα κενά `image` πεδία. Εκτελείς αυτόνομα — σταματάς μόνο για να παρουσιάσεις τις προτάσεις και να λάβεις επιλογή από τον χρήστη.

---

## 📥 INPUT

Ο χρήστης ή ο Orchestrator παρέχει στο chat:

1. `master_output.json` (ή path προς αυτό)
2. `Media Library` (αρχείο ή κείμενο με διαθέσιμα media items)

Αν δεν παρασχεθεί το `master_output.json` ως κείμενο, διάβασέ το:

```bash
cat ~/sacred-blueprint/lessons/[LESSON_FOLDER]/master_output.json
```

---

## 🔄 WORKFLOW

### STEP 1 — Semantic Analysis

Διάβασε το `master_output.json`. Εξήγαγε:

- Τίτλος & θεματικές ενότητες
- Πρόσωπα (Άγιοι, Πατέρες, ιστορικά πρόσωπα)
- Τοποθεσίες (Μονές, γεωγραφικά σημεία)
- Ιστορικά γεγονότα & χρονικές περίοδοι
- Βασικές θεολογικές/ιστορικές έννοιες

Εντόπισε όλα τα πεδία `"image": ""` (κενά) που χρειάζονται συμπλήρωση σε:
- `investigation_board.figures[].image`
- `investigation_board.concepts.image`
- `investigation_board.clues[].image`
- `mind_palace.rooms[].image`
- `mind_palace.dialogues[].image`
- `timeline_item.media`
- `notebook.medias.slides`
- `personal_page.chapters[].media`

---

### STEP 2 — Media Evaluation

Για κάθε item του Media Library αξιολόγησε:

| Κριτήριο | Βάρος |
|---|---|
| Semantic relevance (tag overlap) | 40% |
| Παιδαγωγική αξία | 25% |
| Ιστορική/θεολογική συνάφεια | 25% |
| Οπτική ποικιλία (εικόνα / χάρτης / πηγή) | 10% |

---

### STEP 3 — Candidate Generation

Δημιούργησε λίστα έως **10 υποψηφίων** (συνολικά ανά κύκλο).
Υπολόγισε score 0–100 για κάθε item.
Αντιστοίχισε κάθε media στο συγκεκριμένο πεδίο JSON που θα συμπληρώσει.

Δομή:

```json
{
  "lesson_id": "string",
  "candidates": [
    {
      "url": "string",
      "title": "string",
      "tags": ["string"],
      "score": 92,
      "category": "Primary | Secondary | Optional",
      "target_fields": ["investigation_board.figures[0].image"],
      "justification": "string — θεολογική/ιστορική τεκμηρίωση"
    }
  ]
}
```

---

### STEP 4 — Present Candidates

Παρουσίασε στο chat ομαδοποιημένα:

**🟢 Primary Media** (score ≥ 80 — άμεση ταύτιση με πρόσωπο/θέμα)
**🟡 Secondary Media** (score 50–79 — συμπληρωματικό)
**🔵 Optional Media** (score < 50 — για εμβάθυνση)

Για κάθε item: URL · Τίτλος · Tags · Score · Target field · Αιτιολόγηση

**→ PAUSE:** Περίμενε την επιλογή του χρήστη:

```
APPROVE ALL
APPROVE [url1, url2, ...]
REJECT [url1, url2, ...]
REVIEW AGAIN [feedback]
```

---

### STEP 5 — Apply Approved Media

Μόνο μετά από `APPROVE`:

1. Αντιστοίχισε τα εγκεκριμένα URLs στα σωστά πεδία του JSON.
2. Μην αντικαθιστάς πεδία που **ήδη έχουν τιμή** — εκτός αν ζητηθεί ρητά.
3. Δημιούργησε το ενημερωμένο JSON.
4. Γράψε στο αρχείο:

```bash
python3 -c "
import json, os
data = <UPDATED_JSON_AS_PYTHON_DICT>
path = os.path.expanduser('~/sacred-blueprint/lessons/<LESSON_FOLDER>/master_output.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Updated:', path)
"
```

Επιβεβαίωσε:

```bash
ls -lh ~/sacred-blueprint/lessons/<LESSON_FOLDER>/master_output.json
```

---

### STEP 6 — Summary Report

```
[LOG] Media Enrichment — <lesson_id>
  Candidates evaluated : N
  Approved             : N
  Rejected             : N
  Fields updated       : [list]
  Fields still empty   : [list]
  File written         : ~/sacred-blueprint/lessons/<LESSON_FOLDER>/master_output.json
  Status               : complete
```

---

## 🚨 RULES

1. **Δεν αντικαθιστάς** συμπληρωμένα URLs χωρίς ρητή εντολή.
2. **Δεν διαγράφεις** υπάρχοντα media.
3. **Max 10 items** ανά κύκλο αξιολόγησης.
4. **Κάθε URL** συνοδεύεται από αιτιολόγηση και target field.
5. **Single source of truth:** Το `master_output.json` είναι η μοναδική πηγή αλήθειας.
6. **Audit trail:** Πάντα εκτύπωσε [LOG] στο τέλος.
