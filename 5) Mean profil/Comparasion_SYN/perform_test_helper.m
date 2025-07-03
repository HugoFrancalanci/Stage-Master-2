function [p_val, test_type] = perform_test_helper(data1, data2, muscle_name, comparison_name)
    % Test de normalité simplifié
    if exist('swtest', 'file')
        try
            p_sw1 = swtest(data1, 0.05);
            p_sw2 = swtest(data2, 0.05);
        catch
            % Si swtest échoue, utiliser le test de Lilliefors ou assumer non-normal
            p_sw1 = 0.01;
            p_sw2 = 0.01;
        end
    else
        % Si swtest n'existe pas, assumer non-normal par défaut
        p_sw1 = 0.01;
        p_sw2 = 0.01;
    end
    
    normal1 = all(~isnan(data1)) && (length(data1) > 3) && (p_sw1 > 0.05);
    normal2 = all(~isnan(data2)) && (length(data2) > 3) && (p_sw2 > 0.05);
    
    if normal1 && normal2
        [~, p_var] = vartest2(data1, data2);
        if p_var >= 0.05
            [~, p_val] = ttest2(data1, data2);
            test_type = "t-test";
        else
            [~, p_val] = ttest2(data1, data2, 'Vartype', 'unequal');
            test_type = "Welch";
        end
    else
        p_val = ranksum(data1, data2);
        test_type = "Mann-Whitney";
    end
end