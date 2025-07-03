function cycle_metadata = createCycleMetadata(functional_labels, num_available_cycles_per_functional, num_points)

    % Création des métadonnées pour les cycles
    cycle_metadata = struct();
    cycle_count = 0;
    nb_functional = length(functional_labels);
    
    for functional_idx = 1:nb_functional
        for cycle = 1:num_available_cycles_per_functional(functional_idx)
            cycle_count = cycle_count + 1;
            field_name = sprintf('cycle_%d', cycle_count);
            cycle_metadata.(field_name) = struct(...
                'functional_idx', functional_idx, ...
                'functional_name', functional_labels{functional_idx}, ...
                'cycle_within_functional', cycle, ...
                'start_point', (cycle_count-1) * num_points + 1, ...
                'end_point', cycle_count * num_points);
        end
    end
end