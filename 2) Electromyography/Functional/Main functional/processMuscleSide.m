function [emg_all_subjects] = processMuscleSide(subj_idx, muscles, analogs_functional, b, a, rms_window, time_normalized, mvc, nb_muscles, emg_all_subjects, color_code)
    % Traitement des muscles pour un côté spécifique avec élimination d'artefacts
    for m = 1:nb_muscles
        subplot(ceil(nb_muscles/2), 2, m);
        hold on;
        muscle_name = muscles{m};
        
        if isfield(analogs_functional, muscle_name)
            signal = analogs_functional.(muscle_name);
            
            % Application du filtre passe-bande
            signal_filtered = filtfilt(b, a, signal);
            signal_filtered = abs(signal_filtered);
            
            % 1. ÉLIMINATION DES ARTEFACTS - Utilisation de characterizeArtifacts
            sampling_rate = 2000; 

            % Caractérisation des artefacts (classique sans visualisation)
            % artifacts_info = characterizeArtifacts(signal_filtered, sampling_rate, 'Visualize', false);

            % STD
            artifacts_info = characterizeArtifacts(signal_filtered, sampling_rate, 'Method', 'STD', 'ThresholdFactor', 6, 'MinDuration', 15, 'Visualize', false);

            % MAD
            % artifacts_info = characterizeArtifacts(signal_filtered, sampling_rate, 'Method', 'MAD', 'ThresholdFactor', 4.5, 'MinDuration', 10, 'Visualize', true);

            % IQR
            % artifacts_info = characterizeArtifacts(signal_filtered, sampling_rate, 'Method', 'IQR', 'ThresholdFactor', 3.0, 'MinDuration', 15, 'MaxDuration', 100, 'Visualize', true);

            % Seuils personnalisés
            % artifacts_info = characterizeArtifacts(signal_filtered, sampling_rate, 'Method', 'CUSTOM', 'CustomThresholds', [-0.00005, 0.00005], 'Visualize', true);

            % Obtention des seuils calculés
            upper_threshold = artifacts_info.upper_threshold;
            lower_threshold = artifacts_info.lower_threshold;

            % Détection des valeurs aberrantes (outliers)
            outliers = (signal_filtered > upper_threshold) | (signal_filtered < lower_threshold);

            % 2. REMPLACEMENT DES ARTEFACTS
            % Option 1: Remplacer par des NaN pour interpolation ultérieure
            signal_cleaned = signal_filtered;
            signal_cleaned(outliers) = NaN;

            % Interpolation pour remplacer les NaN (artefacts)
            t = 1:length(signal_cleaned);
            signal_cleaned = fillmissing(signal_cleaned, 'pchip');

            % 3. ÉLIMINATION DES PICS ISOLÉS - Filtre médian (pour les pics très courts)
            window_size = 5; % Taille de fenêtre pour le filtre médian (ajustable)
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
                
                % Vérifier si c'est un muscle SERRA et si son activation maximale dépasse 15% MVC
                if contains(upper(muscle_name), 'SERRA')
                    % Utiliser le 95ème percentile pour représenter la valeur maximale significative
                    % et éviter les valeurs aberrantes
                    max_activation = prctile(emg_normalized, 95);
                    if max_activation > 15
                        % Si c'est un SERRA avec activation max > 15%, tracer en noir
                        plot(time_normalized, emg_normalized, 'k', 'LineWidth', 1.5);
                        title([muscle_name, ' (max:', num2str(max_activation, '%.1f'), '% MVC)'], 'FontWeight', 'bold');
                    else
                        % Sinon, utiliser la couleur par défaut
                        plot(time_normalized, emg_normalized, color_code, 'LineWidth', 1.2);
                        title(muscle_name);
                    end
                else
                    % Muscle non-SERRA, utiliser la couleur par défaut
                    plot(time_normalized, emg_normalized, color_code, 'LineWidth', 1.2);
                    title(muscle_name);
                end
            else
                emg_normalized = emg_interp;
                plot(time_normalized, emg_normalized, color_code, 'LineWidth', 1.2);
                title(muscle_name);
            end

            ylabel('% MVC (Submaximal task)');
            grid on;
            
            % Utiliser le pourcentage d'artefacts calculé par characterizeArtifacts
            pct_artifacts = artifacts_info.percentage;

            % Ajout des annotations  artefacts
            text(0.7, 0.9, sprintf('Artefacts: %.1f%%', ...
                 pct_artifacts), ...
                'Units', 'normalized', 'FontSize', 8, 'BackgroundColor', 'white');

            % Stockage des données pour la figure de segmentation
            if m == 1 % Stockage uniquement pour le premier muscle
                segmentation_data.signal = signal;
                segmentation_data.signal_filtered = signal_filtered;
                segmentation_data.signal_no_spikes = signal_no_spikes;
                segmentation_data.outliers = outliers;
                segmentation_data.upper_threshold = upper_threshold;
                segmentation_data.lower_threshold = lower_threshold;
                segmentation_data.muscle_name = muscle_name;
                segmentation_data.artifacts_info = artifacts_info; % Stockage des infos supplémentaires
            end
        else
            title(sprintf('%s (Données absentes)', muscle_name));
        end
    end

    % Création d'une seconde figure pour la segmentation des artefacts
       if exist('segmentation_data', 'var')
          createSegmentationFigure(segmentation_data, subj_idx);
       end

    % Pour tous les muscles (si nécessaires)

    % for m = 1:nb_muscles
    %     if exist('segmentation_data', 'var')
    %      createSegmentationFigure(segmentation_data, subj_idx);
    %     end
    % end
end

