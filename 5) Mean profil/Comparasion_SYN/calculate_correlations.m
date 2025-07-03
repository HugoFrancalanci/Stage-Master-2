function calculate_correlations(mean_syn1_asymp, mean_syn1_post, mean_syn1_pre, ...
                               mean_syn2_asymp, mean_syn2_post, mean_syn2_pre)
    fprintf('\n=== CORRÉLATIONS ENTRE PROFILS ===\n');
    
    % Synergie 1
    corr_1_asymp_post = corrcoef(mean_syn1_asymp, mean_syn1_post);
    corr_1_asymp_pre = corrcoef(mean_syn1_asymp, mean_syn1_pre);
    corr_1_pre_post = corrcoef(mean_syn1_pre, mean_syn1_post);
    
    fprintf('Synergie 1:\n');
    fprintf('  Asymp vs Post: r = %.3f\n', corr_1_asymp_post(1,2));
    fprintf('  Asymp vs Pre:  r = %.3f\n', corr_1_asymp_pre(1,2));
    fprintf('  Pre vs Post:   r = %.3f\n', corr_1_pre_post(1,2));
    
    % Synergie 2
    corr_2_asymp_post = corrcoef(mean_syn2_asymp, mean_syn2_post);
    corr_2_asymp_pre = corrcoef(mean_syn2_asymp, mean_syn2_pre);
    corr_2_pre_post = corrcoef(mean_syn2_pre, mean_syn2_post);
    
    fprintf('Synergie 2:\n');
    fprintf('  Asymp vs Post: r = %.3f\n', corr_2_asymp_post(1,2));
    fprintf('  Asymp vs Pre:  r = %.3f\n', corr_2_asymp_pre(1,2));
    fprintf('  Pre vs Post:   r = %.3f\n', corr_2_pre_post(1,2));
end