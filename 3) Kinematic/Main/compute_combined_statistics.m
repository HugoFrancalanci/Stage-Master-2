function [combined_mean_cycles, combined_std_cycles, combined_CI_cycles] = compute_combined_statistics(all_movements_data, all_subjects_mean_cycles, config)
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

    for c = 1:3 % Pour chaque composante X, Y, Z
        all_mov = struct('GH', [], 'ST', [], 'HT', []);

        % Collecte des données valides pour chaque mouvement
        for mov_idx = 1:length(config.movements_to_process)
            current_movement = config.movements_to_process(mov_idx);
            valid_subjects = ~cellfun(@isempty, all_movements_data(current_movement).Angles_GH);

            if sum(valid_subjects) > 0
                all_mov.GH = [all_mov.GH; squeeze(all_subjects_mean_cycles(current_movement).GH(valid_subjects, :, c))];
                all_mov.ST = [all_mov.ST; squeeze(all_subjects_mean_cycles(current_movement).ST(valid_subjects, :, c))];
                all_mov.HT = [all_mov.HT; squeeze(all_subjects_mean_cycles(current_movement).HT(valid_subjects, :, c))];
            end
        end

        % Calcul pour chaque articulation
        for j = 1:length(joints)
            joint = joints{j};
            if ~isempty(all_mov.(joint))
                combined_mean_cycles.(joint)(:, c) = mean(all_mov.(joint), 1)';
                combined_std_cycles.(joint)(:, c) = std(all_mov.(joint), 0, 1)';

                n = size(all_mov.(joint), 1);
                t_critical = tinv(0.975, n - 1);
                sem = combined_std_cycles.(joint)(:, c) / sqrt(n);

                combined_CI_cycles.([joint '_lower'])(:, c) = combined_mean_cycles.(joint)(:, c) - t_critical * sem;
                combined_CI_cycles.([joint '_upper'])(:, c) = combined_mean_cycles.(joint)(:, c) + t_critical * sem;
            end
        end
    end
end
