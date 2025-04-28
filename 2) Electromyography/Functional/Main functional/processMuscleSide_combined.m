function [emg_all_subjects] = processMuscleSide_combined(subj_idx, muscles, analogs_functional, b, a, rms_window, time_normalized, mvc, nb_muscles, emg_all_subjects, color_code, display_option)
    % Traitement des muscles pour un côté spécifique avec élimination d'artefacts
    for m = 1:nb_muscles
        if display_option == 1
            subplot(ceil(nb_muscles/2), 2, m);
            hold on;
        end
        
        muscle_name = muscles{m};
        
        if isfield(analogs_functional, muscle_name)
            signal = analogs_functional.(muscle_name);
            
            % Application du filtre passe-bande
            signal_filtered = filtfilt(b, a, signal);
            signal_filtered = abs(signal_filtered);
            
            % 1. ÉLIMINATION DES ARTEFACTS
            sampling_rate = 2000; 
            artifacts_info = characterizeArtifacts(signal_filtered, sampling_rate, 'Method', 'STD', 'ThresholdFactor', 6, 'MinDuration', 15, 'Visualize', false);
            
            % Obtention des seuils calculés
            upper_threshold = artifacts_info.upper_threshold;
            lower_threshold = artifacts_info.lower_threshold;

            % Détection des valeurs aberrantes (outliers)
            outliers = (signal_filtered > upper_threshold) | (signal_filtered < lower_threshold);

            % 2. REMPLACEMENT DES ARTEFACTS
            signal_cleaned = signal_filtered;
            signal_cleaned(outliers) = NaN;
            
            % Interpolation pour remplacer les NaN
            t = 1:length(signal_cleaned);
            signal_cleaned = fillmissing(signal_cleaned, 'pchip');

            % 3. ÉLIMINATION DES PICS ISOLÉS
            window_size = 5;
            signal_no_spikes = medfilt1(signal_cleaned, window_size);
            
            % 4. CALCUL RMS avec signal nettoyé
            emg_rms = sqrt(movmean(signal_no_spikes.^2, rms_window));

            % Normalisation du temps
            time_original = linspace(0, 1, length(emg_rms));
            emg_interp = interp1(time_original, emg_rms, time_normalized, 'spline');
            
            % Normalisation par le MVC
            if mvc(m, subj_idx) > 0
                emg_normalized = (emg_interp / mvc(m, subj_idx)) * 100;
                % Stockage pour le calcul du profil moyen
                emg_all_subjects(subj_idx, :, m) = emg_normalized;
                
                % Affichage conditionnel des graphiques
                if display_option == 1
                    % Vérifier si c'est un muscle SERRA avec activation > 15% MVC
                    if contains(upper(muscle_name), 'SERRA')
                        max_activation = prctile(emg_normalized, 95);
                        if max_activation > 15
                            plot(time_normalized, emg_normalized, 'k', 'LineWidth', 1.5);
                            title([muscle_name, ' (max:', num2str(max_activation, '%.1f'), '% MVC)'], 'FontWeight', 'bold');
                        else
                            plot(time_normalized, emg_normalized, color_code, 'LineWidth', 1.2);
                            title(muscle_name);
                        end
                    else
                        plot(time_normalized, emg_normalized, color_code, 'LineWidth', 1.2);
                        title(muscle_name);
                    end
                    
                    ylabel('% MVC (Submaximal task)');
                    grid on;
                    
                    % Ajout des annotations artefacts
                    pct_artifacts = artifacts_info.percentage;
                    text(0.7, 0.9, sprintf('Artefacts: %.1f%%', pct_artifacts), ...
                         'Units', 'normalized', 'FontSize', 8, 'BackgroundColor', 'white');
                end
            else
                emg_normalized = emg_interp;
                if display_option == 1
                    plot(time_normalized, emg_normalized, color_code, 'LineWidth', 1.2);
                    title(muscle_name);
                    ylabel('% MVC (Submaximal task)');
                    grid on;
                end
            end

            % Stockage des données pour la figure de segmentation (uniquement si affichage activé)
            if m == 1 && display_option == 1
                segmentation_data.signal = signal;
                segmentation_data.signal_filtered = signal_filtered;
                segmentation_data.signal_no_spikes = signal_no_spikes;
                segmentation_data.outliers = outliers;
                segmentation_data.upper_threshold = upper_threshold;
                segmentation_data.lower_threshold = lower_threshold;
                segmentation_data.muscle_name = muscle_name;
                segmentation_data.artifacts_info = artifacts_info;
            end
        elseif display_option == 1
            title(sprintf('%s (Données absentes)', muscle_name));
        end
    end

    % Création conditionnelle de la figure de segmentation
    if exist('segmentation_data', 'var') && display_option == 1
        createSegmentationFigure(segmentation_data, subj_idx);
    end
end
