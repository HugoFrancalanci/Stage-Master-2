function [cycle_info, num_cycles_detected, RHLE_distance_resampled] = detectMovementCycles(c3dH_functional, analogs_functional, muscles, position_threshold_percent, min_duration, num_cycles, fs, manual_selection)
   % Détection des cycles de mouvement
   % manual_selection: si true, utiliser la sélection manuelle via ginput

    % Paramètre par défaut pour la sélection manuelle si non spécifié
    if nargin < 8
        manual_selection = false;
    end

    % Paramètre interne pour le seuil minimal d'amplitude (en % de la distance max)
    amplitude_threshold_percent = 40; % Seuil fixé à 40% de l'amplitude maximale

    % Extraction des données du marqueur RHLE
    points = btkGetPoints(c3dH_functional);
    markers = fieldnames(points);

    % Initialisation par défaut
    cycle_info = [];
    RHLE_distance_resampled = [];
    num_cycles_detected = 0;

    % Vérifier si le marqueur RHLE existe
    if ismember('RHLE', markers)
        % Extraction des coordonnées 3D du marqueur RHLE
        RHLE_pos = points.RHLE;

        % Calculer la position de référence (position de départ)
        RHLE_baseline = mean(RHLE_pos(1:100, :));

        % Calculer la distance euclidienne entre la position actuelle et la position de référence
        RHLE_distance = sqrt(sum((RHLE_pos - repmat(RHLE_baseline, size(RHLE_pos, 1), 1)).^2, 2));

        % Normaliser la distance par la distance maximale
        RHLE_distance_max = max(RHLE_distance);
        RHLE_distance_normalized = (RHLE_distance / RHLE_distance_max) * 100;

        % Adapter la fréquence d'échantillonnage du marqueur à celle de l'EMG
        markers_fs = btkGetPointFrequency(c3dH_functional);
        emg_fs = btkGetAnalogFrequency(c3dH_functional);
        ratio = emg_fs / markers_fs;

        % Interpoler les données du marqueur pour correspondre à la fréquence EMG
        t_marker = (0:length(RHLE_distance_normalized)-1) / markers_fs;
        t_emg = (0:ratio*length(RHLE_distance_normalized)-1) / emg_fs;
        RHLE_distance_resampled = interp1(t_marker, RHLE_distance_normalized, t_emg, 'spline');

        % Ajuster la longueur pour correspondre aux données EMG
        max_length = min([length(RHLE_distance_resampled), length(analogs_functional.(muscles{1}))]);
        RHLE_distance_resampled = RHLE_distance_resampled(1:max_length);

        % Choix entre sélection manuelle ou automatique
        if manual_selection
            % Sélection manuelle des cycles avec ginput
            figure('Name', 'Sélection manuelle des cycles', 'Position', [100, 100, 1200, 600]);
            plot(RHLE_distance_resampled, 'LineWidth', 1.5);
            title('Sélectionnez le début et la fin de chaque cycle (2 points par cycle)');
            xlabel('Échantillons');
            ylabel('Distance normalisée (%)');
            grid on;
            
            % Instructions pour l'utilisateur
            disp(['Sélectionnez ', num2str(num_cycles * 2), ' points (début et fin pour chaque cycle)']);
            disp('Cliquez sur le graphique dans cet ordre: début cycle 1, fin cycle 1, début cycle 2, fin cycle 2, etc.');
            
            % Récupération des points par ginput
            [x_points, ~] = ginput(num_cycles * 2);
            
            % Conversion en indices arrondis
            points_idx = round(x_points);
            
            % Vérification des limites
            points_idx = max(points_idx, 1);
            points_idx = min(points_idx, max_length);
            
            % Organisation des points en cycles (début, fin)
            if ~isempty(points_idx)
                num_cycles_detected = min(num_cycles, floor(length(points_idx)/2));
                
                for cycle = 1:num_cycles_detected
                    idx_start = (cycle-1)*2 + 1;
                    idx_end = idx_start + 1;
                    
                    if idx_end <= length(points_idx)
                        % S'assurer que début < fin
                        movement_start = min(points_idx(idx_start), points_idx(idx_end));
                        movement_end = max(points_idx(idx_start), points_idx(idx_end));
                        
                        cycle_info(cycle, :) = [movement_start, movement_end];
                    end
                end
            else
                % Si annulation ou aucun point sélectionné
                cycle_info(1, :) = [1, max_length];
                num_cycles_detected = 1;
                warning('Aucun point sélectionné. Utilisation de toutes les données comme un seul cycle.');
            end
            
            % Fermer la figure après sélection
            close;
            
        else
            % Méthode automatique originale basée sur les seuils
            movement_mask = RHLE_distance_resampled > position_threshold_percent;

            % Appliquer une durée minimale (filtrage des activations courtes)
            min_samples = round(min_duration * fs);
            movement_mask = bwareaopen(movement_mask, min_samples);

            % Trouver les indices de début et fin
            movement_regions = regionprops(movement_mask, 'PixelIdxList');

            if ~isempty(movement_regions)
                % Fusionner les régions proches
                connected_regions = mergeCloseRegions(movement_regions, fs);

                % Filtrer les régions en fonction de l'amplitude minimale
                valid_regions_idx = [];
                for i = 1:size(connected_regions, 1)
                    start_idx = connected_regions(i, 1);
                    end_idx = connected_regions(i, 2);

                    % Calculer l'amplitude max de ce cycle
                    cycle_data = RHLE_distance_resampled(start_idx:end_idx);
                    cycle_amplitude = max(cycle_data);

                    % Ne garder que les cycles dépassant le seuil d'amplitude
                    if cycle_amplitude >= amplitude_threshold_percent
                        valid_regions_idx = [valid_regions_idx; i];
                    end
                end

                % Ne conserver que les régions valides
                if ~isempty(valid_regions_idx)
                    connected_regions = connected_regions(valid_regions_idx, :);
                else
                    % Si aucune région valide, on remet une seule région sur toutes les données
                    connected_regions = [1, max_length];
                    warning('Aucun cycle ne dépasse le seuil minimal d''amplitude de %d%%. Utilisation de toutes les données.', amplitude_threshold_percent);
                end

                % Sélectionner les cycles disponibles
                num_cycles_detected = min(num_cycles, size(connected_regions, 1));

                for cycle = 1:num_cycles_detected
                    movement_start = connected_regions(cycle, 1);
                    movement_end = connected_regions(cycle, 2);

                    % Ajouter une marge avant et après (10% de la durée du mouvement)
                    margin = round((movement_end - movement_start) * 0.1);
                    movement_start = max(1, movement_start - margin);
                    movement_end = min(max_length, movement_end + margin);

                    cycle_info(cycle, :) = [movement_start, movement_end];
                end
            else
                % Si aucun mouvement détecté, utiliser l'ensemble des données comme un seul cycle
                cycle_info(1, :) = [1, max_length];
                num_cycles_detected = 1;
                warning('Aucun mouvement détecté. Utilisation de toutes les données comme un seul cycle.');
            end
        end
    else
        % Si le marqueur RHLE n'est pas disponible, utiliser l'ensemble des données
        cycle_info(1, :) = [1, length(analogs_functional.(muscles{1}))];
        num_cycles_detected = 1;
        warning('Marqueur RHLE non disponible. Utilisation de toutes les données.');
    end
end