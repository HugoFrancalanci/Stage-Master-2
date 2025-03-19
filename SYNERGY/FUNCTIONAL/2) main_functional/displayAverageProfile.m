function displayAverageProfile(time_normalized, emg_mean, emg_std, snr_mean, muscles, functional_labels, selected_functional, nb_subjects, nb_muscles, color_code, side_label)
    
    % Affichage du profil moyen pour un côté spécifique
    figure;
    sgtitle(sprintf('Profil moyen des %d sujets - %s - Côté %s', nb_subjects, functional_labels{selected_functional}, side_label));
    
    for m = 1:nb_muscles
        subplot(ceil(nb_muscles/2), 2, m);
        hold on;
        
        muscle_name = muscles{m};
        
        % Tracé de la courbe moyenne
        plot(time_normalized, emg_mean(:, m), color_code, 'LineWidth', 1.5);
        
        % Ajout de la zone d'incertitude (± 1 écart-type)
        fill([time_normalized, fliplr(time_normalized)], ...
             [max(emg_mean(:, m) - emg_std(:, m), 0); flipud(emg_mean(:, m) + emg_std(:, m))], ...
             color_code, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        
        title(muscle_name);
        ylabel('EMG (% MVC)');
        xlabel('Temps normalisé');
        grid on;
        
        % Ajout de l'annotation SNR moyen
        snr_quality = evaluate_snr_quality(snr_mean(m));
        text(0.7, 0.9, sprintf('SNR moyen: %.1f dB\nQualité: %s', snr_mean(m), snr_quality), ...
            'Units', 'normalized', 'FontSize', 8, 'BackgroundColor', 'white');
    end
end