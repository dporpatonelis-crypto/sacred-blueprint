---
name: local-distribute-workflow
description: Τοπική διανομή ενεργού μαθήματος στις εφαρμογές χωρίς GitHub — αντιγράφει data/current/ στους τοπικούς φακέλους εφαρμογών.
---

# SKILL: Local Distribute — Offline Lesson Deployment
## Orchestrator · Continue Slash Command

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **Role:** Διανέμεις το ενεργό μάθημα (`data/current/`) στους **τοπικούς** φακέλους εφαρμογών, χωρίς να χρειάζεται GitHub push ή internet.
- **Σχέση με το υπόλοιπο σύστημα:** Αυτό το skill **δεν αντικαθιστά** το `publish_lesson.sh` / `sync_github.sh` — είναι εναλλακτικό τελευταίο βήμα. Το `master_output.json` και το `data/current/` παραμένουν η ίδια πηγή αλήθειας. Χρησιμοποίησέ το όταν θες άμεσο, offline αποτέλεσμα, ή όταν το GitHub Action έχει πρόβλημα.

---

## 📋 ΠΡΟΑΠΑΙΤΟΥΜΕΝΑ — Διάβασε πριν ξεκινήσεις

**Χρειάζεται ήδη να υπάρχει ενεργό μάθημα στο `data/current/`.** Αυτό σημαίνει ότι έχει ήδη τρέξει:

```bash
bash workflows/distribute.sh lessons/ΦΑΚΕΛΟΣ/
```

ή έχει ολοκληρωθεί ροή με skills (`@skill_timeline_explorer` κ.λπ.) που έγραψαν στο `data/current/` και ενημέρωσαν το `master_output.json`.

**Αν δεν υπάρχει `data/current/active_lesson.json`, σταμάτα και ενημέρωσε τον χρήστη** ότι πρέπει πρώτα να τρέξει distribute ή να ολοκληρώσει τη ροή δημιουργίας μαθήματος.

**Δομή τοπικών εφαρμογών που αναμένεται:**

```
~/apps/
├── Map-Timeline/
├── idea-weaver-board/
├── history-explorer-3d/
├── mind-palace-cases/
└── personal-page/
```

Αν ο φάκελος εφαρμογών είναι αλλού, ζήτησε το path στο STEP 1.

---

## 🔄 WORKFLOW

### STEP 1 — Επιβεβαίωση τοποθεσίας εφαρμογών

Έλεγξε αν υπάρχει ο φάκελος `~/apps/`:

```bash
ls ~/apps/ 2>/dev/null
```

**→ PAUSE:** Αν δεν υπάρχει ή είναι κενός, ρώτησε τον χρήστη:
> «Δεν βρήκα τοπικές εφαρμογές στο `~/apps/`. Πού βρίσκονται οι κλωνοποιημένοι φάκελοι (Map-Timeline, mind-palace-cases, κ.λπ.); Ή θες να τους κλωνοποιήσω τώρα;»

Αν ο χρήστης δώσει διαφορετικό path, ενημέρωσε το `APPS_DIR` στο `workflows/local_distribute.sh` αναλόγως πριν συνεχίσεις.

---

### STEP 2 — Επιβεβαίωση ενεργού μαθήματος

```bash
cat ~/sacred-blueprint/data/current/active_lesson.json
```

Εκτύπωσε σύνοψη:

```
📚 Ενεργό μάθημα: <title>
🔑 Lesson ID    : <lesson_id>
📅 Ενεργοποιήθηκε: <activated>

Διαθέσιμα αρχεία στο data/current/:
  <λίστα από timeline.json, investigation.json, κ.λπ. που υπάρχουν>
```

**→ PAUSE:** Ζήτησε επιβεβαίωση ότι αυτό είναι το σωστό μάθημα προς διανομή. Αν ο χρήστης θέλει διαφορετικό, παρέπεμψέ τον σε:
```bash
bash workflows/activate_lesson.sh lessons/ΑΛΛΟΣ_ΦΑΚΕΛΟΣ/
```
και επανέλαβε το STEP 2.

---

### STEP 3 — Εκτέλεση τοπικής διανομής

```bash
cd ~/sacred-blueprint
bash workflows/local_distribute.sh
```

Εκτέλεσε χωρίς να ζητάς περαιτέρω άδεια — είναι τεχνικό βήμα. Παρακολούθησε το output για κάθε εφαρμογή:
- `✅` = επιτυχής αντιγραφή
- `⏭` = παραλείφθηκε (είτε ο φάκελος εφαρμογής δεν υπάρχει, είτε δεν υπάρχει αντίστοιχο JSON στο data/current/)

---

### STEP 4 — Summary Report

```
[LOG] Local Distribute
  Μάθημα       : <title>
  Lesson ID    : <lesson_id>
  Apps dir     : ~/apps/

  Αποτελέσματα:
    🗺️  Timeline      : <✅/⏭>
    🕵️  Investigation : <✅/⏭>
    🏛️  History 3D    : <✅/⏭>
    🧠  Mind Palace   : <✅/⏭>
    🌐  Personal Page : <✅/⏭>

  Status: complete
```

---

### STEP 5 — Προαιρετικό: GitHub sync

Ρώτησε τον χρήστη:

> «Θέλεις να κάνω και push στο GitHub (`sync_github.sh`), ή μένει μόνο τοπικά;»

**→ PAUSE:** Αν **ναι**:
```bash
bash workflows/sync_github.sh "lesson: <title> (local + github)"
```

Αν **όχι**: σταμάτα εδώ. Οι τοπικές εφαρμογές είναι ήδη ενημερωμένες — άνοιξε απευθείας το αντίστοιχο `index.html` στον browser για να δεις το αποτέλεσμα.

---

## 🔗 Σχέση με το υπόλοιπο σύστημα

| Βήμα | Κάνει | Πότε χρησιμοποιείται |
|---|---|---|
| `new_lesson.sh` | Δημιουργεί φάκελο μαθήματος | Πάντα, πρώτο βήμα |
| Skills (`@skill_*`) | Παράγουν JSON + ενημερώνουν `master_output.json` | Πάντα, μετά το new_lesson |
| `distribute.sh` | `master_output.json` → `data/current/` | Πάντα, πριν από οποιαδήποτε διανομή |
| `sync_github.sh` | `data/current/` → GitHub push → Action → apps live | Όταν θες online deploy |
| **`local_distribute.sh`** | `data/current/` → `~/apps/*` τοπικά | Όταν θες offline/άμεσο αποτέλεσμα, ή το GitHub έχει πρόβλημα |

Τα δύο τελευταία βήματα **δεν αλληλοαποκλείονται** — μπορείς να τρέξεις και τα δύο για το ίδιο μάθημα.

---

## 🚨 RULES

1. **Δεν τροποποιεί master_output.json:** Το skill αυτό μόνο διαβάζει από `data/current/` — δεν αγγίζει τη βιβλιοθήκη ή το master.
2. **Δεν χρειάζεται internet:** Όλη η λειτουργία είναι τοπική αντιγραφή αρχείων.
3. **Skip, όχι fail:** Αν κάποια εφαρμογή δεν έχει αντίστοιχο JSON στο `data/current/` ή ο φάκελός της δεν υπάρχει τοπικά, παραλείπεται χωρίς να σταματήσει η ροή.
4. **Ίδιο naming με GitHub flow:** Τα output paths (`data/<id>.json`, `cases/<id>.json`, κ.λπ.) είναι πανομοιότυπα με αυτά που παράγει το GitHub Action — έτσι η δομή είναι συμβατή και αν αργότερα κάνεις push.
5. **History3D transform:** Η εφαρμογή `history-explorer-3d` έχει διαφορετικό JSON schema — το script κάνει αυτόματο transform (ίδιο με GitHub Action), όχι raw copy.
