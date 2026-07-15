# SKILL: Media Library Intake & Curation
## Sub-Skill · Mac mini flow (ξεχωριστό από orchestrator v5) · Καλείται από `new-lesson-workflow`, από άλλο skill (auto-trigger), ή αυτόνομα

> **v2** — Απλοποιημένο μετά από cross-check με το πραγματικό `media_library.xlsx`. Λιγότεροι αυστηροί κανόνες, λιγότερα blocking gates. Τα πεδία που πραγματικά μετράνε: **title, url, tags**. Τα υπόλοιπα συμπληρώνονται best-effort για ομοιόμορφη δομή, χωρίς να μπλοκάρουν τη ροή.

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension, Mac mini M4
- **Workspace:** `~/sacred-blueprint`
- **App:** Media Library — `📚 Media Library` sheet + `media-library/media_library.json` (git-tracked)
- **Role:** Επιμελείσαι νέο εκπαιδευτικό υλικό πριν μπει στη βιβλιοθήκη. Εκτελείς STEPS 1–7 αυτόνομα, **πάντα σταματάς πριν την εγγραφή** (STEP 7b) για Accept/Review/Reject.

**Σχέση με `skill_media_enrichment`:** αυτό γεμίζει τη βιβλιοθήκη· το enrichment αντλεί από αυτήν για να συμπληρώσει `image` πεδία σε `master_output.json`. Δεν αλληλεπικαλύπτονται.

**Σχέση με το άλλο project (orchestrator v5):** άσχετο flow. Αυτό το skill δεν χρειάζεται να συγχρονίζεται μαζί του — είναι σκόπιμα ξεχωριστές διαδικασίες.

---

## 📥 INPUT

1. **Trigger A — Post-lesson:** μετά την παραγωγή JSON ενός μαθήματος, αν εμφανιστεί νέο media URL.
2. **Trigger B — Quick Note:** ρητό αίτημα του χρήστη — τίτλος + URL (ή τοπικό αρχείο), προαιρετικά tags/app_context.

**Δύο κατηγορίες πηγής, πλέον διακριτές (Mac mini):**
- **Cloud media** — YouTube, Google Slides/Drive, NotebookLM, imgbb, GitHub Pages κ.λπ. → `url` = web link.
- **Τοπικά αρχεία Office/PDF** — μένουν στον υπολογιστή, όχι στο cloud → `url` = τοπικό path (π.χ. `/Users/.../file.pdf`). Δεν γίνεται embed-conversion σε τοπικά paths.

---

## 🔄 WORKFLOW

### STEP 1 — Αναγνώριση
Τύπος αρχείου, τίτλος, πηγή, δημιουργός, ημερομηνία, γλώσσα (`el`/`en` — τίποτα άλλο χρειάζεται).

### STEP 2 — Ανάλυση
Σύντομη περίληψη, βασικές έννοιες, θεματική ενότητα.

### STEP 3 — Παιδαγωγική αξιολόγηση
**Skip by default.** Την κάνει ο χρήστης πριν φέρει το υλικό. Μόνο αν ζητηθεί ρητά.

### STEP 4 — URL handling

Αν είναι web URL, κάνε embed-conversion όπου χρειάζεται:

| Type | Μετατροπή |
|---|---|
| `google_slides` | → `https://docs.google.com/presentation/d/FILE_ID/embed` |
| `audio` (Google Drive-hosted) | → `https://docs.google.com/uc?export=download&id=FILE_ID` |
| `youtube` | → `https://www.youtube.com/embed/VIDEO_ID` |
| `notebooklm` link | Διατήρησε αυτούσιο (δεν κάνει embed-convert). |
| Τοπικό αρχείο (pdf, office) | Καμία μετατροπή — κράτα το path όπως είναι. |

**`source_platform` — μάντεψε από το URL host, μη μπλοκάρεις αν δεν είσαι σίγουρος:**

| URL host περιέχει... | source_platform |
|---|---|
| `youtube.com` / `youtu.be` | `YouTube` |
| `docs.google.com` / `drive.google.com` | `Google Drive` |
| `notebooklm.google.com` | `NotebookLM` |
| `i.ibb.co` / `imgbb.com` | `imgbb` |
| `*.github.io` | `GitHub Pages` |
| τοπικό path (χωρίς `http`) | `Local` |
| άλλο/άγνωστο | βάλε το domain name ως έχει — μην μπλοκάρεις για αυτό |

### STEP 5 — Έλεγχος διπλοτύπων

```bash
cat ~/sacred-blueprint/media-library/media_library.json
```

- **Ίδιο URL + σαφώς διαφορετικό concept/τίτλος** → θεμιτό companion entry (π.χ. IMG-005/006/007: ίδια διαφάνεια, 3 διαφορετικές τοποθεσίες). Πρόσθεσε αυτόματα στο `notes`: `"Κοινό URL με <ID>"`.
- **Ίδιο URL + γενικός/ασαφής τίτλος στο νέο entry** → πιθανό λάθος, όχι αυτόματο companion. Flag ρητά στο STEP 7b, μην αποφασίσεις μόνος σου.
- **Ίδιο URL + ίδιο concept** → πραγματικό διπλότυπο, πρότεινε reject/merge.

### STEP 6 — Σύνδεση
Ποια lessons/JSON θα μπορούσαν να χρησιμοποιήσουν αυτό, σχετικές έννοιες.

### STEP 7 — Metadata & ID

**Prefix ανά type** (συνέχισε από το **μεγαλύτερο υπάρχον νούμερο** του ίδιου prefix +1 — όχι γέμισμα κενών, στη βιβλιοθήκη υπάρχουν ήδη κενά π.χ. IMG-008/009/010 λείπουν και είναι OK):

| type | prefix | επιβεβαιωμένο από πραγματικά δεδομένα; |
|---|---|---|
| `youtube` | `VID-` | ✅ |
| `google_slides` | `SLD-` | ✅ |
| `image` | `IMG-` | ✅ |
| `interactive_book` | `HTML-` | ✅ |
| `audio` | `AUD-` | ✅ |
| `pdf` | `PDF-` | 🆕 πρώτη χρήση — πρόταση, όχι ακόμη επιβεβαιωμένο στην πράξη |
| οτιδήποτε άλλο τοπικό αρχείο (Office κ.λπ.) | ρώτα τον χρήστη ποιο prefix θέλει την πρώτη φορά, μετά συνέχισε την ίδια σύμβαση | — |

**`app_context`** — ελεύθερο πεδίο, semicolon-separated όταν είναι πάνω από ένα. Ενδεικτικές τιμές που έχουν ήδη χρησιμοποιηθεί (όχι αυστηρή λίστα, απλά αναφορά): `Mind Palace`, `Explorer History`, `Timeline Map`, `Console`, `Interactive Book`, `Living Anchor`, `UE5`. Αν λείπει, άφησέ το κενό — δεν μπλοκάρει τίποτα.

**`unit_id`** — προαιρετικό, μορφή `U01`/`U02`/... όταν υπάρχει. Συχνά μένει κενό — αυτό είναι φυσιολογικό, όχι πρόβλημα.

**`notes`** — γέμισε το μόνο όταν υπάρχει κάτι ουσιαστικό να ειπωθεί (πηγή, τεχνική σύνδεση, cross-reference διπλοτύπου). Σε γρήγορη προσθήκη είναι εντάξει να μείνει κενό — δεν χρειάζεται πάντα περιεχόμενο.

**→ PAUSE (STEP 7b):**

```
📥 Νέα καταχώρηση Media Library

Τίτλος       : <title>
URL          : <url>
Tags         : "<tag1, tag2, tag3>"
---
Type / ID    : <type> / <προτεινόμενο media_id>
Source       : <source_platform (best guess)>
Πιθανό διπλότυπο: <ΟΧΙ / companion (auto cross-ref) / πιθανό λάθος — δες URL ίδιο με <ID>>
```

Περίμενε: `✅ ACCEPT` / `🟡 REVIEW [feedback]` / `❌ REJECT`

---

### STEP 8 — Write (μόνο μετά από ✅ ACCEPT)

```
A) Πλήρης εγγραφή → media_library.json + TSV γραμμή
B) Μόνο αρχείο
C) Μόνο TSV (copy)
```

**JSON write:**

```bash
python3 -c "
import json, os
entry = <GENERATED_ENTRY_JSON>
path = os.path.expanduser('~/sacred-blueprint/media-library/media_library.json')
if os.path.exists(path):
    with open(path, 'r', encoding='utf-8') as f:
        library = json.load(f)
else:
    library = {'meta': {'last_updated': '', 'source': 'local'}, 'media': []}
library['media'].append(entry)
from datetime import date
library['meta']['last_updated'] = date.today().isoformat()
with open(path, 'w', encoding='utf-8') as f:
    json.dump(library, f, indent=2, ensure_ascii=False)
print('Written. Total media:', len(library['media']))
"
```

**TSV γραμμή (ίδια σειρά με το header του Sheet):**

```
<media_id>	<type>	<title>	<url>	<source_platform>	<app_context>	<unit_id>	"<tag1, tag2>"	<language>	<notes>	<date_added>	active
```

### STEP 9 — Summary

```
[LOG] Media Library Intake
  Media ID     : <id>
  Title        : <τίτλος>
  URL          : <url>
  Tags         : <tags>
  Duplicate    : <ΟΧΙ / companion / πιθανό λάθος>
  Decision     : <ACCEPT/REVIEW/REJECT>
  Write mode   : <A/B/C>
  Status       : complete
```

---

## 📐 JSON SCHEMA

```json
{
  "media_id": "string",
  "type": "youtube | google_slides | image | interactive_book | audio | pdf",
  "title": "string",
  "url": "string (web URL ή τοπικό path)",
  "source_platform": "string (best-effort από URL host)",
  "app_context": ["string"],
  "unit_id": "string ή κενό",
  "tags": ["string"],
  "language": "el | en",
  "notes": "string ή κενό",
  "date_added": "YYYY-MM-DD",
  "status": "active"
}
```

---

## 🚨 RULES

1. **Title, URL, tags είναι τα πεδία που πραγματικά προσέχεις** — αυτά πρέπει να είναι σωστά και ακριβή. Τα υπόλοιπα συμπληρώνονται best-effort, χωρίς να καθυστερούν την εγγραφή.
2. **12 πεδία πάντα, ίδια σειρά** — μόνο και μόνο για να μη χαλάει η δομή του Sheet/JSON.
3. **`type` περιορίζεται στα επιβεβαιωμένα** (`youtube, google_slides, image, interactive_book, audio, pdf`). Νέος τύπος πέρα από αυτά → ρώτα πρώτα, μη τον επινοήσεις.
4. **ID = μεγαλύτερο υπάρχον νούμερο του prefix +1.** Κενά στην αρίθμηση (π.χ. λείπει IMG-008–010) είναι φυσιολογικά — δεν τα γεμίζεις.
5. **Ίδιο URL δεν σημαίνει αυτόματα διπλότυπο** — μόνο αν ταυτίζεται και το concept. Αν ο νέος τίτλος είναι ασαφής/γενικός, μην το αντιμετωπίσεις σαν legit companion — ρώτα.
6. **Τοπικά αρχεία (pdf/Office) στο Mac mini** — `url` = τοπικό path, `source_platform = "Local"`, καμία embed-conversion.
7. **Καμία εγγραφή χωρίς ✅ ACCEPT.**
8. **Δεν αγγίζει JSON μαθήματος** — αυτό είναι αποκλειστικά δουλειά του `skill_media_enrichment`.
9. **Ξεχωριστό flow από το orchestrator v5** — δεν χρειάζεται συγχρονισμός σύμβασης μαζί του.

---

## 🔍 Βρέθηκε στο cross-check (χρειάζεται τον έλεγχό σου, όχι δικό μου fix)

- `VID-002` και `VID-003` έχουν το ίδιο URL (`youtu.be/Ftr5AbtSxWE`) αλλά εντελώς διαφορετικό τίτλο/concept — το VID-003 έχει γενικό τίτλο ("Video overview travel of an idea"). Πιθανό λάθος/leftover δοκιμής, όχι legit companion.
