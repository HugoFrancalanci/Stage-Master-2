function displayAverageProfile(time_normalized, emg_mean, emg_std, muscles, functional_labels, selected_functional, nb_subjects, nb_muscles, color_code, side_label, emg_ci_lower, emg_ci_upper)

% Affichage du profil moyen pour un côté spécifique
figure;
sgtitle(sprintf('Average profile of %d subjects - %s - %s Side', nb_subjects, functional_labels{selected_functional}, side_label));

for m = 1:nb_muscles
    subplot(ceil(nb_muscles/2), 2, m);
    hold on;
    muscle_name = muscles{m};
    
    % Tracé de l'intervalle de confiance en pointillés noirs (sans remplissage)
    h_ci_lower = plot(time_normalized, emg_ci_lower(:, m), 'k--', 'LineWidth', 1);
    h_ci_upper = plot(time_normalized, emg_ci_upper(:, m), 'k--', 'LineWidth', 1);
    
    % Tracé de l'écart-type (en zone ombrée claire)
    h_std = fill([time_normalized, fliplr(time_normalized)], ...
        [max(emg_mean(:, m) - emg_std(:, m), 0); flipud(emg_mean(:, m) + emg_std(:, m))], ...
        color_code, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    
    % Tracé de la courbe moyenne
    h_mean = plot(time_normalized, emg_mean(:, m), color_code, 'LineWidth', 2);
    
    title(muscle_name);
    grid on;
    
    % Ajouter la légende uniquement sur le premier subplot
    if m == 1
        legend([h_mean, h_std, h_ci_lower], {'Mean', 'Std (±1σ)', 'IC 95%'}, 'Location', 'best');
        ylabel('% MVC submaximal task');
        xlabel('Normalized time');
    end
end
end
