function [all_functional_data, num_available_cycles_per_functional] = processFunctionalData(data_path, subjects, muscles, functional_labels, b, a, rms_window, num_points, time_normalized, position_threshold_percent, min_duration, num_cycles, mvc, manual_selection_funcs)
 % Traitement des données fonctionnelles
 nb_subjects = length(subjects);
 nb_muscles = length(muscles);
 nb_functional = length(functional_labels);
 fs = 2000;
 all_functional_data = cell(nb_subjects, nb_functional, nb_muscles, num_cycles);
 num_available_cycles_per_functional = zeros(nb_functional, 1);
 
 % Traitement des données pour tous les mouvements fonctionnels
 for functional_idx = 1:nb_functional
   fprintf('Traitement du mouvement fonctionnel %d: %s\n', functional_idx, functional_labels{functional_idx});
   use_manual = manual_selection_funcs(functional_idx);
   for subj_idx = 1:nb_subjects
     fileName_functional = sprintf('%s\\%s\\%s-PROTOCOL01-FUNCTIONAL%d-01.c3d', ...
                                  data_path, subjects{subj_idx}, subjects{subj_idx}, functional_idx);

     c3dH_functional = btkReadAcquisition(fileName_functional);
     analogs_functional = btkGetAnalogs(c3dH_functional);
     
     % Détection des cycles de mouvement
     [cycle_info, num_cycles_detected, RHLE_distance_resampled] = detectMovementCycles(c3dH_functional, analogs_functional, muscles, position_threshold_percent, min_duration, num_cycles, fs, use_manual);
     num_available_cycles_per_functional(functional_idx) = num_cycles_detected;
     
     % Traitement pour chaque cycle détecté
     for cycle = 1:num_cycles_detected
       movement_start = cycle_info(cycle, 1);
       movement_end = cycle_info(cycle, 2);
       
       % Traitement et visualisation des données EMG pour ce cycle
       all_functional_data = processAndVisualizeCycle(subjects, subj_idx, functional_labels, functional_idx, muscles, analogs_functional, b, a, rms_window, movement_start, movement_end, time_normalized, mvc, cycle, num_cycles_detected, position_threshold_percent, all_functional_data);
       
       % Inversion du mouvement fonctionnel 4
       if functional_idx == 4
         for muscle_idx = 1:nb_muscles
           % Récupération des données du cycle actuel
           current_data = all_functional_data{subj_idx, functional_idx, muscle_idx, cycle};
           
           % Vérification que les données existent
           if ~isempty(current_data)
             % Inversion des données (les 50% premiers deviennent les 50% derniers et vice-versa)
             data_size = size(current_data, 2);
             half_point = ceil(data_size / 2);
             
             % Séparation en deux moitiés
             first_half = current_data(:, 1:half_point);
             second_half = current_data(:, half_point+1:end);
             
             % Inversion et réassemblage
             all_functional_data{subj_idx, functional_idx, muscle_idx, cycle} = [second_half, first_half];
             
             fprintf('Mouvement fonctionnel 4 inversé pour le sujet %s, muscle %s, cycle %d\n', ...
                     subjects{subj_idx}, muscles{muscle_idx}, cycle);
           end
         end
       end
     end
     
     % Visualisation de la détection des cycles
     visualizeCycleDetection(RHLE_distance_resampled, cycle_info, position_threshold_percent, functional_labels, functional_idx, num_cycles_detected);
   end
 end
end