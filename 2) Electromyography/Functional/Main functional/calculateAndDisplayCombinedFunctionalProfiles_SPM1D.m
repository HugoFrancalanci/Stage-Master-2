function calculateAndDisplayCombinedFunctionalProfiles_SPM1D(time_normalized, all_functional_data_R, all_functional_data_L, muscles_R, muscles_L, functional_labels, nb_subjects, nb_muscles)
    % Calcule et affiche les profils EMG moyens en combinant les 4 mouvements fonctionnels et prépare les données à l'analyse SPM1D
    
    % Liste des sujets disponibles
    subject_ids = 1:nb_subjects;

    % Affichage du titre et des options
    fprintf('\n===== Création de graphiques combinant les mouvements fonctionnels =====\n');
    fprintf('1. Sélectionner des sujets côté droit uniquement\n');
    fprintf('2. Sélectionner des sujets côté gauche uniquement\n');
    fprintf('3. Sélectionner des sujets pour les deux côtés (même sélection)\n');
    fprintf('4. Sélectionner des sujets indépendamment pour chaque côté\n');
    fprintf('5. Sélectionner des sujets indépendamment pour chaque côté et afficher une moyenne combinée\n');
    fprintf('6. Sélectionner des sujets et sauvegarder les données sujet par sujet pour analyse spm1d\n');
    choice = input('Choisissez une option pour les profils moyens (1-6) : ');

    % Initialisation des variables
    selected_subjects_R = [];
    selected_subjects_L = [];
    display_right = false;
    display_left = false;
    display_combined = false;
    save_individual_data = false;

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
            
        case 6 % Sélection pour sauvegarde sujet par sujet pour analyse spm1d
            disp('Liste des sujets disponibles pour le côté DROIT :');
            disp(subject_ids);
            selected_subjects_R = input('Entrez les numéros des sujets pour le côté DROIT (ex: [1 3 5 7]) ou [] pour aucun : ');

            disp('Liste des sujets disponibles pour le côté GAUCHE :');
            disp(subject_ids);
            selected_subjects_L = input('Entrez les numéros des sujets pour le côté GAUCHE (ex: [2 4 6 8]) ou [] pour aucun : ');

            display_right = false;
            display_left = false;
            display_combined = true;
            save_individual_data = true;

        otherwise
            error('Option non valide. Veuillez choisir entre 1 et 6.');
    end
    
    % Nombre de mouvements fonctionnels
    nb_functionals = length(functional_labels);
    
    % Couleurs pour chaque mouvement fonctionnel
    functional_colors = {'b', 'r', 'g', 'm'};  % Bleu, Rouge, Vert, Magenta
    
    % Création de la figure pour affichage
    figure('Name', 'Combined Functional EMG Profiles', 'Color', 'white', 'Position', [100, 100, 1200, 800]);
    
    % Pour chaque mouvement fonctionnel et chaque côté, calculer les statistiques
    emg_stats_R = cell(nb_functionals, 1);
    emg_stats_L = cell(nb_functionals, 1);
    emg_stats_combined = cell(nb_functionals, 1);
    
    % Structure pour stocker les données individuelles sujet par sujet si l'option 6 est choisie
    if save_individual_data
        individual_data = struct();
        individual_data.time = time_normalized;
        individual_data.functional_labels = functional_labels;
        individual_data.muscles_R = muscles_R;
        individual_data.muscles_L = muscles_L;
        individual_data.subject_data_R = cell(length(selected_subjects_R), nb_functionals);
        individual_data.subject_data_L = cell(length(selected_subjects_L), nb_functionals);
        individual_data.subject_ids_R = selected_subjects_R;
        individual_data.subject_ids_L = selected_subjects_L;
    end
    
    % Pour le côté droit
    if display_right || display_combined
        % Vérification que les indices sont valides
        if any(selected_subjects_R > nb_subjects) || any(selected_subjects_R < 1)
            error('Indices des sujets hors limites pour le côté droit.');
        end
        
        n_selected_R = length(selected_subjects_R);
        
        for func_idx = 1:nb_functionals
            % Extraction des données pour ce mouvement fonctionnel
            emg_data = all_functional_data_R{func_idx};
            
            % Extraction des données pour les sujets sélectionnés
            emg_selected = emg_data(selected_subjects_R, :, :);
            
            % Sauvegarder les données individuelles sujet par sujet si option 6
            if save_individual_data
                for s_idx = 1:length(selected_subjects_R)
                    % Extraire les données de ce sujet
                    subj_data = squeeze(emg_selected(s_idx, :, :));
                    
                    % Stocker dans la structure
                    individual_data.subject_data_R{s_idx, func_idx} = subj_data;
                end
            end
            
            % Calcul des moyennes et écart-types
            emg_mean = squeeze(mean(emg_selected, 1, 'omitnan'));
            emg_std = squeeze(std(emg_selected, 0, 1, 'omitnan'));
            
            % Vérifier et corriger les dimensions si nécessaire
            if size(emg_mean, 1) == 1 && nb_muscles > 1
                % Si une seule dimension temporelle après squeeze, transposer
                emg_mean = emg_mean';
                emg_std = emg_std';
            end
            
            % Calcul des intervalles de confiance
            emg_sem = emg_std / sqrt(n_selected_R);
            t_critical = tinv((1 + confidence_level) / 2, n_selected_R - 1);
            emg_ci_lower = emg_mean - t_critical * emg_sem;
            emg_ci_upper = emg_mean + t_critical * emg_sem;
            
            % Stockage des statistiques pour ce mouvement
            emg_stats_R{func_idx} = struct('mean', emg_mean, 'std', emg_std, ...
                'ci_lower', emg_ci_lower, 'ci_upper', emg_ci_upper);
        end
    end
    
    % Pour le côté gauche
    if display_left || display_combined
        % Vérification que les indices sont valides
        if any(selected_subjects_L > nb_subjects) || any(selected_subjects_L < 1)
            error('Indices des sujets hors limites pour le côté gauche.');
        end
        
        n_selected_L = length(selected_subjects_L);
        
        for func_idx = 1:nb_functionals
            % Extraction des données pour ce mouvement fonctionnel
            emg_data = all_functional_data_L{func_idx};
            
            % Extraction des données pour les sujets sélectionnés
            emg_selected = emg_data(selected_subjects_L, :, :);
            
            % Sauvegarder les données individuelles sujet par sujet si option 6
            if save_individual_data
                for s_idx = 1:length(selected_subjects_L)
                    % Extraire les données de ce sujet
                    subj_data = squeeze(emg_selected(s_idx, :, :));
                    
                    % Stocker dans la structure
                    individual_data.subject_data_L{s_idx, func_idx} = subj_data;
                end
            end
            
            % Calcul des moyennes et écart-types
            emg_mean = squeeze(mean(emg_selected, 1, 'omitnan'));
            emg_std = squeeze(std(emg_selected, 0, 1, 'omitnan'));
            
            % Vérifier et corriger les dimensions si nécessaire
            if size(emg_mean, 1) == 1 && nb_muscles > 1
                % Si une seule dimension temporelle après squeeze, transposer
                emg_mean = emg_mean';
                emg_std = emg_std';
            end
            
            % Calcul des intervalles de confiance
            emg_sem = emg_std / sqrt(n_selected_L);
            t_critical = tinv((1 + confidence_level) / 2, n_selected_L - 1);
            emg_ci_lower = emg_mean - t_critical * emg_sem;
            emg_ci_upper = emg_mean + t_critical * emg_sem;
            
            % Stockage des statistiques pour ce mouvement
            emg_stats_L{func_idx} = struct('mean', emg_mean, 'std', emg_std, ...
                'ci_lower', emg_ci_lower, 'ci_upper', emg_ci_upper);
        end
    end
    
    % Pour les données combinées (option 5 ou 6)
    if display_combined
        n_combined = n_selected_R + n_selected_L;
        
        for func_idx = 1:nb_functionals
            % Extraction des données pour ce mouvement fonctionnel
            emg_data_R = all_functional_data_R{func_idx};
            emg_data_L = all_functional_data_L{func_idx};
            
            % Extraction des données pour les sujets sélectionnés
            emg_selected_R = emg_data_R(selected_subjects_R, :, :);
            emg_selected_L = emg_data_L(selected_subjects_L, :, :);
            
            % Moyennes pour les deux côtés
            emg_mean_R = squeeze(mean(emg_selected_R, 1, 'omitnan'));
            emg_std_R = squeeze(std(emg_selected_R, 0, 1, 'omitnan'));
            emg_mean_L = squeeze(mean(emg_selected_L, 1, 'omitnan'));
            emg_std_L = squeeze(std(emg_selected_L, 0, 1, 'omitnan'));
            
            % Vérifier et corriger les dimensions si nécessaire
            if size(emg_mean_R, 1) == 1 && nb_muscles > 1
                emg_mean_R = emg_mean_R';
                emg_std_R = emg_std_R';
                emg_mean_L = emg_mean_L';
                emg_std_L = emg_std_L';
            end
            
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
            
            % Stockage des statistiques pour ce mouvement
            emg_stats_combined{func_idx} = struct('mean', emg_mean_combined, 'std', emg_std_combined, ...
                'ci_lower', emg_ci_lower_combined, 'ci_upper', emg_ci_upper_combined);
        end
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
        
        % Tableau pour stocker les handles de légende
        legend_handles = [];
        legend_entries = {};
        
        % Tracé pour chaque mouvement fonctionnel
        for func_idx = 1:nb_functionals
            current_color = functional_colors{func_idx};
            
            % Pour le côté droit
            if display_right
                stats = emg_stats_R{func_idx};
                
                % Extraire correctement les données selon les dimensions
                if size(stats.mean, 1) == nb_muscles
                    mean_data = stats.mean(m, :);
                    ci_upper = stats.ci_upper(m, :);
                    ci_lower = stats.ci_lower(m, :);
                    std_data = stats.std(m, :);
                else
                    % Si les dimensions sont inversées
                    mean_data = stats.mean(:, m)';
                    ci_upper = stats.ci_upper(:, m)';
                    ci_lower = stats.ci_lower(:, m)';
                    std_data = stats.std(:, m)';
                end
                
                % Vérification des dimensions pour le tracé
                if length(time_vector) ~= length(mean_data)
                    error(['Dimensions incompatibles pour le tracé: time_vector length = ', ...
                           num2str(length(time_vector)), ', mean_data length = ', ...
                           num2str(length(mean_data))]);
                end
                
                % Tracé de la ligne moyenne
                h_line = plot(time_vector, mean_data, [current_color '-'], 'LineWidth', 2);
                
                % Ajout à la légende
                legend_handles = [legend_handles, h_line];
                legend_entries = [legend_entries, [functional_labels{func_idx} ' (R)']];
                
                % Tracé de l'écart-type avec fill
                std_upper = mean_data + std_data;
                std_lower = mean_data - std_data;
                h_fill = fill([time_vector, fliplr(time_vector)], ...
                             [std_upper, fliplr(std_lower)], ...
                             current_color, 'EdgeColor', 'none', 'FaceAlpha', 0.1);
                
                % Tracé de l'IC95 en pointillé
                plot(time_vector, ci_upper, [current_color '--'], 'LineWidth', 0.5);
                plot(time_vector, ci_lower, [current_color '--'], 'LineWidth', 0.5);
            end
            
            % Pour le côté gauche
            if display_left
                stats = emg_stats_L{func_idx};
                
                % Extraire correctement les données selon les dimensions
                if size(stats.mean, 1) == nb_muscles
                    mean_data = stats.mean(m, :);
                    ci_upper = stats.ci_upper(m, :);
                    ci_lower = stats.ci_lower(m, :);
                    std_data = stats.std(m, :);
                else
                    % Si les dimensions sont inversées
                    mean_data = stats.mean(:, m)';
                    ci_upper = stats.ci_upper(:, m)';
                    ci_lower = stats.ci_lower(:, m)';
                    std_data = stats.std(:, m)';
                end
                
                % Vérification des dimensions pour le tracé
                if length(time_vector) ~= length(mean_data)
                    error(['Dimensions incompatibles pour le tracé: time_vector length = ', ...
                           num2str(length(time_vector)), ', mean_data length = ', ...
                           num2str(length(mean_data))]);
                end
                
                % Tracé de la ligne moyenne avec un style différent (tirets)
                h_line = plot(time_vector, mean_data, [current_color '-.'], 'LineWidth', 2);
                
                % Ajout à la légende
                legend_handles = [legend_handles, h_line];
                legend_entries = [legend_entries, [functional_labels{func_idx} ' (L)']];
                
                % Tracé de l'écart-type avec fill
                std_upper = mean_data + std_data;
                std_lower = mean_data - std_data;
                h_fill = fill([time_vector, fliplr(time_vector)], ...
                             [std_upper, fliplr(std_lower)], ...
                             current_color, 'EdgeColor', 'none', 'FaceAlpha', 0.1);
                
                % Tracé de l'IC95 en pointillé
                plot(time_vector, ci_upper, [current_color '--'], 'LineWidth', 0.5);
                plot(time_vector, ci_lower, [current_color '--'], 'LineWidth', 0.5);
            end
            
            % Pour les données combinées
            if display_combined
                stats = emg_stats_combined{func_idx};
                
                % Extraire correctement les données selon les dimensions
                if size(stats.mean, 1) == nb_muscles
                    mean_data = stats.mean(m, :);
                    ci_upper = stats.ci_upper(m, :);
                    ci_lower = stats.ci_lower(m, :);
                    std_data = stats.std(m, :);
                else
                    % Si les dimensions sont inversées
                    mean_data = stats.mean(:, m)';
                    ci_upper = stats.ci_upper(:, m)';
                    ci_lower = stats.ci_lower(:, m)';
                    std_data = stats.std(:, m)';
                end
                
                % Vérification des dimensions pour le tracé
                if length(time_vector) ~= length(mean_data)
                    error(['Dimensions incompatibles pour le tracé: time_vector length = ', ...
                           num2str(length(time_vector)), ', mean_data length = ', ...
                           num2str(length(mean_data))]);
                end
                
                % Tracé de la ligne moyenne
                h_line = plot(time_vector, mean_data, [current_color '-'], 'LineWidth', 2);
                
                % Ajout à la légende
                legend_handles = [legend_handles, h_line];
                legend_entries = [legend_entries, [functional_labels{func_idx} ' (Combined)']];
                
                % Tracé de l'écart-type avec fill
                std_upper = mean_data + std_data;
                std_lower = mean_data - std_data;
                h_fill = fill([time_vector, fliplr(time_vector)], ...
                             [std_upper, fliplr(std_lower)], ...
                             current_color, 'EdgeColor', 'none', 'FaceAlpha', 0.1);
                
                % Tracé de l'IC95 en pointillé
                plot(time_vector, ci_upper, [current_color '--'], 'LineWidth', 0.5);
                plot(time_vector, ci_lower, [current_color '--'], 'LineWidth', 0.5);
            end
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
        for func_idx = 1:nb_functionals
            if display_right
                stats = emg_stats_R{func_idx};
                if size(stats.ci_upper, 1) == nb_muscles
                    y_data = [y_data; stats.ci_upper(m, :)];
                else
                    y_data = [y_data; stats.ci_upper(:, m)'];
                end
            end
            
            if display_left
                stats = emg_stats_L{func_idx};
                if size(stats.ci_upper, 1) == nb_muscles
                    y_data = [y_data; stats.ci_upper(m, :)];
                else
                    y_data = [y_data; stats.ci_upper(:, m)'];
                end
            end
            
            if display_combined
                stats = emg_stats_combined{func_idx};
                if size(stats.ci_upper, 1) == nb_muscles
                    y_data = [y_data; stats.ci_upper(m, :)];
                else
                    y_data = [y_data; stats.ci_upper(:, m)'];
                end
            end
        end
        
        if ~isempty(y_data)
            y_max = max(y_data(:));
            ylim([0, y_max * 1.1]);
        end
        
        grid on;
        
        % Affichage de la légende
        if ~isempty(legend_handles)
            legend(legend_handles, legend_entries, 'Location', 'best', 'FontSize', 8);
        end
    end
    
    % Préparation du titre global avec les informations des sujets
    title_str = 'Combined Functional Movements - Average EMG Profiles';
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
    fprintf('\n===== Sujets sélectionnés =====\n');
    if display_right || (display_combined && ~isempty(selected_subjects_R))
        fprintf('Côté DROIT : %s (n=%d)\n', mat2str(selected_subjects_R), length(selected_subjects_R));
    end
    if display_left || (display_combined && ~isempty(selected_subjects_L))
        fprintf('Côté GAUCHE : %s (n=%d)\n', mat2str(selected_subjects_L), length(selected_subjects_L));
    end
    
    % Sauvegarde des données sujet par sujet pour analyse SPM1D si l'option 6 est choisie
    if save_individual_data
        % Affichage d'un message pour informer l'utilisateur
        fprintf('\n===== Sauvegarde des données individuelles pour analyse SPM1D =====\n');
        
        % Demander le nom du fichier pour la sauvegarde
        default_filename = 'combined_functional_data_for_spm1d.mat';
        filename = input(['Entrez le nom du fichier pour la sauvegarde (par défaut: ' default_filename '): '], 's');
        if isempty(filename)
            filename = default_filename;
        end
        
        % Ajout de l'extension .mat si nécessaire
        if ~contains(filename, '.mat')
            filename = [filename '.mat'];
        end
        
        % Sauvegarde de la structure de données
        save(filename, 'individual_data');
        fprintf('Données sauvegardées dans le fichier "%s"\n', filename);
        
        % Afficher un résumé des données sauvegardées
        fprintf('\nRésumé des données sauvegardées:\n');
        fprintf('- Nombre de sujets côté droit: %d\n', length(selected_subjects_R));
        fprintf('- Nombre de sujets côté gauche: %d\n', length(selected_subjects_L));
        fprintf('- Nombre de mouvements fonctionnels: %d\n', nb_functionals);
        fprintf('- Nombre de muscles: %d\n', nb_muscles);
        fprintf('- Longueur du signal normalisé: %d points\n', length(time_normalized));
        
        % Rappel de l'utilisation pour analyse SPM1D
        fprintf('\nPour utiliser ces données dans votre analyse SPM1D:\n');
        fprintf('1. Chargez les données: load(''%s'')\n', filename);
        fprintf('2. Accédez aux données d''un sujet spécifique:\n');
        fprintf('   - Côté droit: individual_data.subject_data_R{sujet_index, mouvement_index}\n');
        fprintf('   - Côté gauche: individual_data.subject_data_L{sujet_index, mouvement_index}\n');
        fprintf('3. Les indices des sujets originaux sont stockés dans:\n');
        fprintf('   - individual_data.subject_ids_R\n');
        fprintf('   - individual_data.subject_ids_L\n');
    end
end