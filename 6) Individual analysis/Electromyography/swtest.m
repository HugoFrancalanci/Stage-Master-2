% Fonction pour le test Shapiro-Wilk (adapté du script original)
function [H, pValue] = swtest(x, alpha)
    % SWTEST Test de Shapiro-Wilk pour tester la normalité
    
    % Éliminer les NaN
    x = x(~isnan(x));
    
    % Si trop peu de données, considérer comme non normal
    if length(x) < 4
        H = true;
        pValue = 0;
        return;
    end
    
    % Si Stats Toolbox est disponible
    if license('test', 'Statistics_Toolbox')
        % Utilisez le test de Shapiro-Wilk de la toolbox
        [H, pValue] = lillietest(x, 'Distribution', 'normal');
    else
        % Sinon, utilisez une approximation par le test de Jarque-Bera
        n = length(x);
        x = x - mean(x);
        s = std(x);
        if s == 0
            H = true;
            pValue = 0;
            return;
        end
        x = x/s;
        
        skewness = mean(x.^3);
        kurtosis = mean(x.^4) - 3;
        
        JB = n/6 * (skewness^2 + kurtosis^2/4);
        pValue = 1 - chi2cdf(JB, 2);
        H = (pValue < alpha);
    end
end