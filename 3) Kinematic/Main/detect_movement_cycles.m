function [cycles_frames, num_cycles] = detect_movement_cycles(markers, nFrames, config, subject)
    if isfield(markers, 'RHLE')
        % Calculer la position de référence (moyenne des 100 premières frames)
        RHLE_baseline = mean(markers.RHLE(1:min(100, nFrames), :));
        
        % Calculer la distance euclidienne entre position actuelle et position de référence
        RHLE_distance = sqrt(sum((markers.RHLE - repmat(RHLE_baseline, size(markers.RHLE, 1), 1)).^2, 2));
        
        % Normaliser la distance par rapport à la distance maximale (0-100%)
        RHLE_distance_max = max(RHLE_distance);
        RHLE_distance_normalized = (RHLE_distance / RHLE_distance_max) * 100;
        
        % Filtrage pour lisser la courbe de distance
        fc = 1; % Fréquence de coupure pour le filtre
        [b, a] = butter(2, fc / (config.fs/2), 'low');
        RHLE_distance_filtered = filtfilt(b, a, RHLE_distance_normalized);
        
        % Détection des cycles basée sur le franchissement d'un seuil
        [cycle_starts, cycle_ends, max_amplitude_cycles] = find_cycles(RHLE_distance_filtered, config.cycle_threshold_pct, config.min_cycle_duration);
        
        % Affichage de vérification visuelle des cycles
        plot_cycles_verification(RHLE_distance_filtered, cycle_starts, cycle_ends, max_amplitude_cycles, config, subject);
        
        % Validation des cycles selon leur amplitude
        [valid_cycles, num_cycles] = validate_cycles(max_amplitude_cycles, config.min_cycle_amplitude);
        
        % Mise à jour des listes de cycles avec uniquement les cycles valides
        if ~isempty(valid_cycles)
            cycle_starts = cycle_starts(valid_cycles);
            cycle_ends = cycle_ends(valid_cycles);
            num_cycles = length(valid_cycles);
            fprintf('Détection réussie: %d cycles valides identifiés pour le sujet %s.\n', num_cycles, subject);
        else
            fprintf('Attention: Aucun cycle valide détecté pour le sujet %s. Utilisation de toutes les données.\n', subject);
            cycle_starts = 1;
            cycle_ends = nFrames;
            num_cycles = 1;
        end
        
        % Limiter à 3 cycles maximum si plus ont été détectés
        if num_cycles > 3
            cycle_starts = cycle_starts(1:3);
            cycle_ends = cycle_ends(1:3);
            num_cycles = 3;
            fprintf('Plus de 3 cycles détectés, seuls les 3 premiers sont utilisés.\n');
        end
        
        % Stocker les indices de frames pour chaque cycle
        cycles_frames = cell(num_cycles, 1);
        for i = 1:num_cycles
            cycles_frames{i} = cycle_starts(i):cycle_ends(i);
        end
    else
        warning('Le marqueur RHLE n''est pas disponible pour le sujet %s.', subject);
        cycles_frames = {1:nFrames}; % Utiliser toutes les frames si RHLE n'est pas disponible
        num_cycles = 1;
    end
end
