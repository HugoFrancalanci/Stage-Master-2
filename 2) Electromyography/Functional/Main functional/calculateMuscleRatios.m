function calculateMuscleRatios(emg_all_subjects_R, emg_all_subjects_L, muscles_R, muscles_L, functional_labels, selected_functional, nb_subjects)
    
    % Définition des paires de muscles à analyser
    muscle_pairs = {
        {'DELTA', 'DELTM'}, 'AD/MD';
        {'DELTP', 'DELTM'}, 'PD/MD';
        {'TRAPS', 'SERRA'}, 'UT/AS';
        {'TRAPM', 'SERRA'}, 'MT/AS';
    };
    
    % Liste des sujets disponibles
    subject_ids = 1:nb_subjects;
    
    % Débogage - Afficher les muscles disponibles
    disp('===== MUSCLES DISPONIBLES =====');
    disp('Muscles côté droit:');
    disp(muscles_R);
    disp('Muscles côté gauche:');
    disp(muscles_L);
    
    % Affichage du titre et des options
    fprintf('\n===== Calcul des ratios musculaires avec sélection des sujets =====\n');
    fprintf('1. Sélectionner des sujets côté droit uniquement\n');
    fprintf('2. Sélectionner des sujets côté gauche uniquement\n');
    fprintf('3. Sélectionner des sujets pour les deux côtés (même sélection)\n');
    fprintf('4. Sélectionner des sujets indépendamment pour chaque côté\n');
    fprintf('5. Sélectionner des sujets indépendamment pour chaque côté et combiner les résultats\n');
    choice = input('Choisissez une option (1-5) pour le ratio musculaire : ');
    
    % Initialisation des variables
    selected_subjects_R = [];
    selected_subjects_L = [];
    display_right = false;
    display_left = false;
    display_combined = false;
    
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
        
        case 5 % Sélection indépendante et combinaison des résultats
            disp('Liste des sujets disponibles pour le côté DROIT :');
            disp(subject_ids);
            selected_subjects_R = input('Entrez les numéros des sujets pour le côté DROIT (ex: [1 3 5 7]) ou [] pour aucun : ');
            
            disp('Liste des sujets disponibles pour le côté GAUCHE :');
            disp(subject_ids);
            selected_subjects_L = input('Entrez les numéros des sujets pour le côté GAUCHE (ex: [2 4 6 8]) ou [] pour aucun : ');
            
            % Pour l'option 5, on affiche uniquement les résultats combinés
            display_right = false;
            display_left = false;
            display_combined = true;
            
        otherwise
            error('Option non valide. Veuillez choisir entre 1 et 5.');
    end
    
    % Vérification des sélections
    if (display_right || display_combined) && (any(selected_subjects_R > nb_subjects) || any(selected_subjects_R < 1))
        error('Indices des sujets hors limites pour le côté droit.');
    end
    
    if (display_left || display_combined) && (any(selected_subjects_L > nb_subjects) || any(selected_subjects_L < 1))
        error('Indices des sujets hors limites pour le côté gauche.');
    end
    
    % Niveau de confiance pour l'intervalle (généralement 95%)
    confidence_level = 0.95;
    
    % Initialisation des tableaux pour stocker les résultats
    Sujet = cell(0);
    Cote = cell(0);
    Paire = cell(0);
    Muscle1 = cell(0);
    Muscle2 = cell(0);
    Ratio = zeros(0, 1);
    Ecart_Type = zeros(0, 1);
    IC_Inf = zeros(0, 1);
    IC_Sup = zeros(0, 1);
    Interpretation = cell(0);
    
    % Stockage des données pour le barplot
    plot_data = struct();
    
    % Affichage des informations sur les sujets sélectionnés
    fprintf('\n===== Sujets sélectionnés =====\n');
    if display_right || display_combined
        fprintf('Côté DROIT : %s (n=%d)\n', mat2str(selected_subjects_R), length(selected_subjects_R));
    end
    if display_left || display_combined
        fprintf('Côté GAUCHE : %s (n=%d)\n', mat2str(selected_subjects_L), length(selected_subjects_L));
    end
    if display_combined
        fprintf('COMBINÉS pour analyse\n');
    end
    
    fprintf('\nRatios musculaires pour %s:\n', functional_labels{selected_functional});
    
    row_idx = 1; % Index pour le tableau de résultats
    
    for p = 1:size(muscle_pairs, 1)
        muscle1_base = muscle_pairs{p, 1}{1};
        muscle2_base = muscle_pairs{p, 1}{2};
        pair_code = muscle_pairs{p, 2};
        
        muscle1_R = ['R' muscle1_base];
        muscle2_R = ['R' muscle2_base];
        muscle1_L = ['L' muscle1_base];
        muscle2_L = ['L' muscle2_base];
        
        % Débogage - afficher ce qu'on cherche
        fprintf('\n===== RECHERCHE PAIRE %s =====\n', pair_code);
        fprintf('Cherche muscles côté droit: %s et %s\n', muscle1_R, muscle2_R);
        fprintf('Cherche muscles côté gauche: %s et %s\n', muscle1_L, muscle2_L);
        
        % MODIFICATION: Utiliser contains au lieu de strcmp pour être moins strict
        muscle1_idx_R = find(contains(muscles_R, muscle1_base));
        muscle2_idx_R = find(contains(muscles_R, muscle2_base));
        muscle1_idx_L = find(contains(muscles_L, muscle1_base));
        muscle2_idx_L = find(contains(muscles_L, muscle2_base));
        
        % Débogage - afficher les résultats de la recherche
        fprintf('Indices trouvés côté droit: %s et %s\n', mat2str(muscle1_idx_R), mat2str(muscle2_idx_R));
        fprintf('Indices trouvés côté gauche: %s et %s\n', mat2str(muscle1_idx_L), mat2str(muscle2_idx_L));
        
        % En cas de multiples correspondances, prendre la première
        if length(muscle1_idx_R) > 1, muscle1_idx_R = muscle1_idx_R(1); end
        if length(muscle2_idx_R) > 1, muscle2_idx_R = muscle2_idx_R(1); end
        if length(muscle1_idx_L) > 1, muscle1_idx_L = muscle1_idx_L(1); end
        if length(muscle2_idx_L) > 1, muscle2_idx_L = muscle2_idx_L(1); end
        
        % Côté droit
        ratios_R = [];
        if (display_right || display_combined) && ~isempty(muscle1_idx_R) && ~isempty(muscle2_idx_R)
            ratios_R = NaN(1, length(selected_subjects_R)); % Utiliser NaN par défaut
            
            % Calcul des ratios pour chaque sujet sélectionné
            for i = 1:length(selected_subjects_R)
                s = selected_subjects_R(i);
                if s <= size(emg_all_subjects_R, 1) % Vérifier que le sujet existe
                    sig1_R = squeeze(emg_all_subjects_R(s, :, muscle1_idx_R));
                    sig2_R = squeeze(emg_all_subjects_R(s, :, muscle2_idx_R));
                    
                    rR = calculate_muscle_ratio(sig1_R, sig2_R);
                    ratios_R(i) = rR;
                    
                    % Ajouter à la table - côté droit (seulement si on affiche les côtés séparés)
                    if display_right
                        Sujet{row_idx} = s;
                        Cote{row_idx} = 'D';
                        Paire{row_idx} = pair_code;
                        Muscle1{row_idx} = muscle1_R;
                        Muscle2{row_idx} = muscle2_R;
                        Ratio(row_idx) = rR;
                        Ecart_Type(row_idx) = NaN; % Non applicable pour un sujet individuel
                        IC_Inf(row_idx) = NaN;     % Non applicable pour un sujet individuel
                        IC_Sup(row_idx) = NaN;     % Non applicable pour un sujet individuel
                        Interpretation{row_idx} = evaluate_muscle_ratio(rR, pair_code);
                        row_idx = row_idx + 1;
                    end
                end
            end
            
            % Calculer les statistiques si des données valides existent
            valid_data_R = ~isnan(ratios_R);
            if any(valid_data_R) && display_right
                mean_R = nanmean(ratios_R);
                std_R = nanstd(ratios_R);
                n_subjects_R = sum(valid_data_R);
                
                % Calcul de l'intervalle de confiance
                sem_R = std_R / sqrt(n_subjects_R);
                t_critical = tinv((1 + confidence_level) / 2, n_subjects_R - 1);
                ci_lower_R = mean_R - t_critical * sem_R;
                ci_upper_R = mean_R + t_critical * sem_R;
                
                % Ajouter ligne moyenne droite
                Sujet{row_idx} = 'Moy';
                Cote{row_idx} = 'D';
                Paire{row_idx} = pair_code;
                Muscle1{row_idx} = muscle1_R;
                Muscle2{row_idx} = muscle2_R;
                Ratio(row_idx) = mean_R;
                Ecart_Type(row_idx) = std_R;
                IC_Inf(row_idx) = ci_lower_R;
                IC_Sup(row_idx) = ci_upper_R;
                Interpretation{row_idx} = evaluate_muscle_ratio(mean_R, pair_code);
                row_idx = row_idx + 1;
                
                % Stocker pour le plot
                valid_pair_code = strrep(pair_code, '/', '_');
                plot_data.(sprintf('%s_R', valid_pair_code)) = struct('mean', mean_R, 'std', std_R, 'ci_lower', ci_lower_R, 'ci_upper', ci_upper_R);
            elseif ~any(valid_data_R) && display_right
                warning('Aucune donnée valide pour le côté droit de la paire %s', pair_code);
            end
        end
        
        % Côté gauche
        ratios_L = [];
        if (display_left || display_combined) && ~isempty(muscle1_idx_L) && ~isempty(muscle2_idx_L)
            ratios_L = NaN(1, length(selected_subjects_L)); % Utiliser NaN par défaut
            
            % Calcul des ratios pour chaque sujet sélectionné
            for i = 1:length(selected_subjects_L)
                s = selected_subjects_L(i);
                if s <= size(emg_all_subjects_L, 1) % Vérifier que le sujet existe
                    sig1_L = squeeze(emg_all_subjects_L(s, :, muscle1_idx_L));
                    sig2_L = squeeze(emg_all_subjects_L(s, :, muscle2_idx_L));
                    
                    rL = calculate_muscle_ratio(sig1_L, sig2_L);
                    ratios_L(i) = rL;
                    
                    % Ajouter à la table - côté gauche (seulement si on affiche les côtés séparés)
                    if display_left
                        Sujet{row_idx} = s;
                        Cote{row_idx} = 'G';
                        Paire{row_idx} = pair_code;
                        Muscle1{row_idx} = muscle1_L;
                        Muscle2{row_idx} = muscle2_L;
                        Ratio(row_idx) = rL;
                        Ecart_Type(row_idx) = NaN; % Non applicable pour un sujet individuel
                        IC_Inf(row_idx) = NaN;     % Non applicable pour un sujet individuel
                        IC_Sup(row_idx) = NaN;     % Non applicable pour un sujet individuel
                        Interpretation{row_idx} = evaluate_muscle_ratio(rL, pair_code);
                        row_idx = row_idx + 1;
                    end
                end
            end
            
            % Calculer les statistiques si des données valides existent
            valid_data_L = ~isnan(ratios_L);
            if any(valid_data_L) && display_left
                mean_L = nanmean(ratios_L);
                std_L = nanstd(ratios_L);
                n_subjects_L = sum(valid_data_L);
                
                % Calcul de l'intervalle de confiance
                sem_L = std_L / sqrt(n_subjects_L);
                t_critical = tinv((1 + confidence_level) / 2, n_subjects_L - 1);
                ci_lower_L = mean_L - t_critical * sem_L;
                ci_upper_L = mean_L + t_critical * sem_L;
                
                % Ajouter ligne moyenne gauche
                Sujet{row_idx} = 'Moy';
                Cote{row_idx} = 'G';
                Paire{row_idx} = pair_code;
                Muscle1{row_idx} = muscle1_L;
                Muscle2{row_idx} = muscle2_L;
                Ratio(row_idx) = mean_L;
                Ecart_Type(row_idx) = std_L;
                IC_Inf(row_idx) = ci_lower_L;
                IC_Sup(row_idx) = ci_upper_L;
                Interpretation{row_idx} = evaluate_muscle_ratio(mean_L, pair_code);
                row_idx = row_idx + 1;
                
                % Stocker pour le plot
                valid_pair_code = strrep(pair_code, '/', '_');
                plot_data.(sprintf('%s_L', valid_pair_code)) = struct('mean', mean_L, 'std', std_L, 'ci_lower', ci_lower_L, 'ci_upper', ci_upper_L);
            elseif ~any(valid_data_L) && display_left
                warning('Aucune donnée valide pour le côté gauche de la paire %s', pair_code);
            end
        end
        
        % Combinaison des résultats (option 5)
        if display_combined
            % Combiner les ratios valides des deux côtés
            ratios_combined = [];
            
            % Ajouter les ratios valides du côté droit
            if ~isempty(ratios_R)
                valid_indices = ~isnan(ratios_R);
                ratios_combined = [ratios_combined, ratios_R(valid_indices)];
            end
            
            % Ajouter les ratios valides du côté gauche
            if ~isempty(ratios_L)
                valid_indices = ~isnan(ratios_L);
                ratios_combined = [ratios_combined, ratios_L(valid_indices)];
            end
            
            % Calculer les statistiques combinées si des données existent
            if ~isempty(ratios_combined)
                mean_combined = mean(ratios_combined);
                std_combined = std(ratios_combined);
                n_combined = length(ratios_combined);
                
                % Calcul de l'intervalle de confiance
                sem_combined = std_combined / sqrt(n_combined);
                t_critical = tinv((1 + confidence_level) / 2, n_combined - 1);
                ci_lower_combined = mean_combined - t_critical * sem_combined;
                ci_upper_combined = mean_combined + t_critical * sem_combined;
                
                % Ajouter les résultats individuels à la table
                for i = 1:length(ratios_combined)
                    if i <= length(ratios_R(~isnan(ratios_R)))
                        % C'est un ratio du côté droit
                        s_idx = find(~isnan(ratios_R), i);
                        if ~isempty(s_idx) && length(s_idx) >= i
                            s = selected_subjects_R(s_idx(i));
                            side = 'D';
                            muscle1 = muscle1_R;
                            muscle2 = muscle2_R;
                        else
                            continue;
                        end
                    else
                        % C'est un ratio du côté gauche
                        adjusted_i = i - length(ratios_R(~isnan(ratios_R)));
                        s_idx = find(~isnan(ratios_L), adjusted_i);
                        if ~isempty(s_idx) && length(s_idx) >= adjusted_i
                            s = selected_subjects_L(s_idx(adjusted_i));
                            side = 'G';
                            muscle1 = muscle1_L;
                            muscle2 = muscle2_L;
                        else
                            continue;
                        end
                    end
                    
                    Sujet{row_idx} = s;
                    Cote{row_idx} = side;
                    Paire{row_idx} = pair_code;
                    Muscle1{row_idx} = muscle1;
                    Muscle2{row_idx} = muscle2;
                    Ratio(row_idx) = ratios_combined(i);
                    Ecart_Type(row_idx) = NaN; % Non applicable pour un sujet individuel
                    IC_Inf(row_idx) = NaN;
                    IC_Sup(row_idx) = NaN;
                    Interpretation{row_idx} = evaluate_muscle_ratio(ratios_combined(i), pair_code);
                    row_idx = row_idx + 1;
                end
                
                % Ajouter ligne moyenne combinée
                Sujet{row_idx} = 'Moy';
                Cote{row_idx} = 'C'; % C pour Combiné
                Paire{row_idx} = pair_code;
                Muscle1{row_idx} = [muscle1_base ' (D+G)']; 
                Muscle2{row_idx} = [muscle2_base ' (D+G)'];
                Ratio(row_idx) = mean_combined;
                Ecart_Type(row_idx) = std_combined;
                IC_Inf(row_idx) = ci_lower_combined;
                IC_Sup(row_idx) = ci_upper_combined;
                Interpretation{row_idx} = evaluate_muscle_ratio(mean_combined, pair_code);
                row_idx = row_idx + 1;
                
                % Stocker pour le plot
                valid_pair_code = strrep(pair_code, '/', '_');
                plot_data.(sprintf('%s_C', valid_pair_code)) = struct('mean', mean_combined, 'std', std_combined, 'ci_lower', ci_lower_combined, 'ci_upper', ci_upper_combined);
            else
                warning('Aucune donnée valide combinée pour la paire %s', pair_code);
            end
        end
    end
    
    % Génération de la table finale (seulement si des données existent)
    if row_idx > 1
        T = table(Sujet', Cote', Paire', Muscle1', Muscle2', Ratio', Ecart_Type', IC_Inf', IC_Sup', Interpretation', ...
            'VariableNames', {'Sujet', 'Côté', 'Paire', 'Muscle1', 'Muscle2', 'Ratio', 'Ecart_Type', 'IC_Inf', 'IC_Sup', 'Interpretation'});
        
        % Affichage dans MATLAB
        disp(T);
        
        % Créer le barplot
        if ~isempty(fieldnames(plot_data))
            % Déterminer quels côtés afficher pour le plot
            plot_sides = 0;
            if display_right, plot_sides = plot_sides + 1; end
            if display_left, plot_sides = plot_sides + 2; end
            if display_combined, plot_sides = plot_sides + 4; end
            
            % Modifier la fonction plotMuscleRatios pour gérer l'option combinée
            plotMuscleRatios(plot_data, muscle_pairs, display_right, display_left, display_combined, functional_labels, selected_functional);
        else
            warning('Aucune donnée disponible pour le graphique');
        end
    else
        warning('Aucune donnée valide trouvée pour l''analyse');
    end
end
