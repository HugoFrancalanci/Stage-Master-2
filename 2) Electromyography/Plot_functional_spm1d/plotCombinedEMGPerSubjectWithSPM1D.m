function plotCombinedEMGPerSubjectWithSPM1D(data_files, use_dtw)
    % Cette fonction trace les profils EMG moyens des 4 mouvements combinés 
    % pour tous les sujets, avec une figure distincte pour chaque muscle,
    % réalise un alignement par DTW et une analyse SPM1D pour comparer les groupes
    % Permet aussi de sélectionner trois cycles qui seront moyennés pour l'analyse
    %
    % Paramètres:
    %   data_files - Cellule contenant les chemins des fichiers .mat (jusqu'à 3)
    %               ou chaîne de caractères pour un seul fichier
    %   use_dtw - Booléen indiquant si l'alignement DTW doit être utilisé
    
    % Ajouter le chemin vers SPM1D
    addpath(genpath('C:\Users\Francalanci Hugo\Documents\MATLAB\Stage Sainte-Justine\HUG\Statistics\spm1dmatlab-master'))  
    
    % Vérifier si l'utilisateur a spécifié d'utiliser DTW ou non
    if nargin < 2
        use_dtw = true; % Par défaut, utiliser DTW
    end
    
    % Demander si l'utilisateur souhaite sélectionner des cycles
    fprintf('\n======== SÉLECTION DE CYCLES ========\n');
    fprintf('Souhaitez-vous sélectionner et moyenner trois cycles pour l''analyse? (O/N): ');
    select_cycle_input = input('', 's');
    select_cycle = lower(select_cycle_input) == 'o' || lower(select_cycle_input) == 'y' || ~isempty(select_cycle_input);
    
    if select_cycle
        fprintf('\nVous allez sélectionner 3 cycles qui seront moyennés pour l''analyse SPM.\n');
        fprintf('Pour chaque muscle, vous devrez cliquer sur le début et la fin de chaque cycle (6 clics au total).\n');
        fprintf('Les cycles seront ensuite moyennés pour l''analyse statistique.\n\n');
        num_cycles = 3; % Nombre de cycles à sélectionner
    else
        fprintf('\nAucun cycle ne sera sélectionné, l''analyse sera effectuée sur toute la courbe.\n\n');
    end
    
    % Vérifier le type de l'entrée et la convertir en cellule si nécessaire
    if ischar(data_files) || isstring(data_files)
        data_files = {data_files};
    end
    
    % Limiter à 3 fichiers maximum
    if length(data_files) > 3
        warning('Un maximum de 3 fichiers est supporté. Seuls les 3 premiers seront traités.');
        data_files = data_files(1:3);
    end
    
    % Nombre de fichiers à traiter
    num_files = length(data_files);
    
    % Définir les styles de ligne pour chaque fichier
    line_styles = {'-', '--', ':'};
    
    % Définir les couleurs pour chaque fichier (RGB)
    line_colors = {[0, 0.4470, 0.7410],    % bleu
                  [0.8500, 0.3250, 0.0980], % rouge-orange
                  [0.4660, 0.6740, 0.1880]};% vert
              
    % Couleurs pour les intervalles de confiance (plus claires)
    fill_colors = {[0.3010, 0.7450, 0.9330],    % bleu clair
                  [0.9290, 0.6940, 0.1250],     % orange clair
                  [0.4660, 0.8740, 0.3880]};    % vert clair
    
    % Pour stocker les données de chaque fichier
    all_data = cell(num_files, 1);
    file_labels = cell(num_files, 1);
    
    % Charger tous les fichiers
    for f = 1:num_files
        % Vérifier si le fichier existe
        if ~exist(data_files{f}, 'file')
            error('Le fichier de données spécifié n''existe pas: %s', data_files{f});
        end
        
        % Charger les données
        fprintf('Chargement des données depuis %s...\n', data_files{f});
        data = load(data_files{f});
        
        % Vérifier que la structure contient les données nécessaires
        if ~isfield(data, 'individual_data')
            error('Le fichier %s ne contient pas la structure "individual_data" attendue.', data_files{f});
        end
        
        % Stocker les données
        all_data{f} = data.individual_data;
        
        % Extraire le nom du fichier pour le label
        [~, file_name, ~] = fileparts(data_files{f});
        file_labels{f} = file_name;
    end
    
    % Déterminer les labels pour les groupes
    % Par défaut: asympt, pre, post (si disponible)
    group_labels = cell(num_files, 1);
    if num_files == 1
        group_labels{1} = 'Groupe';
    elseif num_files == 2
        if contains(lower(file_labels{1}), 'pre')
            group_labels{1} = 'Pre';
            if contains(lower(file_labels{2}), 'post')
                group_labels{2} = 'Post';
            else
                group_labels{2} = 'Asympt';
            end
        elseif contains(lower(file_labels{1}), 'asympt')
            group_labels{1} = 'Asympt';
            group_labels{2} = 'Pre/Post';
        else
            group_labels{1} = 'Groupe 1';
            group_labels{2} = 'Groupe 2';
        end
    elseif num_files == 3
        for f = 1:num_files
            if contains(lower(file_labels{f}), 'asympt')
                group_labels{f} = 'Asympt';
            elseif contains(lower(file_labels{f}), 'pre')
                group_labels{f} = 'Pre';
            elseif contains(lower(file_labels{f}), 'post')
                group_labels{f} = 'Post';
            else
                group_labels{f} = ['Groupe ' num2str(f)];
            end
        end
    end
    
    % Extraire les informations nécessaires du premier fichier pour initialisation
    time_normalized = all_data{1}.time;
    muscles_R = all_data{1}.muscles_R;
    muscles_L = all_data{1}.muscles_L;
    
    % Nombre de muscles
    nb_muscles = length(muscles_R);
    if nb_muscles ~= length(muscles_L)
        warning('Le nombre de muscles diffère entre les côtés droit et gauche.');
        nb_muscles = min(length(muscles_R), length(muscles_L));
    end
    
    % Pour chaque muscle, créer une figure séparée
    for m = 1:nb_muscles
        % Créer une nouvelle figure pour ce muscle
        figure('Name', sprintf('Muscle %d: %s', m, muscles_R{m}), 'Color', 'white', 'Position', [100+m*50, 100+m*30, 800, 500]);
        hold on;
        
        % Légende pour cette figure
        legend_handles = [];
        legend_labels = {};
        
        % Pour stocker les données de chaque fichier (pour analyse SPM1D)
        muscle_data_by_file = cell(num_files, 1);
        
        % Pour stocker les données alignées par DTW
        aligned_data_by_file = cell(num_files, 1);
        
        % Traiter chaque fichier
        for f = 1:num_files
            % Extraire les données de ce fichier
            data = all_data{f};
            
            % Extraire les informations spécifiques
            functional_labels = data.functional_labels;
            subject_data_R = data.subject_data_R;
            subject_data_L = data.subject_data_L;
            subject_ids_R = data.subject_ids_R;
            subject_ids_L = data.subject_ids_L;
            
            % Nombre de mouvements fonctionnels
            nb_functionals = length(functional_labels);
            
            % Nombre de sujets pour chaque côté
            nb_subjects_R = length(subject_ids_R);
            nb_subjects_L = length(subject_ids_L);
            
            % Matrices pour stocker toutes les moyennes de sujets
            all_means_R = zeros(nb_subjects_R, length(time_normalized));
            all_means_L = zeros(nb_subjects_L, length(time_normalized));
            
            % Calculer la moyenne des 4 mouvements pour chaque sujet côté droit
            for s = 1:nb_subjects_R
                subject_mean = zeros(1, length(time_normalized));
                
                for func = 1:nb_functionals
                    % Extraire les données de ce sujet pour ce mouvement
                    subj_data = subject_data_R{s, func};
                    
                    % Vérifier les dimensions et extraire les données du muscle
                    if size(subj_data, 1) == nb_muscles
                        % Les muscles sont en ligne
                        muscle_data = subj_data(m, :);
                    else
                        % Les muscles sont en colonne
                        muscle_data = subj_data(:, m)';
                    end
                    
                    % Ajouter à la moyenne
                    subject_mean = subject_mean + muscle_data;
                end
                
                % Calculer la moyenne des mouvements pour ce sujet
                subject_mean = subject_mean / nb_functionals;
                
                % Stocker dans le tableau
                all_means_R(s, :) = subject_mean;
            end
            
            % Calculer la moyenne des 4 mouvements pour chaque sujet côté gauche
            for s = 1:nb_subjects_L
                subject_mean = zeros(1, length(time_normalized));
                
                for func = 1:nb_functionals
                    % Extraire les données de ce sujet pour ce mouvement
                    subj_data = subject_data_L{s, func};
                    
                    % Vérifier les dimensions et extraire les données du muscle
                    if size(subj_data, 1) == nb_muscles
                        % Les muscles sont en ligne
                        muscle_data = subj_data(m, :);
                    else
                        % Les muscles sont en colonne
                        muscle_data = subj_data(:, m)';
                    end
                    
                    % Ajouter à la moyenne
                    subject_mean = subject_mean + muscle_data;
                end
                
                % Calculer la moyenne des mouvements pour ce sujet
                subject_mean = subject_mean / nb_functionals;
                
                % Stocker dans le tableau
                all_means_L(s, :) = subject_mean;
            end
            
            % Combiner les données des côtés droit et gauche
            all_means_combined = [all_means_R; all_means_L];
            
            % Stocker les données pour l'analyse SPM1D
            muscle_data_by_file{f} = all_means_combined;
            
            % Calculer la moyenne finale et l'écart-type de tous les sujets
            mean_data = mean(all_means_combined, 1, 'omitnan');
            std_data = std(all_means_combined, 0, 1, 'omitnan');
            
            % Calculer l'intervalle de confiance à 95%
            n_subjects = size(all_means_combined, 1);
            sem = std_data / sqrt(n_subjects);
            t_crit = tinv(0.975, n_subjects - 1);  % 95% de confiance
            ci_lower = mean_data - t_crit * sem;
            ci_upper = mean_data + t_crit * sem;
            
            % Tracer la ligne moyenne avec le style approprié
            h_line = plot(time_normalized, mean_data, line_styles{f}, 'LineWidth', 2.5, 'Color', line_colors{f});
            
            % Tracer l'intervalle de confiance avec fill
            x_fill = [time_normalized, fliplr(time_normalized)];
            y_fill = [ci_upper, fliplr(ci_lower)];
            fill(x_fill, y_fill, fill_colors{f}, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
            
            % Ajouter à la légende
            legend_handles = [legend_handles, h_line];
            
            % Créer une étiquette avec le nom du fichier et le nombre de sujets
            legend_label = sprintf('%s (n=%d)', group_labels{f}, n_subjects);
            legend_labels{end+1} = legend_label;
        end
        
        % Définir le titre de la figure
        if isequal(muscles_R{m}, muscles_L{m})
            title_str = muscles_R{m};
        else
            title_str = [muscles_R{m} ' / ' muscles_L{m}];
        end
        title(title_str, 'FontWeight', 'bold', 'FontSize', 14);
        
        % Axes et grille
        xlabel('Temps normalisé (%)', 'FontSize', 12);
        ylabel('EMG normalisé (% MVC)', 'FontSize', 12);
        xlim([min(time_normalized), max(time_normalized)]);
        grid on;
        box on;
        
        % Ajouter la légende
        if ~isempty(legend_handles)
            legend(legend_handles, legend_labels, 'Location', 'best', 'FontSize', 12);
        end
        
        % Ajuster la mise en page
        set(gca, 'FontSize', 12);
        
        % Sélection de cycles si demandé
        cycle_bounds = [];
        if select_cycle
            fprintf('\n======== SÉLECTION DES CYCLES - MUSCLE: %s ========\n', title_str);
            fprintf('Veuillez sélectionner 3 cycles pour le muscle %s.\n', title_str);
            fprintf('Pour chaque cycle, cliquez sur le graphique pour marquer:\n');
            fprintf('  - Le début du cycle (premier clic)\n');
            fprintf('  - La fin du cycle (deuxième clic)\n\n');
            
            % Initialiser un tableau pour stocker les limites des cycles
            all_cycle_bounds = zeros(num_cycles, 2);
            
            % Sélectionner les points pour chaque cycle
            for c = 1:num_cycles
                fprintf('Sélection du CYCLE %d/%d:\n', c, num_cycles);
                fprintf('Cliquez pour marquer le DÉBUT du cycle %d...\n', c);
                [x_start, ~] = ginput(1);
                fprintf('Début du cycle %d: %.2f%%\n', c, x_start);
                
                fprintf('Cliquez pour marquer la FIN du cycle %d...\n', c);
                [x_end, ~] = ginput(1);
                fprintf('Fin du cycle %d: %.2f%%\n', c, x_end);
                
                % Stocker les limites (triées si nécessaire)
                all_cycle_bounds(c, :) = sort([x_start, x_end]);
                
                % Afficher une ligne verticale pour marquer les limites
                line([x_start, x_start], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--');
                line([x_end, x_end], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--');
                
                % Ajouter un texte numéroté pour le cycle
                y_range = get(gca, 'YLim');
                y_pos = y_range(1) + (y_range(2) - y_range(1)) * 0.9;
                text((x_start + x_end)/2, y_pos, sprintf('Cycle %d', c), 'HorizontalAlignment', 'center');
            end
            
            fprintf('\nTous les cycles ont été sélectionnés.\n');
            fprintf('Création de la figure avec les cycles moyennés...\n\n');
            
            % Matrices pour stocker les données de chaque cycle
            cycle_data_by_file = cell(num_files, num_cycles);
            
            % Créer une nouvelle figure pour montrer les cycles sélectionnés
            figure('Name', sprintf('Cycles - Muscle %d: %s', m, title_str), 'Color', 'white', 'Position', [100+m*50+400, 100+m*30, 800, 500]);
            subplot(2, 1, 1); % Pour montrer les cycles individuels
            hold on;
            title('Cycles individuels sélectionnés', 'FontWeight', 'bold', 'FontSize', 14);
            
            % Pour chaque groupe, extraire et montrer les cycles
            for f = 1:num_files
                legend_handles_cycles = [];
                legend_labels_cycles = {};
                
                for c = 1:num_cycles
                    % Obtenir les limites de ce cycle
                    cycle_start = all_cycle_bounds(c, 1);
                    cycle_end = all_cycle_bounds(c, 2);
                    
                    % Extraire les indices correspondant aux limites du cycle
                    indices = find(time_normalized >= cycle_start & time_normalized <= cycle_end);
                    
                    if isempty(indices)
                        warning('Aucun point de données trouvé dans les limites du cycle %d.', c);
                        continue;
                    end
                    
                    % Extraire les données du cycle pour ce groupe
                    cycle_data = muscle_data_by_file{f}(:, indices);
                    
                    % Stocker pour utilisation ultérieure
                    cycle_data_by_file{f, c} = cycle_data;
                    
                    % Temps normalisé pour ce cycle (0-100%)
                    cycle_time = linspace(0, 100, length(indices));
                    
                    % Calculer la moyenne de ce cycle pour ce groupe
                    mean_cycle = mean(cycle_data, 1, 'omitnan');
                    
                    % Tracer ce cycle avec style en pointillé
                    h_cycle = plot(cycle_time + (c-1)*110, mean_cycle, '--', 'LineWidth', 1.5, 'Color', line_colors{f});
                    
                    if c == 1
                        % Ajouter à la légende uniquement pour le premier cycle
                        legend_handles_cycles = [legend_handles_cycles, h_cycle];
                        legend_labels_cycles{end+1} = group_labels{f};
                    end
                end
                
                % Ajouter la légende
                if ~isempty(legend_handles_cycles)
                    legend(legend_handles_cycles, legend_labels_cycles, 'Location', 'best', 'FontSize', 10);
                end
            end
            
            % Titres et axes pour les cycles individuels
            xlabel('Cycle normalisé (%) & offset', 'FontSize', 12);
            ylabel('EMG normalisé (% MVC)', 'FontSize', 12);
            grid on;
            box on;
            
            % Subplot pour montrer les cycles moyennés
            subplot(2, 1, 2);
            hold on;
            title('Cycles moyennés pour analyse SPM1D', 'FontWeight', 'bold', 'FontSize', 14);
            
            % Pour chaque groupe, calculer et montrer la moyenne des cycles
            legend_handles_mean = [];
            legend_labels_mean = {};
            
            % Matrices pour stocker les moyennes des cycles pour l'analyse SPM1D
            mean_cycle_data_by_file = cell(num_files, 1);
            
            for f = 1:num_files
                % Préparer une matrice pour stocker les données moyennées
                % Trouver le nombre minimum de points parmi tous les cycles
                min_length = inf;
                for c = 1:num_cycles
                    if ~isempty(cycle_data_by_file{f, c})
                        min_length = min(min_length, size(cycle_data_by_file{f, c}, 2));
                    end
                end
                
                if min_length == inf
                    warning('Aucune donnée valide pour le groupe %s.', group_labels{f});
                    continue;
                end
                
                % Créer une matrice pour stocker les données réalignées
                n_subjects = size(muscle_data_by_file{f}, 1);
                resampled_cycles = zeros(n_subjects, num_cycles, min_length);
                
                % Extraire et réaligner les cycles pour chaque sujet
                for c = 1:num_cycles
                    if isempty(cycle_data_by_file{f, c})
                        continue;
                    end
                    
                    % Réaligner les données du cycle à la même longueur (min_length)
                    for s = 1:n_subjects
                        if c <= size(cycle_data_by_file, 2) && ~isempty(cycle_data_by_file{f, c})
                            subject_cycle = cycle_data_by_file{f, c}(s, :);
                            % Rééchantillonner à min_length points
                            resampled_cycles(s, c, :) = interp1(1:length(subject_cycle), subject_cycle, linspace(1, length(subject_cycle), min_length));
                        end
                    end
                end
                
                % Calculer la moyenne des cycles pour chaque sujet
                mean_cycles_by_subject = zeros(n_subjects, min_length);
                for s = 1:n_subjects
                    mean_cycles_by_subject(s, :) = mean(squeeze(resampled_cycles(s, :, :)), 1, 'omitnan');
                end
                
                % Stocker les données moyennées pour l'analyse SPM1D
                mean_cycle_data_by_file{f} = mean_cycles_by_subject;
                
                % Calculer et tracer la courbe moyenne et l'intervalle de confiance
                mean_curve = mean(mean_cycles_by_subject, 1, 'omitnan');
                std_curve = std(mean_cycles_by_subject, 0, 1, 'omitnan');
                sem_curve = std_curve / sqrt(n_subjects);
                t_crit = tinv(0.975, n_subjects - 1);
                ci_lower = mean_curve - t_crit * sem_curve;
                ci_upper = mean_curve + t_crit * sem_curve;
                
                % Axe X normalisé à 0-100%
                x_mean = linspace(0, 100, min_length);
                
                % Tracer la courbe moyenne
                h_mean = plot(x_mean, mean_curve, line_styles{f}, 'LineWidth', 2.5, 'Color', line_colors{f});
                
                % Tracer l'intervalle de confiance
                x_fill_mean = [x_mean, fliplr(x_mean)];
                y_fill_mean = [ci_upper, fliplr(ci_lower)];
                fill(x_fill_mean, y_fill_mean, fill_colors{f}, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
                
                % Ajouter à la légende
                legend_handles_mean = [legend_handles_mean, h_mean];
                legend_labels_mean{end+1} = sprintf('%s (n=%d)', group_labels{f}, n_subjects);
            end
            
            % Titres et axes pour les cycles moyennés
            xlabel('Cycle normalisé (%)', 'FontSize', 12);
            ylabel('EMG normalisé (% MVC)', 'FontSize', 12);
            grid on;
            box on;
            
            % Ajouter la légende pour les cycles moyennés
            if ~isempty(legend_handles_mean)
                legend(legend_handles_mean, legend_labels_mean, 'Location', 'best', 'FontSize', 10);
            end
            
            % Définir la plage de l'axe X
            xlim([0, 100]);
            
            % Utiliser les données des cycles moyennés pour l'analyse SPM1D
            if num_files > 1
                % Réaliser les analyses SPM1D avec les données moyennées
                for i = 1:num_files
                    for j = (i+1):num_files
                        % S'assurer que les deux fichiers ont des données valides
                        if isempty(mean_cycle_data_by_file{i}) || isempty(mean_cycle_data_by_file{j})
                            warning('Données insuffisantes pour la comparaison %s vs %s.', group_labels{i}, group_labels{j});
                            continue;
                        end
                        
                        % Titre pour l'analyse
                        analysis_title = [title_str ' - Cycles moyennés'];
                        
                        % Préparer les données pour l'analyse SPM1D
                        if use_dtw
                            % Aligner les données avec DTW
                            fprintf('Alignement des courbes par DTW pour %s vs %s...\n', group_labels{i}, group_labels{j});
                            
                            % Calculer les moyennes des groupes pour l'alignement
                            mean_data1 = mean(mean_cycle_data_by_file{i}, 1, 'omitnan');
                            mean_data2 = mean(mean_cycle_data_by_file{j}, 1, 'omitnan');
                            
                            % Vérifier si la fonction DTW est disponible
                            if exist('dtw', 'file')
                                % Utiliser DTW pour aligner les moyennes
                                [~, ix, iy] = dtw(mean_data1, mean_data2);
                                
                                % Aligner chaque sujet du groupe 1 en utilisant les indices de DTW
                                aligned_data1 = zeros(size(mean_cycle_data_by_file{i}, 1), length(ix));
                                for s = 1:size(mean_cycle_data_by_file{i}, 1)
                                    aligned_curve = mean_cycle_data_by_file{i}(s, ix);
                                    aligned_data1(s, :) = aligned_curve;
                                end
                                
                                % Aligner chaque sujet du groupe 2 en utilisant les indices de DTW
                                aligned_data2 = zeros(size(mean_cycle_data_by_file{j}, 1), length(iy));
                                for s = 1:size(mean_cycle_data_by_file{j}, 1)
                                    aligned_curve = mean_cycle_data_by_file{j}(s, iy);
                                    aligned_data2(s, :) = aligned_curve;
                                end
                                
                                % Normaliser à nouveau l'axe du temps
                                x_axis_dtw = linspace(0, 100, length(ix));
                            else
                                warning('La fonction DTW n''est pas disponible. Utilisation des données non alignées.');
                                aligned_data1 = mean_cycle_data_by_file{i};
                                aligned_data2 = mean_cycle_data_by_file{j};
                                x_axis_dtw = linspace(0, 100, min_length);
                            end
                        else
                            % Utiliser les données non alignées
                            fprintf('Utilisation des données non alignées pour %s vs %s...\n', group_labels{i}, group_labels{j});
                            aligned_data1 = mean_cycle_data_by_file{i};
                            aligned_data2 = mean_cycle_data_by_file{j};
                            x_axis_dtw = linspace(0, 100, min_length);
                        end
                        
                        % Effectuer l'analyse SPM1D sur les cycles moyennés
                        fprintf('Réalisation de l''analyse SPM1D pour %s vs %s...\n', group_labels{i}, group_labels{j});
                        
                        % Déterminer le type de test approprié
                        if (contains(group_labels{i}, 'Pre') && contains(group_labels{j}, 'Post')) || ...
                           (contains(group_labels{i}, 'Post') && contains(group_labels{j}, 'Pre'))
                            % Test apparié pour Pre vs Post (mêmes sujets)
                            fprintf('Type de test: Test t apparié (pour Pre vs Post).\n');
                            
                            % Vérifier que les dimensions correspondent
                            if size(aligned_data1, 1) ~= size(aligned_data2, 1)
                                warning('Nombre différent de sujets entre %s et %s. Test apparié impossible.', ...
                                    group_labels{i}, group_labels{j});
                                continue;
                            end
                            
                            % Exécuter le test apparié
                            spm = spm1d.stats.ttest_paired(aligned_data1, aligned_data2);
                        else
                            % Test indépendant pour les autres comparaisons
                            fprintf('Type de test: Test t pour échantillons indépendants.\n');
                            spm = spm1d.stats.ttest2(aligned_data1, aligned_data2);
                        end
                        
                        % Faire l'inférence statistique
                        spmi = spm.inference(0.05, 'two_tailed', true, 'interp', true);
                        
                        % Créer une nouvelle figure pour les résultats SPM1D
                        figure_title = sprintf('SPM1D - %s - %s vs %s', analysis_title, group_labels{i}, group_labels{j});
                        figure('Name', figure_title, 'Color', 'white', 'Position', [100+m*50+800, 100+m*30, 800, 500]);
                        
                        % Tracer les résultats SPM1D
                        subplot(2, 1, 1);
                        % Tracer les moyennes des deux groupes (données alignées)
                        plot(x_axis_dtw, mean(aligned_data1, 1, 'omitnan'), line_styles{i}, 'LineWidth', 2.5, 'Color', line_colors{i});
                        hold on;
                        plot(x_axis_dtw, mean(aligned_data2, 1, 'omitnan'), line_styles{j}, 'LineWidth', 2.5, 'Color', line_colors{j});
                        title(sprintf('Moyennes EMG alignées - %s - %s vs %s', analysis_title, group_labels{i}, group_labels{j}), 'FontSize', 14);
                        xlabel('Cycle normalisé (%)', 'FontSize', 12);
                        ylabel('EMG normalisé (% MVC)', 'FontSize', 12);
                        legend({[group_labels{i} ' (aligné)'], [group_labels{j} ' (aligné)']}, 'Location', 'best', 'FontSize', 10);
                        grid on;
                        
                        % Tracer les résultats statistiques dans le subplot inférieur
                        subplot(2, 1, 2);
                        spmi.plot();
                        spmi.plot_threshold_label();
                        spmi.plot_p_values();
                        title(sprintf('Analyse SPM1D - %s - %s vs %s', analysis_title, group_labels{i}, group_labels{j}), 'FontSize', 14);
                        xlabel('Cycle normalisé (%)', 'FontSize', 12);
                        ylabel('Statistique t', 'FontSize', 12);
                        grid on;
                    end
                end
            end
        else
            % Réaliser les analyses SPM1D avec toutes les données
            if num_files > 1
                for i = 1:num_files
                    for j = (i+1):num_files
                        % S'assurer que les deux fichiers ont des données valides
                        if isempty(muscle_data_by_file{i}) || isempty(muscle_data_by_file{j})
                            warning('Données insuffisantes pour la comparaison %s vs %s.', group_labels{i}, group_labels{j});
                            continue;
                        end
                        
                        % Titre pour l'analyse
                        analysis_title = title_str;
                        
                        % Préparer les données pour l'analyse SPM1D
                        if use_dtw
                            % Aligner les données avec DTW
                            fprintf('Alignement des courbes par DTW pour %s vs %s...\n', group_labels{i}, group_labels{j});
                            
                            % Calculer les moyennes des groupes pour l'alignement
                            mean_data1 = mean(muscle_data_by_file{i}, 1, 'omitnan');
                            mean_data2 = mean(muscle_data_by_file{j}, 1, 'omitnan');
                            
                            % Vérifier si la fonction DTW est disponible
                            if exist('dtw', 'file')
                                % Utiliser DTW pour aligner les moyennes
                                [~, ix, iy] = dtw(mean_data1, mean_data2);
                                
                                % Aligner chaque sujet du groupe 1 en utilisant les indices de DTW
                                aligned_data1 = zeros(size(muscle_data_by_file{i}, 1), length(ix));
                                for s = 1:size(muscle_data_by_file{i}, 1)
                                    aligned_curve = muscle_data_by_file{i}(s, ix);
                                    aligned_data1(s, :) = aligned_curve;
                                end
                                
                                % Aligner chaque sujet du groupe 2 en utilisant les indices de DTW
                                aligned_data2 = zeros(size(muscle_data_by_file{j}, 1), length(iy));
                                for s = 1:size(muscle_data_by_file{j}, 1)
                                    aligned_curve = muscle_data_by_file{j}(s, iy);
                                    aligned_data2(s, :) = aligned_curve;
                                end
                                
                                % Stocker les données alignées
                                aligned_data_by_file{i} = aligned_data1;
                                aligned_data_by_file{j} = aligned_data2;
                            else
                                warning('La fonction DTW n''est pas disponible. Utilisation des données non alignées.');
                                aligned_data1 = muscle_data_by_file{i};
                                aligned_data2 = muscle_data_by_file{j};
                                aligned_data_by_file{i} = aligned_data1;
                                aligned_data_by_file{j} = aligned_data2;
                            end
                        else
                            % Utiliser les données non alignées
                            fprintf('Utilisation des données non alignées pour %s vs %s...\n', group_labels{i}, group_labels{j});
                            aligned_data1 = muscle_data_by_file{i};
                            aligned_data2 = muscle_data_by_file{j};
                            aligned_data_by_file{i} = aligned_data1;
                            aligned_data_by_file{j} = aligned_data2;
                        end
                        
                        % Déterminer le type de test approprié
                        if (contains(group_labels{i}, 'Pre') && contains(group_labels{j}, 'Post')) || ...
                           (contains(group_labels{i}, 'Post') && contains(group_labels{j}, 'Pre'))
                            % Test apparié pour Pre vs Post (mêmes sujets)
                            fprintf('Type de test: Test t apparié (pour Pre vs Post).\n');
                            
                            % Vérifier que les dimensions correspondent
                            if size(aligned_data1, 1) ~= size(aligned_data2, 1)
                                warning('Nombre différent de sujets entre %s et %s. Test apparié impossible.', ...
                                    group_labels{i}, group_labels{j});
                                continue;
                            end
                            
                            % Exécuter le test apparié
                            spm = spm1d.stats.ttest_paired(aligned_data1, aligned_data2);
                        else
                            % Test indépendant pour les autres comparaisons
                            fprintf('Type de test: Test t pour échantillons indépendants.\n');
                            spm = spm1d.stats.ttest2(aligned_data1, aligned_data2);
                        end
                        
                        % Faire l'inférence statistique
                        spmi = spm.inference(0.05, 'two_tailed', true, 'interp', true);
                        
                        % Créer une nouvelle figure pour les résultats SPM1D
                        figure_title = sprintf('SPM1D - %s - %s vs %s', analysis_title, group_labels{i}, group_labels{j});
                        figure('Name', figure_title, 'Color', 'white', 'Position', [100+m*50+800, 100+m*30, 800, 500]);
                        
                        % Tracer les résultats SPM1D
                        subplot(2, 1, 1);
                        
                        % Normaliser l'axe du temps pour l'affichage
                        if use_dtw
                            % Avec DTW, normaliser à 0-100%
                            x_axis1 = linspace(0, 100, size(aligned_data1, 2));
                            x_axis2 = linspace(0, 100, size(aligned_data2, 2));
                        else
                            % Sans DTW, utiliser le temps normalisé d'origine
                            x_axis1 = time_normalized;
                            x_axis2 = time_normalized;
                        end
                        
                        % Tracer les moyennes des deux groupes
                        title_dtw_text = 'alignées (DTW)';
                        plot(x_axis1, mean(aligned_data1, 1, 'omitnan'), line_styles{i}, 'LineWidth', 2.5, 'Color', line_colors{i});
                        hold on;
                        plot(x_axis2, mean(aligned_data2, 1, 'omitnan'), line_styles{j}, 'LineWidth', 2.5, 'Color', line_colors{j});
                        title(sprintf('Moyennes EMG %s - %s vs %s', title_dtw_text, group_labels{i}, group_labels{j}), 'FontSize', 14);
    
                        xlabel_text = 'Temps normalisé (%)';
                        xlabel(xlabel_text, 'FontSize', 12);
                        ylabel('EMG normalisé (% MVC)', 'FontSize', 12);
                        legend({group_labels{i}, group_labels{j}}, 'Location', 'best', 'FontSize', 10);
                        grid on;

                        % Tracer les résultats statistiques dans le subplot inférieur
                        subplot(2, 1, 2);
                        spmi.plot();
                        spmi.plot_threshold_label();
                        spmi.plot_p_values();
                        title(sprintf('Analyse SPM1D - %s - %s vs %s', analysis_title, group_labels{i}, group_labels{j}), 'FontSize', 14);

                       % Pour les labels d'axes du subplot inférieur
                       xlabel_text_subplot = 'Temps normalisé (%)';
                       xlabel(xlabel_text_subplot, 'FontSize', 12);
                       ylabel('Statistique t', 'FontSize', 12);
                       grid on;
                    end
                end
            end
        end
    end
    
    fprintf('\n======== ANALYSE TERMINÉE ========\n');
    fprintf('Tracé des profils EMG terminé pour %d muscles.\n', nb_muscles);
    
    if select_cycle
        fprintf('Analyse avec moyenne de trois cycles terminée.\n');
        fprintf('Pour chaque muscle, %d cycles ont été sélectionnés et moyennés pour l''analyse SPM1D.\n', num_cycles);
    else
        fprintf('Analyse effectuée sur les courbes complètes.\n');
    end
    
    if use_dtw
        fprintf('Les courbes ont été alignées temporellement avec DTW avant l''analyse.\n');
    else
        fprintf('Aucun alignement temporel n''a été effectué.\n');
    end
    
    fprintf('\nNombre de fichiers analysés: %d\n', num_files);
    for f = 1:num_files
        fprintf('  - Fichier %d: %s (Groupe: %s)\n', f, file_labels{f}, group_labels{f});
    end
    
    fprintf('\nPour fermer toutes les figures: close all\n');
    fprintf('Pour exporter les figures: utiliser la fonction saveas() ou exportgraphics()\n\n');
end