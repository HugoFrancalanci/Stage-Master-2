function createSegmentationFigure(data, subj_idx)
    % Création d'une figure spécifique pour visualiser la segmentation des artefacts
    seg_fig = figure('Name', sprintf('Segmentation des artefacts - Sujet %d - %s', subj_idx, data.muscle_name));
    
    % 1. Signal brut avec identification des artefacts
    subplot(3,1,1);
    plot(data.signal, 'b');
    hold on;
    
    % Marquer les artefacts en rouge
    artifact_indices = find(data.outliers);
    plot(artifact_indices, data.signal(artifact_indices), 'r.', 'MarkerSize', 8);
    
    % Ajouter les lignes de seuil
    ylim_vals = get(gca, 'YLim');
    plot([1 length(data.signal)], [data.upper_threshold data.upper_threshold], 'r--');
    plot([1 length(data.signal)], [data.lower_threshold data.lower_threshold], 'r--');
    
    title('Signal brut avec artefacts détectés');
    ylabel('Amplitude');
    legend('Signal', 'Artefacts', 'Seuils');
    
    % 2. Signal filtré vs signal nettoyé
    subplot(3,1,2);
    plot(data.signal_filtered, 'b');
    hold on;
    plot(data.signal_no_spikes, 'g');
    title('Comparaison signal filtré et signal nettoyé');
    ylabel('Amplitude');
    legend('Filtré seulement', 'Artefacts éliminés');
    
    % Ajuster la figure pour une meilleure visualisation
    set(seg_fig, 'Position', [100, 100, 800, 600]);
end
