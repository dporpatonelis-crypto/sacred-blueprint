# SKILL: Personal Page JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** Personal Page (Notebook Media Manager — hub εφαρμογή, ίδιο schema με Notebook Media)
- **Role:** Δημιουργείς chapters για το Personal Page hub με πλούσιο εκπαιδευτικό περιεχόμενο και παιδαγωγικές σημειώσεις. Χρησιμοποιεί **ακριβώς το ίδιο schema** με το Notebook Media αλλά με διαφορετική εκπαιδευτική εστίαση (hub/overview αντί για classroom notes).

---

## 📥 INPUT

Ένα από τα δύο:
1. **Κείμενο πηγής** (θέμα, ενότητα, ερευνητικές σημειώσεις)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή

---

## 🔄 WORKFLOW

### STEP 1 — Extraction

Από το κείμενο εξήγαγε:
- **1–2 chapters** — το Personal Page λειτουργεί ως **ενότητα θέματος** στο hub, όχι ως ημερήσιο notebook
- Τίτλο ενότητας (συνοπτικός, για navigation)
- Πλούσιο HTML: bold, em, ul/li με βασικές έννοιες, πηγές, ερωτήματα
- Plain text για αναζήτηση
- 2–3 stickies (παιδαγωγικές υπενθυμίσεις για τον δάσκαλο)
- Media skeleton με παιδαγωγικά notes για **πότε/πώς** κάθε media χρησιμοποιείται στο μάθημα

Εκτύπωσε σύνοψη.

---

### STEP 2 — JSON Generation

Ίδιο schema με Notebook Media, **διαφορετική εστίαση στο περιεχόμενο:**

```json
{
  "title": "<τίτλος ενότητας/θέματος>",
  "date": "<YYYY-MM-DD σήμερα>",
  "chapters": [
    {
      "index": 1,
      "title": "<σύντομος τίτλος κεφαλαίου>",
      "html": "<p><strong>Θέμα:</strong> <πλούσια HTML περιγραφή></p><ul><li><strong>Βασικές έννοιες:</strong> ...</li><li><strong>Πηγές:</strong> ...</li><li><strong>Ερωτήματα προς διερεύνηση:</strong> ...</li></ul>",
      "text": "<ίδιο ως plain text για αναζήτηση>",
      "stickies": [
        "<παιδαγωγική σημείωση 1 — για τον δάσκαλο>",
        "<σημείωση 2>",
        "<σημείωση 3 — προαιρετική>"
      ],
      "media": {
        "audio": [
          {
            "id": "pp_audio_1",
            "label": "<τίτλος audio ή podcast>",
            "url": "<URL ή κενό>",
            "notes": "<σε ποιο σημείο του μαθήματος — πριν/κατά/μετά>"
          }
        ],
        "slides": [
          {
            "id": "pp_slides_1",
            "label": "<τίτλος παρουσίασης>",
            "url": "<Google Slides pubembed URL ή κενό>",
            "notes": "<σε ποια φάση της διδασκαλίας>"
          }
        ],
        "notebooklm": [
          {
            "id": "pp_nlm_1",
            "label": "NotebookLM — <θέμα>",
            "url": "",
            "notes": "<ερώτηση προς NotebookLM για βαθύτερη ανάλυση>"
          }
        ],
        "pdf": [
          {
            "id": "pp_pdf_1",
            "label": "<τίτλος κειμένου/πηγής>",
            "url": "<URL ή κενό>",
            "notes": "<ποιο μέρος να διαβαστεί και γιατί>"
          }
        ],
        "text": [
          {
            "id": "pp_text_1",
            "label": "<τίτλος αποσπάσματος ή σημείωσης>",
            "url": "",
            "content": "<σύντομο απόσπασμα πηγής, παράθεμα ή εκπαιδευτική σημείωση>",
            "notes": "<σχόλιο χρήσης>"
          }
        ]
      }
    }
  ]
}
```

**Διαφορές από Notebook Media:**
- `pp_` prefix στα ids (αντί για `mi_`)
- `stickies`: έως 3 (αντί για 2) — το Personal Page έχει περισσότερο χώρο για παιδαγωγικές σημειώσεις
- `html`: πιο δομημένο με ul/li ενότητες (βασικές έννοιες + πηγές + ερωτήματα)
- `notes` κάθε media: εξηγεί **πότε** (πριν/κατά/μετά το μάθημα) αντί απλώς πώς

**Media field mapping:**
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
path = os.path.expanduser('~/sacred-blueprint/data/current/personalpage.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

---

### STEP 4 — Summary Report

```
[LOG] Personal Page
  Title        : <τίτλος>
  Chapters     : N
  Stickies     : N (παιδαγωγικές σημειώσεις)
  Media filled : audio: N, slides: N, pdf: N, text: N
  Media empty  : <λίστα κενών>
  File         : ~/sacred-blueprint/data/current/personalpage.json
  Status       : complete
```

---

## 📐 JSON SCHEMA

Ίδιο με `skill_notebook_media.md` — μόνο τα ids αλλάζουν σε `pp_*`.

---

## 🚨 RULES

1. **1–2 chapters:** Το Personal Page είναι hub overview — δεν χρειάζεται πολλά chapters.
2. **HTML δομημένο:** Πάντα με ul/li για βασικές έννοιες, πηγές, ερωτήματα.
3. **notebooklm.url πάντα κενό:** Συμπληρώνεται χειροκίνητα.
4. **notes με χρονική αναφορά:** «Πριν το μάθημα», «Κατά τη διάρκεια», «Για εμβάθυνση» — συγκεκριμένα.
5. **pp_ prefix:** Όλα τα ids ξεκινούν με `pp_` για να διαφέρουν από τα notebook `mi_`.
6. **Ίδιο schema με Notebook:** Αν αμφιβάλλεις για τη δομή, βλ. `skill_notebook_media.md`.
