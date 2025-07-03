function [subjects, muscles, functional_labels, analytic_labels, assigned_analytics, data_path] = defineParameters(groupe_choix)
    % Définis les paramètres du sujet et des muscles
    
    % Définition sujet selon le groupe choisi
    if groupe_choix == 1
        subjects = {'A1'}; % 1-41
        data_path = 'C:\\Users\\Francalanci Hugo\\Documents\\MATLAB\\Stage Sainte-Justine\\HUG\\Sujets\\Asymptomatic';
    elseif groupe_choix == 2
         subjects = {'S1'}; % 1-41
         data_path = 'C:\\Users\\Francalanci Hugo\\Documents\\MATLAB\\Stage Sainte-Justine\\HUG\\Sujets\\Pre_operation';
    elseif groupe_choix == 3
         subjects = {'S1'}; % 1-41
         data_path = 'C:\\Users\\Francalanci Hugo\\Documents\\MATLAB\\Stage Sainte-Justine\\HUG\\Sujets\\Post_operation';
    end
    
    % Définition des muscles (choisir droite ou gauche)
    % Droite
    % muscles = {'RDELTA', 'RDELTM', 'RDELTP', 'RTRAPM', 'RTRAPS', 'RSERRA'};
    % Gauche
    muscles = {'LDELTA', 'LDELTM', 'LDELTP', 'LTRAPM', 'LTRAPS', 'LSERRA'};
    
    % Définition des labels pour les tâches
    functional_labels = {...
        'Porter les mains à la bouche', ...
        'Toucher le haut de la tête', ...
        'Porter les mains le plus haut possible au-dessus de la tête',...
        'Porter les mains le plus haut possible le long de la colonne vertébrale'};
    
    analytic_labels = {
        'Flexion (élévation sagittale)', ...
        'Abduction (élévation coronale)', ...
        'Rotation externe (abduction 0°)', ...
        'Rotation interne (abduction 0°)'};
    
    % Association Muscle -> Tâche analytique définie manuellement
    assigned_analytics = [1, 2, 2, 2, 2, 2];
end