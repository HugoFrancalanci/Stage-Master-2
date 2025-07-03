function connected_regions = mergeCloseRegions(movement_regions, fs)
    % Fusionner les régions proches
    connected_regions = [];
    max_gap = round(0.3 * fs); % 300 ms maximum entre les régions à fusionner
    
    % Trier les régions par leurs indices de début
    starts = cellfun(@min, {movement_regions.PixelIdxList});
    ends = cellfun(@max, {movement_regions.PixelIdxList});
    [~, sort_idx] = sort(starts);
    movement_regions = movement_regions(sort_idx);
    starts = starts(sort_idx);
    ends = ends(sort_idx);
    
    % Fusionner les régions avec un écart faible
    current_start = starts(1);
    current_end = ends(1);
    
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
        % Ne pas trier par durée pour conserver l'ordre temporel
    % Les régions sont déjà dans l'ordre chronologique
    
    % Vérification de l'ordre des cycles
    fprintf('Vérification de l''ordre temporel des cycles :\n');
    for i = 1:size(connected_regions, 1)
        fprintf('Cycle %d: Début à %.2f s, Fin à %.2f s (Durée: %.2f s)\n', ...
            i, connected_regions(i,1)/fs, connected_regions(i,2)/fs, ...
            (connected_regions(i,2)-connected_regions(i,1))/fs);
    end
    
    % Vérification automatique que les cycles sont bien en ordre croissant
    is_ordered = all(diff(connected_regions(:,1)) > 0);
    if is_ordered
        fprintf('Confirmation: Les cycles sont dans l''ordre temporel croissant.\n');
    else
        fprintf('Attention: Les cycles ne sont PAS dans l''ordre temporel.\n');
    end
    
    % Visualisation graphique des cycles
    figure;
    hold on;
    for i = 1:size(connected_regions, 1)
        x_start = connected_regions(i,1)/fs;
        x_end = connected_regions(i,2)/fs;
        plot([x_start x_end], [i i], 'LineWidth', 3);
        text(x_start, i+0.1, sprintf('Cycle %d', i));
    end
    xlabel('Temps (s)');
    ylabel('Numéro du cycle');
    title('Visualisation des cycles dans l''ordre temporel');
    grid on;
end
