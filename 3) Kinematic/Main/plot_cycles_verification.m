function plot_cycles_verification(signal, cycle_starts, cycle_ends, max_amplitudes, config, subject)
    figure;
    time = (0:length(signal)-1) / config.fs;
    
    plot(time, signal, 'b-', 'LineWidth', 1.5);
    hold on;
    yline(config.cycle_threshold_pct, 'r--', 'Seuil', 'LineWidth', 1.5);
    yline(config.min_cycle_amplitude, 'g--', 'Min Amplitude', 'LineWidth', 1.5);
    
    % Marquage des cycles valides et rejetés
    for i = 1:length(cycle_starts)
        if max_amplitudes(i) >= config.min_cycle_amplitude
            % Cycle valide - vert
            plot([time(cycle_starts(i)), time(cycle_ends(i))], [5, 5], 'g-', 'LineWidth', 4);
            text(time(cycle_starts(i)), 10, sprintf('Cycle %d (%.1f%%)', i, max_amplitudes(i)), 'Color', 'g');
        else
            % Cycle rejeté - rouge
            plot([time(cycle_starts(i)), time(cycle_ends(i))], [5, 5], 'r-', 'LineWidth', 4);
            text(time(cycle_starts(i)), 10, sprintf('Cycle %d (%.1f%%)', i, max_amplitudes(i)), 'Color', 'r');
        end
    end
    
    title(sprintf('Vérification des cycles - Sujet: %s', subject));
    xlabel('Temps (s)');
    ylabel('Amplitude normalisée (%)');
    legend('Mouvement', 'Seuil de détection', 'Amplitude minimum');
    grid on;
end