function [clusteredactivations, clusterResults] = activationsStringClustering_kmeans(activations)
    % Clustering de activations représentées sous forme de chaînes, via K-means
    % Entrée :
    %   - activations : cellule de chaînes, ex: {'W1,W2', 'W1,W2,W3'}
    % Sorties :
    %   - clusteredactivations : struct contenant les résultats de clustering
    %   - clusterResults : struct avec infos techniques (silhouette, distance...)

    if ~iscell(activations)
        error('L''entrée doit être une cellule de chaînes.');
    end

    % Étape 1 : extraire les activations uniques
    allactivations = unique(regexp(strjoin(activations, ','), ',', 'split'));

    % Étape 2 : transformer les strings en vecteurs binaires
    synergyMatrix = zeros(length(activations), length(allactivations));
    for i = 1:length(activations)
        current = strsplit(activations{i}, ',');
        for j = 1:length(current)
            idx = find(strcmp(allactivations, current{j}));
            synergyMatrix(i, idx) = 1;
        end
    end

    % Étape 3 : Déterminer le nombre optimal de clusters via silhouette
    % Calcul des scores de silhouette pour k=2 à k=10 (ou moins si peu de données)
    maxK = min(10, size(synergyMatrix, 1)-1);
    if maxK < 2
        maxK = 2;
    end

    silScores = zeros(maxK-1, 1);

    % Calculer silhouette pour différentes valeurs de k
    figure('Name', 'Analyse de Silhouette', 'Position', [100, 100, 1200, 800]);
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
    title('Score de Silhouette moyen');
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

    % Étape 4 : Clustering final avec k = 3 (choix forcé pour cohérence)
    k = 10;
    rng(0)
    [finalClusters, centroids] = kmeans(synergyMatrix, k, 'Replicates', 10, 'Distance', 'sqeuclidean');

    % Étape 5 : Préparer les clusters
    clusterContents = cell(1, k);
    for i = 1:k
        clusterContents{i} = activations(finalClusters == i);
    end

    % ➤ Affichage clair
    fprintf('\n Résumé des Clusters de activations (k-means):\n');
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
    title('Heatmap des centroïdes');
    xlabel('Éléments'); 
    ylabel('Cluster');
    % Ajouter les étiquettes des éléments si pas trop nombreux
    if length(allactivations) <= 20
        xticks(1:length(allactivations));
        xticklabels(allactivations);
        xtickangle(45);
    end

    % ➤ Visualisation 3 : PCA pour visualiser les clusters en 2D
    figure('Name', 'Visualisation PCA et Matrice de Confusion', 'Position', [100, 100, 1200, 500]);
    subplot(1, 2, 1);
    [coeff, score] = pca(synergyMatrix);
    gscatter(score(:,1), score(:,2), finalClusters);
    title('PCA des activations');
    xlabel('1ère composante principale');
    ylabel('2ème composante principale');
    grid on;
    legend('Cluster 1', 'Cluster 2', 'Cluster 3', 'Location', 'best');

    % ➤ Visualisation 4 : Matrice de similarité entre les activations
    subplot(1, 2, 2);
    similarityMatrix = pdist2(synergyMatrix, synergyMatrix, 'jaccard');
    % Réorganiser selon les clusters
    [~, idx] = sort(finalClusters);
    similarityMatrix = similarityMatrix(idx, idx);
    imagesc(1 - similarityMatrix); % 1-similarité pour avoir une échelle intuitive
    colormap('jet');
    colorbar;
    title('Matrice de similarité (réorganisée par clusters)');
    xlabel('Observations'); ylabel('Observations');

    % ➤ Calcul de métriques supplémentaires
    % Davies-Bouldin Index (plus petit = meilleur)
    dbIdx = evalclusters(synergyMatrix, finalClusters, 'DaviesBouldin');

    % Calinski-Harabasz Index (plus grand = meilleur)
    chIdx = evalclusters(synergyMatrix, finalClusters, 'CalinskiHarabasz');

    % ➤ Structure de sortie
    clusteredactivations = struct(...
        'Originalactivations', {activations}, ...
        'Clusters', finalClusters, ...
        'ClusterContents', {clusterContents}, ...
        'UniqueElements', {allactivations});

    clusterResults = struct(...
        'Centroids', centroids, ...
        'BinaryMatrix', synergyMatrix, ...
        'k', k, ...
        'RandomSeed', 0, ...
        'SilhouetteScore', mean(silhouette(synergyMatrix, finalClusters)), ...
        'DaviesBouldinIndex', dbIdx.CriterionValues, ...
        'CalinskiHarabaszIndex', chIdx.CriterionValues, ...
        'OptimalK', optK);

    % Afficher les métriques d'évaluation du clustering
    fprintf('\n Évaluation de la qualité du clustering:\n');
    fprintf('--------------------------------------\n');
    fprintf('• Score de Silhouette: %.4f (idéalement proche de 1)\n', clusterResults.SilhouetteScore);
    fprintf('• Indice Davies-Bouldin: %.4f (plus petit = meilleur)\n', clusterResults.DaviesBouldinIndex);
    fprintf('• Indice Calinski-Harabasz: %.4f (plus grand = meilleur)\n', clusterResults.CalinskiHarabaszIndex);
    fprintf('• Nombre optimal de clusters selon silhouette: %d\n', optK);

end
