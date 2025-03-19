function [emg_normalized, emg_movement] = processEMGSignal(signal, movement_start, movement_end, mvc_value, params)
    % Traitement du signal EMG pour un muscle
    
    % Filtrage du signal
    signal_filtered = filtfilt(params.b, params.a, signal);
    signal_abs = abs(signal_filtered);
    emg_rms = sqrt(movmean(signal_abs.^2, params.rms_window));
    
    % Extraire uniquement la partie correspondant au mouvement
    emg_movement = emg_rms(movement_start:movement_end);
    
    % Normalisation du temps
    time_original = linspace(0, 1, length(emg_movement));
    emg_interp = interp1(time_original, emg_movement, params.time_normalized, 'spline');
    
    % Normalisation par le MVC
    emg_normalized = (emg_interp / mvc_value) * 100;
end