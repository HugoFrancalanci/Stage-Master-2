function saveDataMatrix(subject, selected_functional, all_functional_data, params)
    % Création et sauvegarde de la matrice de données
    
    subject_idx = 1;
    functional_idx = selected_functional;
    
    % Déterminer le nombre de cycles disponibles
    num_available_cycles = 0;
    for cycle = 1:params.num_cycles
        if ~isempty(all_functional_data{subject_idx, functional_idx, 1, cycle})
            num_available_cycles = num_available_cycles + 1;
        end
    end
    
    % Création d'une grande matrice pour sauvegarder les données
    all_data_matrix = zeros(params.nb_muscles, params.num_points * num_available_cycles);
    
    % Remplissage de la matrice
    for m = 1:params.nb_muscles
        col_start = 1;
        
        for cycle = 1:num_available_cycles
            cycle_data = all_functional_data{subject_idx, functional_idx, m, cycle};
            
            if ~isempty(cycle_data)
                % Calculer l'indice de fin pour ce cycle
                col_end = col_start + length(cycle_data) - 1;
                
                % S'assurer que nous ne dépassons pas les limites de la matrice
                if col_end <= size(all_data_matrix, 2)
                    all_data_matrix(m, col_start:col_end) = cycle_data;
                else
                    % Ajuster la taille si nécessaire
                    all_data_matrix(m, col_start:size(all_data_matrix, 2)) = cycle_data(1:(size(all_data_matrix, 2)-col_start+1));
                end
                
                % Mettre à jour l'indice de début pour le prochain cycle
                col_start = col_end + 1;
            end
        end
    end
    
    % Affichage de la taille de la matrice pour vérification
    fprintf('Matrice de données créée avec %d muscles et %d points temporels\n', ...
        size(all_data_matrix, 1), size(all_data_matrix, 2));
    
    % Sauvegarde de la matrice dans un fichier .mat
    save_filename = sprintf('%s_functional%d_data.mat', subject, functional_idx);
    muscles = params.muscles;
    functional_labels = params.functional_labels;
    save(save_filename, 'all_data_matrix', 'muscles', 'functional_labels', 'selected_functional', 'subject');
    
    fprintf('Données sauvegardées dans le fichier: %s\n', save_filename);
    
    % Création d'une table pour une meilleure visualisation des données
    muscle_names = cell(params.nb_muscles, 1);
    for m = 1:params.nb_muscles
        muscle_names{m} = params.muscles{m};
    end
    
    all_data_table = array2table(all_data_matrix', 'VariableNames', muscle_names);
    
    % Affichage des premières lignes de la table
    disp(all_data_table(1:min(10, size(all_data_table, 1)), :));
end