function [emg_all_subjects_R, emg_all_subjects_L] = processFunctionalTask_combined(selected_functional, subjects, muscles_R, muscles_L, b, a, rms_window, time_normalized, mvc_R, mvc_L, functional_labels, nb_subjects, nb_muscles, emg_all_subjects_R, emg_all_subjects_L, base_path, display_option)
    
    % Traitement des données pour la tâche fonctionnelle sélectionnée
    for subj_idx = 1:nb_subjects
        fileName_functional = sprintf('%s\\%s\\%s-PROTOCOL01-FUNCTIONAL%d-01.c3d', ...
                                     base_path, subjects{subj_idx}, subjects{subj_idx}, selected_functional);
        
        if exist(fileName_functional, 'file')
            c3dH_functional = btkReadAcquisition(fileName_functional);
            analogs_functional = btkGetAnalogs(c3dH_functional);
            
            % Création de deux figures pour les côtés droit et gauche
            if display_option == 1
               figure;
               sgtitle(sprintf('Sujet %s - %s - Right Side', subjects{subj_idx}, functional_labels{selected_functional}));
            end
            
            % Traitement des muscles droits et mise à jour des matrices
            [emg_all_subjects_R] = processMuscleSide_combined(subj_idx, muscles_R, analogs_functional, b, a, rms_window, time_normalized, mvc_R, nb_muscles, emg_all_subjects_R, 'b', display_option);
          
            % Création d'une figure pour les muscles gauches
           if display_option == 1
              figure;
              sgtitle(sprintf('Sujet %s - %s - Left Side', subjects{subj_idx}, functional_labels{selected_functional}));
           end
            
            % Traitement des muscles gauches et mise à jour des matrices
            [emg_all_subjects_L] = processMuscleSide_combined(subj_idx, muscles_L, analogs_functional, b, a, rms_window, time_normalized, mvc_L, nb_muscles, emg_all_subjects_L, 'r', display_option);
            
        else
            warning('Fichier introuvable : %s', fileName_functional);
        end
    end
end