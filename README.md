# Sacred Blueprint — Σύνοψη Συστήματος

## Πίνακας Εφαρμογών

| # | Εφαρμογή | Repo | Skill | data/current/ | Τι κάνει | Τρόπος deploy |
|---|---|---|---|---|---|---|
| 1 | 🗺️ **Timeline Explorer** | `Map-Timeline` | `skill_timeline_explorer` | `timeline.json` | Χάρτης Leaflet με χρονολογική γραμμή. Κάθε event = pin στον χάρτη + card. Puzzle Mode ξεχωριστή σελίδα. | GitHub Pages. Action αντιγράφει `data/<id>.json` + ενημερώνει `catalog.json` |
| 2 | 🕵️ **Investigation Board** | `idea-weaver-board` | `skill_investigation_board` | `investigation.json` | Board με clues (evidence/suspect/note). Μαθητής συνδέει στοιχεία για να λύσει την "υπόθεση". | Vercel. Action αντιγράφει `src/data/library/<id>.json` |
| 3 | 🏛️ **History Explorer 3D** | `history-explorer-3d` | `skill_history3d` | `history3d.json` | React Three Fiber σκηνή με NPC χαρακτήρες, διαλόγους και fact panels. Διαχειρίζεται μέσω Google Sheet. | Vercel (Lovable). Action κάνει transform + αντιγράφει `public/data/<id>.json` + ενημερώνει `manifest.json` |
| 4 | 🧠 **Mind Palace Debate** | `mind-palace-cases` | `skill_lesson_architect` | `mindpalace.json` | Investigation Board + δωμάτια Mind Palace με διαλόγους NPCs και ερωτήματα. Αίσθηση mystery game. | GitHub Pages. Action αντιγράφει `cases/<id>.json` + ενημερώνει `catalog.json` |
| 5 | 🌐 **Personal Page** | `personal-page` | `skill_personal_page` / `skill_notebook_media` | `personalpage.json` ή `notebook.json` | Hub εφαρμογή. Chapters με HTML περιεχόμενο, media skeleton (slides/pdf/audio), παιδαγωγικές σημειώσεις. | GitHub Pages / Vercel. Action αντιγράφει `public/data/lessons/<id>.json` + ενημερώνει `index.json` |
| — | ⚓ **Living Anchor** | `living-anchor` | `skill_living_anchor` | `anchor.json` | Layered text annotation (literal/structural/critical). Αποθηκεύεται στο sacred-blueprint, deploy χειροκίνητο. | Χειροκίνητο |
| — | 📖 **Interactive Books** | `interactive-books` | `skill_interactive_books` | `books.json` | Βιβλίο με σελίδες (text/image/video/slides/quiz). Αποθηκεύεται στο sacred-blueprint, deploy χειροκίνητο. | Χειροκίνητο |
| — | 🎮 **Unreal Engine 5** | `sheetunreal` | `skill_unreal_engine5` | `ue5/<id>/` | UE5 C++ scenario με MetaHuman NPCs, acts, dialogues, audio assets. Διαχειρίζεται αποκλειστικά μέσω Google Sheet. | Χειροκίνητο |

---

## Σύνοψη Συστήματος

### Αρχιτεκτονική

```
Mac mini (VS Code + Continue + Qwen)
          │
          │ bash workflows/
          ▼
┌─────────────────────────────────────────┐
│         sacred-blueprint repo           │
│                                         │
│  lessons/                               │
│  └── YYYYMMDD_<slug>/                   │  ← Βιβλιοθήκη (μόνιμη)
│      ├── meta.json                      │
│      └── master_output.json            │
│                                         │
│  data/current/                          │  ← Ενεργό μάθημα (αντικαθίσταται)
│  ├── timeline.json                      │
│  ├── investigation.json                 │
│  ├── history3d.json                     │
│  ├── mindpalace.json                    │
│  ├── personalpage.json                  │
│  ├── notebook.json                      │
│  └── active_lesson.json                 │
│                                         │
│  lessons/index.html                     │  ← Orchestrator Dashboard
└─────────────────────────────────────────┘
          │
          │ git push → trigger GitHub Action
          ▼
┌─────────────────────────────────────────┐
│      distribute.yml (GitHub Action)     │
│                                         │
│  Ανιχνεύει ποια αρχεία άλλαξαν         │
│  → Push μόνο στα αντίστοιχα repos      │
└─────────────────────────────────────────┘
          │
    ┌─────┴──────────────────────────────┐
    │                                    │
    ▼                                    ▼
Map-Timeline          idea-weaver-board  history-explorer-3d
mind-palace-cases     personal-page      (κ.λπ.)
    │
    ▼
GitHub Pages / Vercel → Live εφαρμογές
```

---

### Ροή δημιουργίας μαθήματος

```
1. new_lesson.sh "Θέμα" lesson_type
        ↓
   lessons/YYYYMMDD_slug/ + meta.json

2. Skills στο Continue (@skill_*)
        ↓
   data/current/<app>.json
   + master_output.json (συσσωρεύεται)

3. publish_lesson.sh --skip-transform
        ↓
   distribute.sh    → data/current/ (εξαγωγή sections)
   generate_dashboard.sh → lessons/index.html
   sync_github.sh   → git push

4. GitHub Action (distribute.yml)
        ↓
   Push σε κάθε app repo που άλλαξε
   + Ενημέρωση catalog/manifest/index

5. Apps ανανεώνονται αυτόματα
   (GitHub Pages / Vercel auto-deploy)
```

---

### Εναλλαγή ενεργού μαθήματος

```bash
# Ενεργοποίηση παλιού μαθήματος από βιβλιοθήκη
bash workflows/activate_lesson.sh lessons/YYYYMMDD_slug/
        ↓
   distribute.sh → data/current/ (αντιγραφή εκείνου του μαθήματος)
   git push → Action → Apps
```

---

### Skills — Πλήρης Λίστα

| Skill | Κλήση | Output key | App |
|---|---|---|---|
| `skill_timeline_explorer` | `@skill_timeline_explorer` | `timeline_item` | 🗺️ Timeline |
| `skill_investigation_board` | `@skill_investigation_board` | `investigation_board` | 🕵️ Investigation |
| `skill_history3d` | `@skill_history3d` | `history3d` | 🏛️ History 3D |
| `skill_lesson_architect` | `@skill_lesson_architect` | `mind_palace` + `investigation_board` | 🧠 Mind Palace |
| `skill_living_anchor` | `@skill_living_anchor` | `anchor` | ⚓ Living Anchor |
| `skill_interactive_books` | `@skill_interactive_books` | `books` | 📖 Interactive Books |
| `skill_notebook_media` | `@skill_notebook_media` | `notebook` | 🌐 Personal Page |
| `skill_personal_page` | `@skill_personal_page` | `personal_page` | 🌐 Personal Page |
| `skill_unreal_engine5` | `@skill_unreal_engine5` | `unreal_scenario` + assets + manifest | 🎮 UE5 |
| `skill_media_enrichment` | `@skill_media_enrichment` | in-place στο master | Όλες |

---

### Workflows — Πλήρης Λίστα

| Script | Χρήση | Τι κάνει |
|---|---|---|
| `new_lesson.sh` | `bash workflows/new_lesson.sh "Θέμα" type` | Δημιουργεί φάκελο + meta.json |
| `distribute.sh` | `bash workflows/distribute.sh lessons/ΦΑΚΕΛΟΣ/` | Εξάγει sections → data/current/ + βιβλιοθήκη |
| `publish_lesson.sh` | `bash workflows/publish_lesson.sh lessons/ΦΑΚΕΛΟΣ/ [--skip-transform]` | Ολοκληρωμένη δημοσίευση (distribute + dashboard + push) |
| `activate_lesson.sh` | `bash workflows/activate_lesson.sh lessons/ΦΑΚΕΛΟΣ/` | Ενεργοποίηση παλιού μαθήματος |
| `generate_dashboard.sh` | `bash workflows/generate_dashboard.sh` | Αναγεννά lessons/index.html |
| `sync_github.sh` | `bash workflows/sync_github.sh "message"` | Commit + push στο sacred-blueprint |

---

### Αρχεία ανά εφαρμογή — Naming Conventions

| Orchestrator id | master_output key | data/current/ file | Repo |
|---|---|---|---|
| `timeline` | `timeline_item` | `timeline.json` | `Map-Timeline` |
| `investigation` | `investigation_board` | `investigation.json` | `idea-weaver-board` |
| `history3d` | `history3d` | `history3d.json` | `history-explorer-3d` |
| `mindpalace` | `mind_palace` | `mindpalace.json` | `mind-palace-cases` |
| `anchor` | `anchor` | `anchor.json` | `living-anchor` |
| `books` | `books` | `books.json` | `interactive-books` |
| `notebook` | `notebook` | `notebook.json` | `personal-page` |
| `personalpage` | `personal_page` | `personalpage.json` | `personal-page` |
| `unreal` | `unreal_scenario` | `ue5/<id>/` (3 αρχεία) | `sheetunreal` |
