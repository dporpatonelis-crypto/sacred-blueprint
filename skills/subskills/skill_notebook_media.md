# SKILL: Notebook Media JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** Notebook Media (Samsung tablet/S Pen, handwriting fonts, chapter tabs, JSON import/export)
- **Role:** Δημιουργείς chapters με πλούσιο εκπαιδευτικό περιεχόμενο και πλήρη media skeleton. Εκτελείς χωρίς άδεια για τεχνικά βήματα.

---

## 📥 INPUT

Ένα από τα δύο:
1. **Κείμενο πηγής** (θέμα, σημειώσεις, απόσπασμα)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή

---

## 🔄 WORKFLOW

### STEP 1 — Extraction

Από το κείμενο εξήγαγε:
- **1–2 chapters** (ένα κεφάλαιο ανά μεγάλη θεματική ενότητα)
- Τίτλο notebook και κάθε chapter
- Εκπαιδευτικό περιεχόμενο ως HTML (bold, em, ul/li επιτρέπονται)
- Plain text έκδοση για αναζήτηση
- 2 stickies (σύντομες σημειώσεις για τον δάσκαλο)
- Media skeleton: audio, slides, notebooklm, pdf, text

Εκτύπωσε σύνοψη.

---

### STEP 2 — JSON Generation

```json
{
  "title": "<τίτλος notebook>",
  "date": "<YYYY-MM-DD σήμερα>",
  "chapters": [
    {
      "index": 1,
      "title": "<τίτλος κεφαλαίου>",
      "html": "<p><strong>Θέμα:</strong> <περιγραφή></p><p><em>Βασικές έννοιες: ...</em></p><ul><li><strong>Πηγές:</strong> ...</li></ul>",
      "text": "<ίδιο ως plain text χωρίς HTML tags>",
      "stickies": [
        "<σύντομη παιδαγωγική σημείωση για τον δάσκαλο>",
        "<δεύτερη σημείωση>"
      ],
      "media": {
        "audio": [
          {
            "id": "mi_audio_1",
            "label": "<τίτλος audio ή podcast>",
            "url": "<URL ή κενό>",
            "notes": "<πότε/πώς να το χρησιμοποιήσεις στο μάθημα>"
          }
        ],
        "slides": [
          {
            "id": "mi_slides_1",
            "label": "<τίτλος παρουσίασης>",
            "url": "<Google Slides embed URL ή κενό>",
            "notes": "<σε ποιο σημείο του μαθήματος>"
          }
        ],
        "notebooklm": [
          {
            "id": "mi_nlm_1",
            "label": "NotebookLM — <θέμα>",
            "url": "",
            "notes": "<τι να ρωτήσεις στο NotebookLM για αυτό το θέμα>"
          }
        ],
        "pdf": [
          {
            "id": "mi_pdf_1",
            "label": "<τίτλος PDF/κειμένου>",
            "url": "<URL ή κενό>",
            "notes": "<ποιες σελίδες / τι να διαβάσεις>"
          }
        ],
        "text": [
          {
            "id": "mi_text_1",
            "label": "<τίτλος αποσπάσματος>",
            "url": "",
            "content": "<σύντομο απόσπασμα πηγής ή σημείωση>",
            "notes": ""
          }
        ]
      }
    }
  ]
}
```

**Media field mapping (αν υπάρχουν URLs από library):**
- `image` URL → `text[].content` ως παράθεμα αναφοράς
- `youtube` URL → `audio[].url`
- `google_slides` URL → `slides[].url`
- `pdf` URL → `pdf[].url`

Εκτύπωσε σε code block.

---

### STEP 3 — Write to Workspace

```bash
python3 -c "
import json, os
data = <GENERATED_JSON>
path = os.path.expanduser('~/sacred-blueprint/data/current/notebook.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

---

### STEP 4 — Summary Report

```
[LOG] Notebook Media
  Title        : <τίτλος>
  Chapters     : N
  Media filled : audio: N, slides: N, notebooklm: N, pdf: N, text: N
  Media empty  : <λίστα κενών>
  File         : ~/sacred-blueprint/data/current/notebook.json
  Status       : complete
```

---

## 📐 JSON SCHEMA

```json
{
  "title": "string",
  "date": "YYYY-MM-DD",
  "chapters": [
    {
      "index": 1,
      "title": "string",
      "html": "string (HTML)",
      "text": "string (plain)",
      "stickies": ["string", "string"],
      "media": {
        "audio":       [{"id":"string","label":"string","url":"string","notes":"string"}],
        "slides":      [{"id":"string","label":"string","url":"string","notes":"string"}],
        "notebooklm":  [{"id":"string","label":"string","url":"","notes":"string"}],
        "pdf":         [{"id":"string","label":"string","url":"string","notes":"string"}],
        "text":        [{"id":"string","label":"string","url":"","content":"string","notes":"string"}]
      }
    }
  ]
}
```

---

## 🚨 RULES

1. **1–2 chapters:** Δεν υπερβαίνεις τα 2 ανά κλήση.
2. **HTML πάντα valid:** Μόνο `<p>`, `<strong>`, `<em>`, `<ul>`, `<li>` — όχι `<div>`, `<script>`.
3. **notebooklm.url πάντα κενό:** Το URL συμπληρώνεται χειροκίνητα από τον χρήστη.
4. **notes υποχρεωτικά:** Κάθε media item έχει notes που εξηγούν **πότε/πώς** χρησιμοποιείται στο μάθημα.
5. **ids μοναδικά:** `mi_audio_1`, `mi_slides_1` κ.λπ. — αν υπάρχουν 2 chapters, συνέχισε αρίθμηση (`mi_audio_2`).
6. **Κενά URLs ΟΚ:** Καλύτερο κενό string από εφευρημένο URL.
