# SKILL: History Explorer 3D — Protected Scene Builder

## Σκοπός

Δημιουργείς εκπαιδευτικό περιεχόμενο για το History Explorer 3D χωρίς να
αλλάζεις την κοινή σκηνή. Η μοναδική πηγή αλήθειας για χαρακτήρες, GLB,
θέσεις, χρώματα, ονόματα και μόνιμα props είναι:

`templates/history3d/default.json`

Το template έχει 18 προστατευμένους χαρακτήρες και 3 μόνιμα props:
`dimitris`, `bishop`, `agia_sophia`. Δεν επεξεργάζεσαι το template
χωρίς ρητή εντολή του χρήστη.

## Είσοδος και έξοδος

Είσοδος: κείμενο πηγής ή υπάρχον JSON μαθήματος.

Υποχρεωτικά outputs:

- `data/current/history3d_content.json`: lesson content overlay.
- `data/current/history3d.json`: πλήρες validated scenario.
- `lessons/<lesson-folder>/history3d_output.json`: αντίγραφο βιβλιοθήκης.
- `lessons/<lesson-folder>/master_output.json.history3d`: το ίδιο πλήρες scenario.

## 1. Content overlay

Το overlay περιέχει υποχρεωτικά μόνο:

- `dialogs`
- `facts`
- `screens`

Μπορεί επιπλέον να περιέχει:

- `interactive`
- `character_interactives`
- `completion`
- `quiz`

Δεν περιέχει ποτέ `characters` ή `props`. Αυτά αντιγράφονται αποκλειστικά
από το protected template.

### Βασική δομή

```json
{
  "dialogs": [
    {
      "character_id": "socrates",
      "question": "<ερώτηση>",
      "answer": "<απάντηση>"
    }
  ],
  "facts": [
    {
      "character_id": "socrates",
      "fact": "<ιστορικό ή θεολογικό στοιχείο>"
    }
  ],
  "screens": {
    "left_image_url": "<http(s) URL, /media path ή κενό>",
    "right_image_url": "<http(s) URL, /media path ή κενό>",
    "left_label": "<label>",
    "right_label": "<label>"
  }
}
```

### Προαιρετικός εμπλουτισμός

```json
{
  "interactive": {
    "video_url": "/media/lesson-reward.mp4",
    "target_screen": "right",
    "label": "<label>"
  },
  "character_interactives": {
    "Alexander.glb": {
      "video_url": "/media/alexander.mp4",
      "target_screen": "right",
      "label": "<label>"
    }
  },
  "completion": {
    "required_character_ids": ["socrates", "Alexander.glb"],
    "reward_interactive": {
      "video_url": "/media/reward.mp4",
      "target_screen": "right",
      "label": "<label>"
    }
  },
  "quiz": {
    "id": "lesson-understanding",
    "host_prop_id": "dimitris",
    "host_name": "Δημήτρης",
    "host_title": "Συντονιστής κατανόησης",
    "intro": "<εισαγωγή>",
    "pass_score": 2,
    "reward_text": "<μήνυμα επιτυχίας>",
    "questions": [
      {
        "id": "q1",
        "prompt": "<ερώτηση>",
        "options": ["<Α>", "<Β>", "<Γ>"],
        "correct_index": 0,
        "explanation": "<εξήγηση>"
      }
    ]
  }
}
```

Κάθε media URL αρχίζει με `http://`, `https://` ή `/`.
Το `target_screen` είναι `left` ή `right`. Τα character IDs και το
`host_prop_id` πρέπει να υπάρχουν στο template.

## 2. Παραγωγή πλήρους scenario

```bash
python3 scripts/build_history3d_from_template.py \
  templates/history3d/default.json \
  data/current/history3d_content.json \
  data/current/history3d.json
```

Το builder χρησιμοποιεί το κοινό
`scripts/history3d_contract.py`, αντιγράφει χαρακτήρες/props από το
template και διατηρεί χωρίς απώλεια τα τέσσερα προαιρετικά πεδία.

## 3. Υποχρεωτικός συγχρονισμός βιβλιοθήκης

```bash
cp data/current/history3d.json \
  lessons/<lesson-folder>/history3d_output.json

python3 scripts/sync_history3d_to_master.py \
  templates/history3d/default.json \
  data/current/history3d.json \
  lessons/<lesson-folder>/master_output.json
```

Μην ολοκληρώνεις το skill αν τα τρία πλήρη αντίγραφα
(`current`, `history3d_output`, `master_output.history3d`) δεν είναι
σημασιολογικά ίδια.

## 4. Validation

Πριν από local ή GitHub distribution έλεγξε:

1. Οι `characters` και `props` είναι ακριβώς ίδιοι με το template.
2. Υπάρχουν μόνο τα 5 βασικά και τα 4 προαιρετικά top-level keys.
3. Dialogs/facts αναφέρονται σε υπαρκτά character IDs.
4. Completion και character interactives αναφέρονται σε υπαρκτά IDs.
5. Το quiz χρησιμοποιεί υπαρκτό permanent prop ως host.
6. Κανένα optional enrichment δεν αφαιρείται κατά build ή distribution.

Το `workflows/local_distribute.sh` και το GitHub Action καλούν πλέον τον
ίδιο lossless publisher: `scripts/update_history3d.py`.

## Κανόνες ασφαλείας

1. Μην αλλάζεις ποτέ protected χαρακτήρα, GLB, θέση ή prop μέσα σε lesson JSON.
2. Νέα πρόσωπα ή αλλαγές σκηνής γίνονται μόνο στο template με ρητή εντολή.
3. Μην κάνεις raw copy προς History Explorer χωρίς contract validation.
4. Μην χρησιμοποιείς app-level τίτλο ως lesson title. Η σειρά προτεραιότητας
   είναι `lesson_plan.lesson.title` → `meta.topic` → `master_output.title`.
5. Το `active_lesson.source` είναι repository-relative, ποτέ απόλυτο Mac path.
