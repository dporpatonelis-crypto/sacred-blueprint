# Sacred Blueprint — Claude Project Context

## Τι είναι αυτό το project

Σύστημα δημιουργίας και διανομής θεολογικών μαθημάτων (Πατριστική, Εκκλησιαστική Ιστορία, Ορθόδοξη Δογματική) σε πέντε διαδραστικές εφαρμογές. Ο Dimitrios δημιουργεί μαθήματα τοπικά και τα διανέμει αυτόματα στις εφαρμογές μέσω bash scripts και GitHub Actions.

---

## Workspace

```
~/sacred-blueprint/          ← εδώ τρέχουν όλες οι εντολές
├── lessons/                  ← βιβλιοθήκη μαθημάτων (μόνιμη)
├── data/current/             ← ενεργό μάθημα (αντικαθίσταται κάθε φορά)
├── workflows/                ← bash scripts
└── Skills/subskills/         ← skill αρχεία για Continue

~/apps/                       ← τοπικοί κλώνοι app repos
├── Map-Timeline/
├── idea-weaver-board/
├── history-explorer-3d/
├── mind-palace-cases/
└── personal-page/
```

---

## Bash Scripts (workflows/)

| Script | Χρήση |
|---|---|
| `new_lesson.sh "Τίτλος" type` | Δημιουργεί φάκελο + meta.json |
| `distribute.sh lessons/ΦΑΚΕΛΟΣ/` | master_output.json → data/current/ |
| `publish_lesson.sh lessons/ΦΑΚΕΛΟΣ/` | Πλήρης online ροή (distribute+dashboard+github) |
| `activate_lesson.sh lessons/ΦΑΚΕΛΟΣ/` | Ενεργοποίηση παλιού μαθήματος |
| `generate_dashboard.sh` | Αναγεννά lessons/index.html |
| `local_distribute.sh` | data/current/ → ~/apps/* (offline) |
| `sync_github.sh "message"` | git push sacred-blueprint repo |
| `sync_apps_to_github.sh` | git push όλων ~/apps/* repos |
| `cleanup_catalog.sh` | Αφαιρεί orphan entries από catalogs/manifests |

**Έγκυροι τύποι μαθήματος για new_lesson.sh:**
`patristic_text_analysis` | `historical_event` | `theological_concept` | `3d_exploration` | `quick_concept_overview`

---

## Εφαρμογές & Data Flow

| Εφαρμογή | master_output key | data/current/ file | ~/apps/ path |
|---|---|---|---|
| 🗺️ Timeline Explorer | `timeline_item` | `timeline.json` | `Map-Timeline/data/<id>.json` |
| 🕵️ Investigation Board | `investigation_board` | `investigation.json` | `idea-weaver-board/src/data/library/<id>.json` |
| 🏛️ History Explorer 3D | `history3d` | `history3d.json` | `history-explorer-3d/public/data/<id>.json` |
| 🧠 Mind Palace Debate | `mind_palace` | `mindpalace.json` | `mind-palace-cases/cases/<id>.json` |
| 🌐 Personal Page | `personal_page` | `personalpage.json` | `personal-page/public/data/lessons/<id>.json` |

Οι εφαρμογές Living Anchor, Interactive Books, Unreal Engine 5 **δεν έχουν αυτόματη διανομή** — παραμένουν στο sacred-blueprint repo.

---

## Ροή Δημιουργίας Μαθήματος

```
1. new_lesson.sh → lessons/YYYYMMDD_slug/ + meta.json
2. Skills (Continue) → data/current/*.json + master_output.json
3. distribute.sh lessons/ΦΑΚΕΛΟΣ/ → data/current/ (εξαγωγή sections)
4. local_distribute.sh → ~/apps/* (τοπικά)
   ή publish_lesson.sh → GitHub push → Actions → live apps
5. generate_dashboard.sh → lessons/index.html
```

---

## Skills (Continue Extension)

Κάθε skill γράφει JSON στο `data/current/` ΚΑΙ ενημερώνει `data/current/master_output.json`.

Κάθε skill έχει δομή:
- **STEP 1:** Semantic extraction από κείμενο πηγής
- **STEP 1b:** Επιβεβαίωση εξαγόμενων (PAUSE — περιμένει OK)
- **STEP 2:** JSON generation
- **STEP 2b:** Επιλογή A/B/C (full publish / file only / copy)
- **STEP 3:** Write to data/current/
- **STEP 4:** Summary report
- **STEP 5:** Sync to master_output.json

---

## Master Output JSON — Δομή

```json
{
  "_comment": "Unified master για όλες τις εφαρμογές",
  "title": "...",
  "subtitle": "...",
  "description": "...",
  "date": "YYYY-MM-DD",
  "era": "...",
  "location": "...",
  "coordinates": {"lat": 0, "lng": 0, "zoom": 7},
  "timeline_item": {...},
  "investigation_board": {...},
  "history3d": {...},
  "mind_palace": {...},
  "anchor": {...},
  "books": {...},
  "notebook": {...},
  "personal_page": {...},
  "unreal_scenario": {...}
}
```

---

## Κανόνες Εκτέλεσης

1. **Πάντα `cd ~/sacred-blueprint`** πριν από οποιοδήποτε script.
2. **Σταμάτα μόνο για δεδομένα από χρήστη** (τίτλος, επιβεβαίωση περιεχομένου). Μην ζητάς "άδεια" για τεχνικά βήματα.
3. **Αν κάποιο script αποτύχει**, εκτύπωσε το error και πρότεινε χειροκίνητη εκτέλεση από τον `MANUAL_OPERATIONS_GUIDE.md`.
4. **Μην τροποποιείς scripts** χωρίς ρητή εντολή — το σύστημα έχει δοκιμαστεί και τα ονόματα αρχείων είναι κρίσιμα.
5. **Push αποτυχίες**: αν το `sync_github.sh` αποτύχει, τα αρχεία είναι ήδη τοπικά ενημερωμένα — πρότεινε χειροκίνητο `git push origin main`.
6. **History3D transform**: το `local_distribute.sh` κάνει αυτόματα transform από skill format σε Lovable app format — δεν χρειάζεται χειροκίνητη επέμβαση.

---

## Διαγνωστικά (αν κάτι δεν δουλεύει)

```bash
# Ενεργό μάθημα
cat data/current/active_lesson.json

# Τι υπάρχει στο data/current/
ls -la data/current/

# Git κατάσταση
git status
git remote -v
git log --oneline -5

# Catalogs των apps
cat ~/apps/Map-Timeline/catalog.json
cat ~/apps/mind-palace-cases/catalog.json
```

---

## Σημαντικά Αρχεία για Reference

- `MANUAL_OPERATIONS_GUIDE.md` — χειροκίνητες εντολές για κάθε ροή
- `README.md` — πλήρης αρχιτεκτονική
- `.continue/prompts/new-lesson-workflow.md` — slash command `/new-lesson-workflow`
- `.continue/prompts/local-distribute-workflow.md` — slash command `/local-distribute-workflow`
