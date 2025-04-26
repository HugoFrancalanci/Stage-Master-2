% Fonction pour visualiser toutes les données fonctionnelles
function visualizeAllFunctionalData(subjects, muscles, functional_labels, all_functional_data, num_available_cycles_per_functional, num_points)
    nb_muscles = length(muscles);
    nb_functional = length(functional_labels);
    subject_idx = 1;
    
    % Création d'une figure pour l'enchaînement des cycles de tous les mouvements fonctionnels
    figure;
    sgtitle(sprintf('Sujet %s - Enchaînement des cycles pour les 4 mouvements fonctionnels', subjects{1}));
    
    for m = 1:nb_muscles
        subplot(ceil(nb_muscles/2), 2, m);
        hold on;
        
        % Concaténer les données de tous les mouvements fonctionnels et leurs cycles
        all_movements_data = [];
        movement_boundaries = [0]; % Pour stocker où commence chaque mouvement fonctionnel
        cycle_count = 0;
        
        for functional_idx = 1:nb_functional
            functional_data = [];
            
            for cycle = 1:num_available_cycles_per_functional(functional_idx)
                cycle_data = all_functional_data{subject_idx, functional_idx, m, cycle};
                
                % Concaténer les données
                functional_data = [functional_data, cycle_data];
                cycle_count = cycle_count + 1;
            end
            
            % Ajouter une ligne verticale entre les mouvements fonctionnels
            if functional_idx < nb_functional && ~isempty(functional_data)
                all_movements_data = [all_movements_data, functional_data];
                % Stocker la position de fin de ce mouvement fonctionnel
                movement_boundaries = [movement_boundaries, length(all_movements_data)/num_points];
            elseif functional_idx == nb_functional
                all_movements_data = [all_movements_data, functional_data];
            end
        end
        
        % Créer un vecteur de temps pour l'enchaînement complet
        time_concatenated = linspace(0, length(all_movements_data)/num_points, length(all_movements_data));
        
        % Tracer l'enchaînement des cycles
        plot(time_concatenated, all_movements_data, 'LineWidth', 1.5);
        
        title(muscles{m});
        ylabel('% MVC (submaximal task)');
        xlabel('Cycles');
        grid on;
    end
end