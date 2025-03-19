function saveAllData(subjects, muscles, functional_labels, all_functional_data, num_available_cycles_per_functional, num_points)
    % Sauvegarde de toutes les données
    nb_muscles = length(muscles);
    nb_functional = length(functional_labels);
    subject_idx = 1;
    
    % Calculer le nombre total de cycles détectés
    total_cycles = sum(num_available_cycles_per_functional);
    
    % Création d'une grande matrice pour sauvegarder les données
    all_data_matrix = zeros(nb_muscles, num_points * total_cycles);
    
    % Remplissage de la matrice
    for m = 1:nb_muscles
        col_start = 1;
        
        for functional_idx = 1:nb_functional
            for cycle = 1:num_available_cycles_per_functional(functional_idx)
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
    end
    
    % Créer un fichier JSON pour stocker les métadonnées des cycles
    cycle_metadata = createCycleMetadata(functional_labels, num_available_cycles_per_functional, num_points);
    
    % Affichage de la taille de la matrice pour vérification
    fprintf('Matrice de données créée avec %d muscles et %d points temporels\n', ...
        size(all_data_matrix, 1), size(all_data_matrix, 2));
    
    % Sauvegarde de la matrice et des métadonnées dans un fichier .mat
    %save_filename = sprintf('%s_all_functionals_data.mat', subjects{1});
    %save(save_filename, 'all_data_matrix', 'muscles', 'functional_labels', 'cycle_metadata', 'subjects', 'num_available_cycles_per_functional');
    
    %fprintf('Données sauvegardées dans le fichier: %s\n', save_filename);
    
    % Création d'un récapitulatif des cycles détectés
    printCycleSummary(functional_labels, num_available_cycles_per_functional, total_cycles);
end
