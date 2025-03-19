function [subjects, muscles, functional_labels, analytic_labels, assigned_analytics] = defineParameters()
% Définis les paramètres du sujet et des muscles
    % Définition sujet 
    subjects = {'MG20'}; % Marche pour un sujet
    % 'MF01', 'TF02', 'YL03','SC04', 'RF05', 'AP06'
    % 'TD07', 'IS08', 'LC09', 'MP10', 'PK11'
    % 'TF12','JM13', 'GD14', 'LD15', 'LM16','NQ17', 'JV18'
    % 'EG19', 'MG20', 'LB21', 'AP22', 'SC23'
    % 'TM24', 'EG25', 'RL26'
    
    % Définition des muscles (choisir droite ou gauche)
    muscles = {'RDELTA', 'RDELTM', 'RDELTP', 'RTRAPM', 'RTRAPS', 'RSERRA'};
    % muscles = {'LDELTA', 'LDELTM', 'LDELTP', 'LTRAPM', 'LTRAPS', 'LSERRA'};
    
    % Définition des labels pour les tâches
    functional_labels = {...
        'Porter les mains à la bouche', ...
        'Toucher le haut de la tête', ...
        'Porter les mains le plus haut possible au-dessus de la tête', ...
        'Porter les mains le plus haut possible le long de la colonne vertébrale'};
    analytic_labels = { 
        'Flexion (élévation sagittale)', ...
        'Abduction (élévation coronale)', ...
        'Rotation externe (abduction 0°)', ...
        'Rotation interne (abduction 0°)'};
    
    % Association Muscle -> Tâche Analytique définie manuellement
    assigned_analytics = [1, 2, 2, 2, 2, 2]; %4
end