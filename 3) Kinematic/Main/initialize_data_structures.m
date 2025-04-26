function data_structure = initialize_data_structures(config)
    data_structure = struct();

    for s = {'R', 'L'}
        side = s{1};
        for mov_idx = 1:length(config.movements_to_process)
            current_movement = config.movements_to_process(mov_idx);

            data_structure.(side)(current_movement).Angles_GH = cell(length(config.Subjects), 1);
            data_structure.(side)(current_movement).Angles_ST = cell(length(config.Subjects), 1);
            data_structure.(side)(current_movement).Angles_HT = cell(length(config.Subjects), 1);

            data_structure.(side)(current_movement).mean_cycles_GH = cell(length(config.Subjects), 1);
            data_structure.(side)(current_movement).mean_cycles_ST = cell(length(config.Subjects), 1);
            data_structure.(side)(current_movement).mean_cycles_HT = cell(length(config.Subjects), 1);
        end
    end
end
