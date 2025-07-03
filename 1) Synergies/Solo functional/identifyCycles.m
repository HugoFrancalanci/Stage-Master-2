function [cycle_info, num_available_cycles] = identifyCycles(RHLE_distance_resampled, max_length, params)
    % Identification des cycles de mouvement à partir des données du marqueur RHLE
    
    % Définir le seuil de détection
    position_threshold = params.position_threshold_percent;
    
    % Détection du début et de la fin du mouvement
    movement_mask = RHLE_distance_resampled > position_threshold;
    
    % Appliquer une durée minimale (filtrage des activations courtes)
    min_samples = round(params.min_duration * params.fs);
    movement_mask = bwareaopen(movement_mask, min_samples);
    
    % Trouver les indices de début et fin
    movement_regions = regionprops(movement_mask, 'PixelIdxList');
    
    cycle_info = [];
    
    if ~isempty(movement_regions)
        % Fusionner les régions proches
        connected_regions = mergeCycles(movement_regions, params.fs);
        
        % Sélectionner les cycles les plus significatifs
        num_available_cycles = min(params.num_cycles, size(connected_regions, 1));
        
        for cycle = 1:num_available_cycles
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
        num_available_cycles = 1;
    end
end