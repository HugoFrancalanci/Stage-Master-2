function data_structure = store_mean_cycles(data_structure, side, movement, subject_idx, mean_cycles_GH, mean_cycles_ST, mean_cycles_HT)
    data_structure.(side)(movement).mean_cycles_GH{subject_idx} = mean_cycles_GH;
    data_structure.(side)(movement).mean_cycles_ST{subject_idx} = mean_cycles_ST;
    data_structure.(side)(movement).mean_cycles_HT{subject_idx} = mean_cycles_HT;
end