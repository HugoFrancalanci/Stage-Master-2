function [clusteredSynergies, clusterResults] = synergyStringClustering_kmeans(synergies)
    % Clustering de synergies représentées sous forme de chaînes, via K-means
    % + Visualisations avancées et métriques d'évaluation
    % Entrée :
    %   - synergies : cellule de chaînes, ex: {'W1,W2', 'W1,W2,W3'}
    % Sorties :
    %   - clusteredSynergies : struct contenant les résultats de clustering
    %   - clusterResults : struct avec infos techniques (silhouette, distance...)

    if ~iscell(synergies)
        error('L''entrée doit être une cellule de chaînes.');
    end

    % Étape 1 : extraire les synergies uniques
    allSynergies = unique(regexp(strjoin(synergies, ','), ',', 'split'));

    % Étape 2 : transformer les strings en vecteurs binaires
    synergyMatrix = zeros(length(synergies), length(allSynergies));
    for i = 1:length(synergies)
        current = strsplit(synergies{i}, ',');
        for j = 1:length(current)
            idx = find(strcmp(allSynergies, current{j}));
            synergyMatrix(i, idx) = 1;
        end
    end

    % Étape 3 : Déterminer le nombre optimal de clusters via silhouette
    maxK = min(10, size(synergyMatrix, 1)-1);
    if maxK < 2
        maxK = 2;
    end
    
    silScores = zeros(maxK-1, 1);
    
    % Calculer silhouette pour différentes valeurs de k
    figure('Name', 'Analyse de Silhouette pour Synergies', 'Position', [100, 100, 1200, 800]);
    for k = 2:maxK
        rng(0); % Pour reproductibilité
        [idx, ~] = kmeans(synergyMatrix, k, 'Replicates', 10, 'Distance', 'sqeuclidean');
        
        % Calculer le score silhouette
        silScores(k-1) = mean(silhouette(synergyMatrix, idx));
        
        % Pour k=3, stocker les résultats silhouette détaillés
        if k == 3
            subplot(2, 2, 3);
            [s, h] = silhouette(synergyMatrix, idx);
            title('Silhouette pour k=3');
            silDetails = s;
            silClusterIdx = idx;
        end
    end
    
    % Subplot pour le score silhouette moyen selon k
    subplot(2, 2, 1);
    bar(2:maxK, silScores);
    title('Score de Silhouette moyen par nombre de clusters');
    xlabel('Nombre de clusters (k)');
    ylabel('Score silhouette moyen');
    grid on;
    
    % Trouver le k optimal (meilleur score silhouette)
    [~, optIdx] = max(silScores);
    optK = optIdx + 1;
    hold on;
    plot(optK, silScores(optIdx), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    legend('Scores silhouette', 'k optimal');
    
    % Message sur le k optimal
    fprintf('\nLe nombre optimal de clusters selon le score silhouette est k = %d (score = %.4f)\n', optK, silScores(optIdx));
    
    % Étape 4 : Clustering final avec k 
    k = 4;
    rng(0)
    [finalClusters, centroids] = kmeans(synergyMatrix, k, 'Replicates', 10, 'Distance', 'sqeuclidean');

    % Étape 5 : Préparer les clusters
    clusterContents = cell(1, k);
    for i = 1:k
        clusterContents{i} = synergies(finalClusters == i);
    end

    % ➤ Résumé console
    fprintf('\n Résumé des Clusters de Synergies (k-means):\n');
    fprintf('--------------------------------------\n');
    for i = 1:k
        fprintf('\n Cluster %d (n = %d):\n', i, length(clusterContents{i}));
        fprintf('----------------------------\n');
        for s = 1:length(clusterContents{i})
            fprintf('• %s\n', clusterContents{i}{s});
        end
    end

    % ➤ Visualisation 1 : Barplot des tailles de clusters
    subplot(2, 2, 2);
    histogram(finalClusters, 'BinMethod', 'integers');
    title('Nombre de sujets par cluster');
    xlabel('Cluster'); ylabel('Nombre de sujets');
    grid on;

    % ➤ Visualisation 2 : Heatmap des centroïdes
    subplot(2, 2, 4);
    imagesc(centroids);
    colormap('hot');
    colorbar;
    title('Heatmap des centroïdes de synergies');
    xlabel('Éléments'); 
    ylabel('Cluster');
    % Ajouter les étiquettes des éléments si pas trop nombreux
    if length(allSynergies) <= 20
        xticks(1:length(allSynergies));
        xticklabels(allSynergies);
        xtickangle(45);
    end

    % ➤ Visualisation 3D avec PCA
    figure('Name', 'Analyse PCA et Caractéristiques des Synergies', 'Position', [100, 100, 1200, 800]);
    
    % PCA standard en 2D (améliorée)
    subplot(2, 2, 1);
    [coeff, score, ~] = pca(zscore(synergyMatrix)); % réduction de dimension
    cmap = lines(k); % palette de couleurs
    
    hold on;
    for i = 1:k
        idx = finalClusters == i;
        scatter(score(idx,1), score(idx,2), 80, 'filled', ...
            'MarkerFaceColor', cmap(i,:), 'DisplayName', sprintf('Cluster %d', i));
        
        % Ajouter étiquettes
        for j = find(idx)'
            text(score(j,1)+0.1, score(j,2), sprintf('S%d', j), 'FontSize', 9);
        end
        
        % Ajouter les centroïdes des clusters dans l'espace PCA
        centroid_pca = coeff' * centroids(i,:)';
        scatter(centroid_pca(1), centroid_pca(2), 200, cmap(i,:), 'p', 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 2, 'DisplayName', sprintf('Centre %d', i));
    end
    
title('2D PCA Projection of Synergies with Centroids');
xlabel('Principal Component 1');
ylabel('Principal Component 2');
legend('show', 'Location', 'best');
grid on;
axis equal;
hold off;

    
    % PCA en 3D si suffisamment de dimensions
    if size(score, 2) >= 3
        subplot(2, 2, 2);
        hold on;
        for i = 1:k
            idx = finalClusters == i;
            scatter3(score(idx,1), score(idx,2), score(idx,3), 80, 'filled', ...
                'MarkerFaceColor', cmap(i,:), 'DisplayName', sprintf('Cluster %d', i));
            
            % Étiquettes en 3D (limité pour éviter encombrement)
            if sum(idx) <= 10
                for j = find(idx)'
                    text(score(j,1)+0.1, score(j,2), score(j,3), sprintf('S%d', j), 'FontSize', 9);
                end
            end
        end
        title('Projection PCA 3D des synergies');
        xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
        view(45, 30); % Angle de vue
        legend('show', 'Location', 'best');
        hold off;
    end
    
    % Matrice de confusion / similarité
    subplot(2, 2, 3);
    similarityMatrix = pdist2(synergyMatrix, synergyMatrix, 'jaccard');
    % Réorganiser selon les clusters
    [~, idx] = sort(finalClusters);
    similarityMatrix = similarityMatrix(idx, idx);
    imagesc(1 - similarityMatrix); % 1-similarité pour avoir une échelle intuitive
    colormap('jet');
    colorbar;
    title('Matrice de similarité entre synergies');
    xlabel('Observations'); ylabel('Observations');
    
    % Fréquence des éléments par cluster
    subplot(2, 2, 4);
    clusterFreq = zeros(k, length(allSynergies));
    for i = 1:k
        clusterMembers = finalClusters == i;
        if sum(clusterMembers) > 0
            clusterFreq(i, :) = sum(synergyMatrix(clusterMembers, :)) / sum(clusterMembers);
        end
    end
    bar(clusterFreq', 'stacked');
    title('Fréquence des éléments par cluster');
    if length(allSynergies) <= 15
        set(gca, 'XTick', 1:length(allSynergies), 'XTickLabel', allSynergies);
        xtickangle(45);
    end
    ylabel('Fréquence relative');
    legend(arrayfun(@(x) sprintf('Cluster %d', x), 1:k, 'UniformOutput', false), 'Location', 'best');
    
    % ➤ Calcul de métriques supplémentaires d'évaluation du clustering
    % Davies-Bouldin Index (plus petit = meilleur)
    dbIdx = evalclusters(synergyMatrix, finalClusters, 'DaviesBouldin');
    
    % Calinski-Harabasz Index (plus grand = meilleur)
    chIdx = evalclusters(synergyMatrix, finalClusters, 'CalinskiHarabasz');
    
    % Calculer les distances moyennes intra-cluster et inter-clusters
    intraClusterDist = zeros(k, 1);
    for i = 1:k
        members = finalClusters == i;
        if sum(members) > 1
            pairDist = pdist(synergyMatrix(members, :), 'jaccard');
            intraClusterDist(i) = mean(pairDist);
        end
    end
    
    % Afficher les métriques d'évaluation
    fprintf('\n Évaluation de la qualité du clustering:\n');
    fprintf('--------------------------------------\n');
    fprintf('• Score de Silhouette: %.4f (idéalement proche de 1)\n', mean(silhouette(synergyMatrix, finalClusters)));
    fprintf('• Indice Davies-Bouldin: %.4f (plus petit = meilleur)\n', dbIdx.CriterionValues);
    fprintf('• Indice Calinski-Harabasz: %.4f (plus grand = meilleur)\n', chIdx.CriterionValues);
    fprintf('• Nombre optimal de clusters selon silhouette: %d\n', optK);
    
    % Afficher distances moyennes intra-cluster
    fprintf('\n Distances moyennes intra-cluster (Jaccard):\n');
    for i = 1:k
        fprintf('• Cluster %d: %.4f\n', i, intraClusterDist(i));
    end

    % ➤ Structure de sortie enrichie
    clusteredSynergies = struct(...
        'OriginalSynergies', {synergies}, ...
        'Clusters', finalClusters, ...
        'ClusterContents', {clusterContents}, ...
        'UniqueElements', {allSynergies});

    clusterResults = struct(...
        'Centroids', centroids, ...
        'BinaryMatrix', synergyMatrix, ...
        'k', k, ...
        'RandomSeed', 0, ...
        'PCA_Score', score, ...
        'PCA_Coeff', coeff, ...
        'SilhouetteScore', mean(silhouette(synergyMatrix, finalClusters)), ...
        'DaviesBouldinIndex', dbIdx.CriterionValues, ...
        'CalinskiHarabaszIndex', chIdx.CriterionValues, ...
        'OptimalK', optK, ...
        'IntraClusterDistance', intraClusterDist);
end