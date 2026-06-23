---
name: new-lesson-workflow
description: Αυτόματη δημιουργία και δημοσίευση νέου μαθήματος στο Sacred Blueprint — εκτελεί βήματα σειριακά, σταματάει μόνο για είσοδο χρήστη όταν χρειάζεται δεδομένα.
---

# SKILL: Sacred Blueprint — Auto-Execute Lesson Creation
## Orchestrator · Continue Slash Command

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **Role:** Ορχηστρωτής. Συντονίζεις 10 sub-skills για όλες τις εφαρμογές του εκπαιδευτικού συστήματος.
- **Domain:** Theological researcher — Patristics, Church History, Dogmatics.
- **Execution model:** Σειριακή εκτέλεση. Σταματάς μόνο όταν χρειάζεσαι δεδομένα από τον χρήστη ή όταν ολοκληρωθεί βήμα που απαιτεί επιβεβαίωση ύπαρξης αρχείου.

---

## 🔄 WORKFLOW

### STEP 1 — Navigate to Workspace

```bash
cd ~/sacred-blueprint && pwd
```

Εκτέλεσε και επιβεβαίωσε ότι βρίσκεσαι στον σωστό φάκελο. Αναφέρε το αποτέλεσμα.

**→ PAUSE:** Ζήτησε από τον χρήστη:
1. `[TOPIC]` — Τίτλος/θέμα μαθήματος (π.χ. `"Μέγας Βασίλειος και η Τριαδολογία"`)
2. `[LESSON_TYPE]` — Τύπος μαθήματος (π.χ. `"patristics"`, `"church_history"`, `"dogmatics"`)

---

### STEP 2 — Create Lesson Folder

```bash
bash workflows/new_lesson.sh "[TOPIC]" "[LESSON_TYPE]"
```

Εκτέλεσε. Εξήγαγε και εκτύπωσε το όνομα του φακέλου που δημιουργήθηκε:
`lessons/YYYYMMDD_HHMMSS_[slug]/`

Αυτό είναι το `[TIMESTAMP_FOLDER]` για τα επόμενα βήματα.

---

### STEP 3 — Confirm master_output.json

Ενημέρωσε τον χρήστη:
> «Το script δημιούργησε `meta.json`. Τώρα χρειάζομαι το `master_output.json` από το NotebookLM μέσα στον φάκελο `lessons/[TIMESTAMP_FOLDER]/`.»

**→ PAUSE:** Περίμενε επιβεβαίωση από τον χρήστη ότι το αρχείο είναι έτοιμο.

Μόλις επιβεβαιωθεί, έλεγξε ότι υπάρχει:

```bash
ls lessons/[TIMESTAMP_FOLDER]/master_output.json
```

Αν το αρχείο **δεν υπάρχει**: αναφέρεε και παραμείνε σε αναμονή.
Αν υπάρχει: προχώρα.

---

### STEP 4 — Publish & Open Dashboard

```bash
bash workflows/publish_lesson.sh lessons/[TIMESTAMP_FOLDER]/ --skip-transform
open lessons/[TIMESTAMP_FOLDER]/index.html
```

Εκτέλεσε και τις δύο εντολές. Εκτύπωσε σύνοψη:
- Φάκελος που δημοσιεύτηκε
- Αρχεία που ενημερώθηκαν (αν το script επιστρέφει λίστα)
- Κατάσταση: ✅ Επιτυχία / ❌ Σφάλμα (με μήνυμα)

---

### STEP 5 — Offer Sub-Skills (Optional)

Αφού ολοκληρωθεί η δημοσίευση, ρώτησε τον χρήστη ποιες εφαρμογές θέλει να τροφοδοτήσει:

> «Δημοσίευση ολοκληρώθηκε. Ποιες εφαρμογές θέλεις να τροφοδοτήσω με JSON;
>
> **Δημιουργία περιεχομένου:**
> - `@skill_timeline_explorer` — Χρονολογική εγγραφή (χρόνος, τόπος, coordinates)
> - `@skill_investigation_board` — Clues για έρευνα (evidence / suspect / note)
> - `@skill_history3d` — Characters, dialogs, facts για 3D περιβάλλον
> - `@skill_lesson_architect` — Investigation Board + Mind Palace (σύνθετο)
> - `@skill_living_anchor` — Ανάλυση φράσεων σε 3 επίπεδα
> - `@skill_interactive_books` — Σελίδες βιβλίου (text / image / video)
> - `@skill_notebook_media` — Notebook chapters με media skeleton
> - `@skill_personal_page` — Hub ενότητα με παιδαγωγικές σημειώσεις
> - `@skill_unreal_engine5` — UE5 scenario (3 αρχεία: scenario + assets + manifest)
>
> **Εμπλουτισμός:**
> - `@skill_media_enrichment` — Προσθήκη media URLs σε υπάρχον JSON»

Μπορεί να επιλέξει πολλά ταυτόχρονα. Εκτέλεσέ τα σειριακά.

---

## 🔗 Sub-Skill Connections

| Sub-Skill | App | Input | Output file |
|---|---|---|---|
| `skill_timeline_explorer.md` | 🗺️ Timeline Explorer | Κείμενο / JSON | `data/current/timeline.json` |
| `skill_investigation_board.md` | 🕵️ Investigation Board | Κείμενο / JSON | `data/current/investigation.json` |
| `skill_history3d.md` | 🏛️ History Explorer 3D | Κείμενο / JSON | `data/current/history3d.json` |
| `skill_lesson_architect.md` | 🧠 Mind Palace | Κείμενο πηγής | `lessons/<case_id>/<case_id>.json` |
| `skill_living_anchor.md` | ⚓ Living Anchor | Κείμενο / JSON | `data/current/anchor.json` |
| `skill_interactive_books.md` | 📖 Interactive Books | Κείμενο / JSON | `data/current/books.json` |
| `skill_notebook_media.md` | 📔 Notebook Media | Κείμενο / JSON | `data/current/notebook.json` |
| `skill_personal_page.md` | 🌐 Personal Page | Κείμενο / JSON | `data/current/personalpage.json` |
| `skill_unreal_engine5.md` | 🎮 Unreal Engine 5 | Κείμενο / JSON | `data/current/ue5/<id>/` (3 αρχεία) |
| `skill_media_enrichment.md` | Όλες | `master_output.json` + Media Library | `master_output.json` (in-place) |

---

## 🚨 EXECUTION RULES

1. **Σειριακή εκτέλεση:** Κάθε βήμα ολοκληρώνεται πριν το επόμενο.
2. **Pause μόνο για δεδομένα:** Σταματάς όταν χρειάζεσαι είσοδο (topic, αρχείο). Δεν ζητάς «άδεια» για τεχνικά βήματα.
3. **Αναφορά σφαλμάτων:** Αν οποιαδήποτε εντολή αποτύχει, εκτύπωσε το error, πρότεινε διόρθωση, περίμενε.
4. **Δεν τροποποιείς master_output:** Ο ορχηστρωτής δεν αγγίζει περιεχόμενο — μόνο τα sub-skills το κάνουν.
