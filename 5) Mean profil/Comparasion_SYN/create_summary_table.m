function create_summary_table(p_values, muscle_names, anova_results, test_types)
    fprintf('\n=== TABLEAU RÉCAPITULATIF COMPLET ===\n');
    
    % En-tête du tableau
    fprintf('\n%s\n', repmat('=', 1, 120));
    fprintf('%-15s | %-12s | %-25s | %-25s | %-25s |\n', ...
        'MUSCLE', 'ANOVA', 'ASYMP vs POST', 'ASYMP vs PRE', 'PRE vs POST');
    fprintf('%-15s | %-12s | %-25s | %-25s | %-25s |\n', ...
        '', 'F(p-val)', 'Test(p-val)', 'Test(p-val)', 'Test(p-val)');
    fprintf('%s\n', repmat('=', 1, 120));
    
    fprintf('\n--- SYNERGIE 1 ---\n');
    for i = 1:6
        % Formatage ANOVA
        anova_str = sprintf('%.2f(%.3f%s)', ...
            anova_results.syn1_F(i), ...
            anova_results.syn1_p(i), ...
            ternary(anova_results.syn1_p(i) < 0.05, '*', ''));
        
        % Formatage tests post-hoc
        asymp_post_str = sprintf('%s(%.3f%s)', ...
            test_types.syn1_asymp_post(i), ...
            p_values.syn1_asymp_post(i), ...
            ternary(p_values.syn1_asymp_post(i) < 0.05, '*', ''));
        
        asymp_pre_str = sprintf('%s(%.3f%s)', ...
            test_types.syn1_asymp_pre(i), ...
            p_values.syn1_asymp_pre(i), ...
            ternary(p_values.syn1_asymp_pre(i) < 0.05, '*', ''));
        
        pre_post_str = sprintf('%s(%.3f%s)', ...
            test_types.syn1_pre_post(i), ...
            p_values.syn1_pre_post(i), ...
            ternary(p_values.syn1_pre_post(i) < 0.05, '*', ''));
        
        fprintf('%-15s | %-12s | %-25s | %-25s | %-25s |\n', ...
            muscle_names{i}, anova_str, asymp_post_str, asymp_pre_str, pre_post_str);
    end
    
    fprintf('%s\n', repmat('-', 1, 120));
    
    fprintf('\n--- SYNERGIE 2 ---\n');
    for i = 1:6
        % Formatage ANOVA
        anova_str = sprintf('%.2f(%.3f%s)', ...
            anova_results.syn2_F(i), ...
            anova_results.syn2_p(i), ...
            ternary(anova_results.syn2_p(i) < 0.05, '*', ''));
        
        % Formatage tests post-hoc
        asymp_post_str = sprintf('%s(%.3f%s)', ...
            test_types.syn2_asymp_post(i), ...
            p_values.syn2_asymp_post(i), ...
            ternary(p_values.syn2_asymp_post(i) < 0.05, '*', ''));
        
        asymp_pre_str = sprintf('%s(%.3f%s)', ...
            test_types.syn2_asymp_pre(i), ...
            p_values.syn2_asymp_pre(i), ...
            ternary(p_values.syn2_asymp_pre(i) < 0.05, '*', ''));
        
        pre_post_str = sprintf('%s(%.3f%s)', ...
            test_types.syn2_pre_post(i), ...
            p_values.syn2_pre_post(i), ...
            ternary(p_values.syn2_pre_post(i) < 0.05, '*', ''));
        
        fprintf('%-15s | %-12s | %-25s | %-25s | %-25s |\n', ...
            muscle_names{i}, anova_str, asymp_post_str, asymp_pre_str, pre_post_str);
    end
    
    fprintf('%s\n', repmat('=', 1, 120));
    fprintf('\nLégende: * = significatif (p < 0.05)\n');
    fprintf('Tests: t-test = Student, Welch = Welch, Mann-Whitney = non-paramétrique\n');
    
    % Résumé des résultats significatifs
    fprintf('\n=== RÉSUMÉ DES DIFFÉRENCES SIGNIFICATIVES ===\n');
    
    % Comptage des différences significatives
    sig_count = struct();
    sig_count.syn1_anova = sum(anova_results.syn1_p < 0.05);
    sig_count.syn2_anova = sum(anova_results.syn2_p < 0.05);
    sig_count.syn1_asymp_post = sum(p_values.syn1_asymp_post < 0.05);
    sig_count.syn1_asymp_pre = sum(p_values.syn1_asymp_pre < 0.05);
    sig_count.syn1_pre_post = sum(p_values.syn1_pre_post < 0.05);
    sig_count.syn2_asymp_post = sum(p_values.syn2_asymp_post < 0.05);
    sig_count.syn2_asymp_pre = sum(p_values.syn2_asymp_pre < 0.05);
    sig_count.syn2_pre_post = sum(p_values.syn2_pre_post < 0.05);
    
    fprintf('Synergie 1:\n');
    fprintf('  - ANOVA significatives: %d/6 muscles\n', sig_count.syn1_anova);
    fprintf('  - Asymp vs Post: %d/6 muscles\n', sig_count.syn1_asymp_post);
    fprintf('  - Asymp vs Pre: %d/6 muscles\n', sig_count.syn1_asymp_pre);
    fprintf('  - Pre vs Post: %d/6 muscles\n', sig_count.syn1_pre_post);
    
    fprintf('Synergie 2:\n');
    fprintf('  - ANOVA significatives: %d/6 muscles\n', sig_count.syn2_anova);
    fprintf('  - Asymp vs Post: %d/6 muscles\n', sig_count.syn2_asymp_post);
    fprintf('  - Asymp vs Pre: %d/6 muscles\n', sig_count.syn2_asymp_pre);
    fprintf('  - Pre vs Post: %d/6 muscles\n', sig_count.syn2_pre_post);
end