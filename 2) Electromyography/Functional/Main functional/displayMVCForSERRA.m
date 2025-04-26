function displayMVCForSERRA(emg_all_subjects_R, emg_all_subjects_L, muscles_R, muscles_L, subjects)
    % Affiche la valeur maximale d'activation EMG normalisée (% MVC) pour les muscles SERRA
    % et met en évidence ceux qui dépassent 15% MVC
    
    % Affichage pour chaque côté
    displaySide(emg_all_subjects_R, muscles_R, subjects, 'droits');
    displaySide(emg_all_subjects_L, muscles_L, subjects, 'gauches');
    
    % Légende
    fprintf('\nLégende : *valeur* indique une activation maximale > 15%% du MVC\n');
end

function displaySide(emg_data, muscles, subjects, side_name)
    % Sous-fonction pour afficher les données d'un côté spécifique
    
    % Vérification que les données existent
    if isempty(emg_data) || isempty(muscles)
        fprintf('Pas de données disponibles pour les muscles %s\n', side_name);
        return;
    end
    
    % Identifier les muscles SERRA
    serra_indices = find(contains(upper(muscles), 'SERRA'));
    
    if isempty(serra_indices)
        fprintf('Aucun muscle SERRA trouvé pour le côté %s\n', side_name);
        return;
    end
    
    fprintf('\nActivation maximale (% MVC) - muscles SERRA %s :\n', side_name);
    
    % Définir la largeur des colonnes pour un affichage propre
    col_width = 15;
    
    % En-tête avec les noms des sujets
    fprintf(['%-' num2str(col_width) 's'], 'Muscle');
    for s = 1:length(subjects)
        fprintf(['%-' num2str(col_width) 's'], subjects{s});
    end
    fprintf('\n');
    fprintf(repmat('-', 1, col_width * (length(subjects) + 1)));
    fprintf('\n');
    
    % Parcourir uniquement les muscles SERRA
    for idx = 1:length(serra_indices)
        m = serra_indices(idx);
        muscle_name = muscles{m};
        
        fprintf(['%-' num2str(col_width) 's'], muscle_name);
        
        % Pour chaque sujet
        for s = 1:length(subjects)
            if s <= size(emg_data, 1) && m <= size(emg_data, 3)
                % Extraire les données EMG normalisées
                signal = squeeze(emg_data(s, :, m));
                
                % Vérifier si les données sont valides
                if any(~isnan(signal)) && any(~isinf(signal))
                    valid_signal = signal(~isnan(signal) & ~isinf(signal));
                    if ~isempty(valid_signal)
                        % Prendre le 95ème percentile plutôt que le maximum absolu
                        % pour éviter les valeurs aberrantes
                        max_val = prctile(valid_signal, 95);
                        
                        % Formatter l'affichage selon le seuil de 15%
                        if max_val > 15
                            str_val = sprintf('*%.2f*', max_val);
                        else
                            str_val = sprintf('%.2f', max_val);
                        end
                    else
                        str_val = 'No valid data';
                    end
                else
                    str_val = 'NaN';
                end
            else
                str_val = 'Out of bounds';
            end
            
            fprintf(['%-' num2str(col_width) 's'], str_val);
        end
        fprintf('\n');
    end
end