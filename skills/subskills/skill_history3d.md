# SKILL: History Explorer 3D JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** History Explorer 3D (React Three Fiber, curved screens, NPC models, Firebase Storage)
- **Role:** Δημιουργείς JSON με characters, dialogs, facts και screens για το 3D περιβάλλον. Εκτελείς χωρίς άδεια για τεχνικά βήματα.

---

## 📥 INPUT

Ένα από τα δύο:
1. **Κείμενο πηγής** (ιστορικό θέμα με πρόσωπα και γεγονότα)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή

---

## 🔄 WORKFLOW

### STEP 1 — Extraction

Από το κείμενο εξήγαγε:
- **2 χαρακτήρες** (ιστορικά πρόσωπα που θα είναι NPCs στο 3D περιβάλλον)
- **2 διαλόγους** (ένας ανά χαρακτήρα) με trigger, κείμενο, επιλογές απάντησης
- **3 facts** (συνοπτικά ιστορικά στοιχεία για τα panels)
- **Background** (επιλογή: `bg-agora.jpg` | `bg-library.jpg` | `bg-temple.jpg` | `bg-palace.jpg`)

Εκτύπωσε σύνοψη.

---

### STEP 2 — JSON Generation

```json
{
  "characters": [
    {
      "id": "char_1",
      "name": "<Όνομα χαρακτήρα>",
      "role": "<ρόλος/τίτλος>",
      "description": "<σύντομη βιογραφία, 1-2 προτάσεις>",
      "position_x": 0,
      "position_y": 0,
      "position_z": 0,
      "rotation": 0
    },
    {
      "id": "char_2",
      "name": "<Όνομα χαρακτήρα>",
      "role": "<ρόλος/τίτλος>",
      "description": "<σύντομη βιογραφία>",
      "position_x": 3,
      "position_y": 0,
      "position_z": 0,
      "rotation": 180
    }
  ],
  "dialogs": [
    {
      "character_id": "char_1",
      "trigger": "<τι κάνει ο μαθητής για να ξεκινήσει τον διάλογο>",
      "text": "<ρήση του χαρακτήρα, 2-3 προτάσεις>",
      "response_options": [
        "<επιλογή απάντησης 1>",
        "<επιλογή απάντησης 2>"
      ]
    },
    {
      "character_id": "char_2",
      "trigger": "<trigger για char_2>",
      "text": "<ρήση char_2>",
      "response_options": [
        "<επιλογή 1>",
        "<επιλογή 2>"
      ]
    }
  ],
  "facts": [
    {
      "id": "fact_1",
      "title": "<τίτλος>",
      "content": "<2-3 προτάσεις εκπαιδευτικού περιεχομένου>",
      "era": "<χρονική περίοδος>"
    },
    {
      "id": "fact_2",
      "title": "<τίτλος>",
      "content": "<περιεχόμενο>",
      "era": "<εποχή>"
    },
    {
      "id": "fact_3",
      "title": "<τίτλος>",
      "content": "<περιεχόμενο>",
      "era": "<εποχή>"
    }
  ],
  "screens": {
    "title": "<τίτλος σκηνής>",
    "background": "bg-agora.jpg"
  }
}
```

**Επιλογή background:**
- `bg-agora.jpg` → Αρχαία Αγορά (φιλοσοφία, δημοκρατία, αρχαιότητα)
- `bg-library.jpg` → Βιβλιοθήκη (θεολογία, Πατέρες, κείμενα)
- `bg-temple.jpg` → Ναός (λειτουργία, εικόνες, Βυζάντιο)
- `bg-palace.jpg` → Παλάτι (αυτοκράτορες, πολιτική ιστορία)

Εκτύπωσε σε code block.

---

### STEP 3 — Write to Workspace

```bash
python3 -c "
import json, os
data = <GENERATED_JSON>
path = os.path.expanduser('~/sacred-blueprint/data/current/history3d.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

---

### STEP 4 — Summary Report

```
[LOG] History Explorer 3D
  Characters   : N
  Dialogs      : N
  Facts        : N
  Background   : <bg-*.jpg>
  File         : ~/sacred-blueprint/data/current/history3d.json
  Status       : complete
```

---

## 📐 JSON SCHEMA

```json
{
  "characters": [
    {"id":"string","name":"string","role":"string","description":"string",
     "position_x":0,"position_y":0,"position_z":0,"rotation":0}
  ],
  "dialogs": [
    {"character_id":"string","trigger":"string","text":"string",
     "response_options":["string","string"]}
  ],
  "facts": [
    {"id":"string","title":"string","content":"string","era":"string"}
  ],
  "screens": {"title":"string","background":"bg-agora.jpg"}
}
```

---

## 🚨 RULES

1. **Ακριβώς 2 characters:** Δεν λιγότερο, δεν περισσότερο.
2. **character_id στα dialogs:** Πρέπει να ταιριάζει με `char_1` / `char_2`.
3. **Positions:** Οι χαρακτήρες δεν στέκονται στο ίδιο σημείο — `position_x` να διαφέρει.
4. **Facts max 3:** Συνοπτικά, εκπαιδευτικά, χωρίς Wikipedia-style μήκος.
5. **Background επιλογή:** Ταίριαξε με τη θεματική του μαθήματος.
6. **Μόνο από πηγή:** Οι ρήσεις των χαρακτήρων αντικατοπτρίζουν πραγματικές θέσεις τους.
