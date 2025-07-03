function plotMuscleRatios(plot_data, muscle_pairs, display_right, display_left, display_combined, functional_labels, selected_functional)
    
    % Vérifier qu'il y a des données à tracer
    if isempty(fieldnames(plot_data))
        warning('Aucune donnée disponible pour créer le graphique');
        return;
    end

    figure('Name', sprintf('Ratios Musculaires - %s', functional_labels{selected_functional}), ...
           'Position', [100, 100, 1000, 600]);

    % Initialisation
    pairs_to_plot = {};
    means = [];
    stds = [];
    ci_lowers = [];
    ci_uppers = [];
    bar_colors = [];

    % Boucle sur les paires de muscles
    for p = 1:size(muscle_pairs, 1)
        pair_code = muscle_pairs{p, 2};
        valid_pair_code = strrep(pair_code, '/', '_');

        % Côté droit
        if display_right
            field_name_R = sprintf('%s_R', valid_pair_code);
            if isfield(plot_data, field_name_R)
                pairs_to_plot{end+1} = sprintf('%s (D)', pair_code);
                means(end+1) = plot_data.(field_name_R).mean;
                stds(end+1) = plot_data.(field_name_R).std;
                ci_lowers(end+1) = plot_data.(field_name_R).ci_lower;
                ci_uppers(end+1) = plot_data.(field_name_R).ci_upper;
                bar_colors(end+1, :) = [0.3, 0.3, 0.8]; % Bleu
            end
        end

        % Côté gauche
        if display_left
            field_name_L = sprintf('%s_L', valid_pair_code);
            if isfield(plot_data, field_name_L)
                pairs_to_plot{end+1} = sprintf('%s (G)', pair_code);
                means(end+1) = plot_data.(field_name_L).mean;
                stds(end+1) = plot_data.(field_name_L).std;
                ci_lowers(end+1) = plot_data.(field_name_L).ci_lower;
                ci_uppers(end+1) = plot_data.(field_name_L).ci_upper;
                bar_colors(end+1, :) = [0.8, 0.3, 0.3]; % Rouge
            end
        end
        
        % Côté combiné (nouveau)
        if display_combined
            field_name_C = sprintf('%s_C', valid_pair_code);
            if isfield(plot_data, field_name_C)
                pairs_to_plot{end+1} = sprintf('%s', pair_code);
                means(end+1) = plot_data.(field_name_C).mean;
                stds(end+1) = plot_data.(field_name_C).std;
                ci_lowers(end+1) = plot_data.(field_name_C).ci_lower;
                ci_uppers(end+1) = plot_data.(field_name_C).ci_upper;
                bar_colors(end+1, :) = 	[0.2 0.2 0.2];
            end
        end
    end

    if isempty(pairs_to_plot)
        warning('Aucune paire de muscles valide à afficher');
        close(gcf);
        return;
    end

    % Création du barplot
    b = bar(means, 'FaceColor', 'flat');
    for i = 1:length(means)
        b.CData(i,:) = bar_colors(i,:);
    end

    hold on;
    errorbar(1:length(means), means, stds, 'k.', 'LineWidth', 1.5);

    for i = 1:length(means)
        plot([i, i], [ci_lowers(i), ci_uppers(i)], 'k-', 'LineWidth', 2);
        plot(i, ci_lowers(i), 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
        plot(i, ci_uppers(i), 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
    end

    title(sprintf('Ratio musculaire moyen - %s', functional_labels{selected_functional}), 'FontSize', 14);
    xlabel('Muscle pairs', 'FontSize', 12);
    ylabel('Ratio', 'FontSize', 12);
    set(gca, 'XTick', 1:length(pairs_to_plot), 'XTickLabel', pairs_to_plot);
    set(gcf, 'Color', 'w');
    xtickangle(45);
    grid on;
    
    % Créer une légende plus détaillée
    legend_entries = {'MEAN', 'SD', 'IC 95%'};
    
    % Ajouter une légende pour les couleurs si nécessaire
    if (display_right + display_left + display_combined) > 1
        if display_right
            legend_entries{end+1} = 'Côté droit (D)';
        end
        if display_left
            legend_entries{end+1} = 'Côté gauche (G)';
        end
        if display_combined
            legend_entries{end+1} = 'Combiné (C)';
        end
    end
    
    legend(legend_entries, 'Location', 'best');
    box on;
    hold off;
end