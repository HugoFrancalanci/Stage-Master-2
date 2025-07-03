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
- Effectuer des comparaisons statistiques inter-groupes via des ANOVA, tests t, des analyses de clustering, SPM1D et de similarité cosinus.

Ce dépôt est organisé autour de six grands dossiers principaux : **SYNERGIES**, **ELECTROMYOGRAPHY**, **KINEMATIC**, **CLUSTERING**, **MEAN PROFIL** et **INDIVIDUAL ANALYSIS**. Une notice d'utilisation (en français) permettant de détailler chaque dossier et fonction utilisée est également disponible.

---

## Table des matières
- [1) SYNERGIES](#1-synergies)
- [2) ELECTROMYOGRAPHY](#2-electromyography)
- [3) KINEMATIC](#3-kinematic)
- [4) CLUSTERING](#4-clustering)
- [5) MEAN PROFIL](#5-mean-profil)
- [6) INDIVIDUAL ANALYSIS](#6-individual-analysis)

---

## 1) SYNERGIES
Préparation des données EMG pour l’analyse des synergies musculaires à partir des mouvements fonctionnels.  
Divisé en deux sous-dossiers :

### 1.1) solo_functional
- Traitement d'**un seul mouvement fonctionnel** pour **un sujet**.
- Extraction, traitement et normalisation EMG.
- Découpage automatique en **3 cycles** via le marqueur RHLE (coude).
- Nettoyage du signal, visualisation et export de la matrice EMG traitée.

### 1.2) main_functional
- Traitement de **4 mouvements fonctionnels combinés** (12 cycles).
- Découpage manuel possible, nettoyage des artefacts (écart-type).
- Assemblage de tous les signaux EMG dans une matrice globale concaténée.

---

## 2) ELECTROMYOGRAPHY
Analyse des activations musculaires issues des mouvements analytiques et fonctionnels.  
Organisé en plusieurs sous-dossiers :

### 2.1) Analytic
- Affichage des signaux bruts normalisés issus des mouvements de référence.

### 2.2) Functional
- **Filtrage** passe-bande (15-475 Hz),
- **Rectification** du signal (full-wave),
- **Lissage** (Root Mean Square),
- **Normalisation** des activations (sous-tâches maximales normalisées),
- Calcul des **profils moyens** d'activation, du **rapport signal/bruit** et **ratios d'activation musculaire**,
- Nettoyage des artefacts, détection de l'activité du dentelé antérieur (artefacts cardiaque).
- Calcul des **ratios musculaires**, **rapport signal/bruit**, et **profils moyens**.
- Préparation à l'analyse **SPM1D** sur signaux moyens combinés.
  
---

## 3) KINEMATIC
Analyse cinématique de l'épaule à l'aide de la méthode d'Euler.  

### 3.1) Main
- Extraction des angles gléno-huméral, scapulo-thoracique et huméro-thoracique selon Wu et al. 2005 à partir des marqueurs Qualisys.
- Détection et validation des cycles, centrage, correction et filtrage des angles.
- Calcul des **moyennes globales**, **pics**, **amplitudes** et **vitesses**.
- Comparabilité inter-côtés (entre épaule gauche et droite).

### 3.2) Plot_kin
- Tracé des **courbes moyennes d’élévation HT**.
- Comparaison inter-groupes par **SPM1D**.

---

## 4) CLUSTERING
Méthodes de regroupement des données EMG et cinématiques.

### 4.1) Kinematic clustering
- Clustering des courbes d'**élévation HT** par k-means.
- Sélection automatique du nombre de clusters via la **méthode du coude**.

### 4.2) Synergies clustering
- Clustering des vecteurs **W** (synergies musculaires) et **H** (activations temporelles).
- Application combinée de **PCA** et **k-means**.

---

## 5) MEAN PROFIL
Comparaison des profils moyens extraits de l’analyse des synergies musculaires.

### 5.1) Comparaison_VAF
- Comparaison des **valeurs de variance accounted for (VAF)** entre groupes.

### 5.2) Comparaison_SYN
- Comparaison des **poids musculaires (W)** et **activations (H)** par **ANOVA suivi de post-hoc**.
- Corrélations de Pearson, figures synthétiques, barplots et courbes.

---

## 6) INDIVIDUAL ANALYSIS
Analyse individualisée des profils EMG, cinématiques et synergiques.

### 6.1) Electromyography
- Comparaison des **pics EMG** entre groupes, par muscle et sujet.

### 6.2) Kinematic
- Comparaison des **pics et amplitudes huméro-thoracique** entre groupes.

### 6.3) Synergy
- Calcul de la **similarité cosinus** entre chaque synergie individuelle et le profil de référence asymptomatique.
