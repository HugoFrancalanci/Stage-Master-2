function [clusteredSynergies, clusterResults] = synergyStringClustering_kmeans(synergies)
    % Clustering de synergies représentées sous forme de chaînes, via K-means
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

    % Étape 3 : Forcer le clustering avec k = 3
    k = 3;
    rng(0)
    [finalClusters, centroids] = kmeans(synergyMatrix, k, 'Replicates', 10, 'Distance', 'sqeuclidean');

    % Étape 4 : Préparer les clusters
    clusterContents = cell(1, k);
    for i = 1:k
        clusterContents{i} = synergies(finalClusters == i);
    end

    % ➤ Affichage clair
    fprintf('\n Résumé des Clusters de Synergies (k-means, k = 3):\n');
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
    clusteredSynergies = struct(...
        'OriginalSynergies', {synergies}, ...
        'Clusters', finalClusters, ...
        'ClusterContents', {clusterContents}, ...
        'UniqueElements', {allSynergies});

    clusterResults = struct(...
        'Centroids', centroids, ...
        'BinaryMatrix', synergyMatrix, ...
        'k', k, ...
        'RandomSeed', 0);

end

