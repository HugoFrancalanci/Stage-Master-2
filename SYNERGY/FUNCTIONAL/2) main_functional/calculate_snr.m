function snr_value = calculate_snr(signal_filtered)
    % Estimation du bruit en prenant les 0.5 secondes au début du signal
    noise_samples = min(1000, length(signal_filtered) / 10);  % ~0.5s à 2000Hz ou 10% du signal
    noise = signal_filtered(1:noise_samples);
    noise_power = mean(noise.^2);
    
    % Puissance du signal complet
    signal_power = mean(signal_filtered.^2);
    
    % Calcul du SNR en dB
    if noise_power > 0
        snr_value = 10 * log10(signal_power / noise_power);
    else
        snr_value = 100; % Valeur arbitraire élevée si pas de bruit détecté
    end
end