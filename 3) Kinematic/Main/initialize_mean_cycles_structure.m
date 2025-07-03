function mean_cycles = initialize_mean_cycles_structure(config)
    mean_cycles = struct();
    for mov_idx = 1:length(config.movements_to_process)
        current_movement = config.movements_to_process(mov_idx);
        mean_cycles(current_movement).GH = zeros(length(config.Subjects), config.num_samples_per_cycle, 3);
        mean_cycles(current_movement).ST = zeros(length(config.Subjects), config.num_samples_per_cycle, 3);
        mean_cycles(current_movement).HT = zeros(length(config.Subjects), config.num_samples_per_cycle, 3);
    end
end