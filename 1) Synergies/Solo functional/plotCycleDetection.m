function plotCycleDetection(RHLE_distance_resampled, cycle_info, num_available_cycles, params)
    % Visualisation de la détection des cycles de mouvement
    
    % Figure 1: Détection des cycles
    figure;
    plot(RHLE_distance_resampled, 'b');
    hold on;
    colors = {'r', 'g', 'm'};
    
    for cycle = 1:num_available_cycles
        movement_start = cycle_info(cycle, 1);
        movement_end = cycle_info(cycle, 2);
        color_idx = mod(cycle-1, length(colors)) + 1;
        
        % Tracer des lignes verticales pour chaque cycle
        plot([movement_start movement_start], [0 max(RHLE_distance_resampled)], ...
            [colors{color_idx} '--'], 'LineWidth', 2);
        plot([movement_end movement_end], [0 max(RHLE_distance_resampled)], ...
            [colors{color_idx} '--'], 'LineWidth', 2);
        
        % Ajouter une étiquette
        text(movement_start, max(RHLE_distance_resampled)*0.9, ...
            sprintf('Cycle %d', cycle), 'Color', colors{color_idx}, 'FontWeight', 'bold');
    end
    
    plot([1 length(RHLE_distance_resampled)], [params.position_threshold_percent params.position_threshold_percent], 'k--');
    title(sprintf('Détection des %d cycles basée sur RHLE', num_available_cycles));
    xlabel('Échantillons');
    ylabel('Distance RHLE (% déplacement max)');
    legend('Position RHLE', sprintf('Seuil %d%%', params.position_threshold_percent));
    
    % Figure 2: Coloration des zones actives
    figure;
    plot(RHLE_distance_resampled, 'b');
    hold on;
    
    % Mettre en évidence les zones actives avec différentes couleurs
    y_max = max(RHLE_distance_resampled) * 1.1;
    color_alphas = {[1 0.8 0.8], [0.8 1 0.8], [0.8 0.8 1]};
    
    for cycle = 1:num_available_cycles
        movement_start = cycle_info(cycle, 1);
        movement_end = cycle_info(cycle, 2);
        color_idx = mod(cycle-1, length(color_alphas)) + 1;
        
        % Coloration des zones actives
        movement_mask_viz = zeros(size(RHLE_distance_resampled));
        movement_mask_viz(movement_start:movement_end) = 1;
        area_x = 1:length(RHLE_distance_resampled);
        area_y = y_max * movement_mask_viz;
        area(area_x, area_y, 'FaceColor', color_alphas{color_idx}, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    end
    
    plot([1 length(RHLE_distance_resampled)], [params.position_threshold_percent params.position_threshold_percent], 'k--');
    title(sprintf('Position complète de RHLE avec %d cycles détectés', num_available_cycles));
    xlabel('Échantillons');
    ylabel('Distance RHLE (% déplacement max)');
    legend('Position RHLE', sprintf('Seuil %d%%', params.position_threshold_percent));
end