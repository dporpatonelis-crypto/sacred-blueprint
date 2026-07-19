# SKILL: Interpretive Sculpture JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** Interpretive Sculpture (Three.js/WebXR VR prototype, region-based συλλογική ερμηνεία, GitHub Pages)
- **Role:** Δημιουργείς το αρχικό περιεχόμενο (regions/contributions) και προαιρετικά τα "discoveries" (κρυφές επιγραφές) για το VR γλυπτό ερμηνείας. Εκτελείς χωρίς άδεια για τεχνικά βήματα.

**Πώς λειτουργεί το app (για context):** Ένα 3D γλυπτό χωρισμένο σε **6 σταθερές περιοχές** (`base, trunk, arms, head, periphery, core`) ξεκινά σκοτεινό. Κάθε φορά που προστίθεται μια "συνεισφορά" (contribution) σε μια περιοχή, αυτή φωτίζεται με χρώμα ανάλογο της κατηγορίας (`theological/ethical/historical/philosophical`) και ένταση ανάλογη της τεκμηρίωσης. Τα ονόματα/labels των 6 περιοχών είναι **hardcoded στο index.html** — το skill δεν τα αλλάζει ποτέ, μόνο γεμίζει περιεχόμενο.

---

## 📥 INPUT

Ένα από τα δύο:
1. **Κείμενο πηγής** (πρόσωπο ή έννοια — Πατέρας, Άγιος, δόγμα — με βιογραφικά, δογματικά, ιστορικά και ηθικά στοιχεία)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή (π.χ. από `skill_living_anchor` ή `skill_lesson_architect`)

---

## 🔄 WORKFLOW

### STEP 1 — Extraction

Από το κείμενο αξιολόγησε **κάθε μία από τις 6 σταθερές περιοχές** και κράτησε μόνο όσες τεκμηριώνονται:

| Region | Σημασία (fixed) | Τι αναζητάς στο κείμενο |
|---|---|---|
| `base` | Τα θεμέλια της έννοιας | Βασικές αρχές, ορισμοί, αφετηρία σκέψης |
| `trunk` | Το κύριο σώμα δεδομένων | Βιογραφικά/δογματικά βασικά στοιχεία |
| `arms` | Η δράση και η εφαρμογή | Έργα, ποιμαντική δράση, πράξεις |
| `head` | Το ανώτερο νόημα (Θεολογία) | Θεολογική ερμηνεία, δογματική σημασία |
| `periphery` | Το ιστορικό πλαίσιο | Εποχή, γεγονότα, κοινωνικό περιβάλλον |
| `core` | Η ουσία και η κινητήριος δύναμη | Το κεντρικό «γιατί» — τι κινούσε το πρόσωπο/έννοια |

Για κάθε περιοχή που τεκμηριώνεται εξήγαγε **μία seed contribution**:
- `text`: σύνθεση 2–3 προτάσεων από το κείμενο
- `source`: ακριβής παραπομπή αν υπάρχει στο κείμενο (π.χ. `"Βασίλειος Καισαρείας, Ομιλία Εις τους πλουτούντας"`) — αλλιώς κενό `""`
- `category`: `theological | ethical | historical | philosophical`

*(Προαιρετικά)* Εξήγαγε **1–3 discoveries**: σύντομα αποσπάσματα-«επιγραφές» προς ανακάλυψη μέσα στο VR, δεμένα σε μία περιοχή η καθεμία.

Εκτύπωσε σύνοψη πριν προχωρήσεις.

---

### STEP 2 — JSON Generation

**Αρχείο Α — `sculpture.json`** (πλήρες snapshot, συμβατό με το import/export panel του app):

```json
{
  "template": {
    "version": "1.0",
    "regions": ["base", "trunk", "arms", "head", "periphery", "core"],
    "visualRules": {
      "lighting": "intensity_per_contributions",
      "color": "category_mapping",
      "glow": "documentation_threshold",
      "inscriptions": "primary_source_text"
    }
  },
  "instance": {
    "class": "<τάξη αν δόθηκε, αλλιώς κενό>",
    "subject": "<κεντρικό πρόσωπο/έννοια>",
    "year": <τρέχον έτος ως αριθμός>,
    "createdAt": "<ISO timestamp τώρα>"
  },
  "regions": {
    "base":      {"name": "Βάση",           "contributions": 0, "docStrength": 0, "category": null, "label": "Τα θεμέλια της έννοιας"},
    "trunk":     {"name": "Κορμός",         "contributions": 0, "docStrength": 0, "category": null, "label": "Το κύριο σώμα δεδομένων"},
    "arms":      {"name": "Χέρια",          "contributions": 0, "docStrength": 0, "category": null, "label": "Η δράση και η εφαρμογή"},
    "head":      {"name": "Κεφαλή",         "contributions": 0, "docStrength": 0, "category": null, "label": "Το ανώτερο νόημα (Θεολογία)"},
    "periphery": {"name": "Περιφέρεια",     "contributions": 0, "docStrength": 0, "category": null, "label": "Το ιστορικό πλαίσιο"},
    "core":      {"name": "Εσωτ. Πυρήνας",  "contributions": 0, "docStrength": 0, "category": null, "label": "Η ουσία και η κινητήριος δύναμη"}
  },
  "contributions": [
    {
      "id": 1773388754927,
      "region": "<κλειδί περιοχής>",
      "text": "<κείμενο συνεισφοράς>",
      "source": "<παραπομπή ή κενό>",
      "category": "theological | ethical | historical | philosophical",
      "docScore": 0,
      "timestamp": "<ISO timestamp>"
    }
  ],
  "assets": []
}
```

**⚠️ Κρίσιμος υπολογισμός `docScore` (ακριβώς όπως το app):**
```
docScore = source ? min(αριθμός χαρακτήρων του source / 10, 10) : 1
```
Δηλαδή μια παραπομπή 60+ χαρακτήρων δίνει docScore=6, μια παραπομπή 100+ χαρακτήρων κόβεται στο 10. Χωρίς source → πάντα `1`.

**⚠️ Ενημέρωση `regions[key]` όταν προσθέτεις seed contribution σε μια περιοχή:**
```
regions[key].contributions = πλήθος seed contributions σε αυτή την περιοχή
regions[key].docStrength   = άθροισμα docScore όλων των contributions της περιοχής
regions[key].category      = category της ΤΕΛΕΥΤΑΙΑΣ contribution (όχι μείγμα — το app κρατά μία τιμή)
```
Περιοχές χωρίς τεκμηρίωση **μένουν** `contributions:0, docStrength:0, category:null` — έτσι ξεκινούν σκοτεινές στο VR, ό,τι είναι σωστό παιδαγωγικά (η τάξη τις «ανάβει» η ίδια).

**Αρχείο Β — `sculpture_discoveries.json`** *(μόνο αν βρέθηκαν discoveries στο κείμενο)*:

```json
[
  {
    "id": "<slug, π.χ. 'basil-philanthropy'>",
    "region": "<κλειδί περιοχής όπου θα «ανάψει» όταν βρεθεί>",
    "team": "<Ομάδα Α / Β / ... ή κενό>",
    "category": "theological | ethical | historical | philosophical",
    "markerPosition": {"x": 0, "y": 0, "z": 0},
    "shortText": "<πολύ σύντομο απόσπασμα σε εισαγωγικά, ≤10 λέξεις>",
    "fullText": "<αναλυτική εξήγηση, 2–3 προτάσεις>",
    "source": "<παραπομπή>"
  }
]
```

**Ενδεικτικές συντεταγμένες `markerPosition` ανά περιοχή** (βάσει γεωμετρίας του γλυπτού στο index.html — ρύθμισε οπτικά μέσα στο VR/desktop preview, αυτές είναι μόνο αφετηρία):

| Region | y (ύψος) | x/z (ακτίνα γύρω από το κέντρο) |
|---|---|---|
| `base` | 0.2 – 0.5 | ακτίνα ~2.0–2.3 |
| `trunk` | 1.0 – 3.0 | ακτίνα ~1.0–1.5 |
| `arms` | 2.3 – 2.9 | x: ±1.0 έως ±1.8, z ≈ 0 |
| `head` | 3.8 – 4.6 | ακτίνα ~0.9–1.3 |
| `periphery` | 2.0 – 3.0 | ακτίνα ~2.6–3.5 (έξω από το γλυπτό) |
| `core` | 2.3 – 2.7 | κοντά στο κέντρο, x/z ≈ 0 |

Εκτύπωσε και τα δύο σε ξεχωριστά code blocks.

---

### STEP 3 — Write to Workspace

```bash
python3 -c "
import json, os
data = <SCULPTURE_JSON>
path = os.path.expanduser('~/sacred-blueprint/data/current/sculpture.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

Αν υπάρχουν discoveries:

```bash
python3 -c "
import json, os
data = <DISCOVERIES_JSON>
path = os.path.expanduser('~/sacred-blueprint/data/current/sculpture_discoveries.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

---

### STEP 4 — Summary Report

```
[LOG] Interpretive Sculpture
  Subject       : <θέμα>
  Regions filled: N/6  (λίστα: base✓/✗, trunk✓/✗, arms✓/✗, head✓/✗, periphery✓/✗, core✓/✗)
  Contributions : N (μέσο docScore: X.X)
  Discoveries   : N (⚠ χρειάζεται χειροκίνητη επικόλληση στο DISCOVERIES constant — δες RULES #7)
  Files         : ~/sacred-blueprint/data/current/sculpture.json
                  ~/sacred-blueprint/data/current/sculpture_discoveries.json (αν υπάρχουν discoveries)
  Status        : complete
```

---

## 📐 JSON SCHEMA (σύνοψη)

**sculpture.json** — `{"template", "instance", "regions": {6 σταθερά κλειδιά}, "contributions": [], "assets": []}`

**sculpture_discoveries.json** — `[{"id","region","team","category","markerPosition":{"x","y","z"},"shortText","fullText","source"}]`

---

## 🚨 RULES

1. **Τα 6 regions είναι σταθερά:** `name` και `label` ΠΟΤΕ δεν αλλάζουν — είναι hardcoded στο running app (`regionsData` στο index.html). Το skill γεμίζει μόνο `contributions`, `docStrength`, `category`.
2. **docScore ακριβώς με τον τύπο του app:** `min(len(source)/10, 10)` αν υπάρχει source, αλλιώς `1`. Μην επινοείς άλλη κλίμακα.
3. **category ανά region = μονή τιμή:** Αν μια περιοχή έχει πάνω από μία seed contribution, το `category` του region παίρνει την κατηγορία της τελευταίας — το app δεν κάνει μείγμα χρωμάτων.
4. **assets πάντα `[]`:** Τα 3D μοντέλα (GLB/FBX/OBJ) ανεβαίνουν χειροκίνητα μέσα στην εφαρμογή, όχι από το skill.
5. **Άδειες περιοχές ΟΚ:** Δεν χρειάζεται να γεμίσεις και τις 6 — 2–4 τεκμηριωμένες περιοχές είναι καλύτερα από 6 αδύναμες.
6. **Μόνο από πηγή:** contributions/discoveries προέρχονται αποκλειστικά από το κείμενο εισόδου.
7. **⚠️ Τα discoveries ΔΕΝ φορτώνονται ακόμα αυτόματα:** Το `DISCOVERIES` array μέσα στο index.html είναι προς το παρόν ένα hardcoded JS constant (όχι fetch από αρχείο) — βλ. σχόλιο στο ίδιο το index.html. Το `sculpture_discoveries.json` που γράφει αυτό το skill είναι προετοιμασία για μελλοντικό `loadDiscoveries()` pipeline. Μέχρι να συνδεθεί, αντέγραψε το περιεχόμενο χειροκίνητα μέσα στη σταθερά `DISCOVERIES` του index.html.
8. **markerPosition είναι σημείο εκκίνησης:** Οι συντεταγμένες του πίνακα στο STEP 2 είναι ενδεικτικές — τελική ρύθμιση γίνεται οπτικά μέσα στο app.
