function main_2()
    % Fonction principale qui exécute l'ensemble du script
    
    % Configuration initiale
    [subjects, muscles_R, muscles_L, functional_labels, analytic_labels, assigned_analytics] = configureStudyParameters_solo();
    
    % Paramètres EMG
    [fs, b, a, rms_window, num_points, time_normalized] = configureEMGParameters();
    
    nb_subjects = length(subjects);
    nb_muscles = length(muscles_R);
    
    % Initialisation des matrices pour stocker les données
    [mvc_R, mvc_L, emg_all_subjects_R, emg_all_subjects_L, snr_subjects_R, snr_subjects_L] = initializeDataArrays(nb_subjects, nb_muscles, num_points);
    
    % Calcul du MVC pour chaque sujet et chaque muscle
    [mvc_R, mvc_L] = calculateMVC(subjects, muscles_R, muscles_L, assigned_analytics, b, a, rms_window, nb_subjects, nb_muscles);
    
    % Sélection d'une tâche fonctionnelle unique
    selected_functional = 1;
    
    % Traitement des données pour la tâche fonctionnelle sélectionnée
    [emg_all_subjects_R, emg_all_subjects_L, snr_subjects_R, snr_subjects_L] = processFunctionalTask(selected_functional, subjects, muscles_R, muscles_L,... 
        b, a, rms_window, time_normalized, mvc_R, mvc_L, functional_labels, nb_subjects, nb_muscles, emg_all_subjects_R, emg_all_subjects_L,... 
        snr_subjects_R, snr_subjects_L);
    
    % Calcul et affichage des profils moyens
    calculateAndDisplayAverageProfiles(time_normalized, emg_all_subjects_R, emg_all_subjects_L, snr_subjects_R, snr_subjects_L,... 
        muscles_R, muscles_L, functional_labels, selected_functional, nb_subjects, nb_muscles);
end