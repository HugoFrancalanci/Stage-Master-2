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

    % Étape 3 : Forcer le clustering avec k = 3
    k = 3;
    rng(0)
    [finalClusters, centroids] = kmeans(synergyMatrix, k, 'Replicates', 10, 'Distance', 'sqeuclidean');

    % Étape 4 : Préparer les clusters
    clusterContents = cell(1, k);
    for i = 1:k
        clusterContents{i} = activations(finalClusters == i);
    end

    % ➤ Affichage clair
    fprintf('\n Résumé des Clusters de activations (k-means, k = 3):\n');
    fprintf('--------------------------------------\n');
    for i = 1:k
        fprintf('\n Cluster %d (n = %d):\n', i, length(clusterContents{i}));
        fprintf('----------------------------\n');
        for s = 1:length(clusterContents{i})
            fprintf('• %s\n', clusterContents{i}{s});
        end
    end

 % ➤ Visualisation 1 : Barplot
    figure;
    histogram(finalClusters, 'BinMethod', 'integers');
    title('Nombre de sujets par cluster');
    xlabel('Cluster'); ylabel('Nombre de sujets');
    grid on;

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
        'RandomSeed', 0);

end
