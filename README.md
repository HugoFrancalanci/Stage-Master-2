# STAGE_M2_SYNERGIES

## Description
Ce dépôt contient les scripts développés pour analyser les synergies musculaires et la cinématique de l'épaule . Il est structuré en trois grands sous-dossiers : **SYNERGY**, **KINEMATIC**, et **COUPLAGE EMG KINEMATIC**.

---

## Organisation des dossiers

### 1) SYNERGY
Ce dossier est divisé en trois sous-dossiers : **ANALYTIC**, **FUNCTIONAL**, et **SYNERGIES HUGO**.

#### (1) ANALYTIC
- Contient le script **`solo_analytic_emg`** et une fonction associée.
- Permet d'extraire et de visualiser les données brutes en valeurs absolues des mouvements analytiques pour un sujet.

#### (2) FUNCTIONAL
Ce sous-dossier comprend six scripts principaux :

- **`solo_functional_emg`** : Extraction et visualisation des données brutes en valeurs absolues des mouvements fonctionnels (échelle non et normalisée) pour un sujet.
- **`main_functional_emg`** : Traitement des données de quatre mouvements pour tous les sujets et les deux épaules (13 fonctions associées).

- **`repetition_separation`** : Identification et isolation des trois répétitions dans l’enregistrement des mouvements fonctionnels.
- **`muscles_patterns`** : Identification des pics d'activation pour chaque cycle dans l’enregistrement des mouvements fonctionnels.
- **`artefacts_detection`** : Détection des artefacts restants (cardiaques et mouvements) dans l’enregistrement des mouvements fonctionnels.
- **`normalisation`** : Comparaison des différentes méthodes de normalisation des enregistrements des mouvements fonctionnels.

#### (3) SYNERGIES HUGO
Ce sous-dossier comprend trois scripts :

- **`main_synergies_1functional`** : Extraction, traitement, segmentation en cycles et formatage des données pour préparer l’extraction des synergies sur un mouvement fonctionnel pour un sujet (10 fonctions associées).
- **`main_synergies_4functional`** : Extraction, traitement, segmentation en cycles et formatage des données pour l'extraction des synergies sur les quatre mouvements fonctionnels concaténés pour un sujet (12 fonctions associées).
- **`raisonnement_analyse_synergies`** : Documentation du raisonnement menant à l'extraction et l'interprétation des synergies musculaires.

---

### 2) KINEMATIC
Ce dossier est divisé en deux sous-dossiers : **angles_extraits_c3d** et **calcul_angles_euler**.

#### (1) angles_extraits_c3d
- **`angles_c3d_analytics`** : Contient les angles des mouvements analytiques pour un sujet extraits directement à partir des fichiers **C3D**.

#### (2) calcul_angles_euler
- **`main_analyse_kin`** : Contient les angles calculés avec la méthode d'Euler pour les mouvements fonctionnels d’un sujet.

---

### 3) COUPLAGE EMG KINEMATIC (en cours de développement)
Ce dossier contient un seul sous-dossier :

#### (1) main_couplage
- **`main_couplage`** : Contient un script partiel qui met en corrélation les données **EMG** avec les angles calculés de l’épaule lors des mouvements fonctionnels.
