function plotCycleSequence(subjects, selected_functional, all_functional_data, params)
    % Visualisation de l'enchaînement des cycles pour tous les muscles
    subject_idx = 1;
    functional_idx = selected_functional;

    % Déterminer le nombre de cycles disponibles
    num_available_cycles = 0;
    for cycle = 1:params.num_cycles
        if ~isempty(all_functional_data{subject_idx, functional_idx, 1, cycle})
            num_available_cycles = num_available_cycles + 1;
        end
    end

    % Création de la figure
    figure;
    sgtitle(sprintf('Sujet %s - %s - Enchaînement des %d cycles', ...
        subjects{1}, params.functional_labels{selected_functional}, num_available_cycles));

    for m = 1:params.nb_muscles
        subplot(ceil(params.nb_muscles/2), 2, m);
        hold on;

        % Concaténer les données des cycles valides
        all_cycles_data = [];
        for cycle = 1:params.num_cycles
            cycle_data = all_functional_data{subject_idx, functional_idx, m, cycle};
            if ~isempty(cycle_data)
                % Ajouter une ligne verticale pour séparer les cycles (sauf avant le premier)
                if ~isempty(all_cycles_data)
                    % Ajouter une ligne verticale à la fin du dernier cycle
                    line([length(all_cycles_data)/params.num_points length(all_cycles_data)/params.num_points], ...
                        [0 max(cycle_data)*1.1], 'Color', 'k', 'LineStyle', '--');
                end

                % Concaténer les données
                all_cycles_data = [all_cycles_data, cycle_data];
            end
        end

        % Créer un vecteur de temps pour l'enchaînement des cycles
        time_concatenated = linspace(0, length(all_cycles_data)/params.num_points, length(all_cycles_data));

        % Tracer l'enchaînement des cycles
        plot(time_concatenated, all_cycles_data, 'LineWidth', 1.5);

        % Ajouter des annotations pour les cycles
        for cycle = 1:num_available_cycles
            cycle_start = (cycle-1);
            text(cycle_start + 0.5, max(all_cycles_data)*0.9, sprintf('Cycle %d', cycle), 'FontWeight', 'bold');
        end

        title(params.muscles{m});
        ylabel('% MVC (Submaximal task)');
        xlabel('Cycles');
        grid on;
    end
end
