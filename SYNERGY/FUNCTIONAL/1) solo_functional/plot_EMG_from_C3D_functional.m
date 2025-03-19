function plot_EMG_from_C3D_functional(subjects, muscles_R, muscles_L, functional_labels, data_path)

    nb_subjects = length(subjects);
    nb_functional = length(functional_labels);
    nb_muscles = length(muscles_R);

    % Boucle sur les sujets et les tâches fonctionnelles
    for subj_idx = 1:nb_subjects
        for f_idx = 1:nb_functional
            % Construction du chemin du fichier
            fileName = fullfile(data_path, subjects{subj_idx}, ...
                sprintf('%s-%s-20240101-PROTOCOL01-FUNCTIONAL%d-.c3d', ...
                subjects{subj_idx}, subjects{subj_idx}, f_idx));

            % Vérification de l'existence du fichier
            if ~exist(fileName, 'file')
                fprintf('Fichier non trouvé : %s\n', fileName);
                continue;
            end

            try
                % Lecture des données C3D
                c3dH = btkReadAcquisition(fileName);
                analogs = btkGetAnalogs(c3dH);

                % Création de la figure
                figure;
                sgtitle(sprintf('Sujet %s - %s', subjects{subj_idx}, functional_labels{f_idx}));
                ax = gobjects(nb_muscles, 1); 

                % Boucle sur les muscles
                for m = 1:nb_muscles
                    ax(m) = subplot(ceil(nb_muscles/2), 2, m);
                    hold on;

                    for side = 1:2
                        if side == 1
                            muscle_name = muscles_R{m};
                            color = 'b';
                        else
                            muscle_name = muscles_L{m};
                            color = 'r';
                        end

                        if isfield(analogs, muscle_name)
                            signal = analogs.(muscle_name);
                            time_original = linspace(0, 1, length(signal));

                            % Affichage du signal
                            plot(time_original, abs(signal), 'Color', color, 'LineWidth', 1.2);
                            title(muscle_name(2:end));
                            xlabel('Temps (normalisé)');
                            ylabel('EMG (V)');
                            grid on;
                        else
                            title(sprintf('%s (Données absentes)', muscle_name(2:end)));
                        end
                    end
                    hold off;
                end

                % Uniformisation des axes
                for k = 1:length(ax)
                    ax(k).YAxis.Exponent = 0;
                end
                linkaxes(ax, 'y');

            catch ME
                fprintf('Erreur lors du traitement de %s : %s\n', fileName, ME.message);
            end
        end
    end
end
