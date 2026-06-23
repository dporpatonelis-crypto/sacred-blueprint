# SKILL: Interactive Books JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** Interactive Books (GitHub Pages, catalog.json, CSV-per-book, UE C++ integration: `ULibraryManager`, `UBookEntryWidget`)
- **Role:** Δημιουργείς σελίδες βιβλίου για το Interactive Books. Εκτελείς χωρίς άδεια για τεχνικά βήματα.

---

## 📥 INPUT

Ένα από τα δύο:
1. **Κείμενο πηγής** (θέμα, απόσπασμα, κεφάλαιο)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή

---

## 🔄 WORKFLOW

### STEP 1 — Extraction

Από το κείμενο εξήγαγε:
- **3–4 σελίδες** με διαφορετικά types
- Τίτλο και υπότιτλο κάθε σελίδας
- Περιεχόμενο (2–3 παράγραφοι ή bullet points ανά σελίδα)
- URLs media αν παρέχονται

**Τύποι σελίδων:**
- `text` → κείμενο με παραγράφους
- `image` → εικόνα με λεζάντα
- `video` → YouTube embed
- `slides` → Google Slides embed
- `quiz` → ερώτηση με επιλογές (αν το θέμα το επιτρέπει)

Εκτύπωσε σύνοψη.

---

### STEP 2 — JSON Generation

```json
{
  "pages": [
    {
      "number": 1,
      "type": "text",
      "title": "<τίτλος σελίδας>",
      "subtitle": "<υπότιτλος>",
      "content": [
        "<παράγραφος 1>",
        "<παράγραφος 2>"
      ],
      "image": "<URL εικόνας ή κενό>",
      "videoId": "<YouTube ID ή κενό>",
      "slidesUrl": "<Google Slides URL ή κενό>"
    },
    {
      "number": 2,
      "type": "text",
      "title": "<τίτλος>",
      "subtitle": "<υπότιτλος>",
      "content": ["<παράγραφος 1>", "<παράγραφος 2>"],
      "image": "",
      "videoId": "",
      "slidesUrl": ""
    }
  ]
}
```

**Κανόνες ανά type:**
- `text`: `content` array με 2-3 strings, `image`/`videoId`/`slidesUrl` κενά
- `image`: `image` με URL, `content` με λεζάντα
- `video`: `videoId` με YouTube ID (μόνο το ID, π.χ. `"dQw4w9WgXcQ"`), `content` με εισαγωγή
- `slides`: `slidesUrl` με embed URL, `content` με περιγραφή

Εκτύπωσε σε code block.

---

### STEP 3 — Write to Workspace

```bash
python3 -c "
import json, os
data = <GENERATED_JSON>
path = os.path.expanduser('~/sacred-blueprint/data/current/books.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

---

### STEP 4 — Summary Report

```
[LOG] Interactive Books
  Pages        : N
  Types        : text: N, image: N, video: N, slides: N
  Media URLs   : <filled: N / empty: N>
  File         : ~/sacred-blueprint/data/current/books.json
  Status       : complete
```

---

## 📐 JSON SCHEMA

```json
{
  "pages": [
    {
      "number": 1,
      "type": "text | image | video | slides | quiz",
      "title": "string",
      "subtitle": "string",
      "content": ["string"],
      "image": "string (URL ή κενό)",
      "videoId": "string (YouTube ID ή κενό)",
      "slidesUrl": "string (URL ή κενό)"
    }
  ]
}
```

---

## 🚨 RULES

1. **3–4 σελίδες:** Ελάχιστο 3, μέγιστο 4.
2. **Ποικιλία types:** Τουλάχιστον 2 διαφορετικοί types αν το υλικό το επιτρέπει.
3. **videoId = μόνο ID:** Όχι πλήρες URL — μόνο το 11-ψήφιο YouTube ID.
4. **Κενά media ΟΚ:** Καλύτερο κενό string από λάθος URL.
5. **content πάντα array:** Ακόμα κι αν είναι 1 παράγραφος, να είναι `["string"]`.
