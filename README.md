# STAGE_M2_SYNERGIES

## Description
Ce dépôt contient les scripts développés pour analyser les synergies musculaires et la cinématique de l'épaule à partir de signaux EMG et d'angles articulaires issus de mouvements fonctionnels.  
Il est organisé autour de cinq grands dossiers principaux : **SYNERGIES**, **ELECTROMYOGRAPHY**, **KINEMATIC**, **CLUSTERING** et **MEAN PROFIL**.  
Les traitements incluent l'extraction, le nettoyage personnalisé, le traitement complet des signaux EMG et cinématiques, ainsi que l'analyse statistique des profils musculaires et articulaires.

---

## Table des matières
- [1) SYNERGIES](#1-synergies)
- [2) ELECTROMYOGRAPHY](#2-electromyography)
- [3) KINEMATIC](#3-kinematic)
- [4) CLUSTERING](#4-clustering)
- [5) MEAN PROFIL](#5-mean-profil)

---

## 1) SYNERGIES
Préparation des données EMG pour l’analyse des synergies musculaires à partir des mouvements fonctionnels.  
Divisé en deux sous-dossiers :

### 1.1) solo_functional
- Traitement d'**un seul mouvement fonctionnel** pour **un sujet**.
- Extraction, traitement et formatage des signaux EMG pour un mouvement fonctionnel isolé.

### 1.2) main_functional
- Traitement de **tous les mouvements fonctionnels combinés** pour **un sujet**.
- Extraction, traitement, concaténation des signaux EMG.
- Application d'un **nettoyage personnalisé du signal** avant l'analyse des synergies.

---

## 2) ELECTROMYOGRAPHY
Analyse complète des activations musculaires extraites des mouvements analytiques et fonctionnels.  
Divisé en deux sous-dossiers :

### 2.1) Analytic
- Analyse des mouvements **analytiques** d'un sujet.
- Extraction et traitement des signaux EMG bruts de mouvements de référence simples.

### 2.2) Functional
- Analyse complète des mouvements **fonctionnels** :
  - **Filtrage** passe-bande,
  - **Rectification** du signal,
  - **Lissage** (calcul RMS),
  - **Normalisation** des activations,
  - Calcul des **profils moyens** d'activation,
  - Calcul du **rapport signal/bruit (SNR)**,
  - Calcul des **ratios d'activation musculaire**.

---

## 3) KINEMATIC
Traitement de la cinématique de l'épaule à partir des données de mouvements fonctionnels.  
Contient un sous-dossier :

### 3.1) Main
- Extraction et calcul des **angles articulaires** huméro-thoraciques, scapulo-thoraciques et gléno-huméraux selon la **méthode d'Euler**.
- Correction des discontinuités angulaires et recentrage des mouvements.
- Comparaison statistique des angles articulaires entre différentes populations via **SPM1D**.

---

## 4) CLUSTERING
Regroupement des sujets selon des critères cinématiques ou synergiques.  
Divisé en deux sous-dossiers :

### 4.1) Kinematic clustering
- **Clustering** des courbes d'**élévation huméro-thoracique**.
- Méthodes utilisées : **k-means** et **analyse en composantes principales (PCA)**.

### 4.2) Synergies clustering
- **Clustering** des **vecteurs de synergies** musculaires et des **profils d'activation temporels**.
- Méthodes utilisées : **k-means** et **PCA**.

---

## 5) MEAN PROFIL
Génération et comparaison des profils moyens de synergies et d’activations temporelles entre populations :

- Calcul des **profils moyens** des **vecteurs de synergies** et des **activations temporelles**.
- Comparaison entre différentes populations via :
  - **Tests t** pour détecter les différences significatives,
  - **Corrélations de Pearson** pour évaluer la similarité entre profils.
- Visualisation des résultats statistiques.

### 3) COUPLAGE EMG KINEMATIC (en cours de développement)
Ce dossier contient un seul sous-dossier :

#### (1) main_couplage
- **`main_couplage`** : Contient un script partiel qui met en corrélation les données **EMG** avec les angles calculés de l’épaule lors des mouvements fonctionnels.
