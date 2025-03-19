function [cycle_info, num_cycles_detected, RHLE_distance_resampled] = detectMovementCycles(c3dH_functional, analogs_functional, muscles, position_threshold_percent, min_duration, num_cycles, fs)
   % Détection des cycles de mouvement

    % Extraction des données du marqueur RHLE
    points = btkGetPoints(c3dH_functional);
    markers = fieldnames(points);
    
    % Initialisation par défaut
    cycle_info = [];
    RHLE_distance_resampled = [];
    num_cycles_detected = 0;
    
    % Vérifier si le marqueur RHLE existe
    if ismember('RHLE', markers)
        % Extraction des coordonnées 3D du marqueur RHLE
        RHLE_pos = points.RHLE;
        
        % Calculer la position de référence (position de départ)
        RHLE_baseline = mean(RHLE_pos(1:100, :));
        
        % Calculer la distance euclidienne entre la position actuelle et la position de référence
        RHLE_distance = sqrt(sum((RHLE_pos - repmat(RHLE_baseline, size(RHLE_pos, 1), 1)).^2, 2));
        
        % Normaliser la distance par la distance maximale
        RHLE_distance_max = max(RHLE_distance);
        RHLE_distance_normalized = (RHLE_distance / RHLE_distance_max) * 100;
        
        % Adapter la fréquence d'échantillonnage du marqueur à celle de l'EMG
        markers_fs = btkGetPointFrequency(c3dH_functional);
        emg_fs = btkGetAnalogFrequency(c3dH_functional);
        ratio = emg_fs / markers_fs;
        
        % Interpoler les données du marqueur pour correspondre à la fréquence EMG
        t_marker = (0:length(RHLE_distance_normalized)-1) / markers_fs;
        t_emg = (0:ratio*length(RHLE_distance_normalized)-1) / emg_fs;
        RHLE_distance_resampled = interp1(t_marker, RHLE_distance_normalized, t_emg, 'spline');
        
        % Ajuster la longueur pour correspondre aux données EMG
        max_length = min([length(RHLE_distance_resampled), length(analogs_functional.(muscles{1}))]);
        RHLE_distance_resampled = RHLE_distance_resampled(1:max_length);
        
        % Détection du début et de la fin du mouvement basée sur la position de RHLE
        movement_mask = RHLE_distance_resampled > position_threshold_percent;
        
        % Appliquer une durée minimale (filtrage des activations courtes)
        min_samples = round(min_duration * fs);
        movement_mask = bwareaopen(movement_mask, min_samples);
        
        % Trouver les indices de début et fin
        movement_regions = regionprops(movement_mask, 'PixelIdxList');
        
        if ~isempty(movement_regions)
            % Fusionner les régions proches
            connected_regions = mergeCloseRegions(movement_regions, fs);
            
            % Sélectionner les cycles disponibles
            num_cycles_detected = min(num_cycles, size(connected_regions, 1));
            
            for cycle = 1:num_cycles_detected
                movement_start = connected_regions(cycle, 1);
                movement_end = connected_regions(cycle, 2);
                
                % Ajouter une marge avant et après (10% de la durée du mouvement)
                margin = round((movement_end - movement_start) * 0.1);
                movement_start = max(1, movement_start - margin);
                movement_end = min(max_length, movement_end + margin);
                
                cycle_info(cycle, :) = [movement_start, movement_end];
            end
        else
            % Si aucun mouvement détecté, utiliser l'ensemble des données comme un seul cycle
            cycle_info(1, :) = [1, max_length];
            num_cycles_detected = 1;
            warning('Aucun mouvement détecté. Utilisation de toutes les données comme un seul cycle.');
        end
    else
        % Si le marqueur RHLE n'est pas disponible, utiliser l'ensemble des données
        cycle_info(1, :) = [1, length(analogs_functional.(muscles{1}))];
        num_cycles_detected = 1;
        warning('Marqueur RHLE non disponible. Utilisation de toutes les données.');
    end
end