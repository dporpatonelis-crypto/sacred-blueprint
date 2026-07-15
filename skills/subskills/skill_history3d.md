# SKILL: History Explorer 3D — Protected Scene Builder

## Σκοπός

Δημιουργείς εκπαιδευτικό περιεχόμενο για το History Explorer 3D χωρίς να
αλλάζεις τη σκηνή. Τα GLB models, τα IDs, τα ονόματα, οι θέσεις, οι
περιστροφές, τα χρώματα και τα screen URLs είναι **προστατευμένα** στο:

`templates/history3d/default.json`

Ο χρήστης αλλάζει το template χειροκίνητα μόνο όταν θέλει νέα πρόσωπα ή άλλη
σκηνοθεσία. Το skill δεν επεξεργάζεται ποτέ αυτό το αρχείο.

## Είσοδος

Κείμενο πηγής ή υπάρχον JSON μαθήματος.

## Ροή εργασίας

### 1. Εξαγωγή περιεχομένου

Εξήγαγε 4 ερωτήσεις/απαντήσεις, έως 5 σύντομα facts και δύο labels για τις
υπάρχουσες οθόνες. Μην εξάγεις χαρακτήρες ή χωρικές οδηγίες.

Διάβασε τα IDs από `templates/history3d/default.json`. Χρησιμοποίησε μόνο
υπάρχοντα IDs. Για το τρέχον template είναι προτιμότερα:

- `socrates`
- `hypatia`
- `aristotle`
- `Constantine compressed (2).glb`
- `monk compressed.glb`
- `Alexander.glb`

Αν το κείμενο αναφέρεται σε πρόσωπο που δεν υπάρχει στη σκηνή, παρουσίασε το
περιεχόμενο ως ερώτηση/απάντηση από ένα υπάρχον NPC. Μην μετονομάσεις NPC και
μην επινοήσεις GLB path.

### 2. Δημιουργία content overlay

Δημιούργησε **μόνο** το ακόλουθο JSON. Τα URLs στις οθόνες αντιγράφονται
ακριβώς από το template.

```json
{
  "dialogs": [
    {
      "character_id": "socrates",
      "question": "<ερώτηση του μαθητή>",
      "answer": "<σύντομη απάντηση ή πρόσκληση για σκέψη>"
    }
  ],
  "facts": [
    {
      "character_id": "socrates",
      "fact": "<σύντομο ιστορικό ή θεολογικό στοιχείο>"
    }
  ],
  "screens": {
    "left_image_url": " /models/Judging_Socrates.mp4",
    "right_image_url": "https://i.ibb.co/GQ7P88jD/bg-caseclosed.jpg",
    "left_label": "<τίτλος αριστερής οθόνης>",
    "right_label": "<τίτλος δεξιάς οθόνης>"
  }
}
```

Μην βάζεις `characters`, `glbModel`, `position_x`, `position_y`,
`position_z`, `rotation`, `trigger`, `text`, `response_options`, `title` ή
`background` στο overlay. Αυτά δεν ανήκουν στο schema της εφαρμογής.

### 3. Παραγωγή τελικού JSON

Αποθήκευσε το overlay ως `data/current/history3d_content.json`, έπειτα τρέξε:

```bash
python3 scripts/build_history3d_from_template.py \
  templates/history3d/default.json \
  data/current/history3d_content.json \
  data/current/history3d.json
```

Το script αντιγράφει το template και αντικαθιστά μόνο `dialogs`, `facts` και
`screens`. Αν το validation αποτύχει, διόρθωσε το overlay· μην γράψεις JSON
χειροκίνητα πάνω στο τελικό αρχείο.

### 4. Sync στο master_output.json

```bash
python3 scripts/sync_history3d_to_master.py \
  templates/history3d/default.json \
  data/current/history3d.json \
  lessons/<lesson-folder>/master_output.json
```

## Κανόνες

1. Η σκηνή έχει 17 προστατευμένους χαρακτήρες. Δεν προσθέτεις ή αφαιρείς κανέναν.
2. Δεν αλλάζεις ποτέ GLB model, θέση, περιστροφή, χρώμα, όνομα ή description.
3. Κάθε `character_id` σε dialog ή fact πρέπει να υπάρχει στο template.
4. Τα dialogs έχουν ακριβώς: `character_id`, `question`, `answer`.
5. Τα facts έχουν ακριβώς: `character_id`, `fact`.
6. Τα screens έχουν ακριβώς: `left_image_url`, `right_image_url`, `left_label`, `right_label`.
7. Νέα πρόσωπα ή αλλαγές σκηνής γίνονται αποκλειστικά με χειροκίνητη επεξεργασία του template από τον χρήστη.
