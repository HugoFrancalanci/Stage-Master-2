function afficher_resume(activation_summary)
    articulations = fieldnames(activation_summary);
    fprintf('\n===== Résumé cinématique (pic, amplitude, vitesses) =====\n');
    for i = 1:length(articulations)
        joint = articulations{i};
        fprintf('\n--- %s ---\n', joint);
        for c = 1:3
            data = activation_summary.(joint)(c);
            fprintf('%s :\n', data.composante);
            fprintf('  - Pic à %.1f%% du cycle (%.1f°)\n', data.time_max_pct, data.max_angle_deg);
            fprintf('  - Retour à %.1f%% du cycle\n', data.return_time_pct);
            fprintf('  - Amplitude totale : %.1f°\n', data.amplitude_deg);
            fprintf('  - Vitesse phase aller : %.2f °/%%\n', data.vitesse_aller);
            fprintf('  - Vitesse phase retour : %.2f °/%%\n', data.vitesse_retour);
        end
    end
end