function [cycle_info, num_available_cycles, RHLE_distance_resampled] = detectMovementCycles(c3dH_functional, analogs_functional, params)
    % Détection des cycles de mouvement basée sur le marqueur RHLE
    
    % Extraction des données des marqueurs
    points = btkGetPoints(c3dH_functional);
    markers = fieldnames(points);
    
    % Initialisation des variables de sortie
    cycle_info = [];
    RHLE_distance_resampled = [];
    
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
        
        % Interpoler les données du marqueur
        t_marker = (0:length(RHLE_distance_normalized)-1) / markers_fs;
        t_emg = (0:ratio*length(RHLE_distance_normalized)-1) / emg_fs;
        RHLE_distance_resampled = interp1(t_marker, RHLE_distance_normalized, t_emg, 'spline');
        
        % Ajuster la longueur pour correspondre aux données EMG
        max_length = min([length(RHLE_distance_resampled), length(analogs_functional.(params.muscles{1}))]);
        RHLE_distance_resampled = RHLE_distance_resampled(1:max_length);
        
        % Détection des mouvements
        [cycle_info, num_available_cycles] = identifyCycles(RHLE_distance_resampled, max_length, params);
    else
        % Si le marqueur RHLE n'est pas disponible, utiliser l'ensemble des données
        cycle_info(1, :) = [1, length(analogs_functional.(params.muscles{1}))];
        num_available_cycles = 1;
        warning('Marqueur RHLE non disponible. Utilisation de toutes les données.');
    end
end