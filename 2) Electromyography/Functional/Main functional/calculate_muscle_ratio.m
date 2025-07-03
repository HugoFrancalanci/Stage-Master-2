function ratio_value = calculate_muscle_ratio(signal_muscle1, signal_muscle2)
    % Calcule le ratio d'activité entre deux muscles
    
    % Calcul de l'activité moyenne pour chaque muscle (moyenne des 5 valeurs max)
    activity_muscle1 = mean(maxk(signal_muscle1, 5));
    activity_muscle2 = mean(maxk(signal_muscle2, 5));
    
    % Calcul du ratio (si le dénominateur n'est pas zéro)
    if activity_muscle2 > 0
        ratio_value = activity_muscle1 / activity_muscle2;
    else
        ratio_value = NaN; % Valeur NaN si le dénominateur est zéro
        warning('Attention: Activité nulle pour le second muscle, ratio indéfini.');
    end
end