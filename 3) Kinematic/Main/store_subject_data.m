function data_structure = store_subject_data(data_structure, side, movement, subject_idx, Angles_GH, Angles_ST, Angles_HT)
    data_structure.(side)(movement).Angles_GH{subject_idx} = Angles_GH;
    data_structure.(side)(movement).Angles_ST{subject_idx} = Angles_ST;
    data_structure.(side)(movement).Angles_HT{subject_idx} = Angles_HT;
end
