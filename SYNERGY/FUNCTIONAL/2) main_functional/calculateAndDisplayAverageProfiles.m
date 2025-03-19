function calculateAndDisplayAverageProfiles(time_normalized, emg_all_subjects_R, emg_all_subjects_L, snr_subjects_R, snr_subjects_L, muscles_R, muscles_L, functional_labels, selected_functional, nb_subjects, nb_muscles)
    
    % Calcul du profil moyen et des écarts-types pour le côté droit
    emg_mean_R = squeeze(mean(emg_all_subjects_R, 1, 'omitnan'));
    emg_std_R = squeeze(std(emg_all_subjects_R, 0, 1, 'omitnan'));
    
    % Calcul du profil moyen et des écarts-types pour le côté gauche
    emg_mean_L = squeeze(mean(emg_all_subjects_L, 1, 'omitnan'));
    emg_std_L = squeeze(std(emg_all_subjects_L, 0, 1, 'omitnan'));
    
    % Calcul du SNR moyen pour chaque muscle (côté droit et gauche)
    snr_mean_R = mean(snr_subjects_R, 1, 'omitnan');
    snr_mean_L = mean(snr_subjects_L, 1, 'omitnan');
    
    % Affichage du profil moyen - Côté Droit
    displayAverageProfile(time_normalized, emg_mean_R, emg_std_R, snr_mean_R, muscles_R, functional_labels, selected_functional, nb_subjects, nb_muscles, 'b', 'Droit');
    
    % Affichage du profil moyen - Côté Gauche
    displayAverageProfile(time_normalized, emg_mean_L, emg_std_L, snr_mean_L, muscles_L, functional_labels, selected_functional, nb_subjects, nb_muscles, 'r', 'Gauche');

end