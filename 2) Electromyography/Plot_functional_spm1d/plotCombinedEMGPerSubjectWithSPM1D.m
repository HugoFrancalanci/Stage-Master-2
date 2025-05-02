function plotCombinedEMGPerSubjectWithSPM1D(data_files, use_dtw)
    % Cette fonction trace les profils EMG moyens des 4 mouvements combinés 
    % pour tous les sujets, avec une figure distincte pour chaque muscle,
    % réalise un alignement par DTW et une analyse SPM1D pour comparer les groupes
    %
    % Paramètres:
    %   data_files - Cellule contenant les chemins des fichiers .mat (jusqu'à 3)
    %               ou chaîne de caractères pour un seul fichier
    addpath(genpath('C:\Users\Francalanci Hugo\Documents\MATLAB\Stage Sainte-Justine\HUG\Statistics\spm1dmatlab-master'))  
    % Vérifier si l'utilisateur a spécifié d'utiliser DTW ou non
    if nargin < 2
        use_dtw = true; % Par défaut, utiliser DTW
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
        
                    % Réaliser les analyses SPM1D
        if num_files > 1
            % Vérifier que SPM1D est installé
            addpath(genpath('C:\Users\Francalanci Hugo\Documents\MATLAB\Stage Sainte-Justine\HUG\Statistics\spm1dmatlab-master'))  
                
                % Créer toutes les comparaisons possibles
                for i = 1:num_files
                    for j = (i+1):num_files
                        % Préparer les données pour l'analyse SPM1D
                        data1 = muscle_data_by_file{i};
                        data2 = muscle_data_by_file{j};
                        
                        % Préparer les données pour l'analyse SPM1D
                        if use_dtw
                            % Aligner les données avec DTW si demandé
                            fprintf('Alignement des courbes par DTW pour %s vs %s...\n', group_labels{i}, group_labels{j});
                            
                            % Calculer les moyennes des groupes pour l'alignement
                            mean_data1 = mean(data1, 1, 'omitnan');
                            mean_data2 = mean(data2, 1, 'omitnan');
                            
                            % Vérifier si la fonction DTW est disponible
                            if exist('dtw', 'file')
                                % Utiliser DTW pour aligner les moyennes
                                [~, ix, iy] = dtw(mean_data1, mean_data2);
                                
                                % Aligner chaque sujet du groupe 1 en utilisant les indices de DTW
                                aligned_data1 = zeros(size(data1, 1), length(ix));
                                for s = 1:size(data1, 1)
                                    aligned_curve = data1(s, ix);
                                    aligned_data1(s, :) = aligned_curve;
                                end
                                
                                % Aligner chaque sujet du groupe 2 en utilisant les indices de DTW
                                aligned_data2 = zeros(size(data2, 1), length(iy));
                                for s = 1:size(data2, 1)
                                    aligned_curve = data2(s, iy);
                                    aligned_data2(s, :) = aligned_curve;
                                end
                            else
                                warning('La fonction DTW n''est pas disponible. Utilisation des données non alignées.');
                                aligned_data1 = data1;
                                aligned_data2 = data2;
                            end
                        else
                            % Utiliser les données non alignées
                            fprintf('Utilisation des données non alignées pour %s vs %s...\n', group_labels{i}, group_labels{j});
                            aligned_data1 = data1;
                            aligned_data2 = data2;
                        end
                        
                        % Utiliser les données alignées pour l'analyse SPM1D
                        fprintf('Analyse SPM1D sur données alignées: %s vs %s\n', group_labels{i}, group_labels{j});
                        
                        % Choisir le test approprié en fonction des groupes
                        if (strcmp(group_labels{i}, 'Pre') && strcmp(group_labels{j}, 'Post')) || ...
                           (strcmp(group_labels{i}, 'Post') && strcmp(group_labels{j}, 'Pre'))
                            % Test apparié pour Pre vs Post (mêmes sujets)
                            fprintf('Analyse SPM1D: Test apparié pour %s vs %s\n', group_labels{i}, group_labels{j});
                            
                            % Vérifier que les dimensions correspondent
                            if size(aligned_data1, 1) ~= size(aligned_data2, 1)
                                warning('Nombre différent de sujets entre %s et %s. Test apparié impossible.', ...
                                    group_labels{i}, group_labels{j});
                                continue;
                            end
                            
                            % Exécuter le test apparié sur données alignées
                            spm = spm1d.stats.ttest_paired(aligned_data1, aligned_data2);
                        else
                            % Test indépendant pour les autres comparaisons
                            fprintf('Analyse SPM1D: Test indépendant pour %s vs %s\n', group_labels{i}, group_labels{j});
                            spm = spm1d.stats.ttest2(aligned_data1, aligned_data2);
                        end
                        
                        % Faire l'inférence statistique
                        spmi = spm.inference(0.05, 'two_tailed', true, 'interp', true);
                        
                        % Créer une nouvelle figure pour les résultats SPM1D
                        figure('Name', sprintf('SPM1D - %s - %s vs %s', title_str, group_labels{i}, group_labels{j}), ...
                               'Color', 'white', 'Position', [100+m*50, 100+m*30, 800, 500]);
                        
                        % Tracer les résultats SPM1D
                        subplot(2, 1, 1);
                        % Tracer les moyennes des deux groupes (données alignées)
                        time_idx1 = 1:length(mean(aligned_data1, 1, 'omitnan'));
                        time_idx2 = 1:length(mean(aligned_data2, 1, 'omitnan'));
                        
                        % Normaliser les indices pour l'axe X
                        time_axis1 = linspace(min(time_normalized), max(time_normalized), length(time_idx1));
                        time_axis2 = linspace(min(time_normalized), max(time_normalized), length(time_idx2));
                        
                        plot(time_axis1, mean(aligned_data1, 1, 'omitnan'), line_styles{i}, 'LineWidth', 2.5, 'Color', line_colors{i});
                        hold on;
                        plot(time_axis2, mean(aligned_data2, 1, 'omitnan'), line_styles{j}, 'LineWidth', 2.5, 'Color', line_colors{j});
                        title(sprintf('Moyennes EMG alignées (DTW) - %s - %s vs %s', title_str, group_labels{i}, group_labels{j}), 'FontSize', 14);
                        xlabel('Temps normalisé (%)', 'FontSize', 12);
                        ylabel('EMG normalisé (% MVC)', 'FontSize', 12);
                        legend({[group_labels{i} ' (aligné)'], [group_labels{j} ' (aligné)']}, 'Location', 'best');
                        grid on;
                        
                        % Tracer les résultats statistiques dans le subplot inférieur
                        subplot(2, 1, 2);
                        spmi.plot();
                        spmi.plot_threshold_label();
                        spmi.plot_p_values();
                        title(sprintf('Analyse SPM1D - %s - %s vs %s', title_str, group_labels{i}, group_labels{j}), 'FontSize', 14);
                        xlabel('Temps normalisé (%)', 'FontSize', 12);
                        ylabel('Statistique t', 'FontSize', 12);
                        grid on;
                    end
                end
            end
    end
    
    fprintf('\nTracé des profils EMG terminé. %d figures créées.\n', nb_muscles);
end