function calculateSNRWithCal3(subjects, muscles_R, muscles_L, selected_functional, base_path)
    % Paramètres pour le filtrage et le traitement des signaux
    fs = 2000; % fréquence d'échantillonnage
    fcLow = 15; % fréquence de coupure basse (Hz)
    fcHigh = 475; % fréquence de coupure haute (Hz)
    [b, a] = butter(4, [fcLow/(fs/2) fcHigh/(fs/2)], 'bandpass');
    
    % Initialisation des variables
    nb_subjects = length(subjects);
    nb_muscles_R = length(muscles_R);
    nb_muscles_L = length(muscles_L);
    
    % Affichage du titre et des options
    fprintf('\n===== Calcul du SNR avec sélection des sujets =====\n');
    fprintf('1. Sélectionner des sujets côté droit uniquement\n');
    fprintf('2. Sélectionner des sujets côté gauche uniquement\n');
    fprintf('3. Sélectionner des sujets pour les deux côtés (même sélection)\n');
    fprintf('4. Sélectionner des sujets indépendamment pour chaque côté\n');
    fprintf('5. Sélectionner des sujets indépendamment pour chaque côté et combiner les résultats\n');
    choice = input('Choisissez une option (1-5) pour le SNR : ');
    
    % Liste des sujets disponibles
    subject_ids = 1:nb_subjects;
    
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
    
    % Tableaux pour stocker les SNRs
    if display_right
        snr_values_R = zeros(length(selected_subjects_R), nb_muscles_R);
    end
    
    if display_left
        snr_values_L = zeros(length(selected_subjects_L), nb_muscles_L);
    end
    
    if display_combined
        % Trouver les muscles communs entre les deux côtés
        common_muscles = {};
        muscle_indices_R = [];
        muscle_indices_L = [];
        
        % Enlever le préfixe R ou L pour comparer les noms de muscles
        muscles_R_base = cellfun(@(m) m(2:end), muscles_R, 'UniformOutput', false);
        muscles_L_base = cellfun(@(m) m(2:end), muscles_L, 'UniformOutput', false);
        
        % Identifier les muscles communs
        for i = 1:length(muscles_R_base)
            for j = 1:length(muscles_L_base)
                if strcmp(muscles_R_base{i}, muscles_L_base{j})
                    common_muscles{end+1} = muscles_R_base{i};
                    muscle_indices_R(end+1) = i;
                    muscle_indices_L(end+1) = j;
                    break;
                end
            end
        end
        
        if isempty(common_muscles)
            warning('Aucun muscle commun trouvé entre les côtés droit et gauche.');
            display_combined = false;
        else
            % Initialiser les tableaux pour les valeurs SNR combinées
            snr_values_R_combined = zeros(length(selected_subjects_R), length(common_muscles));
            snr_values_L_combined = zeros(length(selected_subjects_L), length(common_muscles));
        end
    end
    
    % Affichage des informations sur les sujets sélectionnés
    fprintf('\n===== Sujets sélectionnés =====\n');
    if display_right
        fprintf('Côté DROIT : %s (n=%d)\n', mat2str(selected_subjects_R), length(selected_subjects_R));
    end
    if display_left
        fprintf('Côté GAUCHE : %s (n=%d)\n', mat2str(selected_subjects_L), length(selected_subjects_L));
    end
    if display_combined
        fprintf('Côté DROIT : %s (n=%d)\n', mat2str(selected_subjects_R), length(selected_subjects_R));
        fprintf('Côté GAUCHE : %s (n=%d)\n', mat2str(selected_subjects_L), length(selected_subjects_L));
        fprintf('COMBINÉS pour analyse\n');
    end
    fprintf('\n');
    
    % Traitement pour le côté droit
    if display_right || display_combined
        % Pour chaque sujet sélectionné
        for i = 1:length(selected_subjects_R)
            subj_idx = selected_subjects_R(i);
            fprintf('Traitement du sujet %s (Droit) (%d/%d)\n', subjects{subj_idx}, i, length(selected_subjects_R));
            
            % Charger les données de calibration 3 (bruit)
            cal3_file = sprintf('%s\\%s\\%s-PROTOCOL01-CALIBRATION3-01.c3d', ...
                base_path, subjects{subj_idx}, subjects{subj_idx});
            
            if ~exist(cal3_file, 'file')
                warning('Fichier calibration3 introuvable pour le sujet %s', subjects{subj_idx});
                continue;
            end
            
            % Charger les données fonctionnelles (signal)
            func_file = sprintf('%s\\%s\\%s-PROTOCOL01-FUNCTIONAL%d-01.c3d', ...
                base_path, subjects{subj_idx}, subjects{subj_idx}, selected_functional);
            
            if ~exist(func_file, 'file')
                warning('Fichier fonctionnel introuvable pour le sujet %s', subjects{subj_idx});
                continue;
            end
            
            % Lecture des fichiers
            cal3_data = btkReadAcquisition(cal3_file);
            func_data = btkReadAcquisition(func_file);
            
            % Récupération des données EMG
            cal3_analogs = btkGetAnalogs(cal3_data);
            func_analogs = btkGetAnalogs(func_data);
            
            % Traitement des muscles droits
            for m = 1:nb_muscles_R
                muscle = muscles_R{m};
                
                % Vérifier que les deux signaux existent
                if ~isfield(cal3_analogs, muscle) || ~isfield(func_analogs, muscle)
                    fprintf('Signal %s manquant pour le sujet %s\n', muscle, subjects{subj_idx});
                    continue;
                end
                
                % Récupération des signaux bruts
                cal3_raw = cal3_analogs.(muscle);
                func_raw = func_analogs.(muscle);
                
                % Filtrage des signaux
                cal3_filtered = filtfilt(b, a, cal3_raw);
                func_filtered = filtfilt(b, a, func_raw);
                
                % Calcul du SNR (puissance du signal / puissance du bruit)
                noise_power = mean(cal3_filtered.^2);
                signal_power = mean(maxk(func_filtered.^2, 100));
                
                if signal_power > noise_power
                    snr_db = 10 * log10(signal_power / noise_power);
                else
                    snr_db = 0; % Si le signal est plus faible que le bruit
                end
                
                % Limiter à des valeurs raisonnables
                snr_db = min(50, max(0, snr_db));
                
                % Stockage du résultat pour l'affichage individuel
                if display_right
                    snr_values_R(i, m) = snr_db;
                end
                
                % Stockage pour l'analyse combinée
                if display_combined
                    % Vérifier si ce muscle est dans la liste des muscles communs
                    common_idx = find(muscle_indices_R == m);
                    if ~isempty(common_idx)
                        snr_values_R_combined(i, common_idx) = snr_db;
                    end
                end
                
                fprintf('  SNR %s (D): %.2f dB\n', muscle, snr_db);
            end
        end
    end
    
    % Traitement pour le côté gauche
    if display_left || display_combined
        % Pour chaque sujet sélectionné
        for i = 1:length(selected_subjects_L)
            subj_idx = selected_subjects_L(i);
            fprintf('Traitement du sujet %s (Gauche) (%d/%d)\n', subjects{subj_idx}, i, length(selected_subjects_L));
            
            % Charger les données de calibration 3 (bruit)
            cal3_file = sprintf('%s\\%s\\%s-PROTOCOL01-CALIBRATION3-01.c3d', ...
                base_path, subjects{subj_idx}, subjects{subj_idx});
            
            if ~exist(cal3_file, 'file')
                warning('Fichier calibration3 introuvable pour le sujet %s', subjects{subj_idx});
                continue;
            end
            
            % Charger les données fonctionnelles (signal)
            func_file = sprintf('%s\\%s\\%s-PROTOCOL01-FUNCTIONAL%d-01.c3d', ...
                base_path, subjects{subj_idx}, subjects{subj_idx}, selected_functional);
            
            if ~exist(func_file, 'file')
                warning('Fichier fonctionnel introuvable pour le sujet %s', subjects{subj_idx});
                continue;
            end
            
            % Lecture des fichiers
            cal3_data = btkReadAcquisition(cal3_file);
            func_data = btkReadAcquisition(func_file);
            
            % Récupération des données EMG
            cal3_analogs = btkGetAnalogs(cal3_data);
            func_analogs = btkGetAnalogs(func_data);
            
            % Traitement des muscles gauches
            for m = 1:nb_muscles_L
                muscle = muscles_L{m};
                
                % Vérifier que les deux signaux existent
                if ~isfield(cal3_analogs, muscle) || ~isfield(func_analogs, muscle)
                    fprintf('Signal %s manquant pour le sujet %s\n', muscle, subjects{subj_idx});
                    continue;
                end
                
                % Récupération des signaux bruts
                cal3_raw = cal3_analogs.(muscle);
                func_raw = func_analogs.(muscle);
                
                % Filtrage des signaux
                cal3_filtered = filtfilt(b, a, cal3_raw);
                func_filtered = filtfilt(b, a, func_raw);
                
                % Calcul du SNR (puissance du signal / puissance du bruit)
                noise_power = mean(cal3_filtered.^2);
                signal_power = mean(maxk(func_filtered.^2, 100));
                
                if signal_power > noise_power
                    snr_db = 10 * log10(signal_power / noise_power);
                else
                    snr_db = 0; % Si le signal est plus faible que le bruit
                end
                
                % Limiter à des valeurs raisonnables
                snr_db = min(50, max(0, snr_db));
                
                % Stockage du résultat pour l'affichage individuel
                if display_left
                    snr_values_L(i, m) = snr_db;
                end
                
                % Stockage pour l'analyse combinée
                if display_combined
                    % Vérifier si ce muscle est dans la liste des muscles communs
                    common_idx = find(muscle_indices_L == m);
                    if ~isempty(common_idx)
                        snr_values_L_combined(i, common_idx) = snr_db;
                    end
                end
                
                fprintf('  SNR %s (G): %.2f dB\n', muscle, snr_db);
            end
        end
    end
    
    % Affichage des résultats et graphiques
    if display_right
        % Ajouter des statistiques
        stats_R = [mean(snr_values_R, 'omitnan'); std(snr_values_R, 'omitnan'); median(snr_values_R, 'omitnan')];
        
        T_stats_R = array2table(stats_R, 'VariableNames', muscles_R, 'RowNames', {'Moyenne', 'Écart-type', 'Médiane'});
        
        fprintf('\nRésultats moyens SNR (dB) - Côté droit:\n');
        disp(T_stats_R);
        
        % Visualisation des résultats côté droit
        figure('Name', 'SNR par muscle et sujet - Côté droit', 'Position', [100, 100, 600, 400]);
        boxplot(snr_values_R, 'Labels', muscles_R);
        title(['SNR Côté droit - ' num2str(length(selected_subjects_R)) ' sujets']);
        ylabel('SNR (dB)');
        grid on;
    end
    
    if display_left
        % Ajouter des statistiques
        stats_L = [mean(snr_values_L, 'omitnan'); std(snr_values_L, 'omitnan'); median(snr_values_L, 'omitnan')];
        
        T_stats_L = array2table(stats_L, 'VariableNames', muscles_L, 'RowNames', {'Moyenne', 'Écart-type', 'Médiane'});
        
        fprintf('\nRésultats moyens SNR (dB) - Côté gauche:\n');
        disp(T_stats_L);
        
        % Visualisation des résultats côté gauche
        figure('Name', 'SNR par muscle et sujet - Côté gauche', 'Position', [700, 100, 600, 400]);
        boxplot(snr_values_L, 'Labels', muscles_L);
        title(['SNR Côté gauche - ' num2str(length(selected_subjects_L)) ' sujets']);
        ylabel('SNR (dB)');
        grid on;
    end
    
    % Si les deux côtés sont affichés individuellement, créer une figure comparée
    if display_right && display_left
        figure('Name', 'SNR par muscle et sujet - Comparaison', 'Position', [300, 500, 1200, 600]);
        
        % SNR côté droit
        subplot(1, 2, 1);
        boxplot(snr_values_R, 'Labels', muscles_R);
        title(['SNR Côté droit - ' num2str(length(selected_subjects_R)) ' sujets']);
        ylabel('SNR (dB)');
        grid on;
        
        % SNR côté gauche
        subplot(1, 2, 2);
        boxplot(snr_values_L, 'Labels', muscles_L);
        title(['SNR Côté gauche - ' num2str(length(selected_subjects_L)) ' sujets']);
        ylabel('SNR (dB)');
        grid on;
    end
    
    % Si l'option combinée est sélectionnée, traiter et afficher les résultats combinés
    if display_combined && ~isempty(common_muscles)
        % Combiner les données des deux côtés
        all_snr_values = [];
        all_muscle_labels = {};
        all_subjects = {};
        all_sides = {};
        
        % Ajouter les données du côté droit
        for i = 1:length(selected_subjects_R)
            for m = 1:length(common_muscles)
                all_snr_values(end+1) = snr_values_R_combined(i, m);
                all_muscle_labels{end+1} = common_muscles{m};
                all_subjects{end+1} = num2str(selected_subjects_R(i));
                all_sides{end+1} = 'D';
            end
        end
        
        % Ajouter les données du côté gauche
        for i = 1:length(selected_subjects_L)
            for m = 1:length(common_muscles)
                all_snr_values(end+1) = snr_values_L_combined(i, m);
                all_muscle_labels{end+1} = common_muscles{m};
                all_subjects{end+1} = num2str(selected_subjects_L(i));
                all_sides{end+1} = 'G';
            end
        end
        
        % Création de la table de données
        combined_data = table(all_snr_values', all_muscle_labels', all_sides', all_subjects', ...
            'VariableNames', {'SNR', 'Muscle', 'Cote', 'Sujet'});
        
        % Calculer les statistiques par muscle
        unique_muscles = unique(all_muscle_labels);
        stats_combined = zeros(3, length(unique_muscles)); % Moyenne, Écart-type, Médiane
        
        for m = 1:length(unique_muscles)
            muscle_data = all_snr_values(strcmp(all_muscle_labels, unique_muscles{m}));
            stats_combined(1, m) = mean(muscle_data, 'omitnan');
            stats_combined(2, m) = std(muscle_data, 'omitnan');
            stats_combined(3, m) = median(muscle_data, 'omitnan');
        end
        
        % Afficher la table des statistiques
        T_stats_combined = array2table(stats_combined, ...
            'VariableNames', unique_muscles, ...
            'RowNames', {'Moyenne', 'Écart-type', 'Médiane'});
        
        fprintf('\nRésultats moyens SNR (dB) - Combinés (D+G):\n');
        disp(T_stats_combined);
        
        % Visualisation des résultats combinés
        figure('Name', 'SNR par muscle - Combiné (D+G)', 'Position', [300, 100, 800, 500]);
        
        % Boxplot des valeurs SNR groupées par muscle
        muscle_names = cellfun(@(m) m, unique_muscles, 'UniformOutput', false);
        boxplot(all_snr_values', all_muscle_labels, 'Labels', muscle_names);
        title('SNR Combiné (Droite + Gauche)');
        ylabel('SNR (dB)');
        grid on;
        
        % Figure supplémentaire pour comparer les côtés D/G pour chaque muscle
        figure('Name', 'Comparaison SNR D vs G par muscle', 'Position', [300, 700, 900, 500]);
        
        % Créer une catégorie pour chaque combinaison muscle-côté
        muscle_side_categories = cell(size(all_muscle_labels));
        for i = 1:length(all_muscle_labels)
            muscle_side_categories{i} = sprintf('%s (%s)', all_muscle_labels{i}, all_sides{i});
        end
        
        % Boxplot par muscle et côté
        boxplot(all_snr_values', muscle_side_categories);
        title('Comparaison SNR par muscle et côté (D/G)');
        ylabel('SNR (dB)');
        grid on;
        xtickangle(45);
    end
end