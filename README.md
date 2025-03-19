Explication des scripts


Nom des scripts
- One drive : Scripts Hugo (dans le dossier principal numéro 3)
- GitHub : STAGE_M2_SYNERGIES

Contexte : le dossier contient trois grands sous dossiers

1)	SYNERGY : se décline en trois sous-dossiers. 

- (1) Le premier « ANALYTIC » contient le script « solo_analytic_emg » et 1 fonction pour extraire et visualiser les données brutes en valeurs absolues des mouvements analytiques pour un sujet
 
- (2) Le deuxième « FUNCTIONAL » contient 6 scripts : 
         . (2.1) « solo_functional_emg » et 2 fonctions pour extraire et visualiser les données brutes en valeurs absolues des mouvements fonctionnels (avec échelle non et normalisées) pour un sujet
         . (2.2) « main_functional_emg » et 13 fonctions pour traiter les données des quatre mouvements, de tous les sujets sur les deux épaules des mouvements fonctionnels pour tous les sujets

         . (2.3) « repetition_separation » pour regarder les données traitées et isoler les trois répétitions dans l’enregistrement des mouvements fonctionnels
         . (2.4) « muscles_patterns » pour regarder les données traitées et identifier les pics d’activations de chaque pour chaque cycle dans l’enregistrement des mouvements fonctionnels
         . (2.5) « artefacts_detection » pour regarder les données traitées et identifier artefacts restants (cardiaques et de mouvements)  dans l’enregistrement des mouvements fonctionnels
         . (2.5) « normalisation » pour observer les données prétraitées et comparer les différentes méthodes de normalisation dans les enregistrements des mouvements fonctionnels

- (3) Le troisième « SYNERGIES HUGO » contient 2 scripts :
         . (3.1) « main_synergies_1functional » et 10 fonctions pour extraire, traiter, séparer en cycles et formater les données pour préparer à l’extraction d’un mouvement fonctionnel pour un sujet
         . (3.2) « main_synergies_4functional » pour extraire, traiter, séparer en cycles et formater les données pour préparer l’extraction des 4 mouvements fonctionnels concaténés pour un sujet
         . (3.3) « raisonnement_analyse_synergies » pour analyser le raisonnement complet menant à l’extraction et l’interprétation des synergies musculaires

2)	KINEMATIC : se décline en deux sous-dossiers. 

- (1) Le premier « angles_extraits_c3d » contient les angles des mouvements analytiques pour un sujet extrait directement à partir du c3d

- (2) Le deuxième « calcul_angles_euler » contient les angles calculés avec la méthode d'Euler pour les mouvements fonctionnels d’un sujet

3)	COUPLAGE EMG KINEMATIC (en cours de développement) : se décline en un sous-dossiers. 

- (1) « main_couplage » contient un script partiel qui met en corrélation les données EMG avec les angles calculés de l’épaule lors des mouvements fonctionnels
