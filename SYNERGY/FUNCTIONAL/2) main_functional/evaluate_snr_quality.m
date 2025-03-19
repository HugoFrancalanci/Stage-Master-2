function quality = evaluate_snr_quality(snr_value)
    % Évaluation de la qualité du SNR
    
    if snr_value >= 20
        quality = 'Excellent';
    elseif snr_value >= 15
        quality = 'Très bon';
    elseif snr_value >= 10
        quality = 'Bon';
    elseif snr_value >= 5
        quality = 'Acceptable';
    else
        quality = 'Faible';
    end
end