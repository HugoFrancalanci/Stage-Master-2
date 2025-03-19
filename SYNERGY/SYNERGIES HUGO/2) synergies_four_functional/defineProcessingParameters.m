function [b, a, rms_window, num_points, time_normalized, position_threshold_percent, min_duration, num_cycles] = defineProcessingParameters()
% Définis les paramètres de traitement
    % Paramètres EMG
    fs = 2000;
    [b, a] = butter(4, [15, 475] / (fs/2), 'bandpass');
    rms_window = round(0.250 * fs);
    num_points = 1000;
    time_normalized = linspace(0, 1, num_points);
    
    % Paramètres pour la détection basée sur le marqueur RHLE
    position_threshold_percent = 35; % 15  % Seuil de déplacement significatif (% du déplacement max)
    min_duration = 0.1;  % Durée minimale d'un mouvement (en secondes)
    num_cycles = 3;      % Nombre de cycles à traiter par mouvement fonctionnel
end