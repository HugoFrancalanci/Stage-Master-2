function all_functional_data = processFunctionalData(subject, selected_functional, mvc, params, all_functional_data, subj_idx)
    % Traitement des données fonctionnelles pour un sujet
    % Lecture du fichier C3D
    fileName_functional = sprintf('%s%s\\%s-%s-20240101-PROTOCOL01-FUNCTIONAL%d-.c3d', ...
        params.base_path, subject, subject, subject, selected_functional);
    c3dH_functional = btkReadAcquisition(fileName_functional);
    analogs_functional = btkGetAnalogs(c3dH_functional);
    
    % Ajout de la visualisation des données du sujet sans les cycles
    figure;
    sgtitle(sprintf('Sujet %s - %s - Signal EMG complet', ...
        subject, params.functional_labels{selected_functional}));
    
    % Traitement pour chaque muscle
    for m = 1:params.nb_muscles
        subplot(ceil(params.nb_muscles/2), 2, m);
        muscle_name = params.muscles{m};
        
        if isfield(analogs_functional, muscle_name)
            % Récupération et normalisation du signal EMG complet
            signal = analogs_functional.(muscle_name);

            % Filtrage du signal
            signal_filtered = filtfilt(params.b, params.a, signal);
            signal_abs = abs(signal_filtered);
            emg_rms = sqrt(movmean(signal_abs.^2, params.rms_window));
    
            % Normalisation du temps
            time_original = linspace(0, 1, length(emg_rms));
            emg_interp = interp1(time_original, emg_rms, params.time_normalized, 'spline');
    
            % Normalisation par le MVC
            emg_normalized = (emg_interp / mvc(m)) * 100;

            % Affichage du signal
            plot(params.time_normalized, emg_normalized, 'LineWidth', 1.2);
            title(muscle_name);
            ylabel('EMG (% MVC)');
            xlabel('Temps (s)');
            grid on;
        else
            title(sprintf('%s (Données absentes)', muscle_name));
        end
    end
    
    % Détection des cycles de mouvement
    [cycle_info, num_available_cycles, RHLE_distance_resampled] = detectMovementCycles(c3dH_functional, analogs_functional, params);
    
    % Traitement des données pour chaque cycle
    for cycle = 1:num_available_cycles
        movement_start = cycle_info(cycle, 1);
        movement_end = cycle_info(cycle, 2);
        
        % Création de la figure pour ce cycle
        figure;
        sgtitle(sprintf('Sujet %s - %s - Cycle %d/%d (RHLE > %d%% déplacement max)', ...
            subject, params.functional_labels{selected_functional}, ...
            cycle, num_available_cycles, params.position_threshold_percent));
        
        % Traitement pour chaque muscle
        for m = 1:params.nb_muscles
            subplot(ceil(params.nb_muscles/2), 2, m);
            muscle_name = params.muscles{m};
            
            if isfield(analogs_functional, muscle_name)
                % Traitement du signal EMG
                [emg_normalized, emg_movement] = processEMGSignal(analogs_functional.(muscle_name), ...
                    movement_start, movement_end, mvc(m), params);
                
                % Stockage des données traitées
                all_functional_data{subj_idx, selected_functional, m, cycle} = emg_normalized;
                
                % Affichage du signal
                plot(params.time_normalized, emg_normalized, 'LineWidth', 1.2);
                title(muscle_name);
                ylabel('EMG (% MVC)');
                grid on;
            else
                title(sprintf('%s (Données absentes)', muscle_name));
            end
        end
    end
    
    % Visualisation de la détection des cycles
    if exist('RHLE_distance_resampled', 'var')
        plotCycleDetection(RHLE_distance_resampled, cycle_info, num_available_cycles, params);
    end
end