function [cycle_starts, cycle_ends, max_amplitude_cycles] = find_cycles(signal, threshold, min_duration)
    % Initialisation des variables pour détecter les cycles
    cycle_starts = [];
    cycle_ends = [];
    max_amplitude_cycles = [];
    in_cycle = false;
    last_start = 0;
    
    for i = 2:length(signal)
        % Détection du début d'un cycle (franchissement du seuil à la montée)
        if ~in_cycle && signal(i) > threshold && signal(i-1) <= threshold
            in_cycle = true;
            last_start = i;
        % Détection de la fin d'un cycle (retour sous le seuil après une durée minimale)
        elseif in_cycle && signal(i) < threshold && signal(i-1) >= threshold && (i - last_start) > min_duration
            in_cycle = false;
            cycle_starts = [cycle_starts, last_start];
            cycle_ends = [cycle_ends, i];
            
            % Calcul de l'amplitude maximale du cycle
            cycle_data = signal(last_start:i);
            max_amplitude = max(cycle_data);
            max_amplitude_cycles = [max_amplitude_cycles, max_amplitude];
        end
    end
end