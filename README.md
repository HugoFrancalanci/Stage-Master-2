![Made with MATLAB](https://img.shields.io/badge/Made%20with-MATLAB-orange)
![Research Project](https://img.shields.io/badge/Project-Research-blue)
![License MIT](https://img.shields.io/badge/License-MIT-green)

# STAGE MASTER 2

## Description
Ce dépôt contient les scripts de traitement et d'analyse développés dans le cadre d'une étude portant sur l'**effet d'une arthroplastie totale inversée d'épaule** sur les **synergies musculaires** et la **cinématique articulaire**.  
Le projet vise à :
- Traiter les données électromyographiques et cinématiques de patients avant et après chirurgie, ainsi que de sujets asymptomatiques ;
- Extraire et comparer les **synergies musculaires** (coordination inter-musculaire) ;
- Analyser la cinématique articulaire huméro-thoracique, scapulo-thoracique et gléno-humérale ;
- Effectuer des comparaisons statistiques inter-groupes via des tests t, des analyses de clustering et des analyses de similarité.

Ce dépôt est organisé autour de cinq grands dossiers principaux : **SYNERGIES**, **ELECTROMYOGRAPHY**, **KINEMATIC**, **CLUSTERING** et **MEAN PROFIL**.  

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

### 1.1) solo_functional (10 fonctions)
- Traitement d'**un seul mouvement fonctionnel** pour **un sujet**.
- Extraction, traitement et formatage des signaux EMG pour un mouvement fonctionnel isolé.

### 1.2) main_functional (14 fonctions)
- Traitement de **tous les mouvements fonctionnels combinés** pour **un sujet**.
- Extraction, traitement, concaténation des signaux EMG.
- Application d'un **nettoyage personnalisé du signal** (population pathologique) avant l'analyse des synergies.

---

## 2) ELECTROMYOGRAPHY
Analyse complète des activations musculaires extraites des mouvements analytiques et fonctionnels.  
Divisé en deux sous-dossiers :

### 2.1) Analytic (1 fonction)
- Analyse des mouvements **analytiques** d'un sujet.
- Extraction des signaux EMG bruts de mouvements de référence simples.

### 2.2) Functional (25 fonctions)
- Analyse complète des mouvements **fonctionnels** :
  - **Filtrage** passe-bande (15-475 Hz),
  - **Rectification** du signal (full-wave),
  - **Lissage** (Root Mean Square),
  - **Normalisation** des activations (sous-tâches maximales normalisées),
  - Calcul des **profils moyens** d'activation,
  - Calcul du **rapport signal/bruit**,
  - Calcul des **ratios d'activation musculaire**,
  - Option pour calculer **tous les mouvements combinés**
  - Analyse statistique SPM1D pour **comparer les courbes d'activation entre les groupes**.
---

## 3) KINEMATIC
Traitement de la cinématique de l'épaule à partir des données de mouvements fonctionnels.  
Contient un sous-dossier :

### 3.1) Main (35 fonctions)
- Analyse cinémtique effectuée selon les recommendations de la société internationale de biomécanique (Wu el al. 2005) à l'aide des marqueurs cinématiques Qualysis
- Extraction et calcul des **angles articulaires** huméro-thoraciques, scapulo-thoraciques et gléno-huméraux selon la **méthode d'Euler**.
- Comparaison statistique des angles articulaires entre différentes populations via **SPM1D**.

---

## 4) CLUSTERING
Regroupement des sujets selon des critères cinématiques ou synergiques.  
Divisé en deux sous-dossiers :

### 4.1) Kinematic clustering (2 fonctions)
- **Clustering** des courbes d'**élévation huméro-thoracique**.
- Méthodes utilisées : **k-means**, **méthode du coude** et **analyse en composantes principales (PCA)**.

### 4.2) Synergies clustering (2 fonctions)
- **Clustering** des **vecteurs de synergies** musculaires et des **profils d'activation temporels**.
- Méthodes utilisées : **k-means**, **méthode du coude** et **PCA**.

---

## 5) MEAN PROFIL
Génération et comparaison des profils moyens de synergies et d’activations temporelles entre populations :

- Calcul des **profils moyens** des **vecteurs de synergies** et des **activations temporelles**.
- Comparaison entre différentes populations via :
  - **Tests t** pour détecter les différences significatives,
  - **Corrélations de Pearson** pour évaluer la similarité entre profils.
- Visualisation des résultats statistiques.
