function plot_synergy_comparison_improved(mean1, std1, mean2, std2, p_values, title_str, color1, color2, muscle_names, show_labels, subplot_index)
    x = 1:6;
    data_to_plot = [mean1, mean2];
    
    % Barres plus larges et plus lisibles
    b = bar(x, data_to_plot, 'BarWidth', 0.9);
    b(1).FaceColor = color1;
    b(2).FaceColor = color2;
    b(1).EdgeColor = 'none';
    b(2).EdgeColor = 'none';
    hold on

    % Barres d'erreur avec écart-type seulement
    x1 = b(1).XEndPoints;
    x2 = b(2).XEndPoints;
    errorbar(x1, mean1, std1, 'k', 'LineStyle', 'none', 'LineWidth', 1.5, 'CapSize', 4);
    errorbar(x2, mean2, std2, 'k', 'LineStyle', 'none', 'LineWidth', 1.5, 'CapSize', 4);

    % Signification statistique plus visible
    for i = 1:6
        if p_values(i) < 0.05
            y_pos = max([mean1(i)+std1(i), mean2(i)+std2(i)]) + 0.05;
                text(i, y_pos+0.05, '*', 'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold');
        end
    end

    title(title_str, 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Muscle weight', 'FontSize', 14);
    if subplot_index == 1 || subplot_index == 5 || subplot_index == 9
       ylabel('Muscle weight', 'FontSize', 16);
    else
       set(gca, 'YTickLabel', []);
       ylabel('');
    end
    xticks(1:6);

    if show_labels
        xticklabels(muscle_names);
        xtickangle(45);
    else
        xticklabels({});
    end

    ylim([0 1.2]);
    set(gca, 'FontSize', 14, 'TickDir', 'out', 'Box', 'off', 'LineWidth', 1);
    grid off;
    hold off;

    % Ajouter une légende uniquement pour les subplots 1, 5, 9
    if subplot_index == 1
       legend({'Asymptomatic', 'Symptomatic (pre)'}, 'Location', 'northoutside', 'Orientation', 'horizontal', 'FontSize', 11);
       elseif subplot_index == 5
       legend({'Asymptomatic', 'Symptomatic (post)'}, 'Location', 'northoutside', 'Orientation', 'horizontal', 'FontSize', 11);
       elseif subplot_index == 9
       legend({'Symptomatic (pre)', 'Symptomatic (post)'}, 'Location', 'northoutside', 'Orientation', 'horizontal', 'FontSize', 11);
    end

end