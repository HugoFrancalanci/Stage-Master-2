function [combined_mean_cycles, combined_std_cycles, combined_CI_cycles] = compute_subject_combined_statistics(subject_movement_data, config)
    % Cette fonction calcule les statistiques combinées pour un sujet spécifique
    % en utilisant ses données de mouvement déjà collectées
    
    % Initialisation des structures pour stocker les moyennes combinées
    combined_mean_cycles = struct();
    combined_std_cycles = struct();
    combined_CI_cycles = struct();

    joints = {'GH', 'ST', 'HT'};
    num_samples = config.num_samples_per_cycle;

    % Initialisation des matrices pour chaque articulation et composante
    for j = 1:length(joints)
        joint = joints{j};
        combined_mean_cycles.(joint) = zeros(num_samples, 3);
        combined_std_cycles.(joint) = zeros(num_samples, 3);
        combined_CI_cycles.([joint '_lower']) = zeros(num_samples, 3);
        combined_CI_cycles.([joint '_upper']) = zeros(num_samples, 3);
    end

    for j = 1:length(joints)
        joint = joints{j};
        
        % Vérifier si des données existent pour cette articulation
        if isempty(subject_movement_data.(joint))
            continue;
        end
        
        % Nombre de mouvements pour ce sujet
        num_movements = size(subject_movement_data.(joint), 3);
        
        if num_movements > 0
            % Pour chaque composante X, Y, Z
            for c = 1:3
                % Extraire les données pour cette composante sur tous les mouvements
                all_movements_data = squeeze(subject_movement_data.(joint)(:, c, :));
                
                % Si un seul mouvement, reshaper pour avoir la bonne dimension
                if num_movements == 1
                    all_movements_data = all_movements_data(:);
                end
                
                % Calculer la moyenne sur tous les mouvements
                combined_mean_cycles.(joint)(:, c) = mean(all_movements_data, 2);
                
                % Calculer l'écart-type s'il y a plus d'un mouvement
                if num_movements > 1
                    combined_std_cycles.(joint)(:, c) = std(all_movements_data, 0, 2);
                    
                    % Calculer l'intervalle de confiance
                    t_critical = tinv(0.975, num_movements - 1);
                    sem = combined_std_cycles.(joint)(:, c) / sqrt(num_movements);
                    
                    combined_CI_cycles.([joint '_lower'])(:, c) = combined_mean_cycles.(joint)(:, c) - t_critical * sem;
                    combined_CI_cycles.([joint '_upper'])(:, c) = combined_mean_cycles.(joint)(:, c) + t_critical * sem;
                else
                    % Si un seul mouvement, pas d'écart-type ni d'IC
                    combined_std_cycles.(joint)(:, c) = zeros(num_samples, 1);
                    combined_CI_cycles.([joint '_lower'])(:, c) = combined_mean_cycles.(joint)(:, c);
                    combined_CI_cycles.([joint '_upper'])(:, c) = combined_mean_cycles.(joint)(:, c);
                end
            end
        end
    end
end