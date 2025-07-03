function [global_mean, global_std] = calculate_global_statistics(all_subjects_data, movement, valid_subjects)
    global_mean = struct();
    global_std = struct();
    
    % Moyennes
    global_mean.GH = squeeze(mean(all_subjects_data(movement).GH(valid_subjects==1, :, :), 1));
    global_mean.ST = squeeze(mean(all_subjects_data(movement).ST(valid_subjects==1, :, :), 1));
    global_mean.HT = squeeze(mean(all_subjects_data(movement).HT(valid_subjects==1, :, :), 1));
    
    % Écarts types
    global_std.GH = squeeze(std(all_subjects_data(movement).GH(valid_subjects==1, :, :), 0, 1));
    global_std.ST = squeeze(std(all_subjects_data(movement).ST(valid_subjects==1, :, :), 0, 1));
    global_std.HT = squeeze(std(all_subjects_data(movement).HT(valid_subjects==1, :, :), 0, 1));
end