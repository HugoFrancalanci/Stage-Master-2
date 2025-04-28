function [saved_data] = calculateAndDisplayAverageFunctionalProfile(time_normalized, all_functional_data_R, all_functional_data_L, muscles_R, muscles_L, nb_subjects, nb_muscles)
    % Cette fonction calcule et affiche un profil EMG moyen combinant tous les mouvements fonctionnels en une seule ligne
    % 
    % Paramètres:
    %   time_normalized - Vecteur de temps normalisé
    %   all_functional_data_R - Structure contenant les données EMG pour les 4 mouvements (côté droit)
    %   all_functional_data_L - Structure contenant les données EMG pour les 4 mouvements (côté gauche)
    %   muscles_R - Cellule contenant les noms des muscles côté droit
    %   muscles_L - Cellule contenant les noms des muscles côté gauche
    %   nb_subjects - Nombre de sujets
    %   nb_muscles - Nombre de muscles
    %
    % Sortie:
    %   saved_data - Structure contenant les données finales du graphique
    
    % Initialisation de la structure pour sauvegarder les données
    saved_data = struct();
    saved_data.time = time_normalized;
    saved_data.muscles_R = muscles_R;
    saved_data.muscles_L = muscles_L;
    
    % Affichage du titre et des options
    fprintf('\n===== Création du graphique de la moyenne globale des mouvements =====\n');
    fprintf('1. Sélectionner des sujets côté droit uniquement\n');
    fprintf('2. Sélectionner des sujets côté gauche uniquement\n');
    fprintf('3. Sélectionner des sujets pour les deux côtés (même sélection)\n');
    fprintf('4. Sélectionner des sujets indépendamment pour chaque côté\n');
    fprintf('5. Sélectionner des sujets indépendamment pour chaque côté et afficher une moyenne combinée\n');
    choice = input('Choisissez une option pour les profils moyens (1-5) : ');

    % Liste des sujets disponibles
    subject_ids = 1:nb_subjects;

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
    
    % Ajout des sujets sélectionnés à la structure de sortie
    saved_data.selected_subjects_R = selected_subjects_R;
    saved_data.selected_subjects_L = selected_subjects_L;
    saved_data.display_option = choice;
    
    % Vérification de la validité des indices des sujets
    if display_right || display_combined
        if any(selected_subjects_R > nb_subjects) || any(selected_subjects_R < 1)
            error('Indices des sujets hors limites pour le côté droit.');
        end
        n_selected_R = length(selected_subjects_R);
    end
    
    if display_left || display_combined
        if any(selected_subjects_L > nb_subjects) || any(selected_subjects_L < 1)
            error('Indices des sujets hors limites pour le côté gauche.');
        end
        n_selected_L = length(selected_subjects_L);
    end
    
    % Nombre de mouvements fonctionnels
    nb_functionals = length(all_functional_data_R);
    
    % Calcul de la moyenne des données de tous les mouvements fonctionnels
    % Pour le côté droit
    if display_right || display_combined
        all_emg_right = zeros(n_selected_R, size(time_normalized, 2), nb_muscles, nb_functionals);
        
        for func_idx = 1:nb_functionals
            % Extraction des données EMG pour ce mouvement fonctionnel
            emg_data = all_functional_data_R{func_idx};
            
            % Extraction des données pour les sujets sélectionnés
            all_emg_right(:, :, :, func_idx) = emg_data(selected_subjects_R, :, :);
        end
        
        % Calcul de la moyenne sur tous les mouvements fonctionnels
        mean_emg_right = mean(all_emg_right, 4, 'omitnan');
        
        % Calcul des moyennes et écart-types pour tous les sujets
        emg_mean_right = squeeze(mean(mean_emg_right, 1, 'omitnan'));
        emg_std_right = squeeze(std(mean_emg_right, 0, 1, 'omitnan'));
        
        % Vérifier et corriger les dimensions si nécessaire
        if size(emg_mean_right, 1) == 1 && nb_muscles > 1
            emg_mean_right = emg_mean_right';
            emg_std_right = emg_std_right';
        end
        
        % Calcul des intervalles de confiance
        emg_sem_right = emg_std_right / sqrt(n_selected_R);
        t_critical = tinv((1 + confidence_level) / 2, n_selected_R - 1);
        emg_ci_lower_right = emg_mean_right - t_critical * emg_sem_right;
        emg_ci_upper_right = emg_mean_right + t_critical * emg_sem_right;
        
        % Sauvegarde des données dans la structure de sortie
        saved_data.right.mean = emg_mean_right;
        saved_data.right.std = emg_std_right;
        saved_data.right.sem = emg_sem_right;
        saved_data.right.ci_lower = emg_ci_lower_right;
        saved_data.right.ci_upper = emg_ci_upper_right;
        saved_data.right.n = n_selected_R;
    end
    
    % Pour le côté gauche
    if display_left || display_combined
        all_emg_left = zeros(n_selected_L, size(time_normalized, 2), nb_muscles, nb_functionals);
        
        for func_idx = 1:nb_functionals
            % Extraction des données EMG pour ce mouvement fonctionnel
            emg_data = all_functional_data_L{func_idx};
            
            % Extraction des données pour les sujets sélectionnés
            all_emg_left(:, :, :, func_idx) = emg_data(selected_subjects_L, :, :);
        end
        
        % Calcul de la moyenne sur tous les mouvements fonctionnels
        mean_emg_left = mean(all_emg_left, 4, 'omitnan');
        
        % Calcul des moyennes et écart-types pour tous les sujets
        emg_mean_left = squeeze(mean(mean_emg_left, 1, 'omitnan'));
        emg_std_left = squeeze(std(mean_emg_left, 0, 1, 'omitnan'));
        
        % Vérifier et corriger les dimensions si nécessaire
        if size(emg_mean_left, 1) == 1 && nb_muscles > 1
            emg_mean_left = emg_mean_left';
            emg_std_left = emg_std_left';
        end
        
        % Calcul des intervalles de confiance
        emg_sem_left = emg_std_left / sqrt(n_selected_L);
        t_critical = tinv((1 + confidence_level) / 2, n_selected_L - 1);
        emg_ci_lower_left = emg_mean_left - t_critical * emg_sem_left;
        emg_ci_upper_left = emg_mean_left + t_critical * emg_sem_left;
        
        % Sauvegarde des données dans la structure de sortie
        saved_data.left.mean = emg_mean_left;
        saved_data.left.std = emg_std_left;
        saved_data.left.sem = emg_sem_left;
        saved_data.left.ci_lower = emg_ci_lower_left;
        saved_data.left.ci_upper = emg_ci_upper_left;
        saved_data.left.n = n_selected_L;
    end
    
    % Pour les données combinées (option 5)
    if display_combined
        n_combined = n_selected_R + n_selected_L;
        
        % Moyenne pondérée des moyennes
        emg_mean_combined = zeros(size(emg_mean_right));
        emg_std_combined = zeros(size(emg_std_right));
        
        % Calculer la moyenne pondérée des moyennes
        for m = 1:nb_muscles
            % Extraire les données selon les dimensions
            if size(emg_mean_right, 1) == nb_muscles && size(emg_mean_left, 1) == nb_muscles
                % Si les données sont organisées avec les muscles en lignes
                emg_mean_combined(m, :) = (n_selected_R * emg_mean_right(m, :) + n_selected_L * emg_mean_left(m, :)) / n_combined;
                
                % Calculer l'écart-type combiné (formule de combinaison des variances)
                var_R = emg_std_right(m, :).^2;
                var_L = emg_std_left(m, :).^2;
                mean_diff_R = emg_mean_right(m, :) - emg_mean_combined(m, :);
                mean_diff_L = emg_mean_left(m, :) - emg_mean_combined(m, :);
                
                combined_var = ((n_selected_R-1) * var_R + (n_selected_L-1) * var_L + ...
                              n_selected_R * mean_diff_R.^2 + n_selected_L * mean_diff_L.^2) / ...
                              (n_combined - 1);
                
                emg_std_combined(m, :) = sqrt(combined_var);
            else
                % Si les dimensions sont inversées
                emg_mean_combined(:, m) = (n_selected_R * emg_mean_right(:, m) + n_selected_L * emg_mean_left(:, m)) / n_combined;
                
                var_R = emg_std_right(:, m).^2;
                var_L = emg_std_left(:, m).^2;
                mean_diff_R = emg_mean_right(:, m) - emg_mean_combined(:, m);
                mean_diff_L = emg_mean_left(:, m) - emg_mean_combined(:, m);
                
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
        
        % Sauvegarde des données combinées dans la structure de sortie
        saved_data.combined.mean = emg_mean_combined;
        saved_data.combined.std = emg_std_combined;
        saved_data.combined.sem = emg_sem_combined;
        saved_data.combined.ci_lower = emg_ci_lower_combined;
        saved_data.combined.ci_upper = emg_ci_upper_combined;
        saved_data.combined.n = n_combined;
    end
    
    % Création de la figure pour affichage
    figure('Name', 'Average of All Functional EMG Profiles', 'Color', 'white', 'Position', [100, 100, 1200, 800]);
    
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
        
        % Pour créer des handles pour la légende
        legend_handles = [];
        legend_labels = {};
        
        % Pour le côté droit
        if display_right
            % Extraire correctement les données selon les dimensions
            if size(emg_mean_right, 1) == nb_muscles
                mean_data = emg_mean_right(m, :);
                ci_upper = emg_ci_upper_right(m, :);
                ci_lower = emg_ci_lower_right(m, :);
                std_data = emg_std_right(m, :);
            else
                % Si les dimensions sont inversées
                mean_data = emg_mean_right(:, m)';
                ci_upper = emg_ci_upper_right(:, m)';
                ci_lower = emg_ci_lower_right(:, m)';
                std_data = emg_std_right(:, m)';
            end
            
            % Vérification des dimensions pour le tracé
            if length(time_vector) ~= length(mean_data)
                error(['Dimensions incompatibles pour le tracé: time_vector length = ', ...
                       num2str(length(time_vector)), ', mean_data length = ', ...
                       num2str(length(mean_data))]);
            end
            
            % Tracé de la ligne moyenne
            h_line_right = plot(time_vector, mean_data, 'b-', 'LineWidth', 2);
            legend_handles = [legend_handles, h_line_right];
            legend_labels{end+1} = 'Moyenne Droite';
            
            % Tracé de l'écart-type avec fill
            std_upper = mean_data + std_data;
            std_lower = mean_data - std_data;
            h_fill_right = fill([time_vector, fliplr(time_vector)], ...
                         [std_upper, fliplr(std_lower)], ...
                         'b', 'EdgeColor', 'none', 'FaceAlpha', 0.1);
            legend_handles = [legend_handles, h_fill_right];
            legend_labels{end+1} = 'ET Droite';
            
            % Tracé de l'IC95 en pointillé
            h_ci_right = plot(time_vector, ci_upper, 'b--', 'LineWidth', 0.5);
            plot(time_vector, ci_lower, 'b--', 'LineWidth', 0.5);
            legend_handles = [legend_handles, h_ci_right];
            legend_labels{end+1} = 'IC95% Droite';
        end
        
        % Pour le côté gauche
        if display_left
            % Extraire correctement les données selon les dimensions
            if size(emg_mean_left, 1) == nb_muscles
                mean_data = emg_mean_left(m, :);
                ci_upper = emg_ci_upper_left(m, :);
                ci_lower = emg_ci_lower_left(m, :);
                std_data = emg_std_left(m, :);
            else
                % Si les dimensions sont inversées
                mean_data = emg_mean_left(:, m)';
                ci_upper = emg_ci_upper_left(:, m)';
                ci_lower = emg_ci_lower_left(:, m)';
                std_data = emg_std_left(:, m)';
            end
            
            % Vérification des dimensions pour le tracé
            if length(time_vector) ~= length(mean_data)
                error(['Dimensions incompatibles pour le tracé: time_vector length = ', ...
                       num2str(length(time_vector)), ', mean_data length = ', ...
                       num2str(length(mean_data))]);
            end
            
            % Tracé de la ligne moyenne avec un style différent
            h_line_left = plot(time_vector, mean_data, 'r-', 'LineWidth', 2);
            legend_handles = [legend_handles, h_line_left];
            legend_labels{end+1} = 'Moyenne Gauche';
            
            % Tracé de l'écart-type avec fill
            std_upper = mean_data + std_data;
            std_lower = mean_data - std_data;
            h_fill_left = fill([time_vector, fliplr(time_vector)], ...
                         [std_upper, fliplr(std_lower)], ...
                         'r', 'EdgeColor', 'none', 'FaceAlpha', 0.1);
            legend_handles = [legend_handles, h_fill_left];
            legend_labels{end+1} = 'ET Gauche';
            
            % Tracé de l'IC95 en pointillé
            h_ci_left = plot(time_vector, ci_upper, 'r--', 'LineWidth', 0.5);
            plot(time_vector, ci_lower, 'r--', 'LineWidth', 0.5);
            legend_handles = [legend_handles, h_ci_left];
            legend_labels{end+1} = 'IC95% Gauche';
        end
        
        % Pour les données combinées
        if display_combined
            % Extraire correctement les données selon les dimensions
            if size(emg_mean_combined, 1) == nb_muscles
                mean_data = emg_mean_combined(m, :);
                ci_upper = emg_ci_upper_combined(m, :);
                ci_lower = emg_ci_lower_combined(m, :);
                std_data = emg_std_combined(m, :);
            else
                % Si les dimensions sont inversées
                mean_data = emg_mean_combined(:, m)';
                ci_upper = emg_ci_upper_combined(:, m)';
                ci_lower = emg_ci_lower_combined(:, m)';
                std_data = emg_std_combined(:, m)';
            end
            
            % Vérification des dimensions pour le tracé
            if length(time_vector) ~= length(mean_data)
                error(['Dimensions incompatibles pour le tracé: time_vector length = ', ...
                       num2str(length(time_vector)), ', mean_data length = ', ...
                       num2str(length(mean_data))]);
            end
            
            % Tracé de la ligne moyenne
            h_line_combined = plot(time_vector, mean_data, 'g-', 'LineWidth', 2);
            legend_handles = [legend_handles, h_line_combined];
            legend_labels{end+1} = 'Moyenne Combinée';
            
            % Tracé de l'écart-type avec fill
            std_upper = mean_data + std_data;
            std_lower = mean_data - std_data;
            h_fill_combined = fill([time_vector, fliplr(time_vector)], ...
                         [std_upper, fliplr(std_lower)], ...
                         'g', 'EdgeColor', 'none', 'FaceAlpha', 0.1);
            legend_handles = [legend_handles, h_fill_combined];
            legend_labels{end+1} = 'ET Combiné';
            
            % Tracé de l'IC95 en pointillé
            h_ci_combined = plot(time_vector, ci_upper, 'g--', 'LineWidth', 0.5);
            plot(time_vector, ci_lower, 'g--', 'LineWidth', 0.5);
            legend_handles = [legend_handles, h_ci_combined];
            legend_labels{end+1} = 'IC95% Combiné';
        end
        
        % Création de la légende avec tous les éléments
        if ~isempty(legend_handles)
            legend(legend_handles, legend_labels, 'Location', 'best', 'FontSize', 8);
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
        ylabel('Normalized EMG (% MVC)');
        xlim([min(time_vector), max(time_vector)]);
        
        % Définir les limites de l'axe y
        y_data = [];
        
        if display_right
            if size(emg_ci_upper_right, 1) == nb_muscles
                y_data = [y_data; emg_ci_upper_right(m, :)];
            else
                y_data = [y_data; emg_ci_upper_right(:, m)'];
            end
        end
        
        if display_left
            if size(emg_ci_upper_left, 1) == nb_muscles
                y_data = [y_data; emg_ci_upper_left(m, :)];
            else
                y_data = [y_data; emg_ci_upper_left(:, m)'];
            end
        end
        
        if display_combined
            if size(emg_ci_upper_combined, 1) == nb_muscles
                y_data = [y_data; emg_ci_upper_combined(m, :)];
            else
                y_data = [y_data; emg_ci_upper_combined(:, m)'];
            end
        end
        
        if ~isempty(y_data)
            y_max = max(y_data(:));
            ylim([0, y_max * 1.1]);
        end
        
        grid on;
    end
    
    % Préparation du titre global avec les informations des sujets
    title_str = 'Average of All Functional Movements - EMG Profile';
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
    
    % Ajout du titre global
    sgtitle(title_str, 'FontWeight', 'bold', 'FontSize', 14);

    % Ajustement de la mise en page
    set(gcf, 'Color', 'white');
    set(findall(gcf, '-property', 'FontSize'), 'FontSize', 11);

    % Affichage des informations sur les sujets sélectionnés
    fprintf('\n===== Sujets sélectionnés pour la moyenne globale =====\n');
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