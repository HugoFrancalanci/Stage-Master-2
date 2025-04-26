function analyze_elevation_planes(subjects, data_path)
    % Matrice pour stocker les caractéristiques des plans d'élévation
    elevation_features = [];
    subject_labels = {};
    
    % Extraire les caractéristiques pour chaque sujet
    for i = 1:length(subjects)
        try
            % Sélection mouvement spécifique (1-4)
            [Angles_HT, time] = extract_HT_angles(subjects{i}, 1, data_path);
            angle_plan = rad2deg(Angles_HT(:,1));
            
            % Caractéristiques enrichies
            features = [
                mean(angle_plan), ...       % Moyenne 
                std(angle_plan), ...        % Écart-type
                median(angle_plan), ...     % Médiane
                skewness(angle_plan), ...   % Asymétrie
                kurtosis(angle_plan), ...   % Kurtosis
                max(abs(angle_plan)), ...   % Amplitude maximale
                range(angle_plan)           % Étendue
            ];
            
            elevation_features = [elevation_features; features];
            subject_labels{end+1} = subjects{i};
        catch
            fprintf('Erreur lors du traitement du sujet %s\n', subjects{i});
        end
    end
    
    % Normalisation des caractéristiques
    features_normalized = (elevation_features - mean(elevation_features)) ./ std(elevation_features);
    
    % Méthode du coude pour sélectionner le nombre optimal de clusters
    max_k = 5;
    sum_squared_distances = zeros(1, max_k);
    
    for k = 1:max_k
        [idx, centroids] = kmeans(features_normalized, k, 'Replicates', 10);
        sum_squared_distances(k) = sum(min(pdist2(features_normalized, centroids), [], 2));
    end
    
    % Tracer la courbe du coude
    figure;
    plot(1:max_k, sum_squared_distances, 'bo-');
    title('Méthode du coude pour sélectionner le nombre de clusters');
    xlabel('Nombre de clusters (k)');
    ylabel('Somme des distances au carré');
    
    % Sélection basée sur la méthode du coude
    k_optimal = 3;
    
    % Clustering K-means avec le nombre optimal de clusters
    [idx, centroids] = kmeans(features_normalized, k_optimal, 'Replicates', 10);
    
    % Visualisation des clusters
    figure;
    scatter(features_normalized(:,1), features_normalized(:,6), [], idx, 'filled');
    title(sprintf('Clustering K-means (K = %d) - Plan d''élévation', k_optimal));
    xlabel('Moyenne du plan d''élévation normalisée');
    ylabel('Élévation normalisée maximale');
    %ylabel('Variation du plan d''élévation normalisée');
    
    % Afficher les étiquettes des sujets
    for i = 1:size(features_normalized, 1)
        text(features_normalized(i,1), features_normalized(i,2), subject_labels{i}, ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
    
    % Afficher les centroïdes
    hold on;
    plot(centroids(:,1), centroids(:,2), 'kx', 'MarkerSize', 10, 'LineWidth', 2);
    
    % Calcul de la silhouette
    silhouette_scores = silhouette(features_normalized, idx);
    mean_silhouette = mean(silhouette_scores);
    fprintf('Score de silhouette moyen : %.3f\n', mean_silhouette);
    
    % Récapitulatif des clusters
    cluster_summary = cell(k_optimal, 1);
    for c = 1:k_optimal
        cluster_subjects = subject_labels(idx == c);
        cluster_summary{c} = strjoin(cluster_subjects, ', ');
        fprintf('Cluster %d: %s\n', c, cluster_summary{c});
    end
end