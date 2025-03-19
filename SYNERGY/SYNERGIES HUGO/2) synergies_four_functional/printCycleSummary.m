function printCycleSummary(functional_labels, num_available_cycles_per_functional, total_cycles)
% Afficher un récapitulatif des cycles détectés
    fprintf('\nRécapitulatif des cycles détectés:\n');
    fprintf('-----------------------------\n');
    for functional_idx = 1:length(functional_labels)
        fprintf('Mouvement %d - %s: %d cycles\n', ...
            functional_idx, functional_labels{functional_idx}, num_available_cycles_per_functional(functional_idx));
    end
    fprintf('Total: %d cycles\n', total_cycles);
end