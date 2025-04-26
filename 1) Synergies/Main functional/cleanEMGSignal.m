function [signal_cleaned, artifacts_info] = cleanEMGSignal(signal_raw, b, a, rms_window)
% cleanEMGSignal : Filtrage, détection et correction d'artefacts dans un signal EMG
%
% Entrées :
%   - signal_raw    : signal EMG brut
%   - b, a          : coefficients du filtre passe-bande
%   - rms_window    : fenêtre pour le calcul RMS (en échantillons)
%
% Sorties :
%   - signal_cleaned : signal filtré, nettoyé, prêt pour RMS
%   - artifacts_info : struct contenant les infos sur les artefacts détectés

    sampling_rate = 2000; % Hz

    % 1. Filtrage passe-bande et rectification
    signal_filtered = filtfilt(b, a, signal_raw);
    signal_filtered = abs(signal_filtered);

    % 2. Caractérisation des artefacts (personnalisable)
    artifacts_info = characterizeArtifacts(signal_filtered, sampling_rate, ...
        'Method', 'STD', 'ThresholdFactor', 6, ...
        'MinDuration', 15, 'Visualize', false);

    % 3. Suppression des outliers
    outliers = (signal_filtered > artifacts_info.upper_threshold) | ...
               (signal_filtered < artifacts_info.lower_threshold);

    signal_cleaned = signal_filtered;
    signal_cleaned(outliers) = NaN;

    % 4. Interpolation pour remplacer les NaN
    signal_cleaned = fillmissing(signal_cleaned, 'pchip');

    % 5. Élimination des pics courts : filtre médian
    window_size = 5;
    signal_cleaned = medfilt1(signal_cleaned, window_size);
end
