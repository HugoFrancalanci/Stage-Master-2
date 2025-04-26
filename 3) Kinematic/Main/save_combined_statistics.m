function side_data = save_combined_statistics(combined_mean, combined_std, combined_CI, side_code)
    % Fonction pour organiser les données combinées pour un côté
    side_data = struct();
    
    % Articulations à traiter
    articulations = {'GH', 'ST', 'HT'};
    
    % Composantes pour chaque articulation
    composantes = struct();
    composantes.GH = {'Plan_elevation', 'Elevation', 'Rotation_axiale'};
    composantes.ST = {'Protraction_Retraction', 'Rotation_mediale_laterale', 'Inclinaison'};
    composantes.HT = {'Plan_elevation_global', 'Elevation_globale', 'Rotation_axiale_globale'};
    
    % Pour chaque articulation
    for a = 1:length(articulations)
        articulation = articulations{a};
        side_data.(articulation) = struct();
        
        % Vérifier si cette articulation existe dans les données
        if ~isfield(combined_mean, articulation)
            warning('Les données combinées pour %s_%s n''existent pas. Ignoré.', side_code, articulation);
            continue;
        end
        
        % Pour chaque composante
        for c = 1:3
            comp_name = composantes.(articulation){c};
            
            % Stockage des données
            side_data.(articulation).(comp_name) = struct();
            side_data.(articulation).(comp_name).mean = combined_mean.(articulation)(:,c);
            side_data.(articulation).(comp_name).std = combined_std.(articulation)(:,c);
            
            % Stocker les intervalles de confiance s'ils existent
            if isfield(combined_CI, [articulation '_upper']) && isfield(combined_CI, [articulation '_lower'])
                side_data.(articulation).(comp_name).CI_upper = combined_CI.([articulation '_upper'])(:,c);
                side_data.(articulation).(comp_name).CI_lower = combined_CI.([articulation '_lower'])(:,c);
                
                % Conversion en degrés pour les IC
                side_data.(articulation).(comp_name).CI_upper_deg = rad2deg(side_data.(articulation).(comp_name).CI_upper);
                side_data.(articulation).(comp_name).CI_lower_deg = rad2deg(side_data.(articulation).(comp_name).CI_lower);
            end
            
            % Conversion en degrés
            side_data.(articulation).(comp_name).mean_deg = rad2deg(side_data.(articulation).(comp_name).mean);
            side_data.(articulation).(comp_name).std_deg = rad2deg(side_data.(articulation).(comp_name).std);
            
            % Statistiques supplémentaires
            side_data.(articulation).(comp_name).max_deg = max(side_data.(articulation).(comp_name).mean_deg);
            side_data.(articulation).(comp_name).min_deg = min(side_data.(articulation).(comp_name).mean_deg);
            side_data.(articulation).(comp_name).range_deg = side_data.(articulation).(comp_name).max_deg - side_data.(articulation).(comp_name).min_deg;
        end
    end
end