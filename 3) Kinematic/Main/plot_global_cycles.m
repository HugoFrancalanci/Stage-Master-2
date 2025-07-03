function plot_global_cycles(global_mean_cycles, global_std_cycles, current_movement, config)
    % Temps normalisé pour les figures
    cycle_time_norm = linspace(0, 100, size(global_mean_cycles.GH, 1));

    % Inversion conditionnelle du mouvement fonctionnel 4 pour les titres
    title_suffix = '';
    if current_movement == 4 && config.invert_functional4_left && config.invert_functional4_right
        title_suffix = ' (Inversé)';
    end

    % Figure 1 : Cycles moyens GH globaux avec écarts types
    figure;
    sgtitle(sprintf('Cycle moyen global - Gléno-Huméral - Mouvement %d%s', current_movement, title_suffix));

    subplot(3,1,1);
    plot(cycle_time_norm, rad2deg(global_mean_cycles.GH(:,1)), 'r', 'LineWidth', 2);
    hold on;
    fill([cycle_time_norm, fliplr(cycle_time_norm)], ...
         [rad2deg(global_mean_cycles.GH(:,1) + global_std_cycles.GH(:,1))', fliplr(rad2deg(global_mean_cycles.GH(:,1) - global_std_cycles.GH(:,1))')], ...
         'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    ylabel('Plan élévation (°)');
    title('Composante 1');
    grid on;

    subplot(3,1,2);
    plot(cycle_time_norm, rad2deg(global_mean_cycles.GH(:,2)), 'g', 'LineWidth', 2);
    hold on;
    fill([cycle_time_norm, fliplr(cycle_time_norm)], ...
         [rad2deg(global_mean_cycles.GH(:,2) + global_std_cycles.GH(:,2))', fliplr(rad2deg(global_mean_cycles.GH(:,2) - global_std_cycles.GH(:,2))')], ...
         'g', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    ylabel('Élévation (°)');
    title('Composante 2');
    grid on;

    subplot(3,1,3);
    plot(cycle_time_norm, rad2deg(global_mean_cycles.GH(:,3)), 'b', 'LineWidth', 2);
    hold on;
    fill([cycle_time_norm, fliplr(cycle_time_norm)], ...
         [rad2deg(global_mean_cycles.GH(:,3) + global_std_cycles.GH(:,3))', fliplr(rad2deg(global_mean_cycles.GH(:,3) - global_std_cycles.GH(:,3))')], ...
         'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    ylabel('Rotation axiale (°)');
    xlabel('% du cycle');
    title('Composante 3');
    grid on;

    % Figure 2 : Cycles moyens ST globaux avec écarts types
    figure;
    sgtitle(sprintf('Cycle moyen global - Scapulo-Thoracique - Mouvement %d%s', current_movement, title_suffix));

    subplot(3,1,1);
    plot(cycle_time_norm, rad2deg(global_mean_cycles.ST(:,1)), 'r', 'LineWidth', 2);
    hold on;
    fill([cycle_time_norm, fliplr(cycle_time_norm)], ...
         [rad2deg(global_mean_cycles.ST(:,1) + global_std_cycles.ST(:,1))', fliplr(rad2deg(global_mean_cycles.ST(:,1) - global_std_cycles.ST(:,1))')], ...
         'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    ylabel('Protraction/Rétraction (°)');
    title('Composante 1');
    grid on;

    subplot(3,1,2);
    plot(cycle_time_norm, rad2deg(global_mean_cycles.ST(:,2)), 'g', 'LineWidth', 2);
    hold on;
    fill([cycle_time_norm, fliplr(cycle_time_norm)], ...
         [rad2deg(global_mean_cycles.ST(:,2) + global_std_cycles.ST(:,2))', fliplr(rad2deg(global_mean_cycles.ST(:,2) - global_std_cycles.ST(:,2))')], ...
         'g', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    ylabel('Rotation médiale/latérale (°)');
    title('Composante 2');
    grid on;

    subplot(3,1,3);
    plot(cycle_time_norm, rad2deg(global_mean_cycles.ST(:,3)), 'b', 'LineWidth', 2);
    hold on;
    fill([cycle_time_norm, fliplr(cycle_time_norm)], ...
         [rad2deg(global_mean_cycles.ST(:,3) + global_std_cycles.ST(:,3))', fliplr(rad2deg(global_mean_cycles.ST(:,3) - global_std_cycles.ST(:,3))')], ...
         'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    ylabel('Inclinaison (°)');
    xlabel('% du cycle');
    title('Composante 3');
    grid on;

    % Figure 3 : Cycles moyens HT globaux avec écarts types
    figure;
    sgtitle(sprintf('Cycle moyen global - Huméro-Thoracique - Mouvement %d%s', current_movement, title_suffix));

    subplot(3,1,1);
    plot(cycle_time_norm, rad2deg(global_mean_cycles.HT(:,1)), 'r', 'LineWidth', 2);
    hold on;
    fill([cycle_time_norm, fliplr(cycle_time_norm)], ...
         [rad2deg(global_mean_cycles.HT(:,1) + global_std_cycles.HT(:,1))', fliplr(rad2deg(global_mean_cycles.HT(:,1) - global_std_cycles.HT(:,1))')], ...
         'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    ylabel('Plan élévation global (°)');
    title('Composante 1');
    grid on;

    subplot(3,1,2);
    plot(cycle_time_norm, rad2deg(global_mean_cycles.HT(:,2)), 'g', 'LineWidth', 2);
    hold on;
    fill([cycle_time_norm, fliplr(cycle_time_norm)], ...
         [rad2deg(global_mean_cycles.HT(:,2) + global_std_cycles.HT(:,2))', fliplr(rad2deg(global_mean_cycles.HT(:,2) - global_std_cycles.HT(:,2))')], ...
         'g', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    ylabel('Élévation globale (°)');
    title('Composante 2');
    grid on;

    subplot(3,1,3);
    plot(cycle_time_norm, rad2deg(global_mean_cycles.HT(:,3)), 'b', 'LineWidth', 2);
    hold on;
    fill([cycle_time_norm, fliplr(cycle_time_norm)], ...
         [rad2deg(global_mean_cycles.HT(:,3) + global_std_cycles.HT(:,3))', fliplr(rad2deg(global_mean_cycles.HT(:,3) - global_std_cycles.HT(:,3))')], ...
         'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    ylabel('Rotation axiale globale (°)');
    xlabel('% du cycle');
    title('Composante 3');
    grid on;
end
