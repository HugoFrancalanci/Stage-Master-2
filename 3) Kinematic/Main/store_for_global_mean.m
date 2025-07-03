function mean_cycles = store_for_global_mean(mean_cycles, side, movement, subject_idx, mean_cycles_GH, mean_cycles_ST, mean_cycles_HT)
    mean_cycles.(side)(movement).GH(subject_idx, :, :) = mean_cycles_GH;
    mean_cycles.(side)(movement).ST(subject_idx, :, :) = mean_cycles_ST;
    mean_cycles.(side)(movement).HT(subject_idx, :, :) = mean_cycles_HT;
end