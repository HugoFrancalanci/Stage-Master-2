function [emg_all_subjects_R, emg_all_subjects_L, snr_subjects_R, snr_subjects_L] = processFunctionalTask(selected_functional, subjects, muscles_R, muscles_L, b, a, rms_window, time_normalized, mvc_R, mvc_L, functional_labels, nb_subjects, nb_muscles, emg_all_subjects_R, emg_all_subjects_L, snr_subjects_R, snr_subjects_L)
    
    % Traitement des données pour la tâche fonctionnelle sélectionnée
    for subj_idx = 1:nb_subjects
        fileName_functional = sprintf(['C:\\Users\\Francalanci Hugo\\Documents\\MATLAB\\Stage Sainte-Justine\\HUG\\Sujets\\%s\\' ...
            '%s-%s-20240101-PROTOCOL01-FUNCTIONAL%d-.c3d'], ...
            subjects{subj_idx}, subjects{subj_idx}, subjects{subj_idx}, selected_functional);
        
        if exist(fileName_functional, 'file')
            c3dH_functional = btkReadAcquisition(fileName_functional);
            analogs_functional = btkGetAnalogs(c3dH_functional);
            
            % Création de deux figures pour les côtés droit et gauche
            figure;
            sgtitle(sprintf('Sujet %s - %s - Côté Droit', subjects{subj_idx}, functional_labels{selected_functional}));
            
            % Traitement des muscles droits et mise à jour des matrices
            [emg_all_subjects_R, snr_subjects_R] = processMuscleSide(subj_idx, muscles_R, analogs_functional, b, a, rms_window, time_normalized, mvc_R, nb_muscles, emg_all_subjects_R, snr_subjects_R, 'b');

            
            % Création d'une figure pour les muscles gauches
            figure;
            sgtitle(sprintf('Sujet %s - %s - Côté Gauche', subjects{subj_idx}, functional_labels{selected_functional}));
            
            % Traitement des muscles gauches et mise à jour des matrices
            [emg_all_subjects_L, snr_subjects_L] = processMuscleSide(subj_idx, muscles_L, analogs_functional, b, a, rms_window, time_normalized, mvc_L, nb_muscles, emg_all_subjects_L, snr_subjects_L, 'r');
            
        else
            warning('Fichier introuvable : %s', fileName_functional);
        end
    end
end