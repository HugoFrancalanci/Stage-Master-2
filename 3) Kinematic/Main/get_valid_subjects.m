function valid_subjects = get_valid_subjects(all_movements_data, movement, subjects)
    valid_subjects = zeros(length(subjects), 1);
    for subj_idx = 1:length(subjects)
        if ~isempty(all_movements_data(movement).Angles_GH{subj_idx})
            valid_subjects(subj_idx) = 1;
        end
    end
end