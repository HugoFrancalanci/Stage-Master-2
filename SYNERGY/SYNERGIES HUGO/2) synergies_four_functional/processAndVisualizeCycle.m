function all_functional_data = processAndVisualizeCycle(subjects, subj_idx, functional_labels, functional_idx, muscles, analogs_functional, b, a, rms_window, movement_start, movement_end, time_normalized, mvc, cycle, num_cycles_detected, position_threshold_percent, all_functional_data)
    % Traitement et visualisation des données EMG d'un cycle

    nb_muscles = length(muscles);
    
    % Figure pour ce cycle spécifique
    figure;
    sgtitle(sprintf('Sujet %s - %s - Cycle %d/%d (RHLE > %d%% déplacement max)', ...
        subjects{subj_idx}, functional_labels{functional_idx}, ...
        cycle, num_cycles_detected, position_threshold_percent));
    
    for m = 1:nb_muscles
        subplot(ceil(nb_muscles/2), 2, m);
        muscle_name = muscles{m};
        if isfield(analogs_functional, muscle_name)
            signal = analogs_functional.(muscle_name);
            signal_filtered = filtfilt(b, a, signal);
            signal_abs = abs(abs(signal_filtered));
            emg_rms = sqrt(movmean(signal_abs.^2, rms_window));
            
            % Extraire uniquement la partie correspondant au mouvement
            emg_movement = emg_rms(movement_start:movement_end);
            
            % Normalisation du temps
            time_original = linspace(0, 1, length(emg_movement));
            emg_interp = interp1(time_original, emg_movement, time_normalized, 'spline');
            
            % Normalisation par le MVC associé à la tâche prédéfinie
            emg_normalized = (emg_interp / mvc(m)) * 100;
            
            all_functional_data{subj_idx, functional_idx, m, cycle} = emg_normalized;
            plot(time_normalized, emg_normalized, 'LineWidth', 1.2);
            title(muscle_name);
            ylabel('EMG (% MVC)');
            grid on;
        else
            title(sprintf('%s (Données absentes)', muscle_name));
        end
    end
end