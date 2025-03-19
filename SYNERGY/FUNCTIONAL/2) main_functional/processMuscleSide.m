function [emg_all_subjects, snr_subjects] = processMuscleSide(subj_idx, muscles, analogs_functional, b, a, rms_window, time_normalized, mvc, nb_muscles, emg_all_subjects, snr_subjects, color_code) 
    
    % Traitement des muscles pour un côté spécifique (droit ou gauche)
    for m = 1:nb_muscles
        subplot(ceil(nb_muscles/2), 2, m);
        hold on;
        
        muscle_name = muscles{m};
        
        if isfield(analogs_functional, muscle_name)
            signal = analogs_functional.(muscle_name);
            signal_filtered = filtfilt(b, a, signal);
            
            % Calcul du SNR pour ce muscle et ce sujet
            snr_value = calculate_snr(signal_filtered);
            snr_subjects(subj_idx, m) = snr_value;
            snr_quality = evaluate_snr_quality(snr_value);
            
            emg_rms = sqrt(movmean(abs(signal_filtered).^2, rms_window));
            
            % Normalisation du temps
            time_original = linspace(0, 1, length(emg_rms));
            emg_interp = interp1(time_original, emg_rms, time_normalized, 'spline');
            
            % Normalisation par le MVC
            if mvc(m, subj_idx) > 0
                emg_normalized = (emg_interp / mvc(m, subj_idx)) * 100;
                % Stockage pour le calcul du profil moyen
                emg_all_subjects(subj_idx, :, m) = emg_normalized;
            else
                emg_normalized = emg_interp;
            end
            
            plot(time_normalized, emg_normalized, color_code, 'LineWidth', 1.2);
            title(muscle_name);
            ylabel('EMG (% MVC)');
            grid on;
            
            % Ajout de l'annotation SNR
            text(0.7, 0.9, sprintf('SNR: %.1f dB\nQualité: %s', snr_value, snr_quality), ...
                'Units', 'normalized', 'FontSize', 8, 'BackgroundColor', 'white');
        else
            title(sprintf('%s (Données absentes)', muscle_name));
        end
    end
end