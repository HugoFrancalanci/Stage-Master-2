function [mvc_R, mvc_L, emg_all_subjects_R, emg_all_subjects_L, snr_subjects_R, snr_subjects_L] = initializeDataArrays(nb_subjects, nb_muscles, num_points)
    % Initialisation des matrices pour stocker les données
    
    % Initialisation des MVC des tâches analytiques pour chaque sujet et côté
    mvc_R = zeros(nb_muscles, nb_subjects); % MVC côté droit [muscles, sujet]
    mvc_L = zeros(nb_muscles, nb_subjects); % MVC côté gauche [muscles, sujet]
    
    % Initialisation des matrices pour stocker les signaux normalisés (droite et gauche)
    emg_all_subjects_R = nan(nb_subjects, num_points, nb_muscles);
    emg_all_subjects_L = nan(nb_subjects, num_points, nb_muscles);
    
    % Initialisation des matrices pour stocker les SNR (droite et gauche)
    snr_subjects_R = nan(nb_subjects, nb_muscles);
    snr_subjects_L = nan(nb_subjects, nb_muscles);
end