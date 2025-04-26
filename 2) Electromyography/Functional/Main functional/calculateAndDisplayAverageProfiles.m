function calculateAndDisplayAverageProfiles(time_normalized, emg_all_subjects_R, emg_all_subjects_L, muscles_R, muscles_L, functional_labels, selected_functional, nb_subjects, nb_muscles)
    % Liste des sujets disponibles
    subject_ids = 1:nb_subjects;

    % Affichage du titre et des options
    fprintf('\n===== Création de graphiques moyens avec sélection indépendante des sujets =====\n');
    fprintf('1. Sélectionner des sujets côté droit uniquement\n');
    fprintf('2. Sélectionner des sujets côté gauche uniquement\n');
    fprintf('3. Sélectionner des sujets pour les deux côtés (même sélection)\n');
    fprintf('4. Sélectionner des sujets indépendamment pour chaque côté\n');
    fprintf('5. Sélectionner des sujets indépendamment pour chaque côté et afficher une moyenne combinée\n');
    choice = input('Choisissez une option pour les profils moyens (1-5) : ');

    % Initialisation des variables
    selected_subjects_R = [];
    selected_subjects_L = [];
    display_right = false;
    display_left = false;
    display_combined = false;

    % Niveau de confiance pour les intervalles
    confidence_level = 0.95;

    % Traitement selon le choix
    switch choice
        case 1 % Côté droit uniquement
            disp('Liste des sujets disponibles pour le côté DROIT :');
            disp(subject_ids);
            selected_subjects_R = input('Entrez les numéros des sujets à inclure (ex: [1 3 5 7]) : ');
            display_right = true;

        case 2 % Côté gauche uniquement
            disp('Liste des sujets disponibles pour le côté GAUCHE :');
            disp(subject_ids);
            selected_subjects_L = input('Entrez les numéros des sujets à inclure (ex: [1 3 5 7]) : ');
            display_left = true;

        case 3 % Même sélection pour les deux côtés
            disp('Liste des sujets disponibles (pour les deux côtés) :');
            disp(subject_ids);
            selected_subjects = input('Entrez les numéros des sujets à inclure (ex: [1 3 5 7]) : ');
            selected_subjects_R = selected_subjects;
            selected_subjects_L = selected_subjects;
            display_right = true;
            display_left = true;

        case 4 % Sélection indépendante pour chaque côté
            disp('Liste des sujets disponibles pour le côté DROIT :');
            disp(subject_ids);
            selected_subjects_R = input('Entrez les numéros des sujets pour le côté DROIT (ex: [1 3 5 7]) ou [] pour aucun : ');

            disp('Liste des sujets disponibles pour le côté GAUCHE :');
            disp(subject_ids);
            selected_subjects_L = input('Entrez les numéros des sujets pour le côté GAUCHE (ex: [2 4 6 8]) ou [] pour aucun : ');

            display_right = ~isempty(selected_subjects_R);
            display_left = ~isempty(selected_subjects_L);
            
        case 5 % Sélection indépendante et affichage combiné
            disp('Liste des sujets disponibles pour le côté DROIT :');
            disp(subject_ids);
            selected_subjects_R = input('Entrez les numéros des sujets pour le côté DROIT (ex: [1 3 5 7]) ou [] pour aucun : ');

            disp('Liste des sujets disponibles pour le côté GAUCHE :');
            disp(subject_ids);
            selected_subjects_L = input('Entrez les numéros des sujets pour le côté GAUCHE (ex: [2 4 6 8]) ou [] pour aucun : ');

            display_right = false;
            display_left = false;
            display_combined = true;

        otherwise
            error('Option non valide. Veuillez choisir entre 1 et 5.');
    end

    % Calcul des statistiques pour le côté droit si nécessaire
    if display_right || display_combined
        % Vérification que les indices sont valides
        if any(selected_subjects_R > nb_subjects) || any(selected_subjects_R < 1)
            error('Indices des sujets hors limites pour le côté droit.');
        end

        % Extraction des données pour les sujets sélectionnés
        emg_selected_R = emg_all_subjects_R(selected_subjects_R, :, :);
        n_selected_R = length(selected_subjects_R);

        % Calcul des moyennes et écart-types - Gestion explicite des dimensions
        emg_mean_R = squeeze(mean(emg_selected_R, 1, 'omitnan'));
        emg_std_R = squeeze(std(emg_selected_R, 0, 1, 'omitnan'));

        % Vérifier et corriger les dimensions si nécessaire
        if size(emg_mean_R, 1) == 1 && nb_muscles > 1
            % Si une seule dimension temporelle après squeeze, transposer
            emg_mean_R = emg_mean_R';
            emg_std_R = emg_std_R';
        end

        % Calcul des intervalles de confiance
        emg_sem_R = emg_std_R / sqrt(n_selected_R);
        t_critical_R = tinv((1 + confidence_level) / 2, n_selected_R - 1);
        emg_ci_lower_R = emg_mean_R - t_critical_R * emg_sem_R;
        emg_ci_upper_R = emg_mean_R + t_critical_R * emg_sem_R;
    end

    % Calcul des statistiques pour le côté gauche si nécessaire
    if display_left || display_combined
        % Vérification que les indices sont valides
        if any(selected_subjects_L > nb_subjects) || any(selected_subjects_L < 1)
            error('Indices des sujets hors limites pour le côté gauche.');
        end

        % Extraction des données pour les sujets sélectionnés
        emg_selected_L = emg_all_subjects_L(selected_subjects_L, :, :);
        n_selected_L = length(selected_subjects_L);

        % Calcul des moyennes et écart-types - Gestion explicite des dimensions
        emg_mean_L = squeeze(mean(emg_selected_L, 1, 'omitnan'));
        emg_std_L = squeeze(std(emg_selected_L, 0, 1, 'omitnan'));

        % Vérifier et corriger les dimensions si nécessaire
        if size(emg_mean_L, 1) == 1 && nb_muscles > 1
            % Si une seule dimension temporelle après squeeze, transposer
            emg_mean_L = emg_mean_L';
            emg_std_L = emg_std_L';
        end

        % Calcul des intervalles de confiance
        emg_sem_L = emg_std_L / sqrt(n_selected_L);
        t_critical_L = tinv((1 + confidence_level) / 2, n_selected_L - 1);
        emg_ci_lower_L = emg_mean_L - t_critical_L * emg_sem_L;
        emg_ci_upper_L = emg_mean_L + t_critical_L * emg_sem_L;
    end
    
    % Pour l'option 5: combiner les données des deux côtés
    if display_combined
        % Calculer le nombre total d'observations combinées
        n_combined = n_selected_R + n_selected_L;
        
        % Initialiser les structures pour les données combinées
        emg_mean_combined = zeros(size(emg_mean_R));
        emg_std_combined = zeros(size(emg_std_R));
        
        % Calculer la moyenne pondérée des moyennes
        for m = 1:nb_muscles
            % Extraire les données selon les dimensions
            if size(emg_mean_R, 1) == nb_muscles && size(emg_mean_L, 1) == nb_muscles
                % Si les données sont organisées avec les muscles en lignes
                emg_mean_combined(m, :) = (n_selected_R * emg_mean_R(m, :) + n_selected_L * emg_mean_L(m, :)) / n_combined;
                
                % Calculer l'écart-type combiné (formule de combinaison des variances)
                % Formule: s_combined^2 = ((n1-1)*s1^2 + (n2-1)*s2^2 + n1*(μ1-μ_combined)^2 + n2*(μ2-μ_combined)^2) / (n1+n2-1)
                var_R = emg_std_R(m, :).^2;
                var_L = emg_std_L(m, :).^2;
                mean_diff_R = emg_mean_R(m, :) - emg_mean_combined(m, :);
                mean_diff_L = emg_mean_L(m, :) - emg_mean_combined(m, :);
                
                combined_var = ((n_selected_R-1) * var_R + (n_selected_L-1) * var_L + ...
                               n_selected_R * mean_diff_R.^2 + n_selected_L * mean_diff_L.^2) / ...
                               (n_combined - 1);
                
                emg_std_combined(m, :) = sqrt(combined_var);
            else
                % Si les dimensions sont inversées
                emg_mean_combined(:, m) = (n_selected_R * emg_mean_R(:, m) + n_selected_L * emg_mean_L(:, m)) / n_combined;
                
                var_R = emg_std_R(:, m).^2;
                var_L = emg_std_L(:, m).^2;
                mean_diff_R = emg_mean_R(:, m) - emg_mean_combined(:, m);
                mean_diff_L = emg_mean_L(:, m) - emg_mean_combined(:, m);
                
                combined_var = ((n_selected_R-1) * var_R + (n_selected_L-1) * var_L + ...
                               n_selected_R * mean_diff_R.^2 + n_selected_L * mean_diff_L.^2) / ...
                               (n_combined - 1);
                
                emg_std_combined(:, m) = sqrt(combined_var);
            end
        end
        
        % Calcul des SEM et intervalles de confiance pour les données combinées
        emg_sem_combined = emg_std_combined / sqrt(n_combined);
        t_critical_combined = tinv((1 + confidence_level) / 2, n_combined - 1);
        emg_ci_lower_combined = emg_mean_combined - t_critical_combined * emg_sem_combined;
        emg_ci_upper_combined = emg_mean_combined + t_critical_combined * emg_sem_combined;
    end

    % Création de la figure pour affichage
    figure('Name', ['Average EMG Profiles - ' functional_labels{selected_functional}], 'Color', 'white', 'Position', [100, 100, 1200, 800]);

    % Préparation du titre global avec les informations des sujets
    title_str = [functional_labels{selected_functional} ' - Average EMG Profiles'];
    if display_combined
        title_str = [title_str, ' (Combined: Right n=', num2str(length(selected_subjects_R)), ...
                    ', Left n=', num2str(length(selected_subjects_L)), ', Total n=', num2str(n_combined), ')'];
    elseif display_right && display_left
        title_str = [title_str, ' (Right n=', num2str(length(selected_subjects_R)), ', Left n=', num2str(length(selected_subjects_L)), ')'];
    elseif display_right
        title_str = [title_str, ' (Right n=', num2str(length(selected_subjects_R)), ')'];
    elseif display_left
        title_str = [title_str, ' (Left n=', num2str(length(selected_subjects_L)), ')'];
    end

    % Création des sous-graphiques pour chaque muscle
    for m = 1:nb_muscles
        subplot(ceil(nb_muscles/2), 2, m);
        hold on;

        % Vérification et préparation du vecteur temps
        if size(time_normalized, 1) > 1 && size(time_normalized, 2) == 1
            % Si time_normalized est une colonne, le transposer
            time_vector = time_normalized';
        else
            time_vector = time_normalized;
        end

        % Tracé pour le côté droit si sélectionné
        if display_right
            % Extraire correctement les données selon les dimensions
            if size(emg_mean_R, 1) == nb_muscles
                mean_data_R = emg_mean_R(m, :);
                ci_upper_R = emg_ci_upper_R(m, :);
                ci_lower_R = emg_ci_lower_R(m, :);
            else
                % Si les dimensions sont inversées (par exemple après un squeeze avec un seul muscle)
                mean_data_R = emg_mean_R(:, m)';
                ci_upper_R = emg_ci_upper_R(:, m)';
                ci_lower_R = emg_ci_lower_R(:, m)';
            end

            % Vérification des dimensions pour le tracé
            if length(time_vector) ~= length(mean_data_R)
                error(['Dimensions incompatibles pour le tracé: time_vector length = ', ...
                       num2str(length(time_vector)), ', mean_data_R length = ', ...
                       num2str(length(mean_data_R))]);
            end

           % Tracé de la ligne moyenne
           plot(time_vector, mean_data_R, 'b-', 'LineWidth', 2);

           % Tracé de l'écart-type avec fill
           if size(emg_std_R, 1) == nb_muscles
              % Si la structure est telle que chaque ligne est un muscle
              std_upper_R = mean_data_R + emg_std_R(m, :);
              std_lower_R = mean_data_R - emg_std_R(m, :);
           else
              % Si les dimensions sont inversées après squeeze
              std_upper_R = mean_data_R + emg_std_R(:, m)';
              std_lower_R = mean_data_R - emg_std_R(:, m)';
           end
           h_fill_R = fill([time_vector, fliplr(time_vector)], ...
                           [std_upper_R, fliplr(std_lower_R)], ...
                           [0.7 0.7 1], 'EdgeColor', 'none', 'FaceAlpha', 0.3);

          % Tracé de l'IC95 en pointillé noir
          plot(time_vector, ci_upper_R, 'k--', 'LineWidth', 1);
          plot(time_vector, ci_lower_R, 'k--', 'LineWidth', 1);
       end

        % Tracé pour le côté gauche si sélectionné
        if display_left
            % Extraire correctement les données selon les dimensions
            if size(emg_mean_L, 1) == nb_muscles
                mean_data_L = emg_mean_L(m, :);
                ci_upper_L = emg_ci_upper_L(m, :);
                ci_lower_L = emg_ci_lower_L(m, :);
            else
                % Si les dimensions sont inversées
                mean_data_L = emg_mean_L(:, m)';
                ci_upper_L = emg_ci_upper_L(:, m)';
                ci_lower_L = emg_ci_lower_L(:, m)';
            end

            % Vérification des dimensions pour le tracé
            if length(time_vector) ~= length(mean_data_L)
                error(['Dimensions incompatibles pour le tracé: time_vector length = ', ...
                       num2str(length(time_vector)), ', mean_data_L length = ', ...
                       num2str(length(mean_data_L))]);
            end

            % Tracé de la ligne moyenne
            plot(time_vector, mean_data_L, 'r-', 'LineWidth', 2);

            % Tracé de l'écart-type avec fill
            if size(emg_std_L, 1) == nb_muscles
               std_upper_L = mean_data_L + emg_std_L(m, :);
               std_lower_L = mean_data_L - emg_std_L(m, :);
            else
               std_upper_L = mean_data_L + emg_std_L(:, m)';
               std_lower_L = mean_data_L - emg_std_L(:, m)';
            end
            h_fill_L = fill([time_vector, fliplr(time_vector)], ...
                            [std_upper_L, fliplr(std_lower_L)], ...
                            [1 0.7 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.3);

            % Tracé de l'IC95 en pointillé noir
            plot(time_vector, ci_upper_L, 'k--', 'LineWidth', 1);
            plot(time_vector, ci_lower_L, 'k--', 'LineWidth', 1);
        end
        
        % Tracé pour les données combinées
        if display_combined
            % Extraire correctement les données selon les dimensions
            if size(emg_mean_combined, 1) == nb_muscles
                mean_data_combined = emg_mean_combined(m, :);
                ci_upper_combined = emg_ci_upper_combined(m, :);
                ci_lower_combined = emg_ci_lower_combined(m, :);
            else
                % Si les dimensions sont inversées
                mean_data_combined = emg_mean_combined(:, m)';
                ci_upper_combined = emg_ci_upper_combined(:, m)';
                ci_lower_combined = emg_ci_lower_combined(:, m)';
            end
            
            % Vérification des dimensions pour le tracé
            if length(time_vector) ~= length(mean_data_combined)
                error(['Dimensions incompatibles pour le tracé: time_vector length = ', ...
                       num2str(length(time_vector)), ', mean_data_combined length = ', ...
                       num2str(length(mean_data_combined))]);
            end
            
            % Tracé de la ligne moyenne
            plot(time_vector, mean_data_combined, 'g-', 'LineWidth', 2);
            
            % Tracé de l'écart-type avec fill
            if size(emg_std_combined, 1) == nb_muscles
                std_upper_combined = mean_data_combined + emg_std_combined(m, :);
                std_lower_combined = mean_data_combined - emg_std_combined(m, :);
            else
                std_upper_combined = mean_data_combined + emg_std_combined(:, m)';
                std_lower_combined = mean_data_combined - emg_std_combined(:, m)';
            end
            h_fill_combined = fill([time_vector, fliplr(time_vector)], ...
                                  [std_upper_combined, fliplr(std_lower_combined)], ...
                                  [0.7 1 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
            
            % Tracé de l'IC95 en pointillé noir
            plot(time_vector, ci_upper_combined, 'k--', 'LineWidth', 1);
            plot(time_vector, ci_lower_combined, 'k--', 'LineWidth', 1);
        end

        % Définition du titre du sous-graphique
        if display_combined
            if isequal(muscles_R{m}, muscles_L{m})
                subplot_title = [muscles_R{m} ' (Combined)'];
            else
                subplot_title = [muscles_R{m} ' / ' muscles_L{m} ' (Combined)'];
            end
        elseif display_right && display_left
            if isequal(muscles_R{m}, muscles_L{m})
                subplot_title = muscles_R{m};
            else
                subplot_title = [muscles_R{m} ' (R) / ' muscles_L{m} ' (L)'];
            end
        elseif display_right
            subplot_title = [muscles_R{m} ' (Right)'];
        elseif display_left
            subplot_title = [muscles_L{m} ' (Left)'];
        end
        title(subplot_title, 'FontWeight', 'bold');

        % Axes et grille
        xlabel('Normalized Time (%)');
        ylabel('Normalized EMG');
        xlim([min(time_vector), max(time_vector)]);

        % Calcul des limites d'axe y
        y_max = 0;
        if display_right
            y_max = max(y_max, max(ci_upper_R));
        end
        if display_left
            y_max = max(y_max, max(ci_upper_L));
        end
        if display_combined
            y_max = max(y_max, max(ci_upper_combined));
        end
        ylim([0, y_max * 1.1]);

        grid on;

        % Légende adaptative
        legend_entries = {};
        legend_handles = [];
        
        if display_right
            % Obtenir les handles
            h_line_R = findobj(gca, 'Color', 'b', 'Type', 'line');
            h_ci_line_R = findobj(gca, 'Color', 'k', 'LineStyle', '--', 'Type', 'line');
            if ~isempty(h_line_R)
                legend_entries = [legend_entries, {'Right Side', 'Right SD', 'Right CI95'}];
                legend_handles = [legend_handles, h_line_R(1), h_fill_R, h_ci_line_R(1)];
            end
        end
        
        if display_left
            % Obtenir les handles
            h_line_L = findobj(gca, 'Color', 'r', 'Type', 'line');
            h_ci_line_L = findobj(gca, 'Color', 'k', 'LineStyle', '--', 'Type', 'line');
            if ~isempty(h_line_L)
                legend_entries = [legend_entries, {'Left Side', 'Left SD', 'Left CI95'}];
                legend_handles = [legend_handles, h_line_L(1), h_fill_L, h_ci_line_L(end)];
            end
        end
        
        if display_combined
            % Obtenir les handles
            h_line_combined = findobj(gca, 'Color', 'g', 'Type', 'line');
            h_ci_line_combined = findobj(gca, 'Color', 'k', 'LineStyle', '--', 'Type', 'line');
            if ~isempty(h_line_combined)
                legend_entries = [legend_entries, {'Combined', 'Combined SD', 'Combined CI95'}];
                legend_handles = [legend_handles, h_line_combined(1), h_fill_combined, h_ci_line_combined(1)];
            end
        end
        
        if ~isempty(legend_handles)
            legend(legend_handles, legend_entries, 'Location', 'best');
        end
    end

    % Ajout du titre global
    sgtitle(title_str, 'FontWeight', 'bold', 'FontSize', 14);

    % Ajustement de la mise en page
    set(gcf, 'Color', 'white');
    set(findall(gcf, '-property', 'FontSize'), 'FontSize', 11);

    % Affichage des informations sur les sujets sélectionnés
    fprintf('\n===== Sujets sélectionnés =====\n');
    if display_right || (display_combined && ~isempty(selected_subjects_R))
        fprintf('Côté DROIT : %s (n=%d)\n', mat2str(selected_subjects_R), length(selected_subjects_R));
    end
    if display_left || (display_combined && ~isempty(selected_subjects_L))
        fprintf('Côté GAUCHE : %s (n=%d)\n', mat2str(selected_subjects_L), length(selected_subjects_L));
    end
    if display_combined
        fprintf('COMBINÉ : Total (n=%d)\n', n_combined);
    end
end