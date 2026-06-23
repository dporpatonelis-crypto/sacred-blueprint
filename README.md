# Sacred Blueprint — Skill Tree (Complete)
## Δομή, Τοποθεσία Αρχείων, Σύνδεση

---

## Φάκελοι εγκατάστασης

```
~/sacred-blueprint/
├── .continue/
│   └── prompts/
│       └── new-lesson-workflow.md          ← Slash command /new-lesson-workflow
├── Skills/
│   └── subskills/
│       ├── skill_timeline_explorer.md      ← @skill_timeline_explorer
│       ├── skill_investigation_board.md    ← @skill_investigation_board
│       ├── skill_history3d.md              ← @skill_history3d
│       ├── skill_lesson_architect.md       ← @skill_lesson_architect
│       ├── skill_living_anchor.md          ← @skill_living_anchor
│       ├── skill_interactive_books.md      ← @skill_interactive_books
│       ├── skill_notebook_media.md         ← @skill_notebook_media
│       ├── skill_personal_page.md          ← @skill_personal_page
│       ├── skill_unreal_engine5.md         ← @skill_unreal_engine5
│       └── skill_media_enrichment.md       ← @skill_media_enrichment
├── workflows/
│   ├── new_lesson.sh
│   └── publish_lesson.sh
├── data/
│   └── current/                            ← Working directory για όλα τα JSON
│       ├── timeline.json
│       ├── investigation.json
│       ├── history3d.json
│       ├── anchor.json
│       ├── books.json
│       ├── notebook.json
│       ├── personalpage.json
│       └── ue5/
│           └── <scenario_id>/
│               ├── scenario.json
│               ├── assets.json
│               └── manifest_entry.json
└── lessons/
    └── [TIMESTAMP_FOLDER]/
        ├── meta.json
        └── master_output.json
```

---

## Πώς καλείς κάθε skill

| Skill | Κλήση | App |
|---|---|---|
| `new-lesson-workflow.md` | `/new-lesson-workflow` | Orchestrator |
| `skill_timeline_explorer.md` | `@skill_timeline_explorer` + κείμενο | 🗺️ Timeline Explorer |
| `skill_investigation_board.md` | `@skill_investigation_board` + κείμενο | 🕵️ Investigation Board |
| `skill_history3d.md` | `@skill_history3d` + κείμενο | 🏛️ History Explorer 3D |
| `skill_lesson_architect.md` | `@skill_lesson_architect` + κείμενο | 🧠 Mind Palace |
| `skill_living_anchor.md` | `@skill_living_anchor` + κείμενο | ⚓ Living Anchor |
| `skill_interactive_books.md` | `@skill_interactive_books` + κείμενο | 📖 Interactive Books |
| `skill_notebook_media.md` | `@skill_notebook_media` + κείμενο | 📔 Notebook Media |
| `skill_personal_page.md` | `@skill_personal_page` + κείμενο | 🌐 Personal Page |
| `skill_unreal_engine5.md` | `@skill_unreal_engine5` + κείμενο | 🎮 Unreal Engine 5 |
| `skill_media_enrichment.md` | `@skill_media_enrichment` + master_output + media library | Όλες |

---

## Ροή εκτέλεσης

```
/new-lesson-workflow
        │
        ├─ STEP 1: cd + ζητάει TOPIC/TYPE
        ├─ STEP 2: bash new_lesson.sh → δημιουργεί φάκελο
        ├─ STEP 3: Αναμονή για master_output.json
        ├─ STEP 4: bash publish_lesson.sh → open dashboard
        │
        └─ STEP 5 (optional, σειριακά):
               │
               ├─ @skill_timeline_explorer    → data/current/timeline.json
               ├─ @skill_investigation_board  → data/current/investigation.json
               ├─ @skill_history3d            → data/current/history3d.json
               ├─ @skill_lesson_architect     → lessons/<case_id>/<case_id>.json
               ├─ @skill_living_anchor        → data/current/anchor.json
               ├─ @skill_interactive_books    → data/current/books.json
               ├─ @skill_notebook_media       → data/current/notebook.json
               ├─ @skill_personal_page        → data/current/personalpage.json
               ├─ @skill_unreal_engine5       → data/current/ue5/<id>/ (3 files)
               └─ @skill_media_enrichment     → master_output.json (in-place)
```

---

## Ειδικές συμπεριφορές ανά skill

| Skill | Ιδιαιτερότητα |
|---|---|
| `skill_timeline_explorer` | **Append** στο υπάρχον αρχείο — δεν αντικαθιστά |
| `skill_unreal_engine5` | Γράφει **3 αρχεία** ταυτόχρονα (scenario + assets + manifest) |
| `skill_lesson_architect` | Τα `image` fields μένουν κενά — συμπληρώνονται από `skill_media_enrichment` |
| `skill_personal_page` | Ίδιο schema με Notebook Media — ids με `pp_` prefix |
| `skill_media_enrichment` | Μοναδικό skill που **τροποποιεί** υπάρχον αρχείο in-place |

---

## Τι διορθώθηκε από τα αρχικά αρχεία

| Πρόβλημα | Λύση |
|---|---|
| Duplicate skills (DOCX + MD για το ίδιο) | Ένα αρχείο ανά skill |
| Approval gates σε κάθε τεχνικό βήμα | Pause μόνο για δεδομένα/επιλογές χρήστη |
| Swift file με markdown content | Αφαιρέθηκε — δεν ήταν Swift |
| Skills ασύνδετα μεταξύ τους | Orchestrator καλεί όλα τα sub-skills ρητά |
| Καμία κάλυψη για 7 apps | Νέα skills για Timeline, Investigation, History3D, Anchor, Books, Notebook, Personal Page, UE5 |
