function [subjects, muscles_R, muscles_L, functional_labels, analytic_labels, assigned_analytics] = configureStudyParameters_solo()
    % Configuration des paramètres de l'étude
    
    % Définition des sujets
    subjects = { 'MP10'};
    % subjects = { 'MF01', 'TF02', 'YL03','SC04', 'RF05', 'AP06',...
    %              'TD07', 'IS08', 'LC09', 'MP10', 'PK11'...
    %              'TF12','JM13', 'GD14', 'LD15', 'LM16','NQ17', 'JV18'...
    %              'EG19', 'MG20', 'LB21', 'AP22', 'SC23'...
    %              'TM24', 'EG25', 'RL26'};
    
    % Ajout de la bibliothèque btk  
    addpath(genpath('C:\Users\Francalanci Hugo\Documents\MATLAB\Stage Sainte-Justine\HUG\btk'));
    
    % Définition des muscles pour les côtés droit et gauche
    muscles_R = {'RDELTA', 'RDELTM', 'RDELTP', 'RTRAPI','RTRAPM', 'RTRAPS', 'RLATD', 'RSERRA'};
    muscles_L = {'LDELTA', 'LDELTM', 'LDELTP', 'LTRAPI','LTRAPM', 'LTRAPS', 'LLATD', 'LSERRA'};
    
    % Définition des labels pour les tâches
    functional_labels = {
        'Porter les mains à la bouche', ...
        'Toucher le haut de la tête', ...
        'Porter les mains le plus haut possible au-dessus de la tête', ...
        'Porter les mains le plus haut possible le long de la colonne vertébrale'
    };
    analytic_labels = { 
        'Flexion (élévation sagittale)', ...
        'Abduction (élévation coronale)', ...
        'Rotation externe (abduction 0°)', ...
        'Rotation interne (abduction 0°)'
    };
    
    % Association Muscle -> Tâche Analytique
    assigned_analytics = [1, 2, 2, 2, 2, 2, 4, 2];
end