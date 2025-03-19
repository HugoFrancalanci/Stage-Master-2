function params = initializeParameters()
    % Initialisation des paramètres pour l'analyse EMG
    
    % Définition des muscles (choisir droite ou gauche)
    params.muscles = {'RDELTA', 'RDELTM', 'RDELTP', 'RTRAPM', 'RTRAPS', 'RSERRA'};
    % Gauche
    % params.muscles = {'LDELTA', 'LDELTM', 'LDELTP', 'LTRAPM', 'LTRAPS', 'LSERRA'};
    params.nb_muscles = length(params.muscles);
    
    % Définition des labels pour les tâches
    params.functional_labels = {...
        'Porter les mains à la bouche', ...
        'Toucher le haut de la tête', ...
        'Porter les mains le plus haut possible au-dessus de la tête', ...
        'Porter les mains le plus haut possible le long de la colonne vertébrale'};
    params.analytic_labels = { 
        'Flexion (élévation sagittale)', ...
        'Abduction (élévation coronale)', ...
        'Rotation externe (abduction 0°)', ...
        'Rotation interne (abduction 0°)'};
    
    params.nb_functional = length(params.functional_labels);
    params.nb_analytic = length(params.analytic_labels);
    
    % Paramètres EMG
    params.fs = 2000;
    [params.b, params.a] = butter(4, [15, 475] / (params.fs/2), 'bandpass');
    params.rms_window = round(0.250 * params.fs);
    params.num_points = 1000;
    params.time_normalized = linspace(0, 1, params.num_points);
    
    % Paramètres pour la détection basée sur le marqueur RHLE
    params.position_threshold_percent = 30;  % Seuil de déplacement significatif (% du déplacement max)
    params.min_duration = 0.1;  % Durée minimale d'un mouvement (en secondes)
    params.num_cycles = 3;      % Nombre de cycles à traiter
    
    % Association Muscle -> Tâche Analytique définie manuellement
    params.assigned_analytics = [1, 2, 2, 2, 2, 2];
    
    % Chemin de base pour les fichiers
    params.base_path = 'C:\\Users\\Francalanci Hugo\\Documents\\MATLAB\\Stage Sainte-Justine\\HUG\\Sujets\\';
end