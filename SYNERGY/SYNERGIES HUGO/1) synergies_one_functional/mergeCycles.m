function connected_regions = mergeCycles(movement_regions, fs)
    % Fusion des régions de mouvement proches
    
    % Trier les régions par leurs indices de début
    starts = cellfun(@min, {movement_regions.PixelIdxList});
    ends = cellfun(@max, {movement_regions.PixelIdxList});
    [~, sort_idx] = sort(starts);
    movement_regions = movement_regions(sort_idx);
    starts = starts(sort_idx);
    ends = ends(sort_idx);
    
    % Fusionner les régions avec un écart faible
    max_gap = round(0.3 * fs); % 300 ms maximum entre les régions à fusionner
    current_start = starts(1);
    current_end = ends(1);
    connected_regions = [];
    
    for i = 2:length(movement_regions)
        if starts(i) - current_end <= max_gap
            % Fusionner avec la région actuelle
            current_end = ends(i);
        else
            % Sauvegarder la région actuelle et commencer une nouvelle
            connected_regions = [connected_regions; current_start, current_end];
            current_start = starts(i);
            current_end = ends(i);
        end
    end
    
    % Ajouter la dernière région
    connected_regions = [connected_regions; current_start, current_end];
    
    % Trier les régions fusionnées par durée
    region_durations = connected_regions(:,2) - connected_regions(:,1);
    [~, sort_idx] = sort(region_durations, 'descend');
    connected_regions = connected_regions(sort_idx, :);
end