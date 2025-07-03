function plot_activation_comparison_improved(x_new, mean1_s1, std1_s1, mean1_s2, std1_s2, ...
                                           mean2_s1, std2_s1, mean2_s2, std2_s2, title_str, color1, color2)
    hold on
    
    % CORRECTION: S'assurer des dimensions correctes et cohérentes
    x_new = x_new(:);  % Vecteur colonne
    
    % S'assurer que toutes les moyennes et écarts-types sont des vecteurs colonnes
    mean1_s1 = mean1_s1(:);
    std1_s1 = std1_s1(:);
    mean1_s2 = mean1_s2(:);
    std1_s2 = std1_s2(:);
    mean2_s1 = mean2_s1(:);
    std2_s1 = std2_s1(:);
    mean2_s2 = mean2_s2(:);
    std2_s2 = std2_s2(:);
    
    % Vérifier que toutes les variables ont la même longueur
    if length(x_new) ~= length(mean1_s1) || length(x_new) ~= length(mean2_s1)
        error('Dimension mismatch: x_new and mean vectors must have the same length');
    end
    
    % Zones d'écart-type pour les synergies 1
    x_fill = [x_new; flipud(x_new)];
    y1_fill = [mean1_s1 + std1_s1; flipud(mean1_s1 - std1_s1)];
    y2_fill = [mean2_s1 + std2_s1; flipud(mean2_s1 - std2_s1)];
    
    fill(x_fill, y1_fill, color1, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
    fill(x_fill, y2_fill, color2, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
    
    % Zones d'écart-type pour les synergies 2 (couleurs plus claires)
    y1_fill_s2 = [mean1_s2 + std1_s2; flipud(mean1_s2 - std1_s2)];
    y2_fill_s2 = [mean2_s2 + std2_s2; flipud(mean2_s2 - std2_s2)];
    
    fill(x_fill, y1_fill_s2, color1, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    fill(x_fill, y2_fill_s2, color2, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    
    % Courbes moyennes - Synergies 1 (traits pleins épais)
    h1_s1 = plot(x_new, mean1_s1, 'Color', color1, 'LineWidth', 3, 'LineStyle', '-');
    h2_s1 = plot(x_new, mean2_s1, 'Color', color2, 'LineWidth', 3, 'LineStyle', '-');
    
    % Courbes moyennes - Synergies 2 (traits pointillés)
    h1_s2 = plot(x_new, mean1_s2, 'Color', color1, 'LineWidth', 2.5, 'LineStyle', '--');
    h2_s2 = plot(x_new, mean2_s2, 'Color', color2, 'LineWidth', 2.5, 'LineStyle', '--');
    
        % Déterminer quelles lignes verticales ajouter selon le titre
    if contains(title_str, 'Asymp vs Pre')
        % Asymptomatique (58.5%) et Pré-op (54.5%)
        line([58.5, 58.5], [0, 100], 'Color', color1, 'LineStyle', ':', 'LineWidth', 2);
        line([54.5, 54.5], [0, 100], 'Color', color2, 'LineStyle', ':', 'LineWidth', 2);
    elseif contains(title_str, 'Asymp vs Post')
        % Asymptomatique (58.5%) et Post-op (49.5%)
        line([58.5, 58.5], [0, 100], 'Color', color1, 'LineStyle', ':', 'LineWidth', 2);
        line([49.5, 49.5], [0, 100], 'Color', color2, 'LineStyle', ':', 'LineWidth', 2);
    elseif contains(title_str, 'Pre vs Post')
        % Pré-op (54.5%) et Post-op (49.5%)
        line([54.5, 54.5], [0, 100], 'Color', color1, 'LineStyle', ':', 'LineWidth', 2);
        line([49.5, 49.5], [0, 100], 'Color', color2, 'LineStyle', ':', 'LineWidth', 2);
    end

    xlabel('Cycle (%)', 'FontSize', 16);
    ylabel('Activation level (%)', 'FontSize', 14);
    title(title_str, 'FontSize', 16, 'FontWeight', 'bold');
    
    xlim([min(x_new), max(x_new)]);
    ylim([0 100]);
    set(gca, 'FontSize', 14, 'TickDir', 'out', 'Box', 'off', 'LineWidth', 1);
    grid off;
    
    % Légende améliorée
    legend([h1_s1, h1_s2], ...
           {'Synergy 1', 'Synergy 2'}, ...
           'Location', 'best', 'FontSize', 11);
    
    hold off;
end