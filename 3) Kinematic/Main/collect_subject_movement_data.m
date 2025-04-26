% Fonction pour collecter les données de mouvement de chaque sujet
function subject_data = collect_subject_movement_data(all_data, config, side)
    subject_data = struct();
    
    % Pour chaque sujet
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
        
        % Initialiser la structure pour ce sujet
        subject_data.(subject) = struct();
        subject_data.(subject).GH = [];
        subject_data.(subject).ST = [];
        subject_data.(subject).HT = [];
        
        % Convertir le code de côté en nom complet
        side_name = '';
        if strcmp(side, 'R')
            side_name = 'right';
        elseif strcmp(side, 'L')
            side_name = 'left';
        end
        
        % Collecter les données pour chaque mouvement
        for mov_idx = 1:length(config.movements_to_process)
            current_movement = config.movements_to_process(mov_idx);
            movement_key = sprintf('movement_%d', current_movement);
            
            % Vérifier si le sujet a des données pour ce mouvement
            if isfield(all_data.subjects.(subject).movements, movement_key) && ...
               isfield(all_data.subjects.(subject).movements.(movement_key), side_name)
                
                % Accéder aux données du mouvement pour ce sujet
                movement_data = all_data.subjects.(subject).movements.(movement_key).(side_name);
                
                % Ajouter les données à la collection
                subject_data.(subject).GH = cat(3, subject_data.(subject).GH, movement_data.GH);
                subject_data.(subject).ST = cat(3, subject_data.(subject).ST, movement_data.ST);
                subject_data.(subject).HT = cat(3, subject_data.(subject).HT, movement_data.HT);
            end
        end
    end
end