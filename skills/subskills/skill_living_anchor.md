# SKILL: Living Anchor JSON Architect
## Sub-Skill · Καλείται από `new-lesson-workflow` ή αυτόνομα

---

## 🎯 CONTEXT

- **Environment:** VS Code + Continue Extension
- **Workspace:** `~/sacred-blueprint`
- **App:** Living Anchor (layered text annotation, JSON export)
- **Role:** Δημιουργείς anchors με τριεπίπεδη ανάλυση (literal → structural → critical) και αιτιακές συνδέσεις. Εκτελείς χωρίς άδεια για τεχνικά βήματα.

---

## 📥 INPUT

Ένα από τα δύο:
1. **Κείμενο πηγής** (απόσπασμα, θέμα, σημειώσεις)
2. **Υπάρχον JSON** άλλης εφαρμογής για μετατροπή

---

## 🔄 WORKFLOW

### STEP 1 — Extraction

Από το κείμενο εξήγαγε **3–4 φράσεις-κλειδιά** (anchors).

Για κάθε anchor:
- **Phrase:** Η ακριβής φράση ή έννοια από το κείμενο
- **Literal layer:** Τι λέει κυριολεκτικά (τι, ποιος, πότε)
- **Structural layer:** Πώς συνδέεται με τη δομή του θέματος / ποιος ο ρόλος της
- **Critical layer:** Ποια η σημασία, ποια αντίθεση ή παράδοξο εγείρει, γιατί έχει σημασία σήμερα
- **Cause:** Τι προκάλεσε αυτή τη φράση/κατάσταση
- **Consequence:** Τι προκάλεσε με τη σειρά της

Εκτύπωσε σύνοψη.

---

### STEP 2 — JSON Generation

```json
{
  "metadata": {
    "title": "<τίτλος μαθήματος>",
    "source": "<πηγή κειμένου>",
    "date": "<YYYY-MM-DD σήμερα>"
  },
  "anchors": [
    {
      "id": "<slug π.χ. 'homoousion'>",
      "phrase": "<φράση-κλειδί>",
      "layers": {
        "literal": "<τι λέει κυριολεκτικά>",
        "structural": "<πώς λειτουργεί στο κείμενο/θέμα>",
        "critical": "<γιατί έχει σημασία — αντίθεση, παράδοξο, σύνδεση με παρόν>"
      },
      "causality": {
        "cause": "<τι το προκάλεσε>",
        "consequence": "<τι προκάλεσε>"
      }
    }
  ]
}
```

**Κανόνες για τα layers:**
- `literal` → 1 πρόταση, περιγραφική
- `structural` → 1-2 προτάσεις, αναλυτική
- `critical` → 2-3 προτάσεις, ερμηνευτική — εδώ η παιδαγωγική αξία

Εκτύπωσε σε code block.

---

### STEP 3 — Write to Workspace

```bash
python3 -c "
import json, os
data = <GENERATED_JSON>
path = os.path.expanduser('~/sacred-blueprint/data/current/anchor.json')
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print('Written.')
"
```

---

### STEP 4 — Summary Report

```
[LOG] Living Anchor
  Title        : <τίτλος>
  Source       : <πηγή>
  Anchors      : N
  Layers       : literal / structural / critical (όλα συμπληρωμένα)
  File         : ~/sacred-blueprint/data/current/anchor.json
  Status       : complete
```

---

## 📐 JSON SCHEMA

```json
{
  "metadata": {
    "title": "string",
    "source": "string",
    "date": "YYYY-MM-DD"
  },
  "anchors": [
    {
      "id": "string (slug, lowercase, no spaces)",
      "phrase": "string",
      "layers": {
        "literal": "string",
        "structural": "string",
        "critical": "string"
      },
      "causality": {
        "cause": "string",
        "consequence": "string"
      }
    }
  ]
}
```

---

## 🚨 RULES

1. **3–4 anchors:** Ελάχιστο 3, μέγιστο 4 — ποιότητα πάνω από ποσότητα.
2. **Και τα τρία layers υποχρεωτικά:** Κανένα κενό — το `critical` είναι το πιο σημαντικό.
3. **Slug ids:** Lowercase, χωρίς κενά/τόνους (π.χ. `"homoousion"`, `"periagoge"`, `"apocatastasis"`).
4. **Causality:** Και τα δύο πεδία πρέπει να είναι συγκεκριμένα — όχι γενικόλογα.
5. **Μόνο από πηγή:** Οι anchors επιλέγονται από το κείμενο, δεν επινοούνται.
