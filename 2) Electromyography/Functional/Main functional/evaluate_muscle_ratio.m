function interpretation = evaluate_muscle_ratio(ratio_value, muscle_pair)
    % Interprétation du ratio entre deux muscles
    % ratio_value : valeur du ratio calculé
    % muscle_pair : paire de muscles concernée (pour évaluation spécifique)
    
    % Définir les plages de référence pour chaque paire de muscles
    % Ces valeurs sont hypothétiques et devraient être ajustées en fonction
    % de la littérature ou des données propres à votre étude
    switch muscle_pair
        case 'DA/DM' % Deltoïde antérieur / Deltoïde moyen
            if ratio_value >= 0.8 && ratio_value <= 1.2
                interpretation = 'Normal';
            elseif ratio_value > 1.2
                interpretation = 'Dominance antérieure';
            else
                interpretation = 'Dominance moyenne';
            end
            
        case 'DP/DM' % Deltoïde postérieur / Deltoïde moyen
            if ratio_value >= 0.7 && ratio_value <= 1.1
                interpretation = 'Normal';
            elseif ratio_value > 1.1
                interpretation = 'Dominance postérieure';
            else
                interpretation = 'Dominance moyenne';
            end
            
        case 'TS/GD' % Trapèze supérieur / Grand dentelé
            if ratio_value >= 0.9 && ratio_value <= 1.5
                interpretation = 'Normal';
            elseif ratio_value > 1.5
                interpretation = 'Dominance trapèze supérieur';
            else
                interpretation = 'Dominance grand dentelé';
            end
            
        case 'TM/GD' % Trapèze moyen / Grand dentelé
            if ratio_value >= 0.6 && ratio_value <= 1.2
                interpretation = 'Normal';
            elseif ratio_value > 1.2
                interpretation = 'Dominance trapèze moyen';
            else
                interpretation = 'Dominance grand dentelé';
            end
            
        case 'TI/GD' % Trapèze inférieur / Grand dentelé
            if ratio_value >= 0.5 && ratio_value <= 1.0
                interpretation = 'Normal';
            elseif ratio_value > 1.0
                interpretation = 'Dominance trapèze inférieur';
            else
                interpretation = 'Dominance grand dentelé';
            end
            
        otherwise
            interpretation = 'Paire de muscles non reconnue';
    end
    
    % Ajouter la valeur numérique à l'interprétation
    interpretation = sprintf('%s (ratio = %.2f)', interpretation, ratio_value);
end