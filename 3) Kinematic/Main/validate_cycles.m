function [valid_cycles, num_valid] = validate_cycles(max_amplitudes, min_amplitude)
    valid_cycles = [];
    
    for i = 1:length(max_amplitudes)
        if max_amplitudes(i) >= min_amplitude
            valid_cycles = [valid_cycles, i];
        else
            fprintf('Cycle %d rejeté: amplitude maximale %.1f%% < %d%%\n', i, max_amplitudes(i), min_amplitude);
        end
    end
    
    num_valid = length(valid_cycles);
end