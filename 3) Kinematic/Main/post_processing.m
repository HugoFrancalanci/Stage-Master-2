function post_processing(config, combined_mean_cycles, combined_std_cycles, combined_CI_cycles) 
    % Affichage des cycles moyens combinés
    afficher_tous_mouvements(combined_mean_cycles, combined_std_cycles, combined_CI_cycles, config.num_samples_per_cycle);

    % Résumé cinématique
    activation_summary = resume_cinematique(combined_mean_cycles, config.num_samples_per_cycle);

    % Affichage du résumé
    afficher_resume(activation_summary);
end