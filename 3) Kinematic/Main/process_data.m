function process_data(config, population_name)

    all_movements_data = initialize_data_structures(config);
    all_subjects_mean_cycles = initialize_data_structures(config);

    % Structure pour stocker les données de tous les mouvements et côtés
    all_data = struct();
    all_data.movements = struct();
    all_data.combined = struct(); % Pour les données combinées à la fin
    all_data.subjects = struct(); % Pour les données individuelles par sujet

    % Préparer la structure pour stocker les données par sujet
    for subj_idx = 1:length(config.Subjects)
        subject = config.Subjects{subj_idx};
        all_data.subjects.(subject) = struct();
        all_data.subjects.(subject).movements = struct();
        all_data.subjects.(subject).combined = struct(); % S'assurer que la structure combinée existe
    end

    for mov_idx = 1:length(config.movements_to_process)
        current_movement = config.movements_to_process(mov_idx);
        fprintf('\n============ Mouvement %d ============\n', current_movement);

        % Initialiser la structure pour ce mouvement
        movement_key = sprintf('movement_%d', current_movement);
        all_data.movements.(movement_key) = struct();

        for subj_idx = 1:length(config.Subjects)
            subject = config.Subjects{subj_idx};

            if ~isKey(config.sides_per_subject, subject)
                warning('[!] Pas de côté défini pour %s. Ignoré.', subject);
                continue;
            end

            side = config.sides_per_subject(subject);
            fprintf('Sujet %s - Côté %s\n', subject, side);

            try
                fichier = get_file_path(subject, current_movement, config);
                [markers, nFrames, ~] = read_c3d_file(fichier, config.fs);
                [cycles_frames, num_cycles] = detect_movement_cycles(markers, nFrames, config, subject);
                [Angles_GH, Angles_ST, Angles_HT] = calculate_angles(markers, nFrames, side);
                [Angles_GH, Angles_ST, Angles_HT] = filter_and_correct_angles(Angles_GH, Angles_ST, Angles_HT, config.fs, config.filter_cutoff);

                if current_movement == 4
                    if strcmp(side, 'R') && config.invert_functional4_right
                        disp('→ Mouvement 4 inversé (côté droit)');
                        [Angles_GH, Angles_ST, Angles_HT] = invert_movement(Angles_GH, Angles_ST, Angles_HT);
                    elseif strcmp(side, 'L') && config.invert_functional4_left
                        disp('→ Mouvement 4 inversé (côté gauche)');
                        [Angles_GH, Angles_ST, Angles_HT] = invert_movement(Angles_GH, Angles_ST, Angles_HT);
                    end
                end

                all_movements_data = store_subject_data(all_movements_data, side, current_movement, subj_idx, Angles_GH, Angles_ST, Angles_HT);
                [mean_GH, mean_ST, mean_HT] = calculate_mean_cycles(cycles_frames, num_cycles, Angles_GH, Angles_ST, Angles_HT, config.num_samples_per_cycle);
                all_movements_data = store_mean_cycles(all_movements_data, side, current_movement, subj_idx, mean_GH, mean_ST, mean_HT);
                all_subjects_mean_cycles = store_for_global_mean(all_subjects_mean_cycles, side, current_movement, subj_idx, mean_GH, mean_ST, mean_HT);
                
                % Stocker les cycles moyens pour ce sujet et ce mouvement
                if ~isfield(all_data.subjects.(subject).movements, movement_key)
                    all_data.subjects.(subject).movements.(movement_key) = struct();
                end
                
                % Convertir le code de côté en nom complet
                side_name = '';
                if strcmp(side, 'R')
                    side_name = 'right';
                elseif strcmp(side, 'L')
                    side_name = 'left';
                end
                
                % Sauvegarder les données moyennes de ce sujet pour ce mouvement et ce côté
                all_data.subjects.(subject).movements.(movement_key).(side_name) = struct();
                all_data.subjects.(subject).movements.(movement_key).(side_name).GH = mean_GH;
                all_data.subjects.(subject).movements.(movement_key).(side_name).ST = mean_ST;
                all_data.subjects.(subject).movements.(movement_key).(side_name).HT = mean_HT;

            catch e
                fprintf('[!] Erreur %s : %s\n', subject, e.message);
            end
        end

        % === Moyennes et affichages séparés pour chaque côté
        for s = {'R','L'}
            side = s{1};
            if isfield(all_subjects_mean_cycles, side)
                valid_subjects = get_valid_subjects(all_movements_data.(side), current_movement, config.Subjects);
                [global_mean, global_std] = calculate_global_statistics(all_subjects_mean_cycles.(side), current_movement, valid_subjects);
                plot_global_cycles(global_mean, global_std, current_movement, config);

                % Convertir le code de côté en nom complet
                side_name = '';
                if strcmp(side, 'R')
                    side_name = 'right';
                elseif strcmp(side, 'L')
                    side_name = 'left';
                end

                % Enregistrer les données de ce mouvement et ce côté
                all_data.movements.(movement_key).(side_name) = save_movement_statistics(global_mean, global_std, side);
            end
        end
    end

    % === Tous mouvements confondus
    for s = {'R','L'}
        side = s{1};
        if isfield(all_movements_data, side)
            [combined_mean, combined_std, combined_CI] = compute_combined_statistics(all_movements_data.(side), all_subjects_mean_cycles.(side), config);
            post_processing(config, combined_mean, combined_std, combined_CI);

            % Convertir le code de côté en nom complet
            side_name = '';
            if strcmp(side, 'R')
                side_name = 'right';
            elseif strcmp(side, 'L')
                side_name = 'left';
            end

            % Enregistrer les données combinées de tous les mouvements
            all_data.combined.(side_name) = save_combined_statistics(combined_mean, combined_std, combined_CI, side);
            
            % === Calcul des données combinées pour chaque sujet
            % Cette partie va calculer les moyennes des mouvements pour chaque sujet individuellement
            subject_movement_data = collect_subject_movement_data(all_data, config, side);
            
            % Pour chaque sujet, calculer les données combinées
            for subj_idx = 1:length(config.Subjects)
                subject = config.Subjects{subj_idx};
                
                % Vérifier si le sujet a des données et est du bon côté
                if ~isfield(all_data.subjects, subject) || ~isKey(config.sides_per_subject, subject)
                    continue;
                end
                
                subject_side = config.sides_per_subject(subject);
                if ~strcmp(subject_side, side)
                    continue;
                end
                
                % Vérifier si le sujet a des données de mouvement
                if ~isfield(subject_movement_data, subject) || isempty(fieldnames(subject_movement_data.(subject)))
                    continue;
                end
                
                % Calculer les statistiques combinées pour ce sujet
                [subject_combined_mean, subject_combined_std, subject_combined_CI] = compute_subject_combined_statistics(subject_movement_data.(subject), config);
                
                % Sauvegarder les données combinées pour ce sujet
                all_data.subjects.(subject).combined.(side_name) = save_combined_statistics(subject_combined_mean, subject_combined_std, subject_combined_CI, side);
            end
        end
    end

    % Ajouter des métadonnées
    all_data.metadata = struct();
    all_data.metadata.date_creation = datestr(now);
    all_data.metadata.movements_processed = config.movements_to_process;
    all_data.metadata.num_samples_per_cycle = config.num_samples_per_cycle;

    % Enregistrer la structure complète
    save_path = fullfile(config.output_directory, ['all_angles_statistics_' population_name '.mat']);
    save(save_path, 'all_data');
    fprintf('Toutes les données statistiques des angles enregistrées dans %s\n', save_path);
    
    if config.save_individual_subject_files
        for subj_idx = 1:length(config.Subjects)
            subject = config.Subjects{subj_idx};
            if isfield(all_data.subjects, subject) && ~isempty(fieldnames(all_data.subjects.(subject).movements))
                subject_data = all_data.subjects.(subject);
                subject_data.metadata = all_data.metadata;
                subject_save_path = fullfile(config.output_directory, ['subject_angles_statistics_' subject '_' population_name '.mat']);
                save(subject_save_path, 'subject_data');
                fprintf('Données du sujet %s enregistrées dans %s\n', subject, subject_save_path);
            end
        end
    end
end
