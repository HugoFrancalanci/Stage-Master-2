function process_global_statistics(all_movements_data, all_subjects_mean_cycles, current_movement, config)
    % Compter le nombre de sujets valides pour ce mouvement
    valid_subjects = get_valid_subjects(all_movements_data, current_movement, config.Subjects);
    
    % Calcul des moyennes et écarts types pour les cycles moyens de ce mouvement
    [global_mean_cycles, global_std_cycles] = calculate_global_statistics(all_subjects_mean_cycles, current_movement, valid_subjects);
    
    % Affichage des graphiques des cycles moyens globaux
    plot_global_cycles(global_mean_cycles, global_std_cycles, current_movement, config);
end